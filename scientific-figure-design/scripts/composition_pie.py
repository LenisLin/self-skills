"""展示少数类别在整体中的组成。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from plot_style import new_axes, colors_for


def plot_pie(composition, *, style):
    """Use component,count: outside labels for count-weighted sectors."""
    counts = composition.groupby("component", sort=True, observed=True)["count"].sum()
    palette = colors_for(counts.index, style)
    fig, ax = new_axes(5.5, max(2.8, len(counts) * 0.3))
    wedges, _ = ax.pie(counts, colors=[palette[k] for k in counts.index],
                       startangle=90, counterclock=False,
                       wedgeprops={"edgecolor": "white", "linewidth": 0.6})
    for side in (-1, 1):
        entries = []
        for wedge, (label, value) in zip(wedges, counts.items()):
            angle = np.deg2rad((wedge.theta1 + wedge.theta2) / 2)
            x, y = np.cos(angle), np.sin(angle)
            if (x >= 0) == (side > 0):
                entries.append((y, x, label, value, wedge.get_facecolor()))
        entries.sort()
        for text_y, (y, x, label, value, color) in zip(
                np.linspace(-1.05, 1.05, len(entries)), entries):
            ax.annotate(f"{label} {100 * value / counts.sum():.1f}%",
                        xy=(x, y), xytext=(side * 1.4, text_y),
                        ha="left" if side > 0 else "right", va="center", color=color,
                        arrowprops={"arrowstyle": "-", "color": color, "lw": 0.6,
                                    "connectionstyle": "angle,angleA=0,angleB=90"})
    ax.set_title("Distribution of components")
    ax.set_aspect("equal")
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_pie, ['composition'], 'composition_pie', output)
