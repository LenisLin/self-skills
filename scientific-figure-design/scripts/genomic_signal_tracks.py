"""Compare multiple sets of signals across genomic intervals. Read the bundled simulated data and generate PNG, PDF, and SVG outputs."""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

from matplotlib import pyplot as plt
from plot_style import clean_axis, colors_for


def plot_genome_tracks(tracks, *, style):
    """Return aligned signal tracks with a shared amplitude scale.

    Required: position (bp),group,source,signal. x displays kb, line/fill
    encode signal, color encodes group; rows are grouped by source and use a
    common amplitude scale.
    """
    groups = sorted(tracks['group'].unique())
    sources = [s for s in ['Observed', 'Predicted'] if s in set(tracks['source'])]
    sources += sorted(set(tracks['source']) - set(sources))
    pairs = [(group, source) for source in sources for group in groups
             if ((tracks['group'] == group) & (tracks['source'] == source)).any()]
    fig, axes = plt.subplots(len(pairs), 1, figsize=(5.8, 5.2),
                             sharex=True, sharey=True, squeeze=False,
                             gridspec_kw={'hspace': 0}, layout='constrained')
    axes = axes[:, 0]
    palette = colors_for(groups, style)
    minimum = min(float(tracks['signal'].min()), 0)
    maximum = max(float(tracks['signal'].max()), 0)
    padding = max(maximum - minimum, 1e-12) * 0.08
    for ax, (group, source) in zip(axes, pairs):
        part = tracks.loc[(tracks['group'] == group) &
                          (tracks['source'] == source)].sort_values('position')
        x = part['position'].to_numpy() / 1000
        y = part['signal'].to_numpy()
        ax.set_facecolor('#F5F8F3' if source == 'Observed' else '#FCF3F6')
        ax.fill_between(x, 0, y, color=palette[group], alpha=0.8, linewidth=0)
        ax.plot(x, y, color=palette[group], lw=0.45)
        ax.set_ylabel(f'{group}  {source}', rotation=0, ha='right', va='center',
                      color=palette[group], fontsize=style['tick_size'])
        ax.set_ylim(minimum - padding if minimum < 0 else 0, maximum + padding)
        ax.set_yticks([minimum, maximum] if minimum < 0 else [0, maximum])
        ax.tick_params(axis='y', labelsize=style['tick_size'] * 0.8)
        clean_axis(ax, style)
    axes[-1].set_xlabel('Position (kb)')
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_genome_tracks, ['tracks'], 'genomic_signal_tracks', output)
