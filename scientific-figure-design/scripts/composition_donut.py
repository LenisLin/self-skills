"""Show overall composition and major shares. Read the bundled simulated data and generate PNG, PDF, and SVG outputs."""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib import pyplot as plt
from matplotlib.colors import LinearSegmentedColormap


def plot_donut(composition, *, style):
    """Use component,count: one count-weighted donut and a matching summary bar."""
    counts = composition.groupby("component", sort=True, observed=True)["count"].sum()
    cmap = LinearSegmentedColormap.from_list("donut", style["donut_colors"])
    palette = dict(zip(counts.index, cmap(np.linspace(0, 1, len(counts)))))
    fig = plt.figure(figsize=(5.2, 3.0), layout="constrained")
    grid = fig.add_gridspec(2, 1, height_ratios=[0.28, 2.2])
    bar = fig.add_subplot(grid[0])
    ax = fig.add_subplot(grid[1])
    fractions = counts / counts.sum()
    offset = 0
    for label, fraction in fractions.items():
        bar.barh(0, fraction, left=offset, height=0.65, color=palette[label])
        if fraction >= 0.08:
            bar.text(offset + fraction / 2, 0, f"{100 * fraction:.1f}%",
                     ha="center", va="center", fontsize=6)
        offset += fraction
    bar.set(xlim=(0, 1), title="Component proportions")
    bar.set_axis_off()
    wedges, _ = ax.pie(counts, colors=[palette[k] for k in counts.index],
                       startangle=90, counterclock=False,
                       wedgeprops={"width": 0.44, "edgecolor": "white", "linewidth": 0.5})
    ax.text(0, 0, f"Total count\n{counts.sum():,.0f}", ha="center", va="center")
    labels = [f"{label}: {100 * value / counts.sum():.1f}%"
              for label, value in counts.items()]
    ax.legend(wedges, labels, title="Component", loc="center left", bbox_to_anchor=(1, 0.5))
    ax.set_aspect("equal")
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_donut, ['composition'], 'composition_donut', output)
