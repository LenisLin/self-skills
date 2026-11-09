"""比较两套效应及各自的不确定性。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from scipy import stats
from plot_style import clean_axis, colors_for, new_axes


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


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_effect_errorbar, ['effect_pairs'], 'two_axis_effect_uncertainty', output)
