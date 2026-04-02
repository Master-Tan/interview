## Agentic SFT TunningFactory — 训练流程详解

### 一、训练总入口

训练的启动方式有两种：

```bash
# 方式一：命令行参数
python src/train_bash.py --stage sft --model_name_or_path ... --do_train ...

# 方式二：YAML 配置文件
python src/train_bash.py config.yaml
```

`train_bash.py` 调用 `llmtuner.train.tuner.run_exp()`，这是整个训练流程的总调度函数。

---

### 二、`run_exp()` 调度流程

```python
def run_exp(args=None, callbacks=None):
    # 1. 解析参数
    model_args, data_args, training_args, finetuning_args, generating_args = get_train_args(args)

    # 2. 注册回调
    callbacks = [LogCallback(), SaveTokenizerCallback(), ...]
    if interactive_ckpt_enable():
        callbacks.append(InteractiveCkptCallback())
    if finetuning_args.early_stopping_patience:
        callbacks.append(CustomEarlyStoppingCallback(...))

    # 3. 根据 stage 分发到对应的训练 workflow
    if finetuning_args.stage == "pt":
        run_pt(...)
    elif finetuning_args.stage == "sft":
        run_sft(...)
    elif finetuning_args.stage == "rm":
        run_rm(...)
    elif finetuning_args.stage == "ppo":
        run_ppo(...)
    elif finetuning_args.stage == "dpo":
        run_dpo(...)
    elif finetuning_args.stage == "kto":
        run_kto(...)
    elif finetuning_args.stage == "distill":
        run_distill(...)
```

每个 stage 还支持 **Turbo 模式**（`--use_turbo`），使用 `transformers_turbo` 库加速训练，对应 `workflow_turbo.py`。

---

### 三、七大训练阶段详解

#### 3.1 预训练 (Pre-Training, `stage=pt`)

**目标**：在大规模无标注语料上进行 Next Token Prediction，让模型学习语言知识。

**数据格式**：纯文本，无需 instruction/response 结构。

```json
// wiki_demo.txt — 每行一段文本
"这是一段维基百科的文本内容..."
```

**数据处理器**：`PretrainDatasetProcessor`
- 将文本直接 tokenize，`input_ids` 和 `labels` 相同（自回归目标）
- 支持 Packing：将多段文本拼接到 `cutoff_len` 长度

**训练器**：继承 `Seq2SeqTrainer`，使用标准的 Cross-Entropy Loss。

**典型命令**：
```bash
python src/train_bash.py \
    --stage pt \
    --model_name_or_path meta-llama/Llama-2-7b \
    --dataset wiki_demo \
    --finetuning_type lora \
    --lora_target q_proj,v_proj \
    --output_dir output/pt \
    --per_device_train_batch_size 4 \
    --learning_rate 5e-5 \
    --num_train_epochs 3 \
    --fp16
```

---

#### 3.2 监督微调 (Supervised Fine-Tuning, `stage=sft`)

**目标**：在 instruction-response 数据上微调模型，使其具备指令跟随能力。

**数据格式**（Alpaca 格式）：
```json
{
    "instruction": "请翻译以下英文句子",
    "input": "Hello, how are you?",
    "output": "你好，你怎么样？"
}
```

**数据处理器**：`SupervisedDatasetProcessor`

核心编码逻辑 `_encode_supervised_example()`：
1. 将 prompt + response 组成多轮对话 messages
2. 调用 `template.encode_multiturn()` 编码为 token 对
3. 对 prompt 部分的 labels 设为 `IGNORE_INDEX (-100)`，只在 response 部分计算 loss
4. 支持 `--train_on_prompt`（在 prompt 上也计算 loss）
5. 支持 `--mask_history`（只在最后一轮计算 loss）

**Label Masking 示意**：
```
input_ids:  [BOS] [instruction tokens] [input tokens] [response tokens] [EOS]
labels:     [-100] [-100 ............] [-100 .......] [response tokens] [EOS]
                    ↑ prompt 部分被 mask                ↑ 只在 response 上计算 loss
```

**Packing 模式**（`--packing`）：
- `PackedSupervisedDatasetProcessor`：将多个短样本拼接到一个序列中
- 使用贪心背包算法（`greedy_knapsack`）最优化装箱
- `--neat_packing`：使用 Block-Diagonal 4D Attention Mask 防止跨样本注意力

