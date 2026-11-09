"""Compare the composition of cell types and spatial neighborhoods. Read the bundled simulated data and generate PNG, PDF, and SVG outputs."""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from plot_style import new_axes, sequential_cmap


def _matrix(table, value, column="column"):
    """Preserve first appearance of row and column labels in a complete table."""
    return table.pivot(index="row", columns=column, values=value).reindex(
        index=table["row"].drop_duplicates(), columns=table[column].drop_duplicates())


def _heatmap(ax, matrix, *, cmap, vmin, vmax):
    """Draw untransformed values with explicit matrix labels and color limits."""
    image = ax.imshow(matrix.to_numpy(), cmap=cmap, vmin=vmin, vmax=vmax,
                      aspect="auto", interpolation="nearest")
    ax.set_xticks(np.arange(len(matrix.columns)), matrix.columns, rotation=90)
    ax.set_yticks(np.arange(len(matrix.index)), matrix.index)
    ax.tick_params(length=0)
    for spine in ax.spines.values():
        spine.set_visible(False)
    return image


def plot_cn_fraction(cn_fraction, *, style):
    """Use row,column,fraction: supplied fractions with fixed white→pink [0,1]."""
    matrix = _matrix(cn_fraction, "fraction")
    fig, ax = new_axes(3.6, 4.2)
    image = _heatmap(ax, matrix, cmap=sequential_cmap(style), vmin=0, vmax=1)
    ax.set_aspect("equal")
    ax.yaxis.tick_right()
    ax.set_xticks(np.arange(len(matrix.columns) + 1) - 0.5, minor=True)
    ax.set_yticks(np.arange(len(matrix.index) + 1) - 0.5, minor=True)
    ax.grid(which="minor", color="0.8", linewidth=0.3)
    ax.tick_params(which="minor", length=0)
    fig.colorbar(image, ax=ax, label="Fraction", orientation="horizontal",
                 fraction=0.05, pad=0.12)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_cn_fraction, ['cn_fraction'], 'cell_neighborhood_composition_heatmap', output)
