"""比较细胞群的基因表达强度与覆盖比例。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "_shared"))
from run_example import render

if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render('plots_matrices', 'plot_dotplot', ['dotplot'], 'group_feature_expression_dotplot', output)
