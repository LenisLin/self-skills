"""Structural plotting methods for supplied simulation tables (rules 2026-11-05).

Inputs: loaded DataFrames under simulation_contracts.json; output: open Figures.
Upstream simulation supplies coordinates, PCA variances, effects and P values.
Caller owns rc_context/apply_style, rendering and export.

Source rewrites: CIMA Figure2.py / CIMA_Myeloid_subcluster.py (PCA and
embedding geometry), SCENIC+_GRN_Plot.py (typed concentric network),
Figure3A_B.py (venn2), silicon.cells.py cells 8/10/12 (sequence tracks).
Embedding flow adapts C3's overlay geometry using the supplied analytic field.
Circular hierarchy, radial bars, Circos, genome tracks and CN map are this
round's figure-style adaptations; complete author renderers were not located.
Regional association is a self-contained replacement for the C5 helper call.
These functions reuse visual methods rather than original biological claims.
"""

import numpy as np
import networkx as nx
from matplotlib import pyplot as plt
from matplotlib.cm import ScalarMappable
from matplotlib.colors import Normalize, TwoSlopeNorm
from matplotlib.lines import Line2D
from matplotlib.path import Path
from matplotlib.patches import PathPatch

from plot_style import new_axes, clean_axis, colors_for, sequential_cmap, text_label


def _embedding_points(ax, embedding, style, alpha=None):
    """Draw category-colored coordinates with the shared group mapping."""
    groups = sorted(embedding['group'].unique())
    palette = colors_for(groups, style)
    for group in groups:
        part = embedding.loc[embedding['group'] == group]
        ax.scatter(part['x'], part['y'], s=2, color=palette[group],
                   alpha=style['alpha'] if alpha is None else alpha,
                   linewidths=0, rasterized=True, label=str(group))
    ax.set(xlabel=text_label('Embedding1', style), ylabel=text_label('Embedding2', style))
    clean_axis(ax, style)
    return palette


def plot_embedding(embedding, *, style):
    """Return a Figure: x,y coordinates colored by group; unit identifies points.

    Required: unit,x,y,group. Labels sit just outside each group's median.
    """
    fig, ax = new_axes()
    palette = _embedding_points(ax, embedding, style)
    center = embedding[['x', 'y']].median().to_numpy()
    span = embedding[['x', 'y']].max() - embedding[['x', 'y']].min()
    for group, part in embedding.groupby('group', sort=True):
        median = part[['x', 'y']].median().to_numpy()
        direction = median - center
        direction = direction / max(np.linalg.norm(direction), 1e-12)
        target = median + direction * span.to_numpy() * 0.12
        ax.annotate(str(group), xy=median, xytext=target, color=palette[group],
                    ha='left' if direction[0] >= 0 else 'right', va='center',
                    fontsize=style['label_size'],
                    arrowprops={'arrowstyle': '-', 'color': palette[group],
                                'lw': 0.5, 'shrinkA': 1, 'shrinkB': 1})
    ax.margins(0.2)
    return fig


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


def plot_embedding_flow(embedding, flow, *, style):
    """Return group-colored x,y points and an explicitly analytic streamline field.

    Required embedding: x,y,group; flow: x,y,u,v on the full regular grid.
    Vector components come exclusively from flow, in embedding coordinates.
    """
    fig, ax = new_axes()
    _embedding_points(ax, embedding, style, alpha=0.55)
    u = flow.pivot(index='y', columns='x', values='u').sort_index().sort_index(axis=1)
    v = flow.pivot(index='y', columns='x', values='v').reindex(
        index=u.index, columns=u.columns)
    ax.streamplot(u.columns.to_numpy(), u.index.to_numpy(), u.to_numpy(),
                  v.to_numpy(), density=1.0, color='0.2',
                  linewidth=0.35, arrowsize=0.45, zorder=3)
    ax.text(0.02, 0.98, 'Analytic field', transform=ax.transAxes, va='top',
            fontsize=style['tick_size'],
            bbox={'facecolor': 'white', 'edgecolor': 'none', 'pad': 1})
    return fig


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


