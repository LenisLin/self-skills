"""Show cell clusters and annotations. Read the bundled simulated data and generate PNG, PDF, and SVG outputs."""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from plot_style import new_axes, clean_axis, colors_for, text_label


def _embedding_points(ax, embedding, style, alpha=None):
    """Draw category-colored coordinates with the shared group mapping."""
    groups = sorted(embedding['group'].unique())
    palette = colors_for(groups, style)
    for group in groups:
        part = embedding.loc[embedding['group'] == group]
        ax.scatter(part['x'], part['y'], s=2, color=palette[group],
                   alpha=style['alpha'] if alpha is None else alpha,
                   linewidths=0, rasterized=True, label=str(group))
    ax.set(xlabel=text_label('Embedding1', style), ylabel=text_label('Embedding2', style))
    clean_axis(ax, style)
    return palette


def plot_embedding(embedding, *, style):
    """Return a Figure: x,y coordinates colored by group; unit identifies points.

    Required: unit,x,y,group. Labels sit just outside each group's median.
    """
    fig, ax = new_axes()
    palette = _embedding_points(ax, embedding, style)
    center = embedding[['x', 'y']].median().to_numpy()
    span = embedding[['x', 'y']].max() - embedding[['x', 'y']].min()
    for group, part in embedding.groupby('group', sort=True):
        median = part[['x', 'y']].median().to_numpy()
        direction = median - center
        direction = direction / max(np.linalg.norm(direction), 1e-12)
        target = median + direction * span.to_numpy() * 0.12
        ax.annotate(str(group), xy=median, xytext=target, color=palette[group],
                    ha='left' if direction[0] >= 0 else 'right', va='center',
                    fontsize=style['label_size'],
                    arrowprops={'arrowstyle': '-', 'color': palette[group],
                                'lw': 0.5, 'shrinkA': 1, 'shrinkB': 1})
    ax.margins(0.2)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_embedding, ['embedding'], 'cell_annotation_umap', output)
