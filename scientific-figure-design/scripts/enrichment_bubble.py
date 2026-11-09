"""比较多个通路的富集程度和显著性。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from plot_style import clean_axis, new_axes, sequential_cmap, text_label


def plot_pathway_bubble(pathways, *, style):
    """Encode pathway score, set size as area and -log10(q_value) as color."""
    frame = pathways.sort_values("score").reset_index(drop=True)
    fig, ax = new_axes(4.8, max(3.0, 0.19 * len(frame) + 0.8))
    values = -np.log10(np.maximum(frame.q_value.to_numpy(), np.finfo(float).tiny))
    scatter = ax.scatter(frame.score, np.arange(len(frame)), s=frame["size"] * 0.7,
        c=values, cmap=sequential_cmap(style), vmin=0, edgecolors="0.5", linewidths=0.25)
    ax.set(yticks=range(len(frame)), yticklabels=frame.pathway, xlabel="Enrichment score")
    ax.axvline(0, color="0.7", linewidth=0.55, linestyle="--")
    fig.colorbar(scatter, ax=ax, label=text_label("−log10(BH q)", style), fraction=0.055, pad=0.03)
    sizes = np.unique(np.quantile(frame["size"], [0, 0.5, 1]))
    handles = [ax.scatter([], [], s=n * 0.7, c="0.55", linewidths=0, label=f"{n:g}") for n in sizes]
    ax.legend(handles=handles, title="Set size", loc="upper center", bbox_to_anchor=(0.5, -0.24),
              ncol=len(sizes), borderpad=0.2, columnspacing=1, frameon=False)
    clean_axis(ax, style)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_pathway_bubble, ['pathways'], 'enrichment_bubble', output)
