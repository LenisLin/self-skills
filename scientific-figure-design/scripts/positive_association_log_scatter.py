"""Compare two positive variables spanning orders of magnitude. Read the bundled simulated data and generate PNG, PDF, and SVG outputs."""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib.lines import Line2D
from scipy.stats import linregress
from plot_style import new_axes, clean_axis


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


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_log_scatter, ['log_scatter'], 'positive_association_log_scatter', output)
