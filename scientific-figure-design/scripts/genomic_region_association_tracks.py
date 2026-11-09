"""比较同一区间的多组关联结果。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib import pyplot as plt
from matplotlib.cm import ScalarMappable
from matplotlib.colors import Normalize
from plot_style import clean_axis, sequential_cmap, text_label


def plot_regional_association(locus, *, style):
    """Return three aligned association tracks from supplied P values.

    Required: variant,position (bp),p_value,track,ld. Position is displayed
    in Mb, y is -log10(P), color is LD; the lowest input P defines one shared
    lead-position line across Trait, Expression and Accessibility tracks.
    """
    fig, axes = plt.subplots(3, 1, figsize=(5.2, 4.5), sharex=True,
                             layout='constrained')
    lead_position = locus.loc[locus['p_value'].idxmin(), 'position'] / 1e6
    norm = Normalize(0, 1)
    cmap = sequential_cmap(style)
    for ax, track in zip(axes, ['Trait', 'Expression', 'Accessibility']):
        part = locus.loc[locus['track'] == track].sort_values('position')
        ax.scatter(part['position'] / 1e6, -np.log10(part['p_value']),
                    c=part['ld'], cmap=cmap, norm=norm, s=6,
                    linewidths=0.5 if track == 'Accessibility' else 0,
                    marker='x' if track == 'Accessibility' else 'o')
        ax.axvline(lead_position, color='#D789AE', alpha=0.7, lw=2.5, zorder=0)
        ax.set_ylabel(text_label('−log10(P)', style))
        ax.text(0.01, 0.95, track, transform=ax.transAxes, va='top',
                fontsize=style['label_size'])
        ax.set_ylim(bottom=0)
        ax.margins(y=0.22)
        clean_axis(ax, style)
    axes[-1].set_xlabel('Position (Mb)')
    fig.colorbar(ScalarMappable(norm=norm, cmap=cmap), ax=axes, label='LD',
                 fraction=0.025, pad=0.02)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_regional_association, ['locus'], 'genomic_region_association_tracks', output)
