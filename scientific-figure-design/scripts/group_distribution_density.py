"""Compare value distributions and shifts across groups. Read the bundled simulated data and generate PNG, PDF, and SVG outputs."""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib import pyplot as plt
from scipy.integrate import trapezoid
from scipy.stats import gaussian_kde
from plot_style import clean_axis, colors_for


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


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_density, ['groups'], 'group_distribution_density', output)
