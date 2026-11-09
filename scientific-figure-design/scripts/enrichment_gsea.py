"""展示基因集在排序基因中的富集位置。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib import pyplot as plt
from plot_style import clean_axis


def plot_gsea(ranked, *, style):
    """Draw prepared rank/running_score, hit positions and rank metric on shared x."""
    frame = ranked.sort_values("rank")
    fig, axes = plt.subplots(3, 1, figsize=(3.8, 3.1), sharex=True,
        gridspec_kw={"height_ratios": [2.6, 0.4, 1.1], "hspace": 0.04}, layout="constrained")
    axes[0].plot(frame["rank"], frame.running_score,
                 color=style["colors"]["dark_blue"], linewidth=0.85)
    axes[0].axhline(0, color="0.6", linewidth=0.5)
    peak = frame.iloc[np.argmax(np.abs(frame.running_score.to_numpy()))]
    axes[0].text(0.98, 0.92, f"ES = {peak.running_score:.2f}", transform=axes[0].transAxes,
                 ha="right", va="top", fontsize=6)
    axes[0].set_ylabel("Running score")
    axes[1].vlines(frame.loc[frame.hit, "rank"], 0, 1, color="0.2", linewidth=0.4)
    axes[1].set(yticks=[], ylabel="Hits", ylim=(0, 1))
    axes[1].spines[["left", "bottom", "top", "right"]].set_visible(False)
    axes[1].tick_params(axis="x", length=0)
    for mask, color in [(frame.metric >= 0, style["colors"]["red"]),
                         (frame.metric < 0, style["colors"]["dark_blue"])]:
        axes[2].fill_between(frame["rank"], frame.metric, 0, where=mask, color=color, alpha=0.4)
    axes[2].set(xlabel="Rank of feature", ylabel="Rank metric", xlim=(frame["rank"].min(), frame["rank"].max()))
    clean_axis(axes[0], style)
    clean_axis(axes[2], style)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_gsea, ['gsea'], 'enrichment_gsea', output)
