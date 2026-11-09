"""Compare rankings of feature scores or effects. Read the bundled simulated data and generate PNG, PDF, and SVG outputs."""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from plot_style import new_axes, clean_axis


def plot_lollipop(category_values, *, style):
    """Use category,left: sorted horizontal stems ending at observed values."""
    data = category_values.sort_values("left", kind="stable")
    labels = data["category"].tolist()
    fig, ax = new_axes(4.5, max(2.6, len(data) * 0.22))
    positions = np.arange(len(data))
    ax.hlines(positions, 0, data["left"], color="0.25", linewidth=0.6)
    ax.scatter(data["left"], positions, s=12, color="black", linewidths=0, zorder=3)
    ax.set(yticks=positions, yticklabels=labels, xlabel="Left value", ylabel="Category")
    ax.axvline(0, color="0.5", linewidth=0.5)
    clean_axis(ax, style)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_lollipop, ['category_values'], 'feature_ranking_lollipop', output)
