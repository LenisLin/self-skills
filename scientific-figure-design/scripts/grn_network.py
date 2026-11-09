"""展示调控网络、互作和模块。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path as FilePath

sys.path.insert(0, str(FilePath(__file__).resolve().parent / "_shared"))
from run_example import render

import numpy as np
import networkx as nx
from matplotlib import pyplot as plt
from matplotlib.cm import ScalarMappable
from matplotlib.colors import TwoSlopeNorm
from matplotlib.lines import Line2D
from plot_style import new_axes, colors_for


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


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render(plot_network, ['nodes', 'edges'], 'grn_network', output)