**SFT Workflow** (`train/sft/workflow.py`)：
```
load_template() → get_dataset() → load_model()
    → 构建 SFTDataCollatorWith4DAttentionMask
    → 构建 CustomSeq2SeqTrainer
    → trainer.train() → trainer.save_model()
    → plot_loss() → push_to_mos()
```

**CustomSeq2SeqTrainer 特性**：
- 支持 `predict_with_generate`：训练中同时进行生成式评估
- 支持 IFT Loss（Implicit Future Training）：一种基于未来 token 预测的增强损失
- 支持序列并行的 DataLoader 适配
- 支持动态数据集交错（`DynamicInterleaveCallBack`）
- 自动上传 Checkpoint 到 MOS

**典型命令**：
```bash
python src/train_bash.py \
    --stage sft \
    --model_name_or_path Qwen/Qwen2-7B-Chat \
    --template qwen \
    --dataset alpaca_gpt4_zh \
    --finetuning_type lora \
    --lora_target all \
    --lora_rank 8 \
    --output_dir output/sft \
    --per_device_train_batch_size 4 \
    --gradient_accumulation_steps 4 \
    --learning_rate 5e-5 \
    --num_train_epochs 3 \
    --bf16 \
    --plot_loss
```

---

#### 3.3 奖励模型训练 (Reward Modeling, `stage=rm`)

**目标**：训练一个奖励模型，对模型输出进行质量评分，为 RLHF 提供奖励信号。

**数据格式**（Pairwise 偏好数据）：
```json
{
    "instruction": "写一首关于春天的诗",
    "input": "",
    "chosen": "春风拂面花自开...",    // 优选回答
    "rejected": "春天来了天气好..."    // 劣选回答
}
```

**数据处理器**：`PairwiseDatasetProcessor`
- 将 chosen 和 rejected 分别编码
- 使用 `PairwiseDataCollatorWithPadding` 将两个序列配对

**模型结构**：
- 在 CausalLM 模型上添加 Value Head（`AutoModelForCausalLMWithValueHead`）
- Value Head 是一个线性层，将隐藏状态映射为标量奖励值

**损失函数**：Pairwise Ranking Loss
```
loss = -log(σ(r_chosen - r_rejected))
```

---

#### 3.4 PPO 训练 (Proximal Policy Optimization, `stage=ppo`)

**目标**：使用强化学习优化策略模型，最大化奖励模型的评分。

**核心组件**：
- **策略模型 (Actor)**：待优化的语言模型
- **参考模型 (Ref)**：冻结的原始模型，用于计算 KL 散度
- **奖励模型 (Reward)**：评估生成质量
- **价值模型 (Critic)**：估计状态价值

**训练循环**：
```
1. 策略模型根据 prompt 生成 response
2. 奖励模型对 response 打分
3. 计算 KL 散度惩罚：KL(π_θ || π_ref)
4. 计算 GAE 优势估计
5. PPO Clip 目标更新策略模型
6. 同时更新价值模型
```

**关键超参数**：
| 参数 | 默认值 | 说明 |
|------|--------|------|
| `ppo_epochs` | 4 | 每个 batch 的 PPO 优化轮数 |
| `ppo_target` | 6.0 | 自适应 KL 控制的目标值 |
| `ppo_buffer_size` | 1 | 经验缓冲区大小 |
| `ppo_whiten_rewards` | False | 是否对奖励做白化处理 |

**典型命令**：
```bash
python src/train_bash.py \
    --stage ppo \
    --model_name_or_path Qwen/Qwen2-7B-Chat \
    --reward_model path/to/reward_model \
    --reward_model_type full \
    --template qwen \
    --dataset alpaca_gpt4_zh \
    --finetuning_type full \
    --ppo_epochs 4 \
    --learning_rate 1e-5 \
    --deepspeed scripts/ds_zero2.json \
    --bf16
```

---

#### 3.5 DPO 训练 (Direct Preference Optimization, `stage=dpo`)

**目标**：跳过奖励模型训练，直接从偏好数据优化策略模型。

**核心思想**：将 RLHF 的奖励建模和策略优化合并为一个监督学习问题。

**损失函数**（Sigmoid 变体）：
```
loss = -log σ(β · (log π_θ(y_w|x)/π_ref(y_w|x) - log π_θ(y_l|x)/π_ref(y_l|x)))
```

其中 `y_w` 是优选回答，`y_l` 是劣选回答，`β` 控制偏离参考模型的程度。

