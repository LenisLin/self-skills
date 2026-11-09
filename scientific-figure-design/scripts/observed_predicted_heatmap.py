"""Compare observed and predicted matrix patterns. Read the bundled simulated data and generate PNG, PDF, and SVG outputs."""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib import pyplot as plt
from matplotlib.colors import LinearSegmentedColormap


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


def plot_observed_predicted(observed_predicted, *, style):
    """Use row,column,observed,predicted: aligned matrices with one shared value scale."""
    observed = _matrix(observed_predicted, "observed")
    predicted = _matrix(observed_predicted, "predicted").reindex(
        index=observed.index, columns=observed.columns)
    values = np.concatenate([observed.to_numpy().ravel(), predicted.to_numpy().ravel()])
    vmin, vmax = values.min(), values.max()
    cmap = LinearSegmentedColormap.from_list("observed", ["#fff4e8", "#f69b77", "#9f242c"])
    fig, axes = plt.subplots(2, 1, figsize=(4.6, 6), layout="constrained", sharex=True)
    for ax, matrix, title in zip(axes, [observed, predicted], ["Observed", "Predicted"]):
        image = _heatmap(ax, matrix, cmap=cmap, vmin=vmin, vmax=vmax)
        ax.set_aspect("equal")
        ax.set_title(title, loc="left", fontsize=style["label_size"], pad=2)
    axes[0].tick_params(axis="x", labelbottom=False)
    axes[1].set_xlabel("Column")
    fig.colorbar(image, ax=list(axes), label="Value", fraction=0.03, pad=0.03)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_observed_predicted, ['observed_predicted'], 'observed_predicted_heatmap', output)
