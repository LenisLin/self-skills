"""Align clinical annotations and composition across samples. Read the bundled simulated data and generate PNG, PDF, and SVG outputs."""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib import pyplot as plt
from matplotlib.colors import ListedColormap
from matplotlib.patches import Patch
from plot_style import clean_axis, colors_for


def plot_cohort_tracks(metadata, composition, *, style):
    """Use sample,age,batch,group and sample,component,fraction: aligned age-sorted tracks."""
    meta = metadata.sort_values(["age", "sample"], kind="stable").set_index("sample")
    components = sorted(composition["component"].unique())
    matrix = composition.pivot(index="sample", columns="component", values="fraction").reindex(
        index=meta.index, columns=components)
    palette = colors_for(components, style)
    fig = plt.figure(figsize=(6, 7), layout="constrained")
    grid = fig.add_gridspec(2, 5, height_ratios=[1.2, 6],
                            width_ratios=[0.24, 0.24, 0.24, 2.5, 1.35],
                            hspace=0.06, wspace=0.08)
    hist_ax = fig.add_subplot(grid[0, :4])
    hist_ax.hist(meta["age"], bins="auto", color="#A7D4D6", edgecolor="white", linewidth=0.3)
    hist_ax.set(xlabel="Age (years)", ylabel="Count")
    clean_axis(hist_ax, style)
    axes = [fig.add_subplot(grid[1, 0])]
    axes.extend(fig.add_subplot(grid[1, i], sharey=axes[0]) for i in range(1, 4))
    age_image = axes[0].imshow(meta[["age"]].to_numpy(), aspect="auto", cmap=style["age_cmap"],
                               interpolation="nearest")
    axes[0].set_ylabel("Samples (ordered by age)")
    axes[0].set_xticks([0], ["Age"], rotation=90)
    legend_handles = []
    for ax, field in zip(axes[1:3], ["batch", "group"]):
        labels = sorted(meta[field].unique())
        colors = colors_for(labels, style)
        codes = {label: i for i, label in enumerate(labels)}
        ax.imshow(meta[field].map(codes).to_numpy()[:, None], aspect="auto",
                  cmap=ListedColormap([colors[label] for label in labels]),
                  vmin=-0.5, vmax=len(labels) - 0.5, interpolation="nearest")
        ax.set_xticks([0], [field.capitalize()], rotation=90)
        legend_handles.extend(Patch(facecolor=colors[label], label=f"{field.capitalize()}: {label}")
                              for label in labels)
    for ax in axes[:3]:
        ax.tick_params(length=0, labelleft=False)
        for spine in ax.spines.values():
            spine.set_visible(False)
    left = np.zeros(len(meta))
    for component in components:
        axes[3].barh(np.arange(len(meta)), matrix[component], left=left,
                     color=palette[component], height=1, linewidth=0)
        left += matrix[component].to_numpy()
    axes[3].set(xlim=(0, 1), xlabel="Fraction")
    axes[3].tick_params(axis="y", left=False, labelleft=False)
    clean_axis(axes[3], style)
    legend_ax = fig.add_subplot(grid[1, 4])
    legend_ax.set_axis_off()
    legend_handles.extend(Patch(facecolor=palette[label], label=str(label)) for label in components)
    legend_ax.legend(handles=legend_handles, title="Annotations / component", loc="center left",
                     borderaxespad=0)
    color_ax = legend_ax.inset_axes([0.05, 0.88, 0.75, 0.025])
    fig.colorbar(age_image, cax=color_ax, orientation="horizontal", label="Age (years)")
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_cohort_tracks, ['metadata', 'composition'], 'sample_annotation_tracks', output)