**支持的 DPO 变体**（通过 `--pref_loss` 参数选择）：

| 变体 | 参数值 | 说明 |
|------|--------|------|
| Standard DPO | `sigmoid` | 标准 DPO 损失 |
| IPO | `ipo` | Identity Preference Optimization |
| Hinge | `hinge` | 铰链损失变体 |
| KTO Pair | `kto_pair` | KTO 的配对版本 |
| ORPO | `orpo` | Odds Ratio Preference Optimization |
| SimPO | `simpo` | Simple Preference Optimization |
| IFT | `ift` | Implicit Future Training |

**关键超参数**：
| 参数 | 默认值 | 说明 |
|------|--------|------|
| `pref_beta` | 0.1 | β 参数，控制偏离程度 |
| `pref_ftx` | 0.0 | SFT 损失的混合系数 |
| `dpo_label_smoothing` | 0.0 | 标签平滑参数 |

---

#### 3.6 KTO 训练 (Kahneman-Tversky Optimization, `stage=kto`)

**目标**：使用非配对的偏好数据（只需标注"好"或"不好"）进行优化。

**优势**：不需要 chosen/rejected 配对数据，降低数据标注成本。

**数据格式**：
```json
{
    "instruction": "写一首诗",
    "output": "春风拂面...",
    "kto_tag": true    // true=好, false=不好
}
```

**数据处理器**：`FeedbackDatasetProcessor`

**关键超参数**：
| 参数 | 默认值 | 说明 |
|------|--------|------|
| `kto_chosen_weight` | 1.0 | 正样本的损失权重 |
| `kto_rejected_weight` | 1.0 | 负样本的损失权重 |

---

#### 3.7 知识蒸馏 (Knowledge Distillation, `stage=distill`)

**目标**：将大模型（Teacher）的知识迁移到小模型（Student）。

**核心思想**：Student 模型不仅学习 ground truth labels，还学习 Teacher 模型的 soft logits 分布。

**损失函数**：
```
L_total = (1 - α) · L_SFT + α · L_KD

L_SFT = CrossEntropy(student_logits, labels)
L_KD  = KL_Divergence(student_logits/T, teacher_logits/T) · T²
```

**支持的 KD 目标函数**（`--kd_objective`）：

| 目标 | 说明 |
|------|------|
| `forward_kl` | 前向 KL 散度（标准 KD） |
| `reverse_kl` | 反向 KL 散度（Mode-seeking） |
| `adaptive_kl` | 自适应 KL（前向和反向的加权混合） |
| `skewed_forward_kl` | 偏斜前向 KL |
| `skewed_reverse_kl` | 偏斜反向 KL |
| `js_divergence` | JS 散度 |

**关键超参数**：
| 参数 | 默认值 | 说明 |
|------|--------|------|
| `distill_loss_weight` | 0.5 | KD 损失的权重 α |
| `kd_temperature` | 1.0 | Student 的温度 T |
| `teacher_temperature` | 1.0 | Teacher 的温度 T |

**数据处理**：使用 `DistillDataCollatorWith4DAttentionMask`，同时为 Student 和 Teacher 准备输入（可能使用不同的 template）。

**典型命令**：
```bash
python src/train_bash.py \
    --stage distill \
    --model_name_or_path Qwen/Qwen2-1.5B \
    --template qwen \
    --teacher_model_name_or_path Qwen/Qwen2-72B \
    --teacher_template qwen \
    --distill_loss_weight 0.85 \
    --kd_objective forward_kl \
    --finetuning_type full \
    --deepspeed scripts/ds_zero2.json \
    --bf16
```

---

### 四、微调策略详解

#### 4.1 全参数微调 (Full Fine-Tuning)

- 所有模型参数都参与梯度更新
- 效果最好，但显存需求最大
- 适用场景：有充足 GPU 资源、需要最佳效果

```bash
--finetuning_type full
```

#### 4.2 部分参数冻结 (Freeze Tuning)

- 冻结大部分层，只训练指定的层
- 支持三种冻结模式：
  - **按层数**：`--freeze_trainable_layers 2`（训练最后 2 层）
  - **按前缀**：`--freeze_module_prefix vision_tower`（冻结视觉塔）
  - **LLaMA-Pro**：均匀间隔选择可训练层

```bash
--finetuning_type freeze --freeze_trainable_layers 2
```

#### 4.3 LoRA (Low-Rank Adaptation)

