"""比较样本、特征或区域间的成对相似度。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib.colors import LinearSegmentedColormap
from plot_style import new_axes


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


def plot_pairwise_heatmap(pairwise, *, style):
    """Use row,column,value: pairwise correlations with matching axis order."""
    matrix = _matrix(pairwise, "value")
    matrix = matrix.reindex(columns=matrix.index)
    side = max(5, 2 + 0.15 * len(matrix))
    fig, ax = new_axes(side, side)
    cmap = LinearSegmentedColormap.from_list("pairwise", ["#f7b17a", "#fffaf6", "#543068"])
    image = _heatmap(ax, matrix, cmap=cmap, vmin=matrix.to_numpy().min(),
                     vmax=matrix.to_numpy().max())
    ax.set_aspect("equal")
    ax.yaxis.tick_right()
    ax.tick_params(axis="both", labelsize=min(style["tick_size"], 5))
    fig.colorbar(image, ax=ax, label="Correlation", fraction=0.04, pad=0.16)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_pairwise_heatmap, ['pairwise'], 'pairwise_similarity_heatmap', output)
