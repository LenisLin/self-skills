"""Show unique and shared members of a few gene sets. Read the bundled simulated data and generate PNG, PDF, and SVG outputs."""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

from plot_style import new_axes


def plot_venn(sets, *, style):
    """Return a two-set Venn using unique item memberships in in_a,in_b.

    Required: item,in_a,in_b (booleans). Areas and all three counts represent
    actual input sets, including deduplication by item.
    """
    from matplotlib_venn import venn2

    fig, ax = new_axes()
    a = set(sets.loc[sets['in_a'], 'item'])
    b = set(sets.loc[sets['in_b'], 'item'])
    diagram = venn2([a, b], set_labels=('A', 'B'), ax=ax,
                     set_colors=('#F3E7A5', style['groups']['A']), alpha=0.8)
    for text in diagram.subset_labels + diagram.set_labels:
        if text is not None:
            text.set_fontsize(style['label_size'])
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_venn, ['sets'], 'gene_set_overlap_venn', output)
