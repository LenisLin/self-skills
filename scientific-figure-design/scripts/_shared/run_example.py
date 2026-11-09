"""Render one template using its bundled synthetic input tables."""
from pathlib import Path
import json
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd
from plot_style import apply_style

ROOT = Path(__file__).resolve().parent

def render(draw, inputs, stem, output):
    """Load bundled tables, call the figure script's draw function, and export."""
    style = json.loads((ROOT / "contracts.json").read_text())["style"]
    frames = [pd.read_csv(ROOT / "data" / (name + ".csv")) for name in inputs]
    output = Path(output)
    output.mkdir(parents=True, exist_ok=True)
    with matplotlib.rc_context():
        apply_style(style)
        fig = draw(*frames, style=style)
        for suffix in ("png", "pdf", "svg"):
            fig.savefig(output / (stem + "." + suffix), dpi=style["dpi"])
        plt.close(fig)
    print(f"{stem}: saved PNG, PDF and SVG to {output}")
