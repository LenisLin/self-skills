"""Compare sample principal components and group annotations. Read the bundled simulated data and generate PNG, PDF, and SVG outputs."""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

from matplotlib import pyplot as plt
from plot_style import clean_axis, colors_for


def plot_pca_facets(pca, *, style):
    """Return paired PCA views, colored by age and group.

    Required: pc1,pc2,age,group,variance1,variance2; variances are supplied
    percentages from the upstream high-dimensional PCA, repeated per row.
    """
    fig, axes = plt.subplots(2, 1, figsize=(3.1, 5.0), sharex=True, sharey=True,
                             layout='constrained')
    points = axes[0].scatter(pca['pc1'], pca['pc2'], c=pca['age'],
                             cmap='magma', s=5, linewidths=0,
                             rasterized=True)
    fig.colorbar(points, ax=axes[0], label='Age', fraction=0.045, pad=0.02)
    groups = sorted(pca['group'].unique())
    palette = colors_for(groups, style)
    for group in groups:
        part = pca.loc[pca['group'] == group]
        axes[1].scatter(part['pc1'], part['pc2'], color=palette[group],
                        s=5, linewidths=0, alpha=style['alpha'], label=str(group),
                        rasterized=True)
    axes[1].legend(loc='upper left', bbox_to_anchor=(1, 1), markerscale=2,
                   handletextpad=0.2, borderaxespad=0)
    for ax in axes:
        ax.set_ylabel(f"PC2 ({pca['variance2'].iloc[0]:.1f}%)")
        clean_axis(ax, style)
        ax.spines[['top', 'right']].set_visible(True)
    axes[-1].set_xlabel(f"PC1 ({pca['variance1'].iloc[0]:.1f}%)")
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_pca_facets, ['pca'], 'sample_pca_annotation', output)
