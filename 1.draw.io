<mxfile host="app.diagrams.net" agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36" version="29.6.4">
  <diagram id="nvidia-datasets" name="NVIDIA Dataset Dependency Network">
    <mxGraphModel dx="2025" dy="1327" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="0" pageScale="1" pageWidth="2400" pageHeight="2000" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
        <mxCell id="openmath_reason" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" value="&lt;b&gt;OpenMathReasoning&lt;/b&gt;&lt;br&gt;&lt;span style=&amp;quot;font-size:11px;color:#555;&amp;quot;&gt;开源数学推理数据集&lt;/span&gt;" vertex="1">
          <mxGeometry height="55" width="300" y="42.5" as="geometry" />
        </mxCell>
        <mxCell id="pt_v1" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;" value="&lt;b&gt;Nemotron-Post-Training-Dataset-v1&lt;/b&gt;&lt;br&gt;&lt;span style=&amp;quot;font-size:11px;color:#555;&amp;quot;&gt;后训练数据集 v1（科学/通用/工具调用）&lt;/span&gt;" vertex="1">
          <mxGeometry height="55" width="300" y="127.5" as="geometry" />
        </mxCell>
        <mxCell id="math_v2" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" value="&lt;b&gt;Nemotron-Math-v2&lt;/b&gt;&lt;br&gt;&lt;span style=&amp;quot;font-size:11px;color:#555;&amp;quot;&gt;数学数据集 v2&lt;/span&gt;" vertex="1">
          <mxGeometry height="55" width="300" x="400" y="255" as="geometry" />
        </mxCell>
        <mxCell id="math_proofs" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" value="&lt;b&gt;Nemotron-Math-Proofs-v1&lt;/b&gt;&lt;br&gt;&lt;span style=&amp;quot;font-size:11px;color:#555;&amp;quot;&gt;数学证明数据集 v1&lt;/span&gt;" vertex="1">
          <mxGeometry height="55" width="300" x="400" y="340" as="geometry" />
        </mxCell>
        <mxCell id="sci_v1" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" value="&lt;b&gt;Nemotron-Science-v1&lt;/b&gt;&lt;br&gt;&lt;span style=&amp;quot;font-size:11px;color:#555;&amp;quot;&gt;科学数据集 v1（物理/化学/生物）&lt;/span&gt;" vertex="1">
          <mxGeometry height="55" width="300" x="400" y="425" as="geometry" />
        </mxCell>
        <mxCell id="chat_v1" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#e1d5e7;strokeColor=#9673a6;" value="&lt;b&gt;Nemotron-Instruction-Following-Chat-v1&lt;/b&gt;&lt;br&gt;&lt;span style=&amp;quot;font-size:11px;color:#555;&amp;quot;&gt;指令遵循对话 v1&lt;/span&gt;" vertex="1">
          <mxGeometry height="55" width="300" x="400" y="510" as="geometry" />
        </mxCell>
        <mxCell id="saf_v1" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#f8cecc;strokeColor=#b85450;" value="&lt;b&gt;Nemotron-SFT-Safety-v1&lt;/b&gt;&lt;br&gt;&lt;span style=&amp;quot;font-size:11px;color:#555;&amp;quot;&gt;SFT 安全微调数据集&lt;/span&gt;" vertex="1">
          <mxGeometry height="55" width="300" x="400" y="595" as="geometry" />
        </mxCell>
        <mxCell id="agentic_v1" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#e1d5e7;strokeColor=#9673a6;" value="&lt;b&gt;Nemotron-Agentic-v1&lt;/b&gt;&lt;br&gt;&lt;span style=&amp;quot;font-size:11px;color:#555;&amp;quot;&gt;智能体数据集 v1&lt;/span&gt;" vertex="1">
          <mxGeometry height="55" width="300" x="400" y="680" as="geometry" />
        </mxCell>
        <mxCell id="rl_agentic" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#e1d5e7;strokeColor=#9673a6;" value="&lt;b&gt;Nemotron-RL-Agentic-Conversational-&lt;br&gt;Tool-Use-Pivot-v1&lt;/b&gt;&lt;br&gt;&lt;span style=&amp;quot;font-size:11px;color:#555;&amp;quot;&gt;RL 对话工具调用智能体数据&lt;/span&gt;" vertex="1">
          <mxGeometry height="65" width="300" x="400" y="765" as="geometry" />
        </mxCell>
        <mxCell id="swe_v1" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#ffe6cc;strokeColor=#d79b00;" value="&lt;b&gt;Nemotron-Cascade-SFT-SWE&lt;/b&gt;&lt;br&gt;&lt;span style=&amp;quot;font-size:11px;color:#555;&amp;quot;&gt;级联 SFT 软件工程数据&lt;/span&gt;" vertex="1">
          <mxGeometry height="55" width="300" x="400" y="860" as="geometry" />
        </mxCell>
        <mxCell id="terminal" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#e1d5e7;strokeColor=#9673a6;" value="&lt;b&gt;Nemotron-Terminal-Corpus&lt;/b&gt;&lt;br&gt;&lt;span style=&amp;quot;font-size:11px;color:#555;&amp;quot;&gt;终端操作语料库&lt;/span&gt;" vertex="1">
          <mxGeometry height="55" width="300" x="400" y="945" as="geometry" />
        </mxCell>
        <mxCell id="cas_stg1" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;strokeWidth=2;" value="&lt;b&gt;Nemotron-Cascade-SFT-Stage-1&lt;/b&gt;&lt;br&gt;&lt;span style=&amp;quot;font-size:11px;color:#555;&amp;quot;&gt;级联 SFT 第一阶段（数学/代码/科学/通用）&lt;/span&gt;" vertex="1">
          <mxGeometry height="55" width="300" x="400" as="geometry" />
        </mxCell>
        <mxCell id="cas_stg2" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;strokeWidth=2;" value="&lt;b&gt;Nemotron-Cascade-SFT-Stage-2&lt;/b&gt;&lt;br&gt;&lt;span style=&amp;quot;font-size:11px;color:#555;&amp;quot;&gt;级联 SFT 第二阶段（+SWE/指令跟随）&lt;/span&gt;" vertex="1">
          <mxGeometry height="55" width="300" x="400" y="85" as="geometry" />
        </mxCell>
        <mxCell id="pt_v2" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;strokeWidth=2;" value="&lt;b&gt;Nemotron-Post-Training-Dataset-v2&lt;/b&gt;&lt;br&gt;&lt;span style=&amp;quot;font-size:11px;color:#555;&amp;quot;&gt;后训练数据集 v2（+多语言扩展）&lt;/span&gt;" vertex="1">
          <mxGeometry height="55" width="300" x="400" y="170" as="geometry" />
        </mxCell>
        <mxCell id="cas2_sft" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;strokeWidth=3;" value="&lt;b&gt;Nemotron-Cascade-2-SFT-Data&lt;/b&gt;&lt;br&gt;&lt;span style=&amp;quot;font-size:11px;color:#555;&amp;quot;&gt;级联 2 代 SFT 数据总集（256K 打包训练）&lt;/span&gt;" vertex="1">
          <mxGeometry height="60" width="320" x="800" y="550" as="geometry" />
        </mxCell>
        <mxCell id="e_omr_s1" edge="1" parent="1" source="openmath_reason" style="rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#6c8ebf;fontSize=11;labelBackgroundColor=#ffffff;fontColor=#333333;noEdgeStyle=1;orthogonal=1;" target="cas_stg1" value="数学题目汇入">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="312" y="58.75" />
              <mxPoint x="388" y="16.25" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="e_pt1_s1" edge="1" parent="1" source="pt_v1" style="rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#d6b656;fontSize=11;labelBackgroundColor=#ffffff;fontColor=#333333;noEdgeStyle=1;orthogonal=1;" target="cas_stg1" value="科学/通用领域汇入">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="312" y="140" />
              <mxPoint x="388" y="38.75" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="e_omr_s2" edge="1" parent="1" source="openmath_reason" style="rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#6c8ebf;fontSize=11;labelBackgroundColor=#ffffff;fontColor=#333333;dashed=1;noEdgeStyle=1;orthogonal=1;" target="cas_stg2" value="数学题目汇入">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="312" y="81.25" />
              <mxPoint x="388" y="101.25" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="e_pt1_s2" edge="1" parent="1" source="pt_v1" style="rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#d6b656;fontSize=11;labelBackgroundColor=#ffffff;fontColor=#333333;dashed=1;noEdgeStyle=1;orthogonal=1;" target="cas_stg2" value="科学/工具调用/通用汇入">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="314" y="155" />
              <mxPoint x="388" y="123.75" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="e_pt1_pt2" edge="1" parent="1" source="pt_v1" style="rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#d6b656;fontSize=11;labelBackgroundColor=#ffffff;fontColor=#333333;strokeWidth=2;noEdgeStyle=1;orthogonal=1;" target="pt_v2" value="基础底座迭代">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="312" y="170" />
              <mxPoint x="388" y="197.5" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="e_s1_c2" edge="1" parent="1" source="cas_stg2" style="rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#d6b656;fontSize=11;labelBackgroundColor=#ffffff;fontColor=#333333;strokeWidth=2;noEdgeStyle=1;orthogonal=1;exitX=1;exitY=0.5;exitDx=0;exitDy=0;" target="cas2_sft" value="核心主干基石">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="712" y="112.5" />
              <mxPoint x="788" y="553" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="e_mv2_c2" edge="1" parent="1" source="math_v2" style="rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#6c8ebf;fontSize=11;labelBackgroundColor=#ffffff;fontColor=#333333;noEdgeStyle=1;orthogonal=1;" target="cas2_sft" value="数学提示汇入">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="712" y="282.5" />
              <mxPoint x="786" y="559" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="e_mp_c2" edge="1" parent="1" source="math_proofs" style="rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#6c8ebf;fontSize=11;labelBackgroundColor=#ffffff;fontColor=#333333;noEdgeStyle=1;orthogonal=1;" target="cas2_sft" value="数学证明汇入">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="712" y="367.5" />
              <mxPoint x="784" y="565" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="e_sci_c2" edge="1" parent="1" source="sci_v1" style="rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#6c8ebf;fontSize=11;labelBackgroundColor=#ffffff;fontColor=#333333;noEdgeStyle=1;orthogonal=1;" target="cas2_sft" value="科学数据汇入">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="712" y="452.5" />
              <mxPoint x="782" y="571" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="e_chat_c2" edge="1" parent="1" source="chat_v1" style="rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#9673a6;fontSize=11;labelBackgroundColor=#ffffff;fontColor=#333333;noEdgeStyle=1;orthogonal=1;" target="cas2_sft" value="通用对话+指令跟随汇入">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="712" y="537.5" />
              <mxPoint x="780" y="577" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="e_saf_c2" edge="1" parent="1" source="saf_v1" style="rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#b85450;fontSize=11;labelBackgroundColor=#ffffff;fontColor=#333333;noEdgeStyle=1;orthogonal=1;" target="cas2_sft" value="安全数据汇入">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="712" y="622.5" />
              <mxPoint x="780" y="583" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="e_agnt_c2" edge="1" parent="1" source="agentic_v1" style="rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#9673a6;fontSize=11;labelBackgroundColor=#ffffff;fontColor=#333333;noEdgeStyle=1;orthogonal=1;" target="cas2_sft" value="对话智能体汇入">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="712" y="707.5" />
              <mxPoint x="782" y="589" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="e_rlag_c2" edge="1" parent="1" source="rl_agentic" style="rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#9673a6;fontSize=11;labelBackgroundColor=#ffffff;fontColor=#333333;noEdgeStyle=1;orthogonal=1;" target="cas2_sft" value="对话工具调用汇入">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="712" y="797.5" />
              <mxPoint x="784" y="595" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="e_swe_c2" edge="1" parent="1" source="swe_v1" style="rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#d79b00;fontSize=11;labelBackgroundColor=#ffffff;fontColor=#333333;noEdgeStyle=1;orthogonal=1;" target="cas2_sft" value="软件工程数据汇入">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="712" y="887.5" />
              <mxPoint x="786" y="601" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="e_term_c2" edge="1" parent="1" source="terminal" style="rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#9673a6;fontSize=11;labelBackgroundColor=#ffffff;fontColor=#333333;noEdgeStyle=1;orthogonal=1;" target="cas2_sft" value="终端智能体汇入">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="712" y="972.5" />
              <mxPoint x="788" y="607" />
            </Array>
          </mxGeometry>
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
