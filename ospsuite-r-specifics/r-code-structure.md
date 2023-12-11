# OSPSuite-R Package Structure

## Introduction

In this part of the documentation we will talk about the specifics of the [OSPSuite-R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R) package. This is a package that offers the functionalities of OSPSuite to the R language. We will analyze its elements and code structure, as well as the components that enable us to interface between the OSPSuite codebase in the .NET universe and the R programming language. 

## OSPSuite-R communication with .NET

The `OSPSuite-R` package offers access to functionalities of OSPSuite that are implemented in .NET. The communication between R and .NET using C++ as an intermediate layer is provided by the [rClr package](https://github.com/Open-Systems-Pharmacology/rClr). .NET can communicate with C++ using a custom native host and C++ can then communicate with R through the R .C interface. Using `rClr` we can load the libraries compiled from the .NET code and use them.

![Schema of OSPSuite-R and OSPSuite .NET codebase communication.](../assets/images/r_dotnet_schema.png)

On the .NET side of the OSPSuite, the main project that functions as an entry point for R is [OSPSuite.R in OSPSuite.Core](https://github.com/Open-Systems-Pharmacology/OSPSuite.Core/tree/develop/src/OSPSuite.R). Through it, the package gains access to the other Core libraries that are necessary, like OSPSuite.Core and OSPSuite.Infrastructure. Additionally, in order to access PK-Sim functionalities, a separate entry point exists in the PK-Sim codebase, in [PKSim.R](https://github.com/Open-Systems-Pharmacology/PK-Sim/tree/develop/src/PKSim.R).

## OSPSuite-R code structure

The general file and code structure of the package follows the best practices of R packages. What is special in this package is that OSPSuite-R is strongly object-oriented. Usually R packages tend to be more functional-programming-oriented. This object-oriented tendency comes as a result of using many of the functionalities of PK-Sim and OSPSuite.Core, that are already structured in an object oriented way in .NET. 

### Initializing the package

As per convention with R packages, [zzz.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/zzz.R) is the last file to be evaluated when loading the package, since R loads package files [alphabetically](https://roxygen2.r-lib.org/articles/collate.html#:~:text=R%20loads%20files%20in%20alphabetical,t%20matter%20for%20most%20packages.). For this reason it is the place where `.onLoad()` function is called, to ensure that all the necessary functions defined in other files have already been evaluated. In our case, the `zzz.R` does not contain much more than a check that we are running under the necessary x64 version of R and then call .initPackage(). [init-package.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/init-package.R) then uses rClr to call the entry point of the OSPSuite-R package in the .NET code of OSPSuite.Core.


### Package entry point to .NET

The entry point as well as the necessary preparations and interfacing in the .NET side of the OSPSuite exists in the [OSPSuite.R project](https://github.com/Open-Systems-Pharmacology/OSPSuite.Core/tree/develop/src/OSPSuite.R) of OSPSuite.Core. This also means in terms of compiled code that the entry point resides in the OSPSuite.R.dll. Specifically in the initialize function from the R side we load the OSPSuite.R.dll and call InitializeOnce() on the .NET side through rClr.

[init-package.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/init-package.R) on the R package side:
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
On the .NET side, the [OSPSuite.R project](https://github.com/Open-Systems-Pharmacology/OSPSuite.Core/tree/develop/src/OSPSuite.R) of OSPSuite.Core contains all the code that takes care of the necessary preparations (minimal implementations, container registrations, entry points for R calls, taks creation etc.) for the interfacing for the R package. Specifically the `InitializeOnce` function takes care of the necessary registrations and loads the dimensions and PK parameters from the corresponding xmls.

### Object oriented design and rClr encapsulation

As already mentioned the OSPSuite-R package is strongly object oriented. In R there are various object-oriented frameworks, but in the case of OSPSuite-R we are using [R6](https://r6.r-lib.org/) to create objects and work with them. Since the .NET codebase of OSPSuite is object oriented, the calls that we do through rClr have as a result the creation of objects in the .NET universe. Then we proceed to work on those objects through getters, setter, methods etc. Those objects that get passed to the R universe through rClr we encapsulate in wrappers. Our main base wrapper class for .NET is [DotNetWrapper](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/dot-net-wrapper.R). All other wrapper classes for specific types of objects ( e.g. for a simulation) ultimately inherit from `DotNetWrapper`.

As you can see in the code of the class, it takes care of the basic initialization of the object (`initialize` is the R6 equivalent of a C# constructor) by internally saving a reference to the .NET object:

[DotNetWrapper](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/dot-net-wrapper.R):
```
#' Initialize a new instance of the class
#' @param ref Instance of the `.NET` object to wrap.
#' @return A new `DotNetWrapper` object.
initialize = function(ref) {
    private$.ref <- ref
}
```
Then this base wrapper class also defines basic access operations to the encapsulated class. A good such example is how readonly access to a property of the object is provided.

[DotNetWrapper](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/dot-net-wrapper.R):
```
# Simple way to wrap a get; .NET Read-Only property
wrapReadOnlyProperty = function(propertyName, value) {
    .
    .
    .
    rClr::clrGet(self$ref, propertyName)
}
```

As you can see the wrapper class encapsulates the rClr calls that work on the objects. This is very important. In the OSPSuite-R package the user should never directly have to use or see rClr calls: they are all encapsulated in the wrapper classes or their utilities (that function as extensions to those classes, we will get to that a bit later on).

Specific .NET classes are being wrapped by their corresponding wrapper classes. Those wrapper classes HAVE to be defined in a separate file named after the R class. For example we have the R Simulation class that wraps an OSPSuite simulation and is defined in [simulation.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/simulation.R). 

Note that this class derives from `ObjectBase`, that is basically a `DotNetWrapper` with a Name and Id added to it:

[simulation.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/simulation.R):
```
Simulation <- R6::R6Class(
  "Simulation",
  cloneable = FALSE,
  inherit = ObjectBase,
  .
  .

```

[object-base.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/object-base.R):
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
      private$wrapReadOnlyProperty("Name", value)
    },
    #' @field id The id of the .NET wrapped object. (read-only)
    id = function(value) {
      private$wrapReadOnlyProperty("Id", value)
    }
  )
)
```

As you can see in the R simulation class, we provide access to simulation properties (like f.e. the simulation Output Schema) using the functionalities of the `DotNetWrapper`:

[simulation.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/simulation.R)
```
#' @field outputSchema outputSchema object for the simulation (read-only)
outputSchema = function(value) {
    private$readOnlyProperty("outputSchema", value, private$.settings$outputSchema)
}
```
Please note that it is a requirement for these R wrapper classes to implement a meaningful print function. In our example:

[simulation.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/simulation.R)
```
#' @description
#' Print the object to the console
#' @param ... Rest arguments.
print = function(...) {
    private$printClass()
    private$printLine("Number of individuals", self$count)
    invisible(self)
}
```


Many times the basic access to the object methods and properties is not sufficient, and we need further functionalities on the objects. For this we create a functions that work on that objects and pack them in separate utilities files. For our example with simulation, we have [utilities-simulation.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/utilities-simulation.R). These utilities files contain R code that works on the created objects of the class, but also if necessary rClr calls to .NET functions that work on the objects. Note that rClr functions that just expose properties or methods of the objects do NOT belong here, but in the R wrapper class. 

Please also note that per convention all functions that are only used internally by the package are named starting with a dot. For example `.runSingleSimulation` and not just `runSingleSimulation`:

[utilities-simulation.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/utilities-simulation.R)
```
.runSingleSimulation <- function(simulation, simulationRunOptions, population = NULL, agingData = NULL) {
```



The communication between R and .NET does not come without some overhead. This means that when we can avoid it we should. 

### Tasks and task caching

Often when working with objects we use tasks. Those tasks are objects defined and created on the .NET side that are reusable and can provide functionalities on other objects. They can be accessed through the [Api.cs](https://github.com/Open-Systems-Pharmacology/OSPSuite.Core/blob/develop/src/OSPSuite.R/Api.cs) of OSPSuite.Core as usual - on the OSPSuite side they are created through the [IoC container](https://en.wikipedia.org/wiki/Inversion_of_control). Let's see for example how we can use the HasDimension utility function of the unit wrapper class to check if a dimension (provided as a string) is supported.

[utilities-units.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/utilities-units.R):
```
#' @param dimension String name of the dimension.
#' @details Returns `TRUE` if the provided dimension is supported otherwise `FALSE`
#' @export
hasDimension <- function(dimension) {
  validateIsString(dimension)
  dimensionTask <- .getNetTaskFromCache("DimensionTask")
  rClr::clrCall(dimensionTask, "HasDimension", enc2utf8(dimension))
}
```


As you can see in order to retrieve the Dimension Task, we call the internal function `.getNetTaskFromCache`. In order to avoid having to get them from .NET all the time, we cache them on the R side. As you can see in [get-net-task.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/get-net-task.R):

```
.
.
.

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

we cache the tasks in the `tasksEnv[]` list. If we do not find a task in the cache we retrieve it from .NET through an rClr call and we also add it to the cache for future use.

### Tests

The OSPSuite-R package is well tested and you can find all the code for the tests as usual under [testthat](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/tree/develop/tests/testthat). Apart from guaranteeing the correct and consistent functioning of the package, the tests are also a good entry point to finding out about how the rest of the code works, f.e. how objects get created and used and so on.

## Updating Core dlls

The R package keeps local copies of the necessary dlls coming from OSPSuite.Core and PK-Sim that are necessary for it to function. When a newer version of the .NET codebase is available, those dlls need to be updated semi-manually. Those dlls have to exist under [OSPSuite-R/inst/lib/](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/tree/develop/inst/lib). 

The first step to updating to a newer version of Core is updating the nuget package versions to the correct version. For this you have to manually edit the version numbers in [packages.config](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/packages.config), like the version number in OSPSuite.Core seen here underneath:

```
<?xml version="1.0" encoding="utf-8"?>
<packages>
  .
  .
  .

  <package id="OSPSuite.Core" version="12.0.242"/>
  .
  .

</packages>
```

Then you have to go to the command line in the OSPSuite-R repository main folder and run:
```
nuget restore packages.config -PackagesDirectory packages
```
Note that [nuget](https://learn.microsoft.com/en-us/nuget/install-nuget-client-tools?tabs=windows#nugetexe-cli) has to have been added to the Path (quick guide on how to do this [here](https://www.c-sharpcorner.com/article/how-to-addedit-path-environment-variable-in-windows-11/)), otherwise you will need to provide the full path to nuget.exe.

This will fill the `OSPSuite-R/packages/`packages folder with the correct updated packages. Then you need to manually copy them and paste them to `OSPSuite-R/inst/lib/`.


# Repository Submodules

Exactly the same as with PKSim and MoBi repositories, the OSPSuite.R repository shares some common submodules 

* [scripts](https://github.com/Open-Systems-Pharmacology/build-scripts) that contains scripts for building, updating and so on.

* [PK Parameters](https://github.com/Open-Systems-Pharmacology/OSPSuite.PKParameters) that contains a list of PK Parameters supported by the OSPSuite

* [Dimensions](https://github.com/Open-Systems-Pharmacology/OSPSuite.Dimensions) that contains a list of dimensions supported by the OSPSuite

Supported PK Parameters and Dimensions are read on loading of the R package from the xml file that comes from the submodules. This means that when for example a new supported dimension is to be added for the OSPSuite, it need to be added only to the subrepository and is automatically available in all other projects. 