- 在目标模块旁注入低秩矩阵 A 和 B
- 原始权重冻结，只训练 A 和 B
- 显存节省显著，效果接近全参数

```bash
--finetuning_type lora \
--lora_target q_proj,v_proj \  # 或 --lora_target all
--lora_rank 8 \
--lora_alpha 16 \
--lora_dropout 0.05
```

**LoRA 变体**：
- **DoRA** (`--use_dora`)：Weight-Decomposed LoRA，将权重分解为方向和大小
- **rsLoRA** (`--use_rslora`)：Rank-Stabilized LoRA，使用 `1/√r` 缩放因子
- **多 Adapter 合并**：支持加载多个 LoRA adapter 并合并

#### 4.4 QLoRA (Quantized LoRA)

- 将基础模型量化为 4-bit 或 8-bit
- 在量化模型上应用 LoRA
- 极大降低显存需求

```bash
--finetuning_type lora \
--quantization_bit 4 \
--quantization_type nf4 \
--double_quantization
```

**支持的量化方法**：
| 方法 | 参数 | 说明 |
|------|------|------|
| BitsAndBytes | `--quantization_method bitsandbytes` | 默认，支持 NF4/FP4 |
| GPTQ | 预量化模型 | 需要预先量化的模型权重 |
| AWQ | 预量化模型 | Activation-aware Weight Quantization |
| AQLM | 预量化模型 | Additive Quantization |

#### 4.5 ReFT (Representation Fine-Tuning)

- 基于 pyreft 库，在模型的隐藏表示上进行干预
- 不修改模型权重，而是学习表示空间的变换

```bash
--finetuning_type reft \
--reft_rank 4 \
--reft_layers all \
--reft_intervention_type LoreftIntervention
```

---

### 五、Prompt Template 系统

Template 是连接数据和模型的桥梁，确保输入格式与模型预训练时一致。

#### 5.1 Template 结构

每个 Template 定义了以下格式化器：

| 格式化器 | 作用 |
|---------|------|
| `format_prefix` | 序列开头（如 BOS token） |
| `format_system` | 系统提示词的格式 |
| `format_user` | 用户消息的格式 |
| `format_assistant` | 助手回复的格式 |
| `format_function` | 函数调用的格式 |
| `format_observation` | 工具观察结果的格式 |
| `format_tools` | 工具定义的格式 |
| `format_separator` | 多轮对话的分隔符 |

#### 5.2 编码流程

```
Turn 0: prefix + system + query    →    response
Turn t: separator + query          →    response
```

`_encode()` 方法将每轮对话编码为 token 序列，`_convert_elements_to_ids()` 将字符串和特殊 token 转换为 token ID。

#### 5.3 特殊 Template

- **Llama2Template**：将 system 嵌入到第一轮 user 消息中
- **ReasoningTemplate**：为推理模型添加 `` 思考标签
- **Qwen2vlTemplate / Internvl3Template**：多模态模型的特殊 token 处理

---

### 六、数据处理 Pipeline 详解

#### 6.1 数据集解析 (`parser.py`)

`get_dataset_list()` 解析数据集配置，支持三种来源：

| 来源 | 配置方式 | 示例 |
|------|---------|------|
| `dataset_info.json` | `--dataset alpaca_gpt4_zh` | 在 `data/dataset_info.json` 中注册 |
| 直接文件路径 | `--file_name data/my_data.json` | 指定本地文件 |
| OpenLM 数据集 | `--dataset_name my_dataset` | 从 OpenLM Hub 加载 |

#### 6.2 数据对齐 (`aligner.py`)

将不同格式的数据统一为标准格式：

```python
{
    "prompt": [{"role": "user", "content": "..."}],
    "response": [{"role": "assistant", "content": "..."}],
    "system": "...",
    "tools": "...",
    "image": [...],
    "video": [...],
    "audio": [...]
}
```

支持两种输入格式：
- **Alpaca 格式**：`AlpacaDatasetConverter` — instruction/input/output 字段
- **ShareGPT 格式**：`SharegptDatasetConverter` — conversations 数组

#### 6.3 数据预处理 (`preprocess.py`)

根据训练阶段选择对应的 `DatasetProcessor`：

