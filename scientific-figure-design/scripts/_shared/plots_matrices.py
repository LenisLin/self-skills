"""Reusable matrix and aligned-track Figures from contracted long tables.

The caller supplies styled rc defaults and handles export. The Science panels
guide the visual layout; mapped author scripts provide method references.
"""

import numpy as np
from matplotlib import pyplot as plt
from matplotlib.colors import Normalize, ListedColormap, LinearSegmentedColormap
from matplotlib.collections import PolyCollection
from matplotlib.lines import Line2D
from matplotlib.patches import Patch
from scipy.cluster.hierarchy import linkage, dendrogram

from plot_style import new_axes, clean_axis, colors_for, sequential_cmap, text_label


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


def plot_dotplot(dotplot, *, style):
    """Use group,feature,mean,fraction: mean color and area proportional to fraction."""
    groups = sorted(dotplot["group"].unique())
    features = dotplot["feature"].drop_duplicates().tolist()
    positions_x = {label: i for i, label in enumerate(features)}
    positions_y = {label: i for i, label in enumerate(groups)}
    fig = plt.figure(figsize=(6.8, 3), layout="constrained")
    grid = fig.add_gridspec(1, 2, width_ratios=[5, 1.2])
    ax = fig.add_subplot(grid[0, 0])
    legend_ax = fig.add_subplot(grid[0, 1])
    legend_ax.set_axis_off()
    points = ax.scatter(dotplot["feature"].map(positions_x), dotplot["group"].map(positions_y),
                        c=dotplot["mean"], s=65 * dotplot["fraction"], cmap=style["bubble_cmap"],
                        vmin=min(0, dotplot["mean"].min()),
                        edgecolors="0.25", linewidths=0.3)
    ax.set(xticks=np.arange(len(features)), xticklabels=features,
           yticks=np.arange(len(groups)), yticklabels=groups,
           xlim=(-0.6, len(features) - 0.4), ylim=(len(groups) - 0.4, -0.6),
           xlabel="Feature", ylabel="Group")
    plt.setp(ax.get_xticklabels(), rotation=90, ha="center")
    for spine in ax.spines.values():
        spine.set_visible(False)
    ax.spines["top"].set_visible(True)
    ax.tick_params(length=0)
    color_ax = legend_ax.inset_axes([0.1, 0.58, 0.17, 0.36])
    fig.colorbar(points, cax=color_ax, label="Mean")
    handles = [Line2D([], [], marker="o", linestyle="", color="0.6",
                      markersize=np.sqrt(65 * value), label=f"{value:g}")
               for value in [0.1, 0.5, 1]]
    legend_ax.legend(handles=handles, title="Fraction (area)", loc="lower left",
                     labelspacing=1.1, borderaxespad=0)
    return fig


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


def plot_cohort_tracks(metadata, composition, *, style):
    """Use sample,age,batch,group and sample,component,fraction: aligned age-sorted tracks."""
    meta = metadata.sort_values(["age", "sample"], kind="stable").set_index("sample")
    components = sorted(composition["component"].unique())
    matrix = composition.pivot(index="sample", columns="component", values="fraction").reindex(
        index=meta.index, columns=components)
    palette = colors_for(components, style)
    fig = plt.figure(figsize=(6, 7), layout="constrained")
    grid = fig.add_gridspec(2, 5, height_ratios=[1.2, 6],
                            width_ratios=[0.24, 0.24, 0.24, 2.5, 1.35],
                            hspace=0.06, wspace=0.08)
    hist_ax = fig.add_subplot(grid[0, :4])
    hist_ax.hist(meta["age"], bins="auto", color="#A7D4D6", edgecolor="white", linewidth=0.3)
    hist_ax.set(xlabel="Age (years)", ylabel="Count")
    clean_axis(hist_ax, style)
    axes = [fig.add_subplot(grid[1, 0])]
    axes.extend(fig.add_subplot(grid[1, i], sharey=axes[0]) for i in range(1, 4))
    age_image = axes[0].imshow(meta[["age"]].to_numpy(), aspect="auto", cmap=style["age_cmap"],
                               interpolation="nearest")
    axes[0].set_ylabel("Samples (ordered by age)")
    axes[0].set_xticks([0], ["Age"], rotation=90)
    legend_handles = []
    for ax, field in zip(axes[1:3], ["batch", "group"]):
        labels = sorted(meta[field].unique())
        colors = colors_for(labels, style)
        codes = {label: i for i, label in enumerate(labels)}
        ax.imshow(meta[field].map(codes).to_numpy()[:, None], aspect="auto",
                  cmap=ListedColormap([colors[label] for label in labels]),
                  vmin=-0.5, vmax=len(labels) - 0.5, interpolation="nearest")
        ax.set_xticks([0], [field.capitalize()], rotation=90)
        legend_handles.extend(Patch(facecolor=colors[label], label=f"{field.capitalize()}: {label}")
                              for label in labels)
    for ax in axes[:3]:
        ax.tick_params(length=0, labelleft=False)
        for spine in ax.spines.values():
            spine.set_visible(False)
    left = np.zeros(len(meta))
    for component in components:
        axes[3].barh(np.arange(len(meta)), matrix[component], left=left,
                     color=palette[component], height=1, linewidth=0)
        left += matrix[component].to_numpy()
    axes[3].set(xlim=(0, 1), xlabel="Fraction")
    axes[3].tick_params(axis="y", left=False, labelleft=False)
    clean_axis(axes[3], style)
    legend_ax = fig.add_subplot(grid[1, 4])
    legend_ax.set_axis_off()
    legend_handles.extend(Patch(facecolor=palette[label], label=str(label)) for label in components)
    legend_ax.legend(handles=legend_handles, title="Annotations / component", loc="center left",
                     borderaxespad=0)
    color_ax = legend_ax.inset_axes([0.05, 0.88, 0.75, 0.025])
    fig.colorbar(age_image, cax=color_ax, orientation="horizontal", label="Age (years)")
    return fig
