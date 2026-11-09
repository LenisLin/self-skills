"""展示组织空间中的细胞邻域分布。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

from plot_style import new_axes, clean_axis, colors_for


def plot_cn_map(cn_map, *, style):
    """Return equal-aspect spatial categories and a 100 µm scale bar.

    Required: unit,x_um,y_um,cn (CN01–CN08). x/y are supplied spatial µm;
    color is bound to the complete CN01–CN08 palette even for absent classes.
    """
    fig, ax = new_axes()
    palette = colors_for([f'CN{i:02d}' for i in range(1, 9)], style)
    for cn in sorted(cn_map['cn'].unique()):
        part = cn_map.loc[cn_map['cn'] == cn]
        ax.scatter(part['x_um'], part['y_um'], color=palette[cn], s=3,
                    linewidths=0, label=cn, rasterized=True)
    xmin, xmax = cn_map['x_um'].min(), cn_map['x_um'].max()
    ymin, ymax = cn_map['y_um'].min(), cn_map['y_um'].max()
    span = max(xmax - xmin, ymax - ymin)
    bar_x, bar_y = xmin + 0.04 * span, ymin - 0.08 * span
    ax.plot([bar_x, bar_x + 100], [bar_y, bar_y], color='black', lw=1.4,
             solid_capstyle='butt')
    ax.text(bar_x + 50, bar_y - 0.015 * span, '100 µm', ha='center', va='top',
            fontsize=style['tick_size'])
    ax.set(xlabel='x (µm)', ylabel='y (µm)', aspect='equal',
            xlim=(xmin - 0.03 * span, max(xmax + 0.03 * span, bar_x + 100)),
            ylim=(ymin - 0.17 * span, ymax + 0.03 * span))
    ax.legend(loc='upper left', bbox_to_anchor=(1.02, 1), borderaxespad=0,
               handletextpad=0.3, markerscale=2)
    clean_axis(ax, style)
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_cn_map, ['cn_map'], 'spatial_cell_neighborhood_map', output)
