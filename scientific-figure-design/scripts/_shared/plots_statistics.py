"""Reusable statistical-result plots with CIMA-inspired visual styling.

CRLM code informs the KM, forest, volcano, pathway and GSEA layouts. Science
Fig. 5F and Fig. 6D provide visual references for effects and ROC respectively.
The renderers use the supplied estimates and observations.
"""

import numpy as np
from matplotlib import pyplot as plt
from matplotlib import ticker
from scipy import stats
from sklearn.metrics import auc, roc_curve

from plot_style import clean_axis, colors_for, new_axes, sequential_cmap, text_label


def plot_km(curves, censors, risk, *, style):
    """Plot prepared KM tables; derive groups/times and use style['time_label']."""
    groups = curves["group"].drop_duplicates().tolist()
    fig, (ax, ax_risk) = plt.subplots(2, 1, figsize=(4.1, 2.9 + 0.2 * len(groups)), sharex=True,
        gridspec_kw={"height_ratios": [3.2, max(0.8, 0.22 * len(groups))]}, layout="constrained")
    example_colors = {"A-low": style["colors"]["blue"], "A-high": style["colors"]["dark_blue"],
                      "B-low": style["colors"]["pink"], "B-high": style["colors"]["red"]}
    palette = colors_for(groups, style)
    palette.update({g: example_colors[g] for g in groups if g in example_colors})
    for index, group in enumerate(groups):
        part = curves.loc[curves.group == group].sort_values("time")
        color = palette[group]
        ax.fill_between(part.time, part.lower, part.upper, step="post", color=color, alpha=0.14, linewidth=0)
        ax.step(part.time, part.survival, where="post", color=color, label=group, linewidth=0.85)
        censored = censors.loc[censors.group == group]
        ax.scatter(censored.time, censored.survival, marker="+", s=9, linewidths=0.5, color=color)
        counts = risk.loc[risk.group == group]
        for row in counts.itertuples():
            ax_risk.text(row.time, index, str(row.n_risk), color=color, ha="center", va="center", fontsize=style["tick_size"])
    ax.set(ylabel="Event-free survival", ylim=(0, 1.03))
    ax.legend(loc="upper right", ncol=2, handlelength=1.3, columnspacing=0.7, frameon=False)
    horizon = max(curves["time"].max(), censors["time"].max(), risk["time"].max())
    padding = max(0.5, horizon * 0.015)
    ax_risk.set(yticks=range(len(groups)), yticklabels=groups,
                ylim=(len(groups) - 0.5, -0.5), xlabel=style["time_label"],
                xticks=sorted(risk["time"].unique()), xlim=(-padding, horizon + padding))
    ax_risk.set_title("Number at risk", loc="left", fontsize=style["tick_size"], pad=4)
    ax_risk.spines[["left", "top", "right"]].set_visible(False)
    ax_risk.tick_params(axis="y", length=0, pad=8)
    clean_axis(ax, style)
    return fig


def plot_forest(estimates, *, style):
    """Plot term/estimate/lower/upper/p_value as log-HR geometry and aligned text."""
    frame = estimates.reset_index(drop=True)
    fig, (terms, ax, table) = plt.subplots(1, 3, figsize=(6.3, max(2.4, 0.28 * len(frame) + 0.9)), sharey=True,
        gridspec_kw={"width_ratios": [1.1, 1.45, 1.3], "wspace": 0.04}, layout="constrained")
    y = np.arange(len(frame))
    terms.set(xlim=(0, 1), ylim=(len(frame) - 0.5, -1.1))
    terms.axis("off")
    terms.text(0, -0.75, "Model term", weight="bold", fontsize=style["tick_size"])
    for i, term in enumerate(frame.term):
        terms.text(0, i, str(term), va="center", fontsize=style["tick_size"])
    ax.axvline(1, color="0.6", linestyle="--", linewidth=0.55)
    ax.errorbar(frame.estimate, y,
        xerr=np.vstack([frame.estimate - frame.lower, frame.upper - frame.estimate]),
        fmt="s", markersize=3.6, color=style["colors"]["dark_blue"], elinewidth=0.7, capsize=2)
    ax.set(xscale="log", xlabel="Hazard ratio", yticks=[])
    ax.set_xlim(2 ** np.floor(np.log2(min(frame.lower.min(), 1) / 1.05)),
                2 ** np.ceil(np.log2(max(frame.upper.max(), 1) * 1.05)))
    ax.xaxis.set_major_locator(ticker.LogLocator(base=2))
    ax.xaxis.set_major_formatter(ticker.FuncFormatter(lambda value, pos: f"{value:g}"))
    ax.xaxis.set_minor_formatter(ticker.NullFormatter())
    table.set(xlim=(0, 1))
    table.axis("off")
    table.text(0, -0.75, "HR (95% CI)", weight="bold", fontsize=style["tick_size"])
    table.text(0.78, -0.75, "P value", weight="bold", fontsize=style["tick_size"])
    for i, row in enumerate(frame.itertuples()):
        table.text(0, i, f"{row.estimate:.2f} ({row.lower:.2f}–{row.upper:.2f})", va="center", fontsize=style["tick_size"])
        p_label = f"{row.p_value:.3f}" if row.p_value >= 0.001 else "<0.001"
        table.text(0.78, i, p_label, va="center", fontsize=style["tick_size"])
    clean_axis(ax, style)
    ax.spines["left"].set_visible(False)
    return fig