def plot_network(nodes, edges, *, style):
    """Return a directed network with concentric type layers and value color.

    Required nodes: node,type (TF/Peak/Gene),value; edges: source,target,weight.
    Shapes encode type, diverging node color encodes the supplied value, and
    arrow width encodes absolute edge weight. Positions are layout geometry.
    """
    fig, ax = new_axes(5.8, 4.8)
    graph = nx.DiGraph()
    graph.add_nodes_from(nodes['node'])
    graph.add_weighted_edges_from(edges[['source', 'target', 'weight']].itertuples(
        index=False, name=None))
    positions, angles = {}, {}
    kinds = [kind for kind in ['TF', 'Peak', 'Gene'] if kind in set(nodes['type'])]
    kinds += sorted(set(nodes['type']) - set(kinds))
    shapes = {kind: {'TF': 'h', 'Peak': 'D', 'Gene': 'o'}.get(kind, 'o')
              for kind in kinds}
    type_radii = {kind: 0.34 + i * 0.34 for i, kind in enumerate(kinds)}
    for kind in kinds:
        members = sorted(nodes.loc[nodes['type'] == kind, 'node'], key=str)
        for i, node in enumerate(members):
            angle = np.pi / 2 - 2 * np.pi * i / len(members)
            angles[node] = angle
            positions[node] = type_radii[kind] * np.array([np.cos(angle), np.sin(angle)])
    tf_nodes = sorted(nodes.loc[nodes['type'] == kinds[0], 'node'], key=str)
    branch_colors = colors_for(tf_nodes, style)
    node_branch = {}
    for kind in kinds:
        for node in nodes.loc[nodes['type'] == kind, 'node']:
            predecessors = list(graph.predecessors(node))
            candidates = [node_branch[p] for p in predecessors if p in node_branch]
            node_branch[node] = branch_colors.get(node, candidates[0] if candidates else '0.55')
    weight_scale = edges['weight'].abs().max() if len(edges) else 0
    widths = [0.35 + 0.9 * abs(graph[u][v]['weight']) / (weight_scale or 1)
              for u, v in graph.edges()]
    nx.draw_networkx_edges(graph, positions, ax=ax, width=widths, arrows=True,
                           arrowsize=5, edge_color=[node_branch[u] for u, v in graph.edges()],
                           alpha=0.65, node_size=45, min_source_margin=3,
                           min_target_margin=3, connectionstyle='arc3,rad=0.20')
    cmap = plt.get_cmap(style['diverging_cmap'])
    limit = max(float(nodes['value'].abs().max()), 1e-12)
    norm = TwoSlopeNorm(vmin=-limit, vcenter=0, vmax=limit)
    for kind, marker in shapes.items():
        part = nodes.loc[nodes['type'] == kind]
        nx.draw_networkx_nodes(graph, positions, nodelist=part['node'].tolist(),
                               node_color=part['value'].to_numpy(), cmap=cmap,
                               vmin=-limit, vmax=limit, node_shape=marker,
                               node_size=150 if kind == kinds[0] else 30,
                               edgecolors='0.3', linewidths=0.45, ax=ax)
        for node in part['node']:
            point = positions[node]
            if kind == kinds[0]:
                ax.text(*point, str(node), ha='center', va='center',
                        fontsize=style['tick_size'] * 0.8)
            else:
                angle = angles[node]
                radius = type_radii[kind] + 0.09
                ax.text(radius * np.cos(angle), radius * np.sin(angle), str(node),
                        ha='left' if np.cos(angle) >= 0 else 'right', va='center',
                        fontsize=style['tick_size'] * 0.85)
    handles = [Line2D([], [], marker=shape, color='none', markerfacecolor='0.8',
                      markeredgecolor='0.3', markersize=5, label=kind)
               for kind, shape in shapes.items()]
    ax.legend(handles=handles, loc='upper left', bbox_to_anchor=(1, 1),
              borderaxespad=0, handletextpad=0.4)
    fig.colorbar(ScalarMappable(norm=norm, cmap=cmap), ax=ax, label='Node value',
                 fraction=0.035, pad=0.03, shrink=0.55)
    outer = max(type_radii.values()) + 0.55
    ax.set(xlim=(-outer, outer), ylim=(-outer, outer), aspect='equal')
    ax.set_axis_off()
    return fig


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


