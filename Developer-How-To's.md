# Best Practices R

## Introduction

In this part of the documentation we will present a compilation of useful information for R-developers.

### theme

If you like vscode theme, use [`https://github.com/anthonynorth/rscodeio`](https://github.com/anthonynorth/rscodeio)

### dev_mode

`devtools::dev_mode` function switches your version of R into "development mode". This is useful to avoid clobbering the existing versions of CRAN packages that you need for other tasks. Calling dev_mode() again will turn development mode off, and return you to your default library setup.

```R
# This will install the package in the folder C:/Rpackages
devtools::dev_mode(path="C:/Rpackages")
```

### Reload the package

```R
devtools::load_all()
```

or `Ctrl + Shift + L`

### Add or update script files

`.R` files defined in `tests\dev\` will be removed from the package and can be used to simulate interaction with the package. See [scripts.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/wiki/tests/dev/scripts.R)

### Coding standards
See [Coding standards for R](ospsuite-r-specifics/CODING_STANDARDS_R.md)

### Useful literature
- [**Advanced R** by Hadley Wickham](https://adv-r.hadley.nz/)

### Examples of "good" packages
Examples of packages that can serve as inspiration:
- [tidyverse](https://github.com/tidyverse)
- [PKPDsim](https://github.com/InsightRX/PKPDsim)

### Useful shortcuts

- Show all shortcuts: `Alt+Shift+K`
- Reload package:` Cmd + Shift + L`
- Navigate to: `Ctrl + .`
- Generate Doc: ` Ctrl + Shift + D`
- Run unit tests: `Ctrl + Shift + T`
- Navigate to implementation: `Mouse over + F2` or `CTRL + Mouse Click`
- Un-/Comment line/selection: `Ctrl + Shift + C`
- Multi-select: `CTRL+SHIFT+ALT+M`

### Profiling with R-Studio
Profiling of code can be done within R-Studio with the package `profvis`, a description of the process is given [here](https://support.rstudio.com/hc/en-us/articles/218221837-Profiling-with-RStudio). In short, pass the code to be profiled as argument to the function `profvis`:

```
profvis({
  data(diamonds, package = "ggplot2")

  plot(price ~ carat, data = diamonds)
  m <- lm(price ~ carat, data = diamonds)
  abline(m, col = "red")
})
```

### Graphics
- [Export to SVG](https://stackoverflow.com/questions/12226822/how-to-save-a-plot-made-with-ggplot2-as-svg)

### Snapshot testing
- `{ospsuite}` uses snapshots to test the behavior of plot functions. 
<!-- TODO_LINK_INVALID Read [Introduction to snapshot testing in R](https://esqlabs.github.io/intro-to-snapshot-testing/#/title-slide) for information on how to. -->
- Short summary:
  - The first time a test with snapshot is executed, it creates a snapshot file that will be considered **the truth**. Therefore it is important to check 
  this file for its validity.
  - If the behavior of the tested function changes, the test will fail, as the new output will differ from the snapshot.
  - Run `snapshot_review()` to compare the new output with the snapshot.
  - If the new behavior is correct, accept the snapshot by calling `snapshot_accept()`.
- If build fails because of failing snapshot tests, **never** accept new snapshots without manual review.

### Setting up Linux environment for R development
As an example, a Hyper-V Virtual Machine under Windows 10 is used. Currently tested with Ubuntu 19.10
1. #### Install Ubuntu
  * Download Ubuntu from [https://ubuntu.com/download/desktop](https://ubuntu.com/download/desktop)
  * Tutorial: [https://www.youtube.com/watch?v=oyNjjzg-UXo](https://www.youtube.com/watch?v=oyNjjzg-UXo)
= >This is a very good intro to get ubuntu installed from scratch

2. #### Install git
- `sudo apt install git`

3. #### Install nuget
- `sudo apt install nuget`

4. #### Install R
- `sudo apt install r-base`

5. #### Install R Studio
  * Download R studio from [here](https://www.rstudio.com/products/rstudio/download/#download)

6. #### Install OSPSuite-R
- [Prerequisites](https://github.com/Open-Systems-Pharmacology/rSharp?tab=readme-ov-file#ubuntu)
- [Main Package](https://github.com/Open-Systems-Pharmacology/OSPSuite-R#ospsuite-r-package)
