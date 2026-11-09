"""Reusable distribution and composition figures from contracted long tables.

Return Matplotlib Figures; the caller applies rc style and exports figures.
The registered author snippets inform selected geometries; the published panels
provide visual references. No source script runs.
"""

import numpy as np
from matplotlib import pyplot as plt
from matplotlib.lines import Line2D
from matplotlib.colors import LinearSegmentedColormap
from scipy.integrate import trapezoid
from scipy.stats import gaussian_kde, linregress, mannwhitneyu, t

from plot_style import new_axes, clean_axis, colors_for


def _bounded_density(values, *, fraction_support):
    """Estimate a density on fraction support or on the observed value range."""
    kde = gaussian_kde(values)
    if fraction_support:
        grid = np.linspace(0, 1, 256)
        density = kde(grid) + kde(-grid) + kde(2 - grid)
    else:
        padding = np.sqrt(kde.covariance[0, 0]) * 3
        grid = np.linspace(np.min(values) - padding, np.max(values) + padding, 256)
        density = kde(grid)
    return grid, density / trapezoid(density, grid)


def _boxes(ax, values, positions, palette, *, horizontal=False, width=0.45, showfliers=False):
    """Draw thin colored boxes, optionally showing Tukey outliers."""
    boxes = ax.boxplot(values, positions=positions, widths=width,
                       orientation="horizontal" if horizontal else "vertical",
                       patch_artist=True, showfliers=showfliers,
                       medianprops={"color": "black", "linewidth": 0.7},
                       whiskerprops={"linewidth": 0.55},
                       capprops={"linewidth": 0.55},
                       flierprops={"marker": ".", "markersize": 1.8,
                                   "markeredgecolor": "0.4"})
    for patch, color in zip(boxes["boxes"], palette):
        patch.set(facecolor=color, edgecolor="0.3" if color == "white" else color,
                  alpha=0.6, linewidth=0.6)


def plot_box_jitter(groups, *, style):
    """Use group,value and optional facet: boxes and individual observations."""
    groups = groups.dropna(subset=["group", "value"])
    labels = sorted(groups["group"].unique())
    palette = colors_for(labels, style)
    facets = list(groups["facet"].drop_duplicates()) if "facet" in groups else [None]
    fig, axes = plt.subplots(1, len(facets), figsize=(2.0 * len(facets) + 0.5, 2.6),
                             layout="constrained", squeeze=False)
    rng = np.random.default_rng(20261105)
    for facet, ax in zip(facets, axes[0]):
        subset = groups if facet is None else groups.loc[groups["facet"] == facet]
        present = [label for label in labels if (subset["group"] == label).any()]
        values = [subset.loc[subset["group"] == label, "value"].dropna().to_numpy()
                  for label in present]
        positions = np.arange(len(present))
        _boxes(ax, values, positions, [palette[label] for label in present])
        for position, label, data in zip(positions, present, values):
            ax.scatter(position + rng.uniform(-0.17, 0.17, len(data)), data,
                       s=style["marker_size"], color=palette[label],
                       alpha=style["alpha"], linewidths=0, zorder=3)
        ax.set(xticks=positions, xticklabels=present, xlabel="Group", ylabel="Value")
        if facet is not None:
            ax.set_title(str(facet))
        if style.get("show_group_test", False) and len(values) == 2:
            result = mannwhitneyu(values[0], values[1], alternative="two-sided")
            annotation = f"Mann–Whitney P = {result.pvalue:.2g}"
            text_style = {"fontsize": style["tick_size"]}
            significance = style.get("typography", {}).get("boxplot_significance", {})
            if significance.get("display") == "stars":
                annotation = next(
                    (level["label"] for level in sorted(
                        significance["thresholds"], key=lambda level: level["p_less_than"])
                     if result.pvalue < level["p_less_than"]),
                    significance["nonsignificant_label"])
                text_style.update(fontsize=significance.get("font_size", style["tick_size"]),
                                  fontweight=significance.get("font_weight", "normal"))
            ax.text(0.5, 0.98, annotation,
                    transform=ax.transAxes, ha="center", va="top", **text_style,
                    bbox={"facecolor": "white", "edgecolor": "none", "alpha": 0.85, "pad": 0.8})
        clean_axis(ax, style)
    return fig


