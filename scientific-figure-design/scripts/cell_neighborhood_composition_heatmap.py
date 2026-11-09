"""比较细胞类型与空间邻域的组成。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "_shared"))
from run_example import render

if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render('plots_matrices', 'plot_cn_fraction', ['cn_fraction'], 'cell_neighborhood_composition_heatmap', output)
