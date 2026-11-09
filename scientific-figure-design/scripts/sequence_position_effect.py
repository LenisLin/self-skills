"""展示序列位置及碱基效应。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib import pyplot as plt
from matplotlib.colors import TwoSlopeNorm
from plot_style import clean_axis


def plot_sequence_effect(sequence, *, style):
    """Return aligned signed-effect logo, four-base lines and effect heatmap.

    Required: position (consecutive integer bp),base (A/C/G/T),effect, one per pair.
    All tracks display the same supplied effects; logo stacks signed letters,
    lines encode base identity by color, heatmap uses a zero-centered scale.
    """
    import logomaker

    matrix = sequence.pivot(index='position', columns='base', values='effect')
    matrix = matrix.sort_index().reindex(columns=['A', 'C', 'G', 'T'])
    positions = matrix.index.to_numpy()
    if not (np.all(positions == positions.astype(int)) and np.all(np.diff(positions) == 1)):
        raise ValueError('Sequence positions must be consecutive integer base-pair coordinates.')
    base_colors = {'A': '#367E43', 'C': '#2655A6', 'G': '#F99C31', 'T': '#EE2C28'}
    fig, axes = plt.subplots(3, 1, figsize=(7.2, 3.4), sharex=True,
                             height_ratios=[1, 1, 0.8], layout='constrained')
    logomaker.Logo(matrix.copy(), ax=axes[0], color_scheme=base_colors,
                   flip_below=False, shade_below=0, fade_below=0,
                   **({'font_name': style['font_family']} if 'typography' in style else {}))
    axes[0].set_ylabel('Effect')
    for base, color in base_colors.items():
        axes[1].plot(matrix.index, matrix[base], color=color, label=base, lw=0.7)
    axes[1].set_ylabel('Effect')
    axes[1].legend(ncol=4, loc='upper right', handlelength=1.2,
                   columnspacing=0.8, borderaxespad=0.2)
    limit = max(float(np.abs(matrix.to_numpy()).max()), 1e-12)
    norm = TwoSlopeNorm(vmin=-limit, vcenter=0, vmax=limit)
    image = axes[2].imshow(matrix.to_numpy().T, origin='upper', aspect='auto',
                           interpolation='nearest', cmap=style['diverging_cmap'],
                           norm=norm,
                           extent=(matrix.index.min() - 0.5,
                                   matrix.index.max() + 0.5, 3.5, -0.5))
    axes[2].set_yticks(range(4), ['A', 'C', 'G', 'T'])
    for tick, color in zip(axes[2].get_yticklabels(), base_colors.values()):
        tick.set_color(color)
    for ax in axes:
        if positions.min() <= 0 <= positions.max():
            ax.axvline(0, color='#F385A3', ls='--', lw=0.6)
        clean_axis(ax, style)
    for ax in axes[:2]:
        ax.axhline(0, color='0.6', lw=0.4, zorder=0)
    axes[-1].set(xlabel='Position (bp)',
                 xlim=(matrix.index.min() - 0.5, matrix.index.max() + 0.5))
    fig.colorbar(image, ax=axes[2], label='Effect', fraction=0.025, pad=0.02)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_sequence_effect, ['sequence'], 'sequence_position_effect', output)
