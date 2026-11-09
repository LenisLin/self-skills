"""比较排序样本的特征变化与效应。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib import pyplot as plt
from plot_style import clean_axis


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


def plot_heatmap_aligned_bar(ordered, row_coefficients, metadata, *, style):
    """Use row,sample,value; row,coefficient; sample,age: age order and row bars."""
    meta = metadata.sort_values(["age", "sample"], kind="stable").set_index("sample")
    matrix = _matrix(ordered, "value", "sample").reindex(columns=meta.index)
    coefficients = row_coefficients.set_index("row").reindex(matrix.index)["coefficient"]
    coefficients = coefficients.sort_values(ascending=False, kind="stable")
    matrix = matrix.reindex(index=coefficients.index)
    fig = plt.figure(figsize=(6.8, 3.8), layout="constrained")
    grid = fig.add_gridspec(2, 3, height_ratios=[0.22, 3], width_ratios=[4, 1.1, 0.12],
                            hspace=0.03, wspace=0.04)
    age_ax = fig.add_subplot(grid[0, 0])
    ax = fig.add_subplot(grid[1, 0], sharex=age_ax)
    bar_ax = fig.add_subplot(grid[1, 1], sharey=ax)
    age_image = age_ax.imshow(meta[["age"]].to_numpy().T, aspect="auto", cmap=style["age_cmap"])
    age_ax.set_yticks([0], ["Age"])
    age_ax.set_xticks([])
    age_ax.tick_params(length=0)
    decades = (meta["age"] // 10).astype(int)
    for decade in decades.drop_duplicates():
        positions = np.flatnonzero(decades.to_numpy() == decade)
        age_fraction = age_image.norm(meta["age"].iloc[positions].mean())
        age_ax.text(positions.mean(), 0, f"{decade * 10}-{decade * 10 + 9}",
                    ha="center", va="center", fontsize=style["tick_size"],
                    color="white" if age_fraction > 0.6 else "black")
        if positions[0] > 0:
            age_ax.axvline(positions[0] - 0.5, color="white", linewidth=1)
    value_limit = np.abs(matrix.to_numpy()).max()
    image = _heatmap(ax, matrix, cmap=style["diverging_cmap"], vmin=-value_limit, vmax=value_limit)
    ax.set_xticks([])
    age_ax.tick_params(axis="x", bottom=False, labelbottom=False)
    ax.set_xlabel("Samples (ordered by age)")
    positive_count = int((coefficients >= 0).sum())
    if 0 < positive_count < len(coefficients):
        ax.axhline(positive_count - 0.5, color="white", linewidth=2)
    bar_ax.barh(np.arange(len(matrix)), coefficients,
                color=np.where(coefficients >= 0, "#F0535D", "#7490BC"),
                height=0.75)
    limit = np.abs(coefficients).max() * 1.1
    bar_ax.set(xlim=(-limit, limit), xlabel="Coefficient")
    bar_ax.axvline(0, color="0.4", linewidth=0.5)
    clean_axis(bar_ax, style)
    bar_ax.tick_params(axis="y", left=False, labelleft=False)
    age_color_ax = fig.add_subplot(grid[0, 1:])
    value_color_ax = fig.add_subplot(grid[1, 2])
    fig.colorbar(age_image, cax=age_color_ax, label="Age (years)", orientation="horizontal")
    fig.colorbar(image, cax=value_color_ax, label="Value")
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_heatmap_aligned_bar, ['ordered', 'row_coefficients', 'metadata'], 'ordered_features_effect_heatmap', output)
