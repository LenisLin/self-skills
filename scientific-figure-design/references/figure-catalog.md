# 图型选择与参考图册

单图数据规模用于快速选择图型。选择图像查看参考与实现；运行同名脚本生成模拟示例。Science 图版 DOI：10.1126/science.adt3130；发育图谱 DOI：10.1038/s41586-026-10545-0。

| 图型 | 使用场景 | 数据数量与分布 | 参考情况 | 脚本 |
| --- | --- | --- | --- | --- |
| [group_distribution_box](../assets/figures/group_distribution_box.png) | 比较样本或细胞组间的观测分布 | 2–8 组，每组约 5–300 个观测；连续值、偏态或比例均可 | Science Fig2D 图版参考 | [Python](../scripts/group_distribution_box.py) |
| [group_distribution_violin](../assets/figures/group_distribution_violin.png) | 比较组间分布形状与多峰 | 2–8 组，每组约 20–1000 个观测；适合连续分布 | Science Fig4J 图版参考 | [Python](../scripts/group_distribution_violin.py) |
| [group_distribution_density](../assets/figures/group_distribution_density.png) | 比较组间数值分布及偏移 | 2–5 组叠加或 5–20 组分面；每组数十至数千个连续值 | Science Fig3D 图版参考 | [Python](../scripts/group_distribution_density.py) |
| [value_distribution_histogram](../assets/figures/value_distribution_histogram.png) | 观察单变量的频数分布 | 连续数值可分为约 10–40 个区间；分类频数约 2–20 类 | 模拟实现图；参考图待补 | [Python](../scripts/value_distribution_histogram.py) |
| [continuous_association_regression](../assets/figures/continuous_association_regression.png) | 展示两个连续变量的关系 | 约 20–5000 对观测；保留数据量纲和适合分析的拟合关系 | Science Fig2E 图版参考 | [Python](../scripts/continuous_association_regression.py) |
| [positive_association_log_scatter](../assets/figures/positive_association_log_scatter.png) | 比较跨数量级的两个正值变量 | 约 20–3000 对正值；两轴可用对数尺度 | Science Fig3C 图版参考 | [Python](../scripts/positive_association_log_scatter.py) |
| [feature_ranking_lollipop](../assets/figures/feature_ranking_lollipop.png) | 比较特征得分或效应排序 | 约 5–30 个特征；数值可为正、负或计数 | Science Fig2G 图版参考 | [Python](../scripts/feature_ranking_lollipop.py) |
| [two_group_comparison_mirrored_bars](../assets/figures/two_group_comparison_mirrored_bars.png) | 比较两个群体的分类数量或比例 | 约 5–30 个类别；两侧使用可比较的量纲 | Science Fig2I_K 图版参考 | [Python](../scripts/two_group_comparison_mirrored_bars.py) |
| [two_group_comparison_mirrored_boxes](../assets/figures/two_group_comparison_mirrored_boxes.png) | 比较各类别在两侧的观测分布 | 约 5–20 类；每侧为一组重复观测 | Science Fig2J 图版参考 | [Python](../scripts/two_group_comparison_mirrored_boxes.py) |
| [composition_pie](../assets/figures/composition_pie.png) | 展示少数类别在整体中的组成 | 约 2–6 类；组成数量或比例之和代表整体 | Science Fig3A 图版参考 | [Python](../scripts/composition_pie.py) |
| [composition_donut](../assets/figures/composition_donut.png) | 展示整体组成与主要份额 | 约 2–6 类；每类使用非负计数或比例 | Science Fig5B 图版参考 | [Python](../scripts/composition_donut.py) |
| [sample_composition_stacked_bars](../assets/figures/sample_composition_stacked_bars.png) | 比较各样本的细胞或成分比例 | 约 5–50 个样本、3–10 个成分；每样本比例使用共同分母 | 模拟实现图；参考图待补 | [Python](../scripts/sample_composition_stacked_bars.py) |
| [model_performance_distribution](../assets/figures/model_performance_distribution.png) | 比较多个模型的性能分布 | 约 3–30 类模型或目标；每个点表示一次样本、目标或重复 | Science Fig6C 图版参考 | [Python](../scripts/model_performance_distribution.py) |
| [feature_association_heatmap](../assets/figures/feature_association_heatmap.png) | 展示非负特征之间的关联强度 | 约 10–100 行、5–50 列；使用连续非负值 | Science Fig2F 图版参考 | [Python](../scripts/feature_association_heatmap.py) |
| [cell_neighborhood_composition_heatmap](../assets/figures/cell_neighborhood_composition_heatmap.png) | 比较细胞类型与空间邻域的组成 | 约 10–50 种细胞类型、5–20 个邻域；比例范围 0–1 | Science Fig2F 同类型参考 | [Python](../scripts/cell_neighborhood_composition_heatmap.py) |
| [clustered_signed_effect_heatmap](../assets/figures/clustered_signed_effect_heatmap.png) | 展示有方向效应及聚类模块 | 约 10–100 行、5–50 列；正负效应围绕 0 显示 | Science Fig3I_J 图版参考 | [Python](../scripts/clustered_signed_effect_heatmap.py) |
| [pairwise_similarity_heatmap](../assets/figures/pairwise_similarity_heatmap.png) | 比较样本、特征或区域间的成对相似度 | 约 10–100 个实体形成对称矩阵；相关系数范围随方法定义 | Science Fig4E_F 图版参考 | [Python](../scripts/pairwise_similarity_heatmap.py) |
| [paired_metrics_split_heatmap](../assets/figures/paired_metrics_split_heatmap.png) | 在同一矩阵比较两组度量 | 约 10–80 行、5–30 列；每格包含两种数值 | Science Fig3E 图版参考 | [Python](../scripts/paired_metrics_split_heatmap.py) |
| [ordered_features_effect_heatmap](../assets/figures/ordered_features_effect_heatmap.png) | 比较排序样本的特征变化与效应 | 约 10–60 个特征、20–200 个样本；含有序变量与每特征效应 | Science Fig2H 图版参考 | [Python](../scripts/ordered_features_effect_heatmap.py) |
| [group_feature_expression_dotplot](../assets/figures/group_feature_expression_dotplot.png) | 比较细胞群的基因表达强度与覆盖比例 | 约 5–30 个群、5–40 个特征；颜色表示强度，面积表示比例 | Science Fig5D 图版参考 | [Python](../scripts/group_feature_expression_dotplot.py) |
| [observed_predicted_heatmap](../assets/figures/observed_predicted_heatmap.png) | 比较观测与预测的矩阵模式 | 每幅约 10–60 行、10–100 列；两矩阵具有共同索引 | Science Fig6B 图版参考 | [Python](../scripts/observed_predicted_heatmap.py) |
| [sample_annotation_tracks](../assets/figures/sample_annotation_tracks.png) | 对齐样本的临床注释与组成 | 约 20–500 个样本、3–10 条注释轨；可混合分类值和连续值 | Science Fig1B 图版参考 | [Python](../scripts/sample_annotation_tracks.py) |
| [cell_annotation_umap](../assets/figures/cell_annotation_umap.png) | 展示细胞聚类与注释 | 数千至数十万个细胞，约 5–30 类；使用二维嵌入坐标 | Science Fig1C 图版参考 | [Python](../scripts/cell_annotation_umap.py) |
| [feature_expression_umap](../assets/figures/feature_expression_umap.png) | 展示基因表达或评分在嵌入空间中的分布 | 数千至数十万个观测；颜色表示连续表达、活性或评分 | Science Fig3F_H 图版参考 | [Python](../scripts/feature_expression_umap.py) |
| [sample_pca_annotation](../assets/figures/sample_pca_annotation.png) | 比较样本的主成分及分组注释 | 约 50–5000 个观测；坐标为主成分得分 | Science Fig2B 图版参考 | [Python](../scripts/sample_pca_annotation.py) |
| [cell_trajectory_vector_field](../assets/figures/cell_trajectory_vector_field.png) | 展示嵌入空间中的模型方向或流动 | 数千至数万个观测、约 20–100 条流线；输入包含坐标和向量 | Science Fig3F_H 图版参考 | [Python](../scripts/cell_trajectory_vector_field.py) |
| [cell_hierarchy_circular_tree](../assets/figures/cell_hierarchy_circular_tree.png) | 展示细胞层级与多层注释 | 约 10–80 个叶节点、3–5 层；输入为已有节点及父子关系 | Science Fig1E 图版参考 | [Python](../scripts/cell_hierarchy_circular_tree.py) |
| [grn_network](../assets/figures/grn_network.png) | 展示调控网络、互作和模块 | 约 10–80 个节点、20–200 条边；可编码节点类型及边权 | Science Fig3K_L 图版参考 | [Python](../scripts/grn_network.py) |
| [category_ranking_radial_bars](../assets/figures/category_ranking_radial_bars.png) | 总览较多类别的得分或数量 | 约 10–60 个类别；每项包含一个连续数值 | Science Fig4A_B 图版参考 | [Python](../scripts/category_ranking_radial_bars.py) |
| [genomic_links_circos](../assets/figures/genomic_links_circos.png) | 展示染色体位置及跨区间连接 | 约 1–24 条染色体、5–100 条连接；位置带基因组坐标 | Science Fig4I 图版参考 | [Python](../scripts/genomic_links_circos.py) |
| [gene_set_overlap_venn](../assets/figures/gene_set_overlap_venn.png) | 展示少数基因集的独有与共有成员 | 2–3 个集合；每个区域展示交集数量 | Science Fig3B 图版参考 | [Python](../scripts/gene_set_overlap_venn.py) |
| [genomic_region_association_tracks](../assets/figures/genomic_region_association_tracks.png) | 比较同一区间的多组关联结果 | 每轨约 100–10000 个位点、2–6 轨；位置共用横轴 | Science Fig5C_H_L 图版参考 | [Python](../scripts/genomic_region_association_tracks.py) |
| [genomic_signal_tracks](../assets/figures/genomic_signal_tracks.png) | 比较基因组区间的多组信号 | 每区间约 3–20 条轨道；包含位置和连续信号 | Science Fig6E 图版参考 | [Python](../scripts/genomic_signal_tracks.py) |
| [sequence_position_effect](../assets/figures/sequence_position_effect.png) | 展示序列位置及碱基效应 | 约 20–150 个位置、4 种碱基；效应可为正负值 | Science Fig6F_G 图版参考 | [Python](../scripts/sequence_position_effect.py) |
| [spatial_cell_neighborhood_map](../assets/figures/spatial_cell_neighborhood_map.png) | 展示组织空间中的细胞邻域分布 | 每区域约 10³–10⁵ 个观测、5–20 类；使用实际空间坐标 | 模拟实现图；参考图待补 | [Python](../scripts/spatial_cell_neighborhood_map.py) |
| [survival_kaplan_meier](../assets/figures/survival_kaplan_meier.png) | 比较不同组的事件时间与生存概率 | 约 2–4 组、4–8 个风险表时点；生存概率范围 0–1 | CRLM 参考数据预览对照 | [Python](../scripts/survival_kaplan_meier.py) |
| [effect_estimate_forest](../assets/figures/effect_estimate_forest.png) | 比较多组效应估计及置信区间 | 约 5–25 行，每行 1–3 套估计；比值效应常以 1 为基准 | CRLM 参考数据预览对照 | [Python](../scripts/effect_estimate_forest.py) |
| [two_axis_effect_uncertainty](../assets/figures/two_axis_effect_uncertainty.png) | 比较两套效应及各自的不确定性 | 约 5–50 组效应估计；两轴均可含正负值 | Science Fig5F 图版参考 | [Python](../scripts/two_axis_effect_uncertainty.py) |
| [classification_roc](../assets/figures/classification_roc.png) | 比较分类模型的阈值判别能力 | 约 2–10 条曲线；假阳性率和真阳性率均为 0–1 | Science Fig6D 图版参考 | [Python](../scripts/classification_roc.py) |
| [volcano](../assets/figures/volcano.png) | 展示差异基因的方向与统计显著性 | 约 10³–5×10⁴ 个基因；效应含正负值，P 或 q 为 0–1 | 模拟实现图；参考图待补 | [Python](../scripts/volcano.py) |
| [enrichment_bubble](../assets/figures/enrichment_bubble.png) | 比较多个通路的富集程度和显著性 | 约 10–30 条通路；颜色、大小分别表示统计量或基因数 | CRLM 参考数据预览对照 | [Python](../scripts/enrichment_bubble.py) |
| [enrichment_gsea](../assets/figures/enrichment_gsea.png) | 展示基因集在排序基因中的富集位置 | 每幅约 1 个基因集、数千至数万个排序基因；展示累积得分 | 模拟实现图；参考图待补 | [Python](../scripts/enrichment_gsea.py) |
| [stage_expression_heatmap](../assets/figures/stage_expression_heatmap.png) | 展示多个器官的阶段性基因模块 | 多个器官、数十至数百个基因和若干有序阶段；表达值按基因标准化 | Figure 2a 原图与模拟实现 | [R](../scripts/stage_expression_heatmap.R) |
| [trajectory_gene_modules_heatmap](../assets/figures/trajectory_gene_modules_heatmap.png) | 展示轨迹中基因模块与阶段转换 | 数十至数百个基因、连续排序的轨迹位置；表达值按基因标准化 | Figure 2g 原图与模拟实现；裁图包含相邻图 | [R](../scripts/trajectory_gene_modules_heatmap.R) |
| [stage_differential_volcano](../assets/figures/stage_differential_volcano.png) | 比较多个阶段的差异基因及方向 | 多个阶段、每阶段数百至数万个基因；有正负效应及显著性 | Figure 3b 原图与模拟实现；显著性为模拟构造 | [R](../scripts/stage_differential_volcano.R) |
| [pseudotime_gene_expression](../assets/figures/pseudotime_gene_expression.png) | 比较关键基因沿拟时序的表达趋势 | 若干基因、连续拟时序位置；展示归一化表达曲线 | Figure 4i 原图与模拟实现 | [R](../scripts/pseudotime_gene_expression.R) |
| [disease_gene_organ_stage_heatmap](../assets/figures/disease_gene_organ_stage_heatmap.png) | 展示疾病相关基因在器官和阶段中的表达 | 数百个基因、多器官及多个阶段；表达量使用统一色标 | Figure 5e 原图与模拟实现 | [R](../scripts/disease_gene_organ_stage_heatmap.R) |
| [spatial_anatomy_development](../assets/figures/spatial_anatomy_development.png) | 比较不同发育阶段的空间解剖结构 | 多个阶段、每张切片包含多个空间区域；坐标与比例尺使用共同单位 | Extended Data Figure 2a 原图与模拟实现；模拟轮廓与未校准比例尺 | [R](../scripts/spatial_anatomy_development.R) |
| [brain_region_correlation_heatmap](../assets/figures/brain_region_correlation_heatmap.png) | 比较脑区和阶段间的转录相关性 | 多个脑区与阶段形成样本对称矩阵；Spearman 相关系数范围 −1 至 1 | Extended Data Figure 7c 原图与模拟实现 | [R](../scripts/brain_region_correlation_heatmap.R) |
| [brain_pathway_activity_heatmap](../assets/figures/brain_pathway_activity_heatmap.png) | 比较脑区与阶段的通路活性模块 | 数十至数百个通路、多个脑区或样本；展示连续通路活性 | Extended Data Figure 7d 原图与模拟实现；裁图包含相邻图；分组或词条为模拟构造 | [R](../scripts/brain_pathway_activity_heatmap.R) |
| [cross_species_expression_heatmap](../assets/figures/cross_species_expression_heatmap.png) | 比较两个物种的共同基因随阶段变化 | 数百个同源基因、每个物种多个阶段；行按共同基因对齐 | Extended Data Figure 10f 原图与模拟实现；分组或词条为模拟构造 | [R](../scripts/cross_species_expression_heatmap.R) |
| [color_palette_preview](../assets/figures/color_palette_preview.png) | 选择分类配色 | dittoSeq 前 7 色及 ggsci NPG 10 色；按类别固定映射 | 官方配色色卡 | [R](../scripts/color_palette_preview.R) |
