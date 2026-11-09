"""总览较多类别的得分或数量。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib import pyplot as plt
from plot_style import colors_for


def _radial_label(ax, angle, radius, text, color, style):
    """Keep circular labels upright on both halves of a polar plot."""
    degrees = np.degrees(angle) % 360
    left = 90 < degrees < 270
    ax.text(angle, radius, str(text), rotation=degrees + (180 if left else 0),
            rotation_mode='anchor', ha='right' if left else 'left', va='center',
            color=color, fontsize=style['label_size'], clip_on=False)


def plot_radial_bar(category_values, *, style):
    """Return radial bars: required category,left encode angular label and length.

    Category color is fixed by sorted labels; the inner ring identifies the
    categories and radial tick labels show left in its supplied units.
    right and coefficient are unused optional columns.
    """
    fig, ax = plt.subplots(figsize=(5, 5), subplot_kw={'projection': 'polar'},
                            layout='constrained')
    data = category_values.sort_values('category')
    palette = colors_for(data['category'], style)
    minimum = min(float(data['left'].min()), 0)
    maximum = max(float(data['left'].max()), 0)
    extent = max(maximum - minimum, 1e-12)
    inner = extent * 0.55
    base = inner - minimum
    step = 2 * np.pi / len(data)
    angles = np.pi / 2 - np.arange(len(data)) * step
    ax.bar(angles, data['left'], bottom=base, width=step * 0.9,
           color=[palette[c] for c in data['category']], linewidth=0.3,
           edgecolor='white')
    ax.bar(angles, extent * 0.12, bottom=inner * 0.6, width=step * 0.96,
           color=[palette[c] for c in data['category']], linewidth=0.3,
           edgecolor='white')
    for angle, row in zip(angles, data.itertuples(index=False)):
        _radial_label(ax, angle, base + maximum + extent * 0.08, row.category,
                      palette[row.category], style)
    ticks = np.linspace(minimum, maximum, 4)
    ax.set_yticks(base + ticks, [f'{t:.2g}' for t in ticks],
                  fontsize=style['tick_size'])
    ax.set_rlabel_position(75)
    ax.set_ylim(0, base + maximum + extent * 0.5)
    ax.set_xticks([])
    ax.spines['polar'].set_visible(False)
    ax.grid(axis='y', color='0.85', linewidth=0.4)
    ax.text(0, 0, 'Left', ha='center', va='center', fontsize=style['label_size'])
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_radial_bar, ['category_values'], 'category_ranking_radial_bars', output)