def plot_effect_errorbar(effects, *, style):
    """Encode beta_x/beta_y with 1.96*se_x and 1.96*se_y two-sided intervals."""
    fig, ax = new_axes(3.0, 3.2)
    palette = colors_for(sorted(effects.group.unique()), style)
    for group, part in effects.groupby("group", sort=True):
        ax.errorbar(part.beta_x, part.beta_y, xerr=1.96 * part.se_x, yerr=1.96 * part.se_y,
            fmt="o", markersize=2, color=palette[group], elinewidth=0.45, capsize=0, label=group)
    fit = stats.linregress(effects.beta_x, effects.beta_y)
    x = np.array([effects.beta_x.min(), effects.beta_x.max()])
    ax.plot(x, fit.intercept + fit.slope * x, "--", color=style["colors"]["red"], linewidth=0.65)
    ax.set(xlabel="Effect A (95% CI)", ylabel="Effect B (95% CI)")
    ax.legend(loc="upper right", title="Group", handlelength=1, frameon=False)
    clean_axis(ax, style)
    return fig


def plot_roc(scores, *, style):
    """Compute threshold/FPR/TPR and AUROC from each model's label/score vectors."""
    fig, ax = new_axes(3.3, 3.15)
    palette = colors_for(sorted(scores.model.unique()), style)
    for model, part in scores.groupby("model", sort=True):
        fpr, tpr, _ = roc_curve(part.label, part.score)
        ax.plot(fpr, tpr, color=palette[model], label=f"{model}: {auc(fpr, tpr):.3f}", linewidth=0.9)
    ax.plot([0, 1], [0, 1], "--", color=style["colors"]["dark_blue"], linewidth=0.55, dashes=(3, 4))
    ax.set(xlabel="False positive rate", ylabel="True positive rate",
           xlim=(0, 1), ylim=(0, 1), xticks=np.linspace(0, 1, 6), yticks=np.linspace(0, 1, 6))
    ax.set_title("AUROC", fontsize=style["label_size"], pad=3)
    ax.set_aspect("equal", adjustable="box")
    ax.legend(loc="lower right", handlelength=1.2, frameon=True, facecolor="white", edgecolor="0.65")
    clean_axis(ax, style)
    return fig


