"""Compare effect estimates and confidence intervals across multiple groups. Read the bundled simulated data and generate PNG, PDF, and SVG outputs."""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib import pyplot as plt
from matplotlib import ticker
from plot_style import clean_axis


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


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_forest, ['forest'], 'effect_estimate_forest', output)
