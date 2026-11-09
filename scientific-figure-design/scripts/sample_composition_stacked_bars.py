"""比较各样本的细胞或成分比例。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from plot_style import new_axes, clean_axis, colors_for


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


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_composition_bars, ['composition'], 'sample_composition_stacked_bars', output)
