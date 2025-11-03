# OSPSuite-R Package Structure

## Introduction

This document describes the [OSPSuite-R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R) package structure. The package provides OSPSuite functionality in the R programming language. This document covers the package elements, code structure, and components that interface between the OSPSuite .NET codebase and R. 

## OSPSuite-R communication with .NET

The `OSPSuite-R` package provides access to OSPSuite functionality implemented in .NET. The [`{rsharp}` package](https://github.com/Open-Systems-Pharmacology/rsharp) enables communication between R and .NET using C++ as an intermediate layer. .NET communicates with C++ through a custom native host. C++ then communicates with R through the R `.C` interface. Use `{rsharp}` to load libraries compiled from the .NET code.

<!-- TODO: update schema -->
<!-- ![Schema of OSPSuite-R and OSPSuite .NET codebase communication.](../assets/images/r_dotnet_schema.png) -->

On the .NET side, the [OSPSuite.R project in OSPSuite.Core](https://github.com/Open-Systems-Pharmacology/OSPSuite.Core/tree/develop/src/OSPSuite.R) serves as the main entry point for R. This entry point provides access to required Core libraries, including OSPSuite.Core and OSPSuite.Infrastructure. To access PK-Sim functionality, use the separate entry point in the PK-Sim codebase: [PKSim.R](https://github.com/Open-Systems-Pharmacology/PK-Sim/tree/develop/src/PKSim.R).

## OSPSuite-R code structure

The package follows R package best practices for file and code structure. Unlike most R packages, OSPSuite-R uses an object-oriented design. This design reflects the object-oriented structure of PK-Sim and OSPSuite.Core in .NET. 

### Initializing the package

R loads package files [alphabetically](https://roxygen2.r-lib.org/articles/collate.html#:~:text=R%20loads%20files%20in%20alphabetical,t%20matter%20for%20most%20packages.), so [zzz.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/main/R/zzz.R) is evaluated last. This file calls `.onLoad()` to ensure all functions in other files are evaluated first. The `zzz.R` file checks that R is running the x64 version, then calls `.initPackage()`. The [init-package.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/main/R/init-package.R) file uses `{rsharp}` to call the OSPSuite-R package entry point in OSPSuite.Core.

<!-- TODO: Update this section -->
<!-- ### Package entry point to .NET

The entry point as well as the necessary preparations and interfacing in the .NET side of the OSPSuite exists in the [OSPSuite.R project](https://github.com/Open-Systems-Pharmacology/OSPSuite.Core/tree/develop/src/OSPSuite.R) of OSPSuite.Core. This also means in terms of compiled code that the entry point resides in the OSPSuite.R.dll. Specifically in the initialize function from the R side we load the OSPSuite.R.dll and call InitializeOnce() on the .NET side through `{rsharp}`.

[init-package.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/main/R/init-package.R) on the R package side:
```
.
.
.

rClr::clrLoadAssembly(filePathFor("OSPSuite.R.dll"))

.
.
.

rClr::clrCallStatic("OSPSuite.R.Api", "InitializeOnce", apiConfig$ref)
```


[Api.cs](https://github.com/Open-Systems-Pharmacology/OSPSuite.Core/blob/develop/src/OSPSuite.R/Api.cs) in OSPSuite.Core on the .NET side:
```
.
.
.

public static void InitializeOnce(ApiConfig apiConfig)
{
    Container = ApplicationStartup.Initialize(apiConfig);
}
```
On the .NET side, the [OSPSuite.R project](https://github.com/Open-Systems-Pharmacology/OSPSuite.Core/tree/develop/src/OSPSuite.R) of OSPSuite.Core contains all the code that takes care of the necessary preparations (minimal implementations, container registrations, entry points for R calls, task creation etc.) for the interfacing for the R package. Specifically the `InitializeOnce` function takes care of the necessary registrations and loads the dimensions and PK parameters from the corresponding xmls. -->

### Object oriented design and `{rsharp}` encapsulation

OSPSuite-R uses an object-oriented design. The package uses the [R6](https://r6.r-lib.org/) framework to create and work with objects. Calls through `{rsharp}` create objects in the .NET environment. Access these objects through getters, setters, and methods. Encapsulate objects passed from .NET to R in wrapper classes. The base wrapper class is [DotNetWrapper](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/main/R/dot-net-wrapper.R). All specific wrapper classes (for example, for simulations) inherit from `DotNetWrapper`.

The class handles basic object initialization. The `initialize` method (the R6 equivalent of a C# constructor) saves a reference to the .NET object internally:

[DotNetWrapper](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/main/R/dot-net-wrapper.R):
```
#' Initialize a new instance of the class
#' @param ref Instance of the `.NET` object to wrap.
#' @return A new `DotNetWrapper` object.
initialize = function(ref) {
    private$.ref <- ref
}
```

<!-- TODO: Update this part -->
<!-- Then this base wrapper class also defines basic access operations to the encapsulated class. A good such example is how readonly access to a property of the object is provided.

[DotNetWrapper](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/main/R/dot-net-wrapper.R):
```
# Simple way to wrap a get; .NET Read-Only property
wrapReadOnlyProperty = function(propertyName, value) {
    .
    .
    .
    rClr::clrGet(self$ref, propertyName)
}
``` -->

Wrapper classes encapsulate `{rsharp}` calls that work on objects. Users should never call `{rsharp}` directly. All `{rsharp}` calls are encapsulated in wrapper classes or their utility functions (see utilities files below).

Wrap each .NET class with a corresponding wrapper class. Define wrapper classes in separate files named after the R class. For example, the R `Simulation` class wraps an OSPSuite simulation and is defined in [simulation.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/main/R/simulation.R).

The `Simulation` class derives from `ObjectBase`. `ObjectBase` extends `DotNetWrapper` by adding `Name` and `Id` properties:

[simulation.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/main/R/simulation.R):
```
Simulation <- R6::R6Class(
  "Simulation",
  cloneable = FALSE,
  inherit = ObjectBase,
  ...

```

[object-base.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/main/R/object-base.R):
```
#' @title ObjectBase
#' @docType class
#' @description  Abstract wrapper for an OSPSuite.Core ObjectBase.
#'
#' @format NULL
#' @keywords internal
ObjectBase <- R6::R6Class(
  "ObjectBase",
  cloneable = FALSE,
  inherit = DotNetWrapper,
  active = list(
    #' @field name The name of the object. (read-only)
    name = function(value) {
      private$.wrapReadOnlyProperty("Name", value)
    },
    #' @field id The id of the .NET wrapped object. (read-only)
    id = function(value) {
      private$.wrapReadOnlyProperty("Id", value)
    }
  )
)
```

Access simulation properties (for example, the Output Schema) through `DotNetWrapper` functionality:

[simulation.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/main/R/simulation.R)
```
#' @field outputSchema outputSchema object for the simulation (read-only)
outputSchema = function(value) {
  private$.readOnlyProperty(
    "outputSchema",
    value,
    private$.settings$outputSchema
  )
}
```
R wrapper classes must implement a meaningful `print` function. Example:

[simulation.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/main/R/simulation.R)
```
#' @description
#' Print the object to the console
#' @param ... Rest arguments.
print = function(...) {
  ospsuite.utils::ospPrintClass(self)
  ospsuite.utils::ospPrintItems(list(
    "Name" = self$name,
    "Source file" = self$sourceFile
  ))
}
```


Basic access to object methods and properties is often insufficient. Create utility functions for additional functionality and place them in separate utilities files. For example, see [utilities-simulation.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/main/R/utilities-simulation.R). Utilities files contain R code that works on class objects. These files can also include `{rsharp}` calls to .NET functions that operate on objects. Don't place `{rsharp}` calls that only expose object properties or methods in utilities files. Put those in the R wrapper class.

By convention, prefix internal package functions with a dot. For example, use `.runSingleSimulation` instead of `runSingleSimulation`:

[utilities-simulation.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/main/R/utilities-simulation.R)
```
.runSingleSimulation <- function(
  simulation,
  simulationRunOptions,
  population = NULL,
  agingData = NULL
) { ... }
```

Communication between R and .NET has performance overhead. Minimize cross-language calls when possible. 

### Tasks and task caching

Tasks are reusable objects defined on the .NET side that provide functionality for other objects. Access tasks through [Api.cs](https://github.com/Open-Systems-Pharmacology/OSPSuite.Core/blob/develop/src/OSPSuite.R/Api.cs) in OSPSuite.Core. The OSPSuite side creates tasks through the [IoC container](https://en.wikipedia.org/wiki/Inversion_of_control). 

The following example shows how to use the `hasDimension` utility function to check if a dimension (provided as a string) is supported:

[utilities-units.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/main/R/utilities-units.R):
```
#' Dimension existence
#'
#' @param dimension String name of the dimension.
#' @details Returns `TRUE` if the provided dimension is supported otherwise `FALSE`
#' @export
hasDimension <- function(dimension) {
  validateIsString(dimension)
  dimensionTask <- .getNetTaskFromCache("DimensionTask")
  dimensionTask$call("HasDimension", dimension)
}
```


The example calls the internal function `.getNetTaskFromCache` to retrieve the Dimension Task. To avoid repeated retrieval from .NET, tasks are cached on the R side. See [get-net-task.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/main/R/get-net-task.R):

```
#' @title .getNetTaskFromCache
#' @description Get an instance of the specified `.NET` Task that is retrieved
#' from cache if already initiated. Otherwise a new task will be initiated and
#' cached in the `tasksEnv`.
#'
#' @param taskName The name of the task to retrieve (**without** `Get` prefix).
#'
#' @return returns an instance of of the specified `.NET` task.
#'
#' @keywords internal
.getNetTaskFromCache <- function(taskName) {
  if (is.null(tasksEnv[[taskName]])) {
    tasksEnv[[taskName]] <- .getNetTask(taskName)
  }
  return(tasksEnv[[taskName]])
}
```

Tasks are cached in the `tasksEnv[]` list. If a task is not found in the cache, retrieve it from .NET through an `{rsharp}` call and add it to the cache for future use.

### Tests

The OSPSuite-R package includes comprehensive tests. Find test code in [testthat](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/tree/main/tests/testthat). Tests ensure correct and consistent package functioning. They also serve as examples for understanding how objects are created and used.

## Updating Core DLLs

The R package stores local copies of DLLs from OSPSuite.Core and PK-Sim in [`inst/lib/`](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/tree/main/inst/lib). Update these DLLs when a newer version of the .NET codebase is released.

### Run the update workflow

Use the `update-core-files.yaml` GitHub Actions workflow to update the Core DLLs. The workflow automates downloading files and creating a Pull Request.

To run the workflow:

1. Open the [workflow page](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/actions/workflows/update-core-files.yaml) on GitHub.
2. Click **Run workflow**.
3. Select the branch to run the workflow on (typically `main`).
4. (Optional) Configure workflow inputs:
   - **Branch name**: Specify a custom branch name (default: `update-core-files-YYYYMMDD-HHMMSS`)
   - **PR title**: Specify the Pull Request title (default: "Update Core Files")
   - **PR body**: Specify the Pull Request description (default: auto-generated)
5. Click **Run workflow**.

### What the workflow does

The workflow performs these steps:

1. Runs the R script `.github/scripts/update_core_files.R` to download core files from the latest PK-Sim build artifacts.
2. Checks for changes in the `inst/lib/` directory.
3. If changes are detected:
   - Creates a new branch.
   - Commits the updated files.
   - Creates a Pull Request.
   - Builds SQLite libraries for macOS (arm64).

The workflow file is located at [`.github/workflows/update-core-files.yaml`](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/main/.github/workflows/update-core-files.yaml).
