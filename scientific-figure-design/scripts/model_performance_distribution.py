"""比较多个模型的性能分布。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib import pyplot as plt
from plot_style import new_axes, clean_axis, colors_for


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


def plot_metric_boxes(metrics, *, style):
    """Use group,replicate,value: boxes ordered by observed group median."""
    labels = metrics.groupby("group", observed=True)["value"].median().sort_values(
        ascending=False, kind="stable").index.tolist()
    palette = colors_for(labels, style)
    values = [metrics.loc[metrics["group"] == label, "value"].to_numpy()
              for label in labels]
    fig, ax = new_axes(max(5.5, len(labels) * 0.35), 2.5)
    positions = np.arange(len(labels))
    _boxes(ax, values, positions, [palette[label] for label in labels], showfliers=True)
    ax.set(xticks=positions, xticklabels=labels,
           xlabel="Group", ylabel="Performance value")
    plt.setp(ax.get_xticklabels(), rotation=40, ha="right")
    for tick, label in zip(ax.get_xticklabels(), labels):
        tick.set_color(palette[label])
    clean_axis(ax, style)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_metric_boxes, ['metrics'], 'model_performance_distribution', output)
