"""Show the distribution of gene expression or scores in embedding space. Read the bundled simulated data and generate PNG, PDF, and SVG outputs."""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

from plot_style import new_axes, clean_axis, text_label


def plot_feature_embedding(embedding, *, style):
    """Return a Figure: required x,y,feature encode position and continuous color."""
    fig, ax = new_axes()
    points = ax.scatter(embedding['x'], embedding['y'], c=embedding['feature'],
                        cmap=style['feature_cmap'], s=2, linewidths=0,
                        rasterized=True)
    fig.colorbar(points, ax=ax, label='Feature', fraction=0.05, pad=0.03)
    ax.set(xlabel=text_label('Embedding1', style), ylabel=text_label('Embedding2', style))
    ax.margins(0.12)
    clean_axis(ax, style)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_feature_embedding, ['embedding'], 'feature_expression_umap', output)
