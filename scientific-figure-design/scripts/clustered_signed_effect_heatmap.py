"""展示有方向效应及聚类模块。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib import pyplot as plt
from scipy.cluster.hierarchy import linkage, dendrogram


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


def plot_clustered_heatmap(heatmap, *, style):
    """Use row,column,value,q: Euclidean average clustering; stars mark q<0.05."""
    matrix = _matrix(heatmap, "value")
    row_linkage = linkage(matrix.to_numpy(), method="average", metric="euclidean")
    col_linkage = linkage(matrix.to_numpy().T, method="average", metric="euclidean")
    fig = plt.figure(figsize=(4.5, 5), layout="constrained")
    grid = fig.add_gridspec(1, 2, width_ratios=[0.65, 4], wspace=0.02)
    row_ax = fig.add_subplot(grid[0, 0])
    ax = fig.add_subplot(grid[0, 1])
    row_tree = dendrogram(row_linkage, orientation="left", ax=row_ax,
                           no_labels=True, color_threshold=0,
                           above_threshold_color=style["colors"]["neutral"])
    col_tree = dendrogram(col_linkage, no_plot=True)
    row_ax.set_ylim(10 * len(matrix), 0)
    for collection in row_ax.collections:
        collection.set_linewidth(style["line_width"])
    row_ax.set_axis_off()
    matrix = matrix.iloc[row_tree["leaves"], col_tree["leaves"]]
    limit = np.abs(matrix.to_numpy()).max()
    image = _heatmap(ax, matrix, cmap=style["cluster_cmap"], vmin=-limit, vmax=limit)
    ax.yaxis.tick_right()
    plt.setp(ax.get_xticklabels(), rotation=45, ha="right")
    q = _matrix(heatmap, "q").reindex(index=matrix.index, columns=matrix.columns)
    y, x = np.where(q.to_numpy() < 0.05)
    ax.scatter(x, y, s=9, marker="*", color="black", linewidths=0)
    fig.colorbar(image, ax=ax, label="Value (*: q < 0.05)", fraction=0.04, pad=0.18)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_clustered_heatmap, ['heatmap'], 'clustered_signed_effect_heatmap', output)