def plot_violin(groups, *, style):
    """Use group,value: density silhouettes and inner quartiles.

    Values within [0,1] use the contracted fraction support for boundary correction.
    """
    groups = groups.dropna(subset=["group", "value"])
    labels = sorted(groups["group"].unique())
    fig, ax = new_axes()
    color = style["colors"]["dark_blue"]
    fraction_support = groups["value"].dropna().between(0, 1).all()
    for i, label in enumerate(labels):
        data = groups.loc[groups["group"] == label, "value"].dropna().to_numpy()
        if len(data) >= 2 and np.ptp(data) > 0:
            grid, density = _bounded_density(data, fraction_support=fraction_support)
            half_width = 0.38 * density / density.max()
            ax.fill_betweenx(grid, i - half_width, i + half_width,
                             facecolor=color, edgecolor=color,
                             alpha=0.35, linewidth=style["line_width"])
        q1, median, q3 = np.quantile(data, [0.25, 0.5, 0.75])
        ax.plot([i, i], [q1, q3], color=color, linewidth=3, solid_capstyle="round")
        ax.scatter(i, median, s=7, color="white", zorder=3, linewidths=0)
    ax.set(xticks=np.arange(len(labels)), xticklabels=labels,
           xlabel="Group", ylabel="Value")
    clean_axis(ax, style)
    return fig


def plot_density(groups, *, style):
    """Use group,value: densities and medians, with fraction boundary correction."""
    groups = groups.dropna(subset=["group", "value"])
    labels = sorted(groups["group"].unique())
    palette = colors_for(labels, style)
    fig, axes = plt.subplots(len(labels), 1, figsize=(2.6, max(2.6, len(labels) * 0.8)), sharex=True,
                             layout="constrained", squeeze=False)
    fraction_support = groups["value"].dropna().between(0, 1).all()
    for label, ax in zip(labels, axes[:, 0]):
        data = groups.loc[groups["group"] == label, "value"].dropna().to_numpy()
        if len(data) >= 2 and np.ptp(data) > 0:
            grid, density = _bounded_density(data, fraction_support=fraction_support)
            ax.fill_between(grid, density, color=palette[label], alpha=0.24)
            ax.plot(grid, density, color=palette[label], label=label, linewidth=0.9)
        else:
            ax.text(0.02, 0.85, "KDE unavailable", transform=ax.transAxes)
        ax.axvline(np.median(data), color=palette[label], linewidth=0.6, linestyle=":")
        ax.set(ylim=(0, None), ylabel="Density")
        ax.text(0.98, 0.85, str(label), color=palette[label], ha="right", transform=ax.transAxes)
        clean_axis(ax, style)
    axes[-1, 0].set_xlabel("Value")
    return fig


def plot_histogram(groups, *, style):
    """Use group,value: within-group probability density in 20 shared bins."""
    groups = groups.dropna(subset=["group", "value"])
    labels = sorted(groups["group"].unique())
    palette = colors_for(labels, style)
    fig, ax = new_axes()
    bins = np.histogram_bin_edges(groups["value"].dropna(), bins=20)
    for label in labels:
        ax.hist(groups.loc[groups["group"] == label, "value"],
                bins=bins, density=True, histtype="step",
                color=palette[label], linewidth=0.9, label=label)
    ax.set(xlabel="Value", ylabel="Probability density")
    ax.legend(title="Group")
    clean_axis(ax, style)
    return fig


def plot_regression_scatter(scatter, *, style):
    """Use x,y and optional facet or group: per-panel OLS and pointwise 95% CI."""
    column = "facet" if "facet" in scatter else "group" if "group" in scatter else None
    facets = list(scatter[column].drop_duplicates()) if column else [None]
    fig, axes = plt.subplots(1, len(facets), figsize=(2.1 * len(facets), 2.4),
                             layout="constrained", squeeze=False, sharex=True, sharey=True)
    for facet, ax in zip(facets, axes[0]):
        subset = scatter if column is None else scatter.loc[scatter[column] == facet]
        data = subset[["x", "y"]].dropna()
        x, y = data["x"].to_numpy(), data["y"].to_numpy()
        ax.scatter(x, y, s=style["marker_size"] * 0.65, color=style["colors"]["scatter"],
                   alpha=style["alpha"], linewidths=0)
        if len(x) >= 3 and np.ptp(x) > 0 and np.ptp(y) > 0:
            fit = linregress(x, y)
            grid = np.linspace(x.min(), x.max(), 200)
            prediction = fit.intercept + fit.slope * grid
            residual = y - (fit.intercept + fit.slope * x)
            variance = np.sum(residual ** 2) / (len(x) - 2)
            mean_se = np.sqrt(variance * (1 / len(x) +
                              (grid - x.mean()) ** 2 / np.sum((x - x.mean()) ** 2)))
            interval = t.ppf(0.975, len(x) - 2) * mean_se
            ax.fill_between(grid, prediction - interval, prediction + interval,
                            color=style["colors"]["scatter"], alpha=0.25, linewidth=0)
            ax.plot(grid, prediction, color=style["colors"]["dark_blue"], linewidth=0.8)
            ax.text(0.05, 0.96, f"r = {fit.rvalue:.2f}\nP = {fit.pvalue:.2g}",
                    transform=ax.transAxes, va="top",
                    fontsize=style.get("typography", {}).get("annotation_size", style["font_size"]))
        if facet is not None:
            ax.set_title(str(facet))
        ax.set(xlabel="x", ylabel="y")
        clean_axis(ax, style)
    return fig


