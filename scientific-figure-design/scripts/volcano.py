"""展示差异基因的方向与统计显著性。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from plot_style import clean_axis, new_axes, text_label


def plot_volcano(results, *, style):
    """Encode feature effect and -log10(q_value); q<0.05 colors the direction."""
    fig, ax = new_axes(3.65, 2.8)
    q = results.q_value.to_numpy()
    significant = q < 0.05
    palette = np.full(len(results), style["colors"]["neutral"], dtype=object)
    palette[significant & (results.effect.to_numpy() > 0)] = style["colors"]["red"]
    palette[significant & (results.effect.to_numpy() < 0)] = style["colors"]["dark_blue"]
    y = -np.log10(np.maximum(q, np.finfo(float).tiny))
    ax.scatter(results.effect, y, c=palette, s=4, alpha=0.6, linewidths=0, rasterized=True)
    ax.axhline(-np.log10(0.05), color="0.55", linestyle="--", linewidth=0.55)
    ax.axvline(0, color="0.7", linestyle="--", linewidth=0.45)
    label_counts = {-1: 0, 1: 0}
    for index in np.argsort(q):
        if not significant[index]:
            break
        side = 1 if results.effect.iloc[index] >= 0 else -1
        if label_counts[side] >= 2:
            continue
        ax.annotate(results.feature.iloc[index], (results.effect.iloc[index], y[index]),
            xytext=(0.98 if side == 1 else 0.02, 0.96 - label_counts[side] * 0.085),
            textcoords="axes fraction", ha="right" if side == 1 else "left", fontsize=5.5,
            arrowprops={"arrowstyle": "-", "color": "0.45", "linewidth": 0.35})
        label_counts[side] += 1
        if all(count == 2 for count in label_counts.values()):
            break
    ax.set(xlabel="Effect estimate", ylabel=text_label("−log10(BH q)", style))
    clean_axis(ax, style)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_volcano, ['volcano'], 'volcano', output)
