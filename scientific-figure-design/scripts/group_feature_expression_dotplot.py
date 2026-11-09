"""比较细胞群的基因表达强度与覆盖比例。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib import pyplot as plt
from matplotlib.lines import Line2D


def plot_dotplot(dotplot, *, style):
    """Use group,feature,mean,fraction: mean color and area proportional to fraction."""
    groups = sorted(dotplot["group"].unique())
    features = dotplot["feature"].drop_duplicates().tolist()
    positions_x = {label: i for i, label in enumerate(features)}
    positions_y = {label: i for i, label in enumerate(groups)}
    fig = plt.figure(figsize=(6.8, 3), layout="constrained")
    grid = fig.add_gridspec(1, 2, width_ratios=[5, 1.2])
    ax = fig.add_subplot(grid[0, 0])
    legend_ax = fig.add_subplot(grid[0, 1])
    legend_ax.set_axis_off()
    points = ax.scatter(dotplot["feature"].map(positions_x), dotplot["group"].map(positions_y),
                        c=dotplot["mean"], s=65 * dotplot["fraction"], cmap=style["bubble_cmap"],
                        vmin=min(0, dotplot["mean"].min()),
                        edgecolors="0.25", linewidths=0.3)
    ax.set(xticks=np.arange(len(features)), xticklabels=features,
           yticks=np.arange(len(groups)), yticklabels=groups,
           xlim=(-0.6, len(features) - 0.4), ylim=(len(groups) - 0.4, -0.6),
           xlabel="Feature", ylabel="Group")
    plt.setp(ax.get_xticklabels(), rotation=90, ha="center")
    for spine in ax.spines.values():
        spine.set_visible(False)
    ax.spines["top"].set_visible(True)
    ax.tick_params(length=0)
    color_ax = legend_ax.inset_axes([0.1, 0.58, 0.17, 0.36])
    fig.colorbar(points, cax=color_ax, label="Mean")
    handles = [Line2D([], [], marker="o", linestyle="", color="0.6",
                      markersize=np.sqrt(65 * value), label=f"{value:g}")
               for value in [0.1, 0.5, 1]]
    legend_ax.legend(handles=handles, title="Fraction (area)", loc="lower left",
                     labelspacing=1.1, borderaxespad=0)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_dotplot, ['dotplot'], 'group_feature_expression_dotplot', output)