def plot_log_scatter(log_scatter, *, style):
    """Use positive x,y,size and color: log axes, area=size, color=continuous."""
    fig, ax = new_axes(5, 2.6)
    area_scale = 65 / log_scatter["size"].max()
    points = ax.scatter(log_scatter["x"], log_scatter["y"],
                        s=area_scale * log_scatter["size"],
                        c=log_scatter["color"], cmap=style["log_scatter_cmap"],
                        alpha=0.75, linewidths=0)
    data = log_scatter[["x", "y"]].dropna()
    x, y = np.log10(data["x"].to_numpy()), np.log10(data["y"].to_numpy())
    if len(x) >= 3 and np.ptp(x) > 0 and np.ptp(y) > 0:
        fit = linregress(x, y)
        grid = np.linspace(x.min(), x.max(), 200)
        ax.plot(10 ** grid, 10 ** (fit.intercept + fit.slope * grid),
                color=style["colors"]["dark_blue"], linewidth=0.7)
        ax.text(0.04, 0.96, f"log Pearson r = {fit.rvalue:.2f}\nP = {fit.pvalue:.2g}",
                transform=ax.transAxes, va="top",
                fontsize=style.get("typography", {}).get("annotation_size", style["font_size"]))
    fig.colorbar(points, ax=ax, label="Color value", fraction=0.05, pad=0.03)
    levels = np.quantile(log_scatter["size"], [0.1, 0.5, 0.9])
    handles = [Line2D([], [], linestyle="", marker="o", color="0.5",
                      markersize=np.sqrt(area_scale * value), label=f"{value:.2g}")
               for value in levels]
    ax.legend(handles=handles, title="Size (area)", loc="upper left",
              bbox_to_anchor=(1.28, 1), borderaxespad=0, labelspacing=1)
    ax.set(xscale="log", yscale="log", xlabel="x (log scale)", ylabel="y (log scale)")
    clean_axis(ax, style)
    return fig


def plot_lollipop(category_values, *, style):
    """Use category,left: sorted horizontal stems ending at observed values."""
    data = category_values.sort_values("left", kind="stable")
    labels = data["category"].tolist()
    fig, ax = new_axes(4.5, max(2.6, len(data) * 0.22))
    positions = np.arange(len(data))
    ax.hlines(positions, 0, data["left"], color="0.25", linewidth=0.6)
    ax.scatter(data["left"], positions, s=12, color="black", linewidths=0, zorder=3)
    ax.set(yticks=positions, yticklabels=labels, xlabel="Left value", ylabel="Category")
    ax.axvline(0, color="0.5", linewidth=0.5)
    clean_axis(ax, style)
    return fig


def _mirror_axes(labels, style):
    """Reserve a center column for labels between matched mirrored axes."""
    fig = plt.figure(figsize=(6.8, max(2.6, len(labels) * 0.23)), layout="constrained")
    center_width = max(1.0, max(len(str(label)) for label in labels) * 0.055)
    grid = fig.add_gridspec(1, 3, width_ratios=[2, center_width, 2], wspace=0.04)
    left = fig.add_subplot(grid[0, 0])
    center = fig.add_subplot(grid[0, 1], sharey=left)
    right = fig.add_subplot(grid[0, 2], sharey=left)
    for i, label in enumerate(labels):
        center.text(0.5, i, str(label), ha="center", va="center")
    center.set(xlim=(0, 1), ylim=(len(labels) - 0.5, -0.5))
    center.set_axis_off()
    for ax in (left, right):
        ax.tick_params(axis="y", left=False, labelleft=False)
        clean_axis(ax, style)
        for spine in ax.spines.values():
            spine.set_visible(True)
    return fig, left, right


def plot_mirrored_bars(category_values, *, style):
    """Use category,left,right: matched scales with central category labels."""
    labels = category_values["category"].tolist()
    fig, left, right = _mirror_axes(labels, style)
    positions = np.arange(len(labels))
    low = min(0, category_values[["left", "right"]].to_numpy().min() * 1.08)
    limit = max(0, category_values[["left", "right"]].to_numpy().max() * 1.08)
    left.barh(positions, category_values["left"], color=style["colors"]["mirror_left"], height=0.7)
    right.barh(positions, category_values["right"], color=style["colors"]["mirror_right"], height=0.7)
    left.set(xlim=(limit, low), xlabel="Left value", title="Left")
    right.set(xlim=(low, limit), xlabel="Right value", title="Right")
    left.title.set_color(style["colors"]["mirror_left"])
    right.title.set_color(style["colors"]["mirror_right"])
    return fig


