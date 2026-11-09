"""Shared typography and category colors for the simulation plotting templates.

Input: style dict from simulation_contracts.json. Functions set display defaults
and style axes; they do not transform the measurements supplied to a plot.
"""

import matplotlib as mpl
from matplotlib import pyplot as plt
from matplotlib import font_manager
from matplotlib.colors import LinearSegmentedColormap
from pathlib import Path


def register_fonts(style, font_dir=None):
    """Register task fonts and resolve real faces before rendering any figures.

    Arial requires regular, bold, italic and bold italic faces. An explicit
    directory supplies the four task-owned TTFs; otherwise use installed fonts.
    Return resolved paths for the render record, never configuration placeholders.
    """
    family = style["font_family"]
    faces = {"regular": ("normal", "normal", "Arial.ttf"),
             "bold": ("normal", "bold", "Arial Bold.ttf"),
             "italic": ("italic", "normal", "Arial Italic.ttf"),
             "bold_italic": ("italic", "bold", "Arial Bold Italic.ttf")}
    if font_dir is not None:
        font_dir = Path(font_dir).resolve()
        files = ([font_dir / item[2] for item in faces.values()] if family == "Arial"
                 else sorted(font_dir.glob("*.ttf")))
        if not files:
            raise FileNotFoundError(f"No TTF fonts in {font_dir}")
        registered = []
        for path in files:
            if not path.is_file():
                raise FileNotFoundError(f"Required font missing: {path}")
            font_manager.fontManager.addfont(str(path))
            registered.append(font_manager.fontManager.ttflist[-1])
        # Give task faces priority for subsequent family-based text/math lookups.
        font_manager.fontManager.ttflist = registered + [
            item for item in font_manager.fontManager.ttflist if item not in registered]
    resolved = {}
    for name, (slant, weight, filename) in faces.items():
        if family != "Arial" and name != "regular":
            continue
        prop = font_manager.FontProperties(family=family, style=slant, weight=weight)
        path = Path(font_manager.findfont(prop, directory=font_dir, fallback_to_default=False)).resolve()
        entry = next(item for item in font_manager.fontManager.ttflist
                     if Path(item.fname).resolve() == path)
        if family == "Arial":
            actual_weight = (font_manager.weight_dict[entry.weight]
                             if isinstance(entry.weight, str) else entry.weight)
            if (entry.name != "Arial" or entry.style != slant or
                    (actual_weight >= 600) != (weight == "bold")):
                raise ValueError(f"Arial {name} unavailable; resolved {path} ({entry})")
            if font_dir is not None and path != font_dir / filename:
                raise ValueError(f"Expected task Arial {name}: {font_dir / filename}; got {path}")
        resolved[name] = str(path)
    return resolved


def apply_style(style):
    """Apply final-PDF-inspired dimensions in points to the active rc context."""
    mpl.rcParams.update({
        "font.family": style["font_family"], "font.size": style["font_size"],
        "axes.labelsize": style["label_size"], "axes.titlesize": style["label_size"],
        "xtick.labelsize": style["tick_size"], "ytick.labelsize": style["tick_size"],
        "legend.fontsize": style["tick_size"], "axes.linewidth": style["line_width"],
        "xtick.major.width": style["line_width"], "ytick.major.width": style["line_width"],
        "xtick.major.size": 2.5, "ytick.major.size": 2.5,
        "lines.linewidth": 0.8, "axes.spines.top": False, "axes.spines.right": False,
        "axes.grid": False, "axes.facecolor": "white", "figure.facecolor": "white",
        "savefig.facecolor": "white", "pdf.fonttype": 42, "ps.fonttype": 42,
        "svg.fonttype": "none", "legend.frameon": False,
    })
    typography = style.get("typography")
    if typography:
        # Only this opt-in configuration changes text colors and math fonts.
        mpl.rcParams.update(typography["rc"])
        if typography.get("mathtext_family"):
            family = typography["mathtext_family"]
            mpl.rcParams.update({
                "font.sans-serif": [family], "mathtext.fontset": "custom",
                "mathtext.rm": f"{family}:style=normal:weight=normal",
                "mathtext.it": f"{family}:style=italic:weight=normal",
                "mathtext.bf": f"{family}:style=normal:weight=bold",
                "mathtext.bfit": f"{family}:style=italic:weight=bold",
                "mathtext.sf": family, "mathtext.tt": family, "mathtext.cal": family,
                "mathtext.default": "regular", "mathtext.fallback": None,
            })


def text_label(label, style):
    """Apply configured display wording while retaining the measured quantity."""
    return style.get("typography", {}).get("labels", {}).get(label, label)


def colors_for(labels, style):
    """Bind shared group labels consistently; other categories use a fixed sequence."""
    return {label: style["groups"].get(str(label), style["categories"][i % len(style["categories"])])
            for i, label in enumerate(labels)}


def sequential_cmap(style):
    return LinearSegmentedColormap.from_list("fraction", ["white", style["colors"]["heatmap_pink"]])


def clean_axis(ax, style):
    """Keep thin left/bottom axes for statistical plots."""
    ax.spines[["top", "right"]].set_visible(False)
    for spine in ax.spines.values():
        spine.set_linewidth(style["line_width"])
    ax.tick_params(width=style["line_width"], length=2.5)


def new_axes(width=3.35, height=2.6):
    return plt.subplots(figsize=(width, height), layout="constrained")