def plot_circos(chromosomes, links, *, style):
    """Return proportional chromosome sectors with position-mapped Bezier links.

    Required chromosomes: chrom,length; links: source_chr,source_pos,
    target_chr,target_pos,weight. Sector arc length encodes chromosome length;
    endpoint angle encodes local position, line width absolute link weight.
    """
    fig, ax = new_axes(5, 5)
    palette = colors_for(chromosomes['chrom'], style)
    gap = 0.035
    available = 2 * np.pi - len(chromosomes) * gap
    total = chromosomes['length'].sum()
    sectors = {}
    start = np.pi / 2
    for row in chromosomes.itertuples(index=False):
        extent = available * row.length / total
        sectors[row.chrom] = (start, extent, row.length)
        angles = np.linspace(start, start + extent, 100)
        ax.plot(np.cos(angles), np.sin(angles), color='0.4', lw=5,
                solid_capstyle='butt')
        ax.plot(1.025 * np.cos(angles), 1.025 * np.sin(angles),
                color=palette[row.chrom], lw=1, solid_capstyle='butt')
        mid = start + extent / 2
        ax.text(1.14 * np.cos(mid), 1.14 * np.sin(mid), str(row.chrom),
                ha='center', va='center', fontsize=style['label_size'])
        start += extent + gap
    scale = links['weight'].abs().max() if len(links) else 0
    for row in links.itertuples(index=False):
        source_start, source_extent, source_length = sectors[row.source_chr]
        target_start, target_extent, target_length = sectors[row.target_chr]
        source_angle = source_start + source_extent * row.source_pos / source_length
        target_angle = target_start + target_extent * row.target_pos / target_length
        source = 0.96 * np.array([np.cos(source_angle), np.sin(source_angle)])
        target = 0.96 * np.array([np.cos(target_angle), np.sin(target_angle)])
        path = Path([source, source * 0.25, target * 0.25, target],
                    [Path.MOVETO, Path.CURVE4, Path.CURVE4, Path.CURVE4])
        ax.add_patch(PathPatch(path, facecolor='none',
                                edgecolor=palette[row.source_chr], alpha=0.6,
                                lw=0.4 + 1.0 * abs(row.weight) / (scale or 1)))
    ax.set(xlim=(-1.3, 1.3), ylim=(-1.3, 1.3), aspect='equal')
    ax.set_axis_off()
    return fig


def plot_venn(sets, *, style):
    """Return a two-set Venn using unique item memberships in in_a,in_b.

    Required: item,in_a,in_b (booleans). Areas and all three counts represent
    actual input sets, including deduplication by item.
    """
    from matplotlib_venn import venn2

    fig, ax = new_axes()
    a = set(sets.loc[sets['in_a'], 'item'])
    b = set(sets.loc[sets['in_b'], 'item'])
    diagram = venn2([a, b], set_labels=('A', 'B'), ax=ax,
                     set_colors=('#F3E7A5', style['groups']['A']), alpha=0.8)
    for text in diagram.subset_labels + diagram.set_labels:
        if text is not None:
            text.set_fontsize(style['label_size'])
    return fig


