"""Rank cell types with two variance heatmaps and annotated feature counts.

The cell-type and gene labels mirror the reference; percentages and feature
counts are illustrative. Run with an output directory to create PNG, PDF and SVG.
"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.offsetbox import AnnotationBbox, HPacker, TextArea
from matplotlib.patches import Rectangle


def plot_lollipop(feature_ranking, *, style):
    """Align batches, feature counts and two text groups by ranked cell type.

    Required columns: cell_type, batch1_variance_pct, batch2_variance_pct,
    top_feature_count, red_features, blue_features and highlight. The two
    batches use independent percentage scales, as in the reference panel.
    """
    data = feature_ranking.sort_values(
        "top_feature_count", ascending=False, kind="stable"
    ).reset_index(drop=True)
    n = len(data)
    fig = plt.figure(figsize=(7.1, 5.8), facecolor="white")
    labels = fig.add_axes([0.025, 0.10, 0.280, 0.73])
    batch1 = fig.add_axes([0.321, 0.10, 0.058, 0.73])
    scale1 = fig.add_axes([0.391, 0.65, 0.022, 0.18])
    batch2 = fig.add_axes([0.431, 0.10, 0.058, 0.73])
    scale2 = fig.add_axes([0.500, 0.65, 0.022, 0.18])
    ranking = fig.add_axes([0.540, 0.10, 0.350, 0.73])

    fig.text(0.025, 0.975, "G", va="top", fontsize=16, fontweight="bold")
    fig.text(0.50, 0.975, "Factor 7 (RNA)", ha="center", va="top", fontsize=16)
    fig.text(0.295, 0.900, "Fraction of variance explained (%)", ha="center", fontsize=10.5)
    fig.text(0.745, 0.900, "Number of top-ranked features", ha="center", fontsize=10.5)

    for ax in (labels, batch1, batch2, ranking):
        ax.set_ylim(n - 0.5, -0.5)
        ax.set_facecolor("none")
    labels.set_xlim(0, 1)
    labels.axis("off")
    for i, row in data.iterrows():
        labels.text(
            0.99, i, row["cell_type"], ha="right", va="center", fontsize=12,
            fontweight="bold" if row["highlight"] else "normal",
        )
        if row["highlight"]:
            # The same highlight spans the labels, heatmaps and ranking plot.
            y = 0.10 + 0.73 * (n - i - 1) / n
            fig.add_artist(Rectangle(
                (0.14, y), 0.835, 0.73 / n, transform=fig.transFigure,
                facecolor="#f3a4c6", edgecolor="none", zorder=-1,
            ))

    images = []
    for ax, col, title, maximum in (
        (batch1, "batch1_variance_pct", "Batch 1", 3),
        (batch2, "batch2_variance_pct", "Batch 2", 1),
    ):
        image = ax.imshow(
            data[col].to_numpy()[:, None], cmap="Greys", vmin=0, vmax=maximum,
            aspect="auto", interpolation="nearest", zorder=1,
        )
        images.append(image)
        ax.set_title(title, fontsize=11, pad=5)
        ax.set_xticks([])
        ax.set_yticks([])
        ax.hlines(np.arange(n + 1) - 0.5, -0.5, 0.5, color="0.38", lw=0.35)
        for spine in ax.spines.values():
            spine.set_linewidth(0.5)

    for ax, image, ticks in ((scale1, images[0], (0, 1, 2, 3)),
                             (scale2, images[1], (0, 1))):
        colorbar = fig.colorbar(image, cax=ax, ticks=[])
        maximum = max(ticks)
        for value in ticks:
            y = min(max(value, maximum * 0.08), maximum * 0.92)
            ax.text(0.5, y, str(value), ha="center", va="center", fontsize=7,
                    color="white" if value >= maximum / 2 else "black")
        colorbar.outline.set_linewidth(0.4)

    counts = data["top_feature_count"].to_numpy()
    start = np.floor(counts.min() / 5) * 5
    end = np.ceil(counts.max() / 5) * 5
    ranking.set_xlim(start - 0.2, end + 0.8)
    ranking.set_xticks(np.arange(start, end + 1, 5))
    ranking.set_yticks([])
    ranking.tick_params(axis="x", labelsize=11, width=0.7, length=3)
    ranking.spines[["top", "right"]].set_visible(False)
    for spine in ("left", "bottom"):
        ranking.spines[spine].set_linewidth(0.7)

    for i, row in data.iterrows():
        ranking.hlines(i + 0.18, start, row["top_feature_count"], color="0.36", lw=1.1)
        ranking.scatter(row["top_feature_count"], i + 0.18, s=38, color="black", zorder=3)
        font = {"fontsize": 11.0, "fontstyle": "italic",
                "fontweight": "bold" if row["highlight"] else "normal"}
        red = TextArea(row["red_features"], textprops={**font, "color": "#eb1b2e"})
        blue = TextArea(row["blue_features"], textprops={**font, "color": "#2535a5"})
        text = HPacker(children=[red, blue], align="center", pad=0, sep=5)
        ranking.add_artist(AnnotationBbox(
            text, (start + 0.15, i - 0.19), xycoords="data", frameon=False,
            box_alignment=(0, 0.5), pad=0,
        ))
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_lollipop, ["feature_ranking_lollipop"], "feature_ranking_lollipop", output)
