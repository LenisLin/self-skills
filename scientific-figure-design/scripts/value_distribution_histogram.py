"""观察单变量的频数分布。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from plot_style import new_axes, clean_axis, colors_for


def plot_histogram(groups, *, style):
    """Use group,value: within-group probability density in 20 shared bins."""
    groups = groups.dropna(subset=["group", "value"])
    labels = sorted(groups["group"].unique())
    palette = colors_for(labels, style)
    fig, ax = new_axes()
    bins = np.histogram_bin_edges(groups["value"].dropna(), bins=20)
    for label in labels:
        ax.hist(groups.loc[groups["group"] == label, "value"],
                bins=bins, density=True, histtype="step",
                color=palette[label], linewidth=0.9, label=label)
    ax.set(xlabel="Value", ylabel="Probability density")
    ax.legend(title="Group")
    clean_axis(ax, style)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_histogram, ['groups'], 'value_distribution_histogram', output)
