"""Compare classification models' discrimination across thresholds. Read the bundled simulated data and generate PNG, PDF, and SVG outputs."""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from sklearn.metrics import auc, roc_curve
from plot_style import clean_axis, colors_for, new_axes


def plot_roc(scores, *, style):
    """Compute threshold/FPR/TPR and AUROC from each model's label/score vectors."""
    fig, ax = new_axes(3.3, 3.15)
    palette = colors_for(sorted(scores.model.unique()), style)
    for model, part in scores.groupby("model", sort=True):
        fpr, tpr, _ = roc_curve(part.label, part.score)
        ax.plot(fpr, tpr, color=palette[model], label=f"{model}: {auc(fpr, tpr):.3f}", linewidth=0.9)
    ax.plot([0, 1], [0, 1], "--", color=style["colors"]["dark_blue"], linewidth=0.55, dashes=(3, 4))
    ax.set(xlabel="False positive rate", ylabel="True positive rate",
           xlim=(0, 1), ylim=(0, 1), xticks=np.linspace(0, 1, 6), yticks=np.linspace(0, 1, 6))
    ax.set_title("AUROC", fontsize=style["label_size"], pad=3)
    ax.set_aspect("equal", adjustable="box")
    ax.legend(loc="lower right", handlelength=1.2, frameon=True, facecolor="white", edgecolor="0.65")
    clean_axis(ax, style)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_roc, ['roc'], 'classification_roc', output)