def plot_mirrored_boxes(paired, *, style):
    """Use category,side,value: Left/Right distributions on matched mirrored axes."""
    labels = sorted(paired["category"].unique())
    fig, left, right = _mirror_axes(labels, style)
    limit = max(0, paired["value"].max() * 1.08)
    low = min(0, paired["value"].min() * 1.08)
    positions = np.arange(len(labels))
    for ax, side, color in [(left, "Left", style["colors"]["mirror_left"]),
                             (right, "Right", style["colors"]["mirror_right"])]:
        values = [paired.loc[(paired["category"] == label) &
                             (paired["side"] == side), "value"].to_numpy()
                  for label in labels]
        _boxes(ax, values, positions, [color] * len(labels), horizontal=True)
        # All observations include outliers hidden by the box layer.
        rng = np.random.default_rng(20261105)
        for position, data in zip(positions, values):
            ax.scatter(data, position + rng.uniform(-0.15, 0.15, len(data)),
                       s=4, color=color, alpha=0.4, linewidths=0)
        ax.set(xlabel=f"{side} value", title=side, ylim=(len(labels) - 0.5, -0.5))
        ax.title.set_color(color)
    left.set_xlim(limit, low)
    right.set_xlim(low, limit)
    return fig


def plot_pie(composition, *, style):
    """Use component,count: outside labels for count-weighted sectors."""
    counts = composition.groupby("component", sort=True, observed=True)["count"].sum()
    palette = colors_for(counts.index, style)
    fig, ax = new_axes(5.5, max(2.8, len(counts) * 0.3))
    wedges, _ = ax.pie(counts, colors=[palette[k] for k in counts.index],
                       startangle=90, counterclock=False,
                       wedgeprops={"edgecolor": "white", "linewidth": 0.6})
    for side in (-1, 1):
        entries = []
        for wedge, (label, value) in zip(wedges, counts.items()):
            angle = np.deg2rad((wedge.theta1 + wedge.theta2) / 2)
            x, y = np.cos(angle), np.sin(angle)
            if (x >= 0) == (side > 0):
                entries.append((y, x, label, value, wedge.get_facecolor()))
        entries.sort()
        for text_y, (y, x, label, value, color) in zip(
                np.linspace(-1.05, 1.05, len(entries)), entries):
            ax.annotate(f"{label} {100 * value / counts.sum():.1f}%",
                        xy=(x, y), xytext=(side * 1.4, text_y),
                        ha="left" if side > 0 else "right", va="center", color=color,
                        arrowprops={"arrowstyle": "-", "color": color, "lw": 0.6,
                                    "connectionstyle": "angle,angleA=0,angleB=90"})
    ax.set_title("Distribution of components")
    ax.set_aspect("equal")
    return fig


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


def plot_composition_bars(composition, *, style):
    """Use sample,component,fraction: original fractions stacked per sample."""
    samples = composition["sample"].drop_duplicates()
    components = sorted(composition["component"].unique())
    matrix = composition.pivot(index="sample", columns="component", values="fraction").reindex(
        index=samples, columns=components)
    palette = colors_for(components, style)
    fig, ax = new_axes(max(6.8, len(samples) * 0.07), 2.4)
    bottom = np.zeros(len(samples))
    for component in components:
        ax.bar(np.arange(len(samples)), matrix[component], bottom=bottom,
               width=1, color=palette[component], linewidth=0, label=component)
        bottom += matrix[component].to_numpy()
    ticks = np.arange(0, len(samples), max(1, len(samples) // 8))
    ax.set(xticks=ticks, xticklabels=samples.iloc[ticks],
           xlim=(-0.5, len(samples) - 0.5), xlabel="Sample", ylabel="Fraction")
    ax.tick_params(axis="x", labelrotation=60)
    ax.legend(title="Component", loc="center left", bbox_to_anchor=(1, 0.5))
    clean_axis(ax, style)
    return fig


def plot_metric_boxes(metrics, *, style):
    """Use group,replicate,value: boxes ordered by observed group median."""
    labels = metrics.groupby("group", observed=True)["value"].median().sort_values(
        ascending=False, kind="stable").index.tolist()
    palette = colors_for(labels, style)
    values = [metrics.loc[metrics["group"] == label, "value"].to_numpy()
              for label in labels]
    fig, ax = new_axes(max(5.5, len(labels) * 0.35), 2.5)
    positions = np.arange(len(labels))
    _boxes(ax, values, positions, [palette[label] for label in labels], showfliers=True)
    ax.set(xticks=positions, xticklabels=labels,
           xlabel="Group", ylabel="Performance value")
    plt.setp(ax.get_xticklabels(), rotation=40, ha="right")
    for tick, label in zip(ax.get_xticklabels(), labels):
        tick.set_color(palette[label])
    clean_axis(ax, style)
    return fig