def plot_volcano(results, *, style):
    """Encode feature effect and -log10(q_value); q<0.05 colors the direction."""
    fig, ax = new_axes(3.65, 2.8)
    q = results.q_value.to_numpy()
    significant = q < 0.05
    palette = np.full(len(results), style["colors"]["neutral"], dtype=object)
    palette[significant & (results.effect.to_numpy() > 0)] = style["colors"]["red"]
    palette[significant & (results.effect.to_numpy() < 0)] = style["colors"]["dark_blue"]
    y = -np.log10(np.maximum(q, np.finfo(float).tiny))
    ax.scatter(results.effect, y, c=palette, s=4, alpha=0.6, linewidths=0, rasterized=True)
    ax.axhline(-np.log10(0.05), color="0.55", linestyle="--", linewidth=0.55)
    ax.axvline(0, color="0.7", linestyle="--", linewidth=0.45)
    label_counts = {-1: 0, 1: 0}
    for index in np.argsort(q):
        if not significant[index]:
            break
        side = 1 if results.effect.iloc[index] >= 0 else -1
        if label_counts[side] >= 2:
            continue
        ax.annotate(results.feature.iloc[index], (results.effect.iloc[index], y[index]),
            xytext=(0.98 if side == 1 else 0.02, 0.96 - label_counts[side] * 0.085),
            textcoords="axes fraction", ha="right" if side == 1 else "left", fontsize=5.5,
            arrowprops={"arrowstyle": "-", "color": "0.45", "linewidth": 0.35})
        label_counts[side] += 1
        if all(count == 2 for count in label_counts.values()):
            break
    ax.set(xlabel="Effect estimate", ylabel=text_label("−log10(BH q)", style))
    clean_axis(ax, style)
    return fig


def plot_pathway_bubble(pathways, *, style):
    """Encode pathway score, set size as area and -log10(q_value) as color."""
    frame = pathways.sort_values("score").reset_index(drop=True)
    fig, ax = new_axes(4.8, max(3.0, 0.19 * len(frame) + 0.8))
    values = -np.log10(np.maximum(frame.q_value.to_numpy(), np.finfo(float).tiny))
    scatter = ax.scatter(frame.score, np.arange(len(frame)), s=frame["size"] * 0.7,
        c=values, cmap=sequential_cmap(style), vmin=0, edgecolors="0.5", linewidths=0.25)
    ax.set(yticks=range(len(frame)), yticklabels=frame.pathway, xlabel="Enrichment score")
    ax.axvline(0, color="0.7", linewidth=0.55, linestyle="--")
    fig.colorbar(scatter, ax=ax, label=text_label("−log10(BH q)", style), fraction=0.055, pad=0.03)
    sizes = np.unique(np.quantile(frame["size"], [0, 0.5, 1]))
    handles = [ax.scatter([], [], s=n * 0.7, c="0.55", linewidths=0, label=f"{n:g}") for n in sizes]
    ax.legend(handles=handles, title="Set size", loc="upper center", bbox_to_anchor=(0.5, -0.24),
              ncol=len(sizes), borderpad=0.2, columnspacing=1, frameon=False)
    clean_axis(ax, style)
    return fig


def plot_gsea(ranked, *, style):
    """Draw prepared rank/running_score, hit positions and rank metric on shared x."""
    frame = ranked.sort_values("rank")
    fig, axes = plt.subplots(3, 1, figsize=(3.8, 3.1), sharex=True,
        gridspec_kw={"height_ratios": [2.6, 0.4, 1.1], "hspace": 0.04}, layout="constrained")
    axes[0].plot(frame["rank"], frame.running_score,
                 color=style["colors"]["dark_blue"], linewidth=0.85)
    axes[0].axhline(0, color="0.6", linewidth=0.5)
    peak = frame.iloc[np.argmax(np.abs(frame.running_score.to_numpy()))]
    axes[0].text(0.98, 0.92, f"ES = {peak.running_score:.2f}", transform=axes[0].transAxes,
                 ha="right", va="top", fontsize=6)
    axes[0].set_ylabel("Running score")
    axes[1].vlines(frame.loc[frame.hit, "rank"], 0, 1, color="0.2", linewidth=0.4)
    axes[1].set(yticks=[], ylabel="Hits", ylim=(0, 1))
    axes[1].spines[["left", "bottom", "top", "right"]].set_visible(False)
    axes[1].tick_params(axis="x", length=0)
    for mask, color in [(frame.metric >= 0, style["colors"]["red"]),
                         (frame.metric < 0, style["colors"]["dark_blue"])]:
        axes[2].fill_between(frame["rank"], frame.metric, 0, where=mask, color=color, alpha=0.4)
    axes[2].set(xlabel="Rank of feature", ylabel="Rank metric", xlim=(frame["rank"].min(), frame["rank"].max()))
    clean_axis(axes[0], style)
    clean_axis(axes[2], style)
    return fig
