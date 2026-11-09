"""展示非负特征之间的关联强度。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from plot_style import new_axes, sequential_cmap, text_label


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


def plot_small_heatmap(association, *, style):
    """Use row,column,neg_log10_p: nonnegative association strength in white→pink."""
    matrix = _matrix(association, "neg_log10_p")
    fig, ax = new_axes(2.6, 4)
    image = _heatmap(ax, matrix, cmap=sequential_cmap(style), vmin=0,
                     vmax=matrix.to_numpy().max())
    ax.set_aspect("equal")
    ax.yaxis.tick_right()
    ax.tick_params(axis="x", labelrotation=0)
    if "typography" in style:
        ax.tick_params(axis="y", labelcolor=style["typography"]["secondary_text_color"])
    ax.set_xticks(np.arange(len(matrix.columns) + 1) - 0.5, minor=True)
    ax.set_yticks(np.arange(len(matrix.index) + 1) - 0.5, minor=True)
    ax.grid(which="minor", color="0.6", linewidth=0.35)
    ax.tick_params(which="minor", length=0)
    fig.colorbar(image, ax=ax, label=text_label("−log10(P)", style), orientation="horizontal",
                 fraction=0.05, pad=0.12)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_small_heatmap, ['association'], 'feature_association_heatmap', output)