| 阶段 | 处理器 | 特点 |
|------|--------|------|
| PT | `PretrainDatasetProcessor` | 纯文本，input_ids = labels |
| SFT | `SupervisedDatasetProcessor` | Prompt mask + Response loss |
| SFT + Packing | `PackedSupervisedDatasetProcessor` | 多样本拼接 + 背包算法 |
| SFT + CP Packing | `CPPaddedPackedSupervisedDatasetProcessor` | 序列并行下的对齐 Packing |
| RM | `PairwiseDatasetProcessor` | Chosen/Rejected 配对 |
| KTO | `FeedbackDatasetProcessor` | 正/负反馈标签 |
| PPO | `UnsupervisedDatasetProcessor` | 只需 prompt |

#### 6.4 数据整理 (`collator.py`)

DataCollator 负责将单个样本组装成 batch：

| Collator | 用途 |
|----------|------|
| `MultiModalDataCollatorForSeq2Seq` | 基础多模态 Collator，处理图像/视频/音频特征 |
| `SFTDataCollatorWith4DAttentionMask` | SFT 专用，支持 Block-Diagonal 4D Attention Mask |
| `SFTDataCollatorWithSequenceParallel` | 序列并行专用，按 SP 分片切分序列 |
| `DistillDataCollatorWith4DAttentionMask` | 蒸馏专用，同时准备 Student 和 Teacher 输入 |
| `PairwiseDataCollatorWithPadding` | RM/DPO 专用，处理 Chosen/Rejected 配对 |

---

### 七、Callback 机制

框架通过 HuggingFace Trainer 的 Callback 机制扩展训练行为：

| Callback | 触发时机 | 功能 |
|----------|---------|------|
| `LogCallback` | 每个 logging step | 记录训练日志 |
| `SaveTokenizerCallback` | 保存 checkpoint 时 | 同时保存 tokenizer |
| `SaveProcessorCallback` | 保存 checkpoint 时 | 同时保存 processor（多模态） |
| `PushToMosCallback` | 保存 checkpoint 时 | 自动上传到 MOS 模型仓库 |
| `InteractiveCkptCallback` | 训练过程中 | 支持交互式 checkpoint 管理 |
| `CustomEarlyStoppingCallback` | 每次评估后 | 基于指标的早停 |
| `PredictInTrainingCallback` | 每次评估后 | 训练中同时进行生成式预测 |
| `DynamicInterleaveCallBack` | 每个 epoch | 动态调整多数据集采样概率 |
| `SaveReftCallback` | 保存 checkpoint 时 | 保存 ReFT 干预权重 |

---

### 八、模型导出与合并

#### 8.1 LoRA 合并

将 LoRA adapter 权重合并回基础模型：

```bash
python src/export_model.py \
    --model_name_or_path meta-llama/Llama-2-7b \
    --adapter_name_or_path output/sft/checkpoint-1000 \
    --template llama2 \
    --finetuning_type lora \
    --export_dir output/merged_model \
    --export_size 2
```

#### 8.2 量化导出

导出时进行模型量化：

```bash
python src/export_model.py \
    --model_name_or_path output/merged_model \
    --export_dir output/quantized_model \
    --export_quantization_bit 4 \
    --export_quantization_dataset alpaca_gpt4_zh
```

#### 8.3 MOS 上传

导出的模型会自动尝试上传到 MOS 模型仓库（通过 `push_to_mos()`），供线上推理服务使用。

---

### 九、评估体系

框架集成了三个主流评估基准：

| 基准 | 语言 | 科目数 | 评估方式 |
|------|------|--------|---------|
| MMLU | 英文 | 57 | 4 选 1 |
| C-Eval | 中文 | 52 | 4 选 1 |
| CMMLU | 中文 | 67 | 4 选 1 |

评估通过 `src/evaluate.py` 入口启动，使用 `Evaluator` 类进行 few-shot 评估。

---

### 十、推理服务

#### 10.1 CLI 对话

```bash
python src/cli_demo.py \
    --model_name_or_path Qwen/Qwen2-7B-Chat \
    --template qwen
```

#### 10.2 API 服务

兼容 OpenAI API 格式的 FastAPI 服务：

```bash
python src/api_demo.py \
    --model_name_or_path Qwen/Qwen2-7B-Chat \
    --template qwen
```

支持 `/v1/chat/completions` 端点，可直接接入基于 ChatGPT 的应用。

#### 10.3 批量推理

```bash
python src/generate.py \
    --model_name_or_path Qwen/Qwen2-7B-Chat \
    --template qwen \
    --dataset my_test_data
```

支持 Ray 分布式推理和 vLLM 加速推理。
