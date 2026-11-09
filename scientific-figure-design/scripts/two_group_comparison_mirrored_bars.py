"""比较两个群体的分类数量或比例。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib import pyplot as plt
from plot_style import clean_axis


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


def plot_mirrored_bars(category_values, *, style):
    """Use category,left,right: matched scales with central category labels."""
    labels = category_values["category"].tolist()
    fig, left, right = _mirror_axes(labels, style)
    positions = np.arange(len(labels))
    low = min(0, category_values[["left", "right"]].to_numpy().min() * 1.08)
    limit = max(0, category_values[["left", "right"]].to_numpy().max() * 1.08)
    left.barh(positions, category_values["left"], color=style["colors"]["mirror_left"], height=0.7)
    right.barh(positions, category_values["right"], color=style["colors"]["mirror_right"], height=0.7)
    left.set(xlim=(limit, low), xlabel="Left value", title="Left")
    right.set(xlim=(low, limit), xlabel="Right value", title="Right")
    left.title.set_color(style["colors"]["mirror_left"])
    right.title.set_color(style["colors"]["mirror_right"])
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_mirrored_bars, ['category_values'], 'two_group_comparison_mirrored_bars', output)
