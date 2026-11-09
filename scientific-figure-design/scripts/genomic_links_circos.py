"""Show chromosomal positions and connections across intervals. Read the bundled simulated data and generate PNG, PDF, and SVG outputs."""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib.path import Path
from matplotlib.patches import PathPatch
from plot_style import new_axes, colors_for


def plot_circos(chromosomes, links, *, style):
    """Return proportional chromosome sectors with position-mapped Bezier links.

    Required chromosomes: chrom,length; links: source_chr,source_pos,
    target_chr,target_pos,weight. Sector arc length encodes chromosome length;
    endpoint angle encodes local position, line width absolute link weight.
    """
    fig, ax = new_axes(5, 5)
    palette = colors_for(chromosomes['chrom'], style)
    gap = 0.035
    available = 2 * np.pi - len(chromosomes) * gap
    total = chromosomes['length'].sum()
    sectors = {}
    start = np.pi / 2
    for row in chromosomes.itertuples(index=False):
        extent = available * row.length / total
        sectors[row.chrom] = (start, extent, row.length)
        angles = np.linspace(start, start + extent, 100)
        ax.plot(np.cos(angles), np.sin(angles), color='0.4', lw=5,
                solid_capstyle='butt')
        ax.plot(1.025 * np.cos(angles), 1.025 * np.sin(angles),
                color=palette[row.chrom], lw=1, solid_capstyle='butt')
        mid = start + extent / 2
        ax.text(1.14 * np.cos(mid), 1.14 * np.sin(mid), str(row.chrom),
                ha='center', va='center', fontsize=style['label_size'])
        start += extent + gap
    scale = links['weight'].abs().max() if len(links) else 0
    for row in links.itertuples(index=False):
        source_start, source_extent, source_length = sectors[row.source_chr]
        target_start, target_extent, target_length = sectors[row.target_chr]
        source_angle = source_start + source_extent * row.source_pos / source_length
        target_angle = target_start + target_extent * row.target_pos / target_length
        source = 0.96 * np.array([np.cos(source_angle), np.sin(source_angle)])
        target = 0.96 * np.array([np.cos(target_angle), np.sin(target_angle)])
        path = Path([source, source * 0.25, target * 0.25, target],
                    [Path.MOVETO, Path.CURVE4, Path.CURVE4, Path.CURVE4])
        ax.add_patch(PathPatch(path, facecolor='none',
                                edgecolor=palette[row.source_chr], alpha=0.6,
                                lw=0.4 + 1.0 * abs(row.weight) / (scale or 1)))
    ax.set(xlim=(-1.3, 1.3), ylim=(-1.3, 1.3), aspect='equal')
    ax.set_axis_off()
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_circos, ['chromosomes', 'links'], 'genomic_links_circos', output)
