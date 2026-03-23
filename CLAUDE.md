# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是高德地图AI团队的技术文档仓库，包含两个主要项目的文档和数据处理工具：

1. **STAgent (时空规划Agent)** - `Agent Planning/` 目录
2. **CPT (地理信息基座模型)** - `CPT/` 目录

## 项目架构

### STAgent - 多人行程规划Agent

完整训练流水线：
```
query_creator → simulator → env/generate → env/multi_verify_v2 →
sft_data_refine → pipeline (SFT训练) → env/multi_benchmark (评测) →
STAgent_ROLL_RL (RL训练)
```

**核心技术组件：**

- **三阶段状态机架构**：
  - 状态1：寻找事实（并行工具调用 + 参数审计）
  - 状态2：冲突处理与筛选（汇总事实 + 排除法评估）
  - 状态3：最终审计（草稿事实清单 + 自检 + 修正）
  - 规则：工具调用只能在状态1；进入状态3后禁止工具调用；工具尽可能并行

- **Context机制**：通过ID引用实现跨工具的数据传递

- **DA-GRPO算法**：Difficulty-Aware Group Relative Policy Optimization，在标准GRPO基础上引入difficulty-aware权重，融合SFT先验和RL方差信号

- **数据构造**：
  - SFT数据：5万条（25%垂域 + 75%通用）
  - 垂域数据：9k Strong-Protocol（严格状态机） + 3k Weak-Protocol（不强制状态机但符合事实）
  - 评分维度：requirement_understanding, tool_invocation, hallucination_control, information_organization, conflict_resolution

### CPT - 地理信息基座模型

**训练框架：** Open-Megatron-LLaMA (基于Megatron-LM)

**数据处理：**
- POI数据：8200万条，使用Google S2多尺度编码（L4/L10/L20）
- 道路数据：157万条，转换为4种格式（自然语言、结构化、QA、知识图谱三元组）

**训练配置：**
- 基座模型：Qwen3-1.7B
- 训练规模：64 GPU，10B tokens
- 数据配比：domain:general ≈ 1:14
- 验证方法：Micro-annealing

## 数据处理工具

### 道路信息预训练数据生成

**脚本：** `CPT/road_info_to_pretrain.py`

**支持的输出格式：**

1. **natural_language** - 自然语言描述（推荐用于预训练）
```bash
python road_info_to_pretrain.py \
  --input your_road_data.jsonl \
  --output road_pretrain_natural.jsonl \
  --format natural_language
```

2. **structured** - 结构化格式（类似memory处理）
```bash
python road_info_to_pretrain.py \
  --input your_road_data.jsonl \
  --output road_pretrain_structured.jsonl \
  --format structured
```

3. **qa_pairs** - 问答对格式（推荐用于指令微调）
```bash
python road_info_to_pretrain.py \
  --input your_road_data.jsonl \
  --output road_pretrain_qa.jsonl \
  --format qa_pairs
```

4. **knowledge_graph** - 知识图谱三元组格式
```bash
python road_info_to_pretrain.py \
  --input your_road_data.jsonl \
  --output road_pretrain_kg.jsonl \
  --format knowledge_graph
```

**创建示例数据：**
```bash
python road_info_to_pretrain.py --create-sample --output sample_road_data.jsonl --sample-size 10
```

**生成所有格式：**
```bash
python road_info_to_pretrain.py \
  --input your_road_data.jsonl \
  --output road_pretrain_all.jsonl \
  --format all
```

## Megatron-LM训练

**仓库：**
- 爱橙仓库：https://code.alibaba-inc.com/openlm/Open-Megatron-LLaMA
- 团队仓库：https://code.alibaba-inc.com/amap_alignment/Open-Megatron-LLaMA

**基本使用流程：**
```bash
# 1. 复制示例脚本
cp scripts/task_scripts/task_example.sh scripts/task_scripts/my_task.sh

# 2. 编辑配置参数
vim scripts/task_scripts/my_task.sh

# 3. 执行训练
bash scripts/task_scripts/my_task.sh
```

**关键配置参数：**
- `INTENTION`: pretrain, sft, ppl_eval
- `RUN_MODE`: local, nebula
- `WORLD_SIZE`: 总GPU数量
- `GLOBAL_BATCH_SIZE`: 全局批次大小
- `MICRO_BATCH_SIZE`: 每个GPU的微批次大小
- `LR_DECAY_STYLE`: cosine, linear, WSD

**Qwen模型特殊配置：**
```bash
VOCAB_SIZE=151936
TOKENIZER_TYPE=HuggingFaceTokenizer
TOKENIZER_MODEL=3rdparty/qwen_modeling_hf/qwen3
```

## 重要技术概念

### 道路信息字段分类
- 身份命名：nds_id, link_id, road_id, link_name_chn, link_name_eng
- 地理位置：link_district_adcode, adcode, urcode, link_coors, in_city
- 几何属性：link_length, link_width, fow
- 拓扑关系：link_dir, in_top, out_top, fnode, tnode, road_class
- 车道信息：lanes, formway, link_status, lane_width, navi_type
- 功能标识：fc, is_toll, is_urban, max_speed, route_kmph

### 评分系统
- 评级：极差(1), 较差(2), 一般(3), 较好(4), 优秀(5)
- 样本分桶：Strong-Protocol / Weak-Protocol / Reject

## 文档结构

- `Agent Planning/` - STAgent项目文档
  - 数据构造、SFT训练、RL训练相关文档
  - 多人行程规划技术方案
  - 轨迹生成、筛选、打分文档

- `CPT/` - 地理信息基座模型文档
  - Megatron-LM使用和调试文档
  - POI和道路数据建设文档
  - 预训练实战手册
  - 评测体系文档

- 根目录 - 面试准备材料和项目总结
