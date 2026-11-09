# 科研绘图配色

依据 Wong 的色觉差异配色建议和 dittoSeq 配色说明，优先保证类别区分、文字对比和跨图一致。用户指定的配色或图版参考优先；常规分类图优先使用 dittoSeq，期刊风格可选 ggsci。参考：[Wong, Nature Methods (2011)](https://www.nature.com/articles/nmeth.1618)、[Wong 更正说明](https://www.nature.com/articles/s41592-023-01974-0)、[dittoSeq vignette](https://bioconductor.org/packages/release/bioc/vignettes/dittoSeq/inst/doc/dittoSeq.html)、[ggsci 文档](https://nanx.me/ggsci/)。

| 场景 | 配色选择 | 数值和视觉编码 |
| --- | --- | --- |
| UMAP 注释、分组比较、细胞类型 | dittoSeq 分类色，前 7 色优先；[色卡](../assets/figures/color_palette_preview.png) | 一个类别对应一个固定颜色；组数较多时配合形状、分面或直接标注 |
| 基因表达、比例和非负强度 | 明度递增的连续色标 | 按表达量或比例编码；对比图使用相同数值范围 |
| log2FC、相关系数等有方向数值 | 以 0 或科学基准为中心的发散色标 | 色相表示方向、明度表示大小；相关系数采用 −1 至 1 的量纲 |
| 期刊色彩风格 | 按图形需要选用 ggsci，例如 NPG 色板 | 保持类别映射；结合形状、标签和灰度检查可读性 |

色卡列出 dittoSeq 的前 7 色和 ggsci NPG 的 10 色，分别适合查看分类配色与期刊配色；[R 脚本](../scripts/color_palette_preview.R)可生成色卡。为图中重要类别同时使用可识别的形状、线型或标签，并检查浅黄色在白底上的对比、透明度叠加后的颜色、灰度输出和常见色觉差异。dittoSeq 的 `Simulate()` 可检查其绘图函数在不同色觉条件下的显示。

Wong 的更正说明补充了 Okabe 和 Ito 配色方案的原始来源。

## R：分类变量的稳定映射

```r
library(ggplot2)

group_levels <- c("T cell", "B cell", "Myeloid")
palette <- dittoSeq::dittoColors(reps = 1)
stopifnot(length(group_levels) <= length(unique(palette)))
group_colors <- setNames(palette[seq_along(group_levels)], group_levels)

# p 为已有 ggplot；使用同一命名映射绘制不同子集和面板。
p + scale_colour_manual(values = group_colors) +
  scale_fill_manual(values = group_colors)
```

## R：按数值含义选择色标

```r
# 0–1 比例；比较面板共用 limits。
p + scale_colour_viridis_c(limits = c(0, 1))

# 以 0 为基准的有符号效应。
p + scale_fill_gradient2(low = "#0072B2", mid = "white",
                         high = "#D55E00", midpoint = 0)

# NPG 风格分类色；fill 映射对应 ggsci::scale_fill_npg()。
p + ggsci::scale_color_npg()
```

绘制实际图形时使用数据对应的 limits、变换和单位。已有参考图复现脚本保留图版配色；新图按分析问题和用户指定风格选择。
