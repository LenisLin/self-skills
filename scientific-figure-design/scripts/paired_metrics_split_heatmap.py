"""Compare two sets of metrics in the same matrix. Read the bundled simulated data and generate PNG, PDF, and SVG outputs."""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib import pyplot as plt
from matplotlib.colors import Normalize
from matplotlib.collections import PolyCollection
from matplotlib.lines import Line2D


def plot_split_cell_heatmap(split, *, style):
    """Use row,column,value_a,value_b,flag,point_value: triangles, flag, radius."""
    rows = split["row"].drop_duplicates().tolist()
    columns = split["column"].drop_duplicates().tolist()
    row_positions = {label: i for i, label in enumerate(rows)}
    col_positions = {label: i for i, label in enumerate(columns)}
    vertices, values = [], []
    # C9 polygon geometry: upper/right A, lower/left B; radius is linear in value.
    for item in split.itertuples(index=False):
        x, y = col_positions[item.column], row_positions[item.row]
        vertices.extend([[(x - 0.5, y - 0.5), (x + 0.5, y - 0.5), (x + 0.5, y + 0.5)],
                         [(x + 0.5, y + 0.5), (x - 0.5, y + 0.5), (x - 0.5, y - 0.5)]])
        values.extend([item.value_a, item.value_b])
    fig = plt.figure(figsize=(5.8, max(5.6, min(14, len(rows) * 0.12 + 1))), layout="constrained")
    grid = fig.add_gridspec(1, 2, width_ratios=[3, 1.3])
    ax = fig.add_subplot(grid[0, 0])
    legend_ax = fig.add_subplot(grid[0, 1])
    legend_ax.set_axis_off()
    limit = np.abs(values).max()
    cells = PolyCollection(vertices, array=np.asarray(values),
                            cmap=style["diverging_cmap"], norm=Normalize(-limit, limit),
                            edgecolors="none")
    ax.add_collection(cells)
    marked = split.loc[split["flag"].astype(bool)]
    ax.scatter(marked["column"].map(col_positions), marked["row"].map(row_positions),
               s=(1 + 3 * marked["point_value"]) ** 2, marker="D", facecolors="white",
               edgecolors="0.35", linewidths=0.35)
    ax.set(xlim=(-0.5, len(columns) - 0.5), ylim=(len(rows) - 0.5, -0.5),
           xticks=np.arange(len(columns)), yticks=np.arange(len(rows)),
           xticklabels=columns, yticklabels=rows)
    ax.set_aspect("equal")
    ax.tick_params(axis="x", rotation=90, length=0)
    ax.tick_params(axis="y", length=0)
    for spine in ax.spines.values():
        spine.set_visible(False)
    color_ax = legend_ax.inset_axes([0.08, 0.57, 0.18, 0.38])
    fig.colorbar(cells, cax=color_ax, label="A / B value")
    handles = [Line2D([], [], marker="D", linestyle="", markerfacecolor="white",
                      markeredgecolor="0.35", markeredgewidth=0.35,
                      markersize=1 + 3 * value, label=f"{value:g}")
               for value in [0, 0.5, 1]]
    legend_ax.legend(handles=handles, title="Point value\n(radius; flag=True)",
                     loc="lower left", labelspacing=1.1, borderaxespad=0)
    legend_ax.text(0, 0.47, "A: upper/right\nB: lower/left", va="top",
                   transform=legend_ax.transAxes)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_split_cell_heatmap, ['split'], 'paired_metrics_split_heatmap', output)