def plot_regional_association(locus, *, style):
    """Return three aligned association tracks from supplied P values.

    Required: variant,position (bp),p_value,track,ld. Position is displayed
    in Mb, y is -log10(P), color is LD; the lowest input P defines one shared
    lead-position line across Trait, Expression and Accessibility tracks.
    """
    fig, axes = plt.subplots(3, 1, figsize=(5.2, 4.5), sharex=True,
                             layout='constrained')
    lead_position = locus.loc[locus['p_value'].idxmin(), 'position'] / 1e6
    norm = Normalize(0, 1)
    cmap = sequential_cmap(style)
    for ax, track in zip(axes, ['Trait', 'Expression', 'Accessibility']):
        part = locus.loc[locus['track'] == track].sort_values('position')
        ax.scatter(part['position'] / 1e6, -np.log10(part['p_value']),
                    c=part['ld'], cmap=cmap, norm=norm, s=6,
                    linewidths=0.5 if track == 'Accessibility' else 0,
                    marker='x' if track == 'Accessibility' else 'o')
        ax.axvline(lead_position, color='#D789AE', alpha=0.7, lw=2.5, zorder=0)
        ax.set_ylabel(text_label('−log10(P)', style))
        ax.text(0.01, 0.95, track, transform=ax.transAxes, va='top',
                fontsize=style['label_size'])
        ax.set_ylim(bottom=0)
        ax.margins(y=0.22)
        clean_axis(ax, style)
    axes[-1].set_xlabel('Position (Mb)')
    fig.colorbar(ScalarMappable(norm=norm, cmap=cmap), ax=axes, label='LD',
                 fraction=0.025, pad=0.02)
    return fig


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


def plot_sequence_effect(sequence, *, style):
    """Return aligned signed-effect logo, four-base lines and effect heatmap.

    Required: position (consecutive integer bp),base (A/C/G/T),effect, one per pair.
    All tracks display the same supplied effects; logo stacks signed letters,
    lines encode base identity by color, heatmap uses a zero-centered scale.
    """
    import logomaker

    matrix = sequence.pivot(index='position', columns='base', values='effect')
    matrix = matrix.sort_index().reindex(columns=['A', 'C', 'G', 'T'])
    positions = matrix.index.to_numpy()
    if not (np.all(positions == positions.astype(int)) and np.all(np.diff(positions) == 1)):
        raise ValueError('Sequence positions must be consecutive integer base-pair coordinates.')
    base_colors = {'A': '#367E43', 'C': '#2655A6', 'G': '#F99C31', 'T': '#EE2C28'}
    fig, axes = plt.subplots(3, 1, figsize=(7.2, 3.4), sharex=True,
                             height_ratios=[1, 1, 0.8], layout='constrained')
    logomaker.Logo(matrix.copy(), ax=axes[0], color_scheme=base_colors,
                   flip_below=False, shade_below=0, fade_below=0,
                   **({'font_name': style['font_family']} if 'typography' in style else {}))
    axes[0].set_ylabel('Effect')
    for base, color in base_colors.items():
        axes[1].plot(matrix.index, matrix[base], color=color, label=base, lw=0.7)
    axes[1].set_ylabel('Effect')
    axes[1].legend(ncol=4, loc='upper right', handlelength=1.2,
                   columnspacing=0.8, borderaxespad=0.2)
    limit = max(float(np.abs(matrix.to_numpy()).max()), 1e-12)
    norm = TwoSlopeNorm(vmin=-limit, vcenter=0, vmax=limit)
    image = axes[2].imshow(matrix.to_numpy().T, origin='upper', aspect='auto',
                           interpolation='nearest', cmap=style['diverging_cmap'],
                           norm=norm,
                           extent=(matrix.index.min() - 0.5,
                                   matrix.index.max() + 0.5, 3.5, -0.5))
    axes[2].set_yticks(range(4), ['A', 'C', 'G', 'T'])
    for tick, color in zip(axes[2].get_yticklabels(), base_colors.values()):
        tick.set_color(color)
    for ax in axes:
        if positions.min() <= 0 <= positions.max():
            ax.axvline(0, color='#F385A3', ls='--', lw=0.6)
        clean_axis(ax, style)
    for ax in axes[:2]:
        ax.axhline(0, color='0.6', lw=0.4, zorder=0)
    axes[-1].set(xlabel='Position (bp)',
                 xlim=(matrix.index.min() - 0.5, matrix.index.max() + 0.5))
    fig.colorbar(image, ax=axes[2], label='Effect', fraction=0.025, pad=0.02)
    return fig


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
