"""Show model directions or flow in embedding space. Read the bundled simulated data and generate PNG, PDF, and SVG outputs."""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

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


def plot_embedding_flow(embedding, flow, *, style):
    """Return group-colored x,y points and an explicitly analytic streamline field.

    Required embedding: x,y,group; flow: x,y,u,v on the full regular grid.
    Vector components come exclusively from flow, in embedding coordinates.
    """
    fig, ax = new_axes()
    _embedding_points(ax, embedding, style, alpha=0.55)
    u = flow.pivot(index='y', columns='x', values='u').sort_index().sort_index(axis=1)
    v = flow.pivot(index='y', columns='x', values='v').reindex(
        index=u.index, columns=u.columns)
    ax.streamplot(u.columns.to_numpy(), u.index.to_numpy(), u.to_numpy(),
                  v.to_numpy(), density=1.0, color='0.2',
                  linewidth=0.35, arrowsize=0.45, zorder=3)
    ax.text(0.02, 0.98, 'Analytic field', transform=ax.transAxes, va='top',
            fontsize=style['tick_size'],
            bbox={'facecolor': 'white', 'edgecolor': 'none', 'pad': 1})
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_embedding_flow, ['embedding', 'flow'], 'cell_trajectory_vector_field', output)
