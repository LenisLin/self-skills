"""比较样本或细胞组间的观测分布。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib import pyplot as plt
from scipy.stats import mannwhitneyu
from plot_style import clean_axis, colors_for


def _boxes(ax, values, positions, palette, *, horizontal=False, width=0.45, showfliers=False):
    """Draw thin colored boxes, optionally showing Tukey outliers."""
    boxes = ax.boxplot(values, positions=positions, widths=width,
                       orientation="horizontal" if horizontal else "vertical",
                       patch_artist=True, showfliers=showfliers,
                       medianprops={"color": "black", "linewidth": 0.7},
                       whiskerprops={"linewidth": 0.55},
                       capprops={"linewidth": 0.55},
                       flierprops={"marker": ".", "markersize": 1.8,
                                   "markeredgecolor": "0.4"})
    for patch, color in zip(boxes["boxes"], palette):
        patch.set(facecolor=color, edgecolor="0.3" if color == "white" else color,
                  alpha=0.6, linewidth=0.6)


def plot_box_jitter(groups, *, style):
    """Use group,value and optional facet: boxes and individual observations."""
    groups = groups.dropna(subset=["group", "value"])
    labels = sorted(groups["group"].unique())
    palette = colors_for(labels, style)
    facets = list(groups["facet"].drop_duplicates()) if "facet" in groups else [None]
    fig, axes = plt.subplots(1, len(facets), figsize=(2.0 * len(facets) + 0.5, 2.6),
                             layout="constrained", squeeze=False)
    rng = np.random.default_rng(20261105)
    for facet, ax in zip(facets, axes[0]):
        subset = groups if facet is None else groups.loc[groups["facet"] == facet]
        present = [label for label in labels if (subset["group"] == label).any()]
        values = [subset.loc[subset["group"] == label, "value"].dropna().to_numpy()
                  for label in present]
        positions = np.arange(len(present))
        _boxes(ax, values, positions, [palette[label] for label in present])
        for position, label, data in zip(positions, present, values):
            ax.scatter(position + rng.uniform(-0.17, 0.17, len(data)), data,
                       s=style["marker_size"], color=palette[label],
                       alpha=style["alpha"], linewidths=0, zorder=3)
        ax.set(xticks=positions, xticklabels=present, xlabel="Group", ylabel="Value")
        if facet is not None:
            ax.set_title(str(facet))
        if style.get("show_group_test", False) and len(values) == 2:
            result = mannwhitneyu(values[0], values[1], alternative="two-sided")
            annotation = f"Mann–Whitney P = {result.pvalue:.2g}"
            text_style = {"fontsize": style["tick_size"]}
            significance = style.get("typography", {}).get("boxplot_significance", {})
            if significance.get("display") == "stars":
                annotation = next(
                    (level["label"] for level in sorted(
                        significance["thresholds"], key=lambda level: level["p_less_than"])
                     if result.pvalue < level["p_less_than"]),
                    significance["nonsignificant_label"])
                text_style.update(fontsize=significance.get("font_size", style["tick_size"]),
                                  fontweight=significance.get("font_weight", "normal"))
            ax.text(0.5, 0.98, annotation,
                    transform=ax.transAxes, ha="center", va="top", **text_style,
                    bbox={"facecolor": "white", "edgecolor": "none", "alpha": 0.85, "pad": 0.8})
        clean_axis(ax, style)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_box_jitter, ['box_groups'], 'group_distribution_box', output)
