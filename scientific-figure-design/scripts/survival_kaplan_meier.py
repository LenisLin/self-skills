"""Compare event times and survival probabilities across groups. Read the bundled simulated data and generate PNG, PDF, and SVG outputs."""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

from matplotlib import pyplot as plt
from plot_style import clean_axis, colors_for


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


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_km, ['km_curve', 'km_censors', 'km_risk'], 'survival_kaplan_meier', output)
