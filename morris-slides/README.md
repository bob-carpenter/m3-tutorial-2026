# Morris Slides

Materials for the Stan tutorial slides and companion notebooks.

## Recommended: RStudio or Quarto

The notebooks are Quarto `.qmd` files. For R users, the simplest workflow is to open
the notebooks in RStudio or render them with Quarto.

Install the R packages used by the BRMS notebooks:

```r
install.packages(c(
  "jsonlite", "dplyr", "ggplot2",
  "brms", "posterior", "bayesplot", "tidybayes",
  "cmdstanr", "sf", "geojsonio"
))
```

If CmdStan is not already installed:

```r
cmdstanr::install_cmdstan()
```

Render a notebook:

```bash
QUARTO_PYTHON=.venv/bin/python quarto render brms_notebooks/fit_air_brms.qmd --to html
```

## Optional: JupyterLab with uv

`uv` manages only the Python/Jupyter toolchain. R and R packages are still managed by
R. This setup uses Jupytext so the same `.qmd` notebook can be opened and run in
JupyterLab without maintaining a separate `.ipynb` copy.

Create the Python environment:

```bash
uv sync
```

Register an R kernel for Jupyter:

```r
install.packages("IRkernel")
IRkernel::installspec(user = TRUE)
```

Start JupyterLab:

```bash
./jupyter_lab.sh
```

Open `brms_notebooks/fit_air_brms.qmd`. If JupyterLab opens it as plain text, use
`Open With -> Notebook`. Choose the R kernel if Jupyter does not select it
automatically.

If `.qmd` files still open as text, set Jupytext as the default viewer for Quarto
Markdown notebooks:

```bash
uv run jupytext-config set-default-viewer qmd
```

The launch script sets:

```bash
QUARTO_PYTHON=.venv/bin/python
```

This is required because Quarto otherwise may use the system Python, which does not
know about the uv-managed Jupyter installation or the registered R kernel.

## Notes for Live Demos

Use the `.qmd` files as the source of truth. For a JupyterLab demo, run:

```bash
./jupyter_lab.sh
```

Then open the `.qmd` notebook through Jupytext and run it with the R kernel.
