"""Show the relationship between two continuous variables. Read the bundled simulated data and generate PNG, PDF, and SVG outputs."""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib import pyplot as plt
from scipy.stats import linregress, t
from plot_style import clean_axis


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


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_regression_scatter, ['scatter'], 'continuous_association_regression', output)
