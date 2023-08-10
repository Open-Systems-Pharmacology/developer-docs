# Setup OSPSuite-R on Windows

The release version of the package comes as a binary `*.zip` and can be downloaded from [here](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/releases).

If you use [RStudio IDE](https://posit.co/download/rstudio-desktop/), you can use the Install option in the Packages pane and select the option Install from -> Package Archive File to install a package from binary `*.zip` files.

To install manually, follow these instructions:

```
# Install dependencies (e.g. R6) which are on CRAN
install.packages('R6')

# Install `{rClr}` from local file 
# (`pathTo_rCLR.zip` here should be replaced with the actual path to the `.zip` file)
install.packages(pathTo_rCLR.zip, repos = NULL)

# Install `{ospsuite.utils}` from local file 
# (`pathTo_ospsuite.utils.zip` here should be replaced with the actual path to the `.zip` file)
install.packages(pathTo_ospsuite.utils.zip, repos = NULL)

# Install `{tlf}` from local file 
# (`pathTo_tlf.zip` here should be replaced with the actual path to the `.zip` file)
install.packages(pathTo_tlf.zip, repos = NULL)

# Install `{ospsuite}` from local file
# (`pathToOSPSuite.zip` here should be replaced with the actual path to the `.zip` file)
install.packages(pathToOSPSuite.zip, repos = NULL)
```

The package also requires the Visual C++ Runtime that is installed with OSPS and can be manually downloaded [here](https://aka.ms/vs/16/release/vc_redist.x64.exe).

