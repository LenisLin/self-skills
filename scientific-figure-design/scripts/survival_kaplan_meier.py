"""比较不同组的事件时间与生存概率。读取附带的模拟数据并生成 PNG、PDF、SVG。"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "_shared"))
from run_example import render

if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    render('plots_statistics', 'plot_km', ['km_curve', 'km_censors', 'km_risk'], 'survival_kaplan_meier', output)
