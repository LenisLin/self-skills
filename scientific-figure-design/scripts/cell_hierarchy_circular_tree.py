"""Show cell hierarchies and multiple annotation layers. Read the bundled simulated data and generate PNG, PDF, and SVG outputs."""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
from matplotlib import pyplot as plt
from matplotlib.cm import ScalarMappable
from matplotlib.colors import Normalize
from plot_style import colors_for


def _radial_label(ax, angle, radius, text, color, style):
    """Keep circular labels upright on both halves of a polar plot."""
    degrees = np.degrees(angle) % 360
    left = 90 < degrees < 270
    ax.text(angle, radius, str(text), rotation=degrees + (180 if left else 0),
            rotation_mode='anchor', ha='right' if left else 'left', va='center',
            color=color, fontsize=style['label_size'], clip_on=False)


def plot_circular_hierarchy(tree, *, style):
    """Return a circular topology with group-colored leaf annotation ring.

    Required: node,parent,level,group,value. Parent links determine leaf order
    and branches; level determines layout radius, without distance units.
    Group encodes the inner ring and the leaf value encodes the outer ring;
    branch radii indicate hierarchy level, not quantitative distance.
    """
    fig, ax = plt.subplots(figsize=(5, 5), subplot_kw={'projection': 'polar'},
                            layout='constrained')
    rows = tree.set_index('node')
    children = {node: [] for node in tree['node']}
    root = tree.loc[tree['parent'].isna() | tree['parent'].eq(''), 'node'].iloc[0]
    for row in tree.itertuples(index=False):
        if row.node != root:
            children[row.parent].append(row.node)
    leaves = []

    def visit(node):
        if not children[node]:
            leaves.append(node)
        for child in children[node]:
            visit(child)

    visit(root)
    step = 2 * np.pi / len(leaves)
    angles = {node: (i + 0.5) * step for i, node in enumerate(leaves)}

    def place(node):
        if children[node]:
            angles[node] = np.mean([place(child) for child in children[node]])
        return angles[node]

    place(root)
    groups = sorted(rows.loc[leaves, 'group'].dropna().unique())
    palette = colors_for(groups, style)
    leaf_groups = {}

    def descendant_groups(node):
        if not children[node]:
            leaf_groups[node] = {rows.loc[node, 'group']} if rows.loc[node, 'group'] in palette else set()
        else:
            leaf_groups[node] = set().union(*(descendant_groups(child) for child in children[node]))
        return leaf_groups[node]

    descendant_groups(root)
    max_level = float(tree['level'].max())
    scale = 0.78 / max(max_level, 1)
    for parent, descendants in children.items():
        radius = float(rows.loc[parent, 'level']) * scale
        for child in descendants:
            group_set = leaf_groups[child]
            color = palette[next(iter(group_set))] if len(group_set) == 1 else '0.55'
            t = np.linspace(0, 1, 60)
            smooth = t * t * (3 - 2 * t)
            theta = angles[parent] + (angles[child] - angles[parent]) * smooth
            radii = radius + (float(rows.loc[child, 'level']) * scale - radius) * t
            ax.plot(theta, radii, color=color, lw=1.5, solid_capstyle='round')
            if children[child]:
                ax.text(angles[child], float(rows.loc[child, 'level']) * scale,
                        str(child), ha='center', va='center', color=color,
                        fontsize=style['tick_size'],
                        bbox={'facecolor': 'white', 'edgecolor': 'none', 'pad': 0.5})
    leaf_radius = max_level * scale
    leaf_values = rows.loc[leaves, 'value'].astype(float)
    norm = Normalize(vmin=leaf_values.min(), vmax=leaf_values.max())
    cmap = plt.get_cmap('Reds')
    for leaf in leaves:
        color = palette.get(rows.loc[leaf, 'group'], '0.65')
        ax.bar(angles[leaf], 0.045, width=step * 0.96, bottom=leaf_radius + 0.025,
               color=color, linewidth=0)
        ax.bar(angles[leaf], 0.04, width=step * 0.96, bottom=leaf_radius + 0.075,
               color=cmap(norm(float(rows.loc[leaf, 'value']))), linewidth=0)
        _radial_label(ax, angles[leaf], leaf_radius + 0.14, leaf, color, style)
    fig.colorbar(ScalarMappable(norm=norm, cmap=cmap), ax=ax, label='Leaf value',
                 fraction=0.03, pad=0.06, shrink=0.35)
    ax.set_ylim(0, leaf_radius + 0.34)
    ax.set_axis_off()
    return fig


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_circular_hierarchy, ['tree'], 'cell_hierarchy_circular_tree', output)
