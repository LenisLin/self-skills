"""比较组间分布形状与多峰。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from scipy.integrate import trapezoid
from scipy.stats import gaussian_kde
from plot_style import new_axes, clean_axis


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


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_violin, ['groups'], 'group_distribution_violin', output)
