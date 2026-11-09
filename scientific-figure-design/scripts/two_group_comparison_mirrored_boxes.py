"""比较各类别在两侧的观测分布。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib import pyplot as plt
from plot_style import clean_axis


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


def _mirror_axes(labels, style):
    """Reserve a center column for labels between matched mirrored axes."""
    fig = plt.figure(figsize=(6.8, max(2.6, len(labels) * 0.23)), layout="constrained")
    center_width = max(1.0, max(len(str(label)) for label in labels) * 0.055)
    grid = fig.add_gridspec(1, 3, width_ratios=[2, center_width, 2], wspace=0.04)
    left = fig.add_subplot(grid[0, 0])
    center = fig.add_subplot(grid[0, 1], sharey=left)
    right = fig.add_subplot(grid[0, 2], sharey=left)
    for i, label in enumerate(labels):
        center.text(0.5, i, str(label), ha="center", va="center")
    center.set(xlim=(0, 1), ylim=(len(labels) - 0.5, -0.5))
    center.set_axis_off()
    for ax in (left, right):
        ax.tick_params(axis="y", left=False, labelleft=False)
        clean_axis(ax, style)
        for spine in ax.spines.values():
            spine.set_visible(True)
    return fig, left, right


def plot_mirrored_boxes(paired, *, style):
    """Use category,side,value: Left/Right distributions on matched mirrored axes."""
    labels = sorted(paired["category"].unique())
    fig, left, right = _mirror_axes(labels, style)
    limit = max(0, paired["value"].max() * 1.08)
    low = min(0, paired["value"].min() * 1.08)
    positions = np.arange(len(labels))
    for ax, side, color in [(left, "Left", style["colors"]["mirror_left"]),
                             (right, "Right", style["colors"]["mirror_right"])]:
        values = [paired.loc[(paired["category"] == label) &
                             (paired["side"] == side), "value"].to_numpy()
                  for label in labels]
        _boxes(ax, values, positions, [color] * len(labels), horizontal=True)
        # All observations include outliers hidden by the box layer.
        rng = np.random.default_rng(20261105)
        for position, data in zip(positions, values):
            ax.scatter(data, position + rng.uniform(-0.15, 0.15, len(data)),
                       s=4, color=color, alpha=0.4, linewidths=0)
        ax.set(xlabel=f"{side} value", title=side, ylim=(len(labels) - 0.5, -0.5))
        ax.title.set_color(color)
    left.set_xlim(limit, low)
    right.set_xlim(low, limit)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_mirrored_boxes, ['paired'], 'two_group_comparison_mirrored_boxes', output)
