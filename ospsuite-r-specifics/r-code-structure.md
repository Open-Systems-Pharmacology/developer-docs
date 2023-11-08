# OSPSuite-R Package Structure

## Introduction

In this part of the documentation we will talk about the specifics of the [OSPSuite-R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R) package. This is a package that offers the functionalities of OSPSuite to the R language. We will anaylize its elements and code structure, as well as the components that enable us to interface between the OSPSuite codebase in the .NET universe and the R programming language. 

## OSPSuite-R communication with .NET

As mentioned, through the OSPSuite-R package we get OSPSuite functionalities available in the R programming language. Those OSPSuite functionalities though have been developed and exist in the .NET universe. In order to provide them in R we have to enable communication bewtween R and .NET. To do this we are currently using the [rClr package](https://github.com/Open-Systems-Pharmacology/rClr). This package allows the communication between R and .NET using C++ as an intermediate layer. .NET can communicate with C++ using a custom native host and C++ can then communicate with R through the R .C interface. This is why we need to have the rClr package installed in R for OSPSuite-R to work. Using rClr we can load the dlls produced from the .NET code and use them.

![Schema of OSPSuite-R and OSPSuite .NET codebase communication.](../assets/images/r_dotnet_schema.png)

## OSPSuite-R code structure


The general file and code structure of the package follows the best practices of R packages. What is special in this package is that OSPSuite-R is strongly object-oriented. Usually R packages tend to be more functional-programming-oriented. This object-oriented tendency comes as a result of using many of the functionalities of PK-Sim and OSPSuite.Core, that are already structure in an object oriented way in .NET. 

### Initializing the package

As per convention with R packages, [zzz.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/zzz.R) is the first file that gets executed when loading the package. This is the normal way that R packages work. In our case it does not do much more than check that we are running under the necessary x64 version of R and then call .initPackage(). [init-package.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/init-package.R) then uses rClr to call the entry point of the OSPSuite-R package in the .NET code of OSPSuite.Core.


### Package entry point to .NET

The entry point as well as the necessary preparations and interfacing in the .NET side of the OSPSuite exists in the [OSPSuite.R project](https://github.com/Open-Systems-Pharmacology/OSPSuite.Core/tree/develop/src/OSPSuite.R) of OSPSuite.Core. This also means in terms of compiled code that the entry point resides in the OSPSuite.R.dll. Specifically in the initialize function from the R side we load the OSPSuite.R.dll and call InitializeOnce() on the .NET side through rClr.

[init-package.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/init-package.R) on the R package side.
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


[Api.cs](https://github.com/Open-Systems-Pharmacology/OSPSuite.Core/blob/develop/src/OSPSuite.R/Api.cs) in OSPSuite.Core on the .NET side.
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

As already mentioned the OSPSuite-R package is strongly object oriented. In R there are various object-oriented frameworks, but in the case of OSPSuite-R we are using [R6](https://r6.r-lib.org/) to create objects and work with them. Since the .NET codebase of OSPSuite is object oriented, the calls that we do it through rClr have as a result the creation of objects in the .NET universe. Then we proceed to work on those objects through getters, setter, methods etc. Those objects that get passed to the R universe through rClr we encapsulate in wrappers. Our main base wrapper class for .NET is [DotNetWrapper](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/dot-net-wrapper.R). All other wrapper classes for specific types of objects ( f.e. fro a simulation) ultimately inherit from `DotNetWrapper`.

As you can see in the code of the class, it takes care of the basic initialization of the object (`initialize` is the R6 equivalent of a C# constructor) by internally saving a reference to the .NET object:

[DotNetWrapper](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/dot-net-wrapper.R)
```
#' Initialize a new instance of the class
#' @param ref Instance of the `.NET` object to wrap.
#' @return A new `DotNetWrapper` object.
initialize = function(ref) {
    private$.ref <- ref
}
```
Then this base wrapper class also defines basic access operations to the encapsulated class. A good such example is how readonly access to a property of the object is provided.

[DotNetWrapper](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/dot-net-wrapper.R)
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

Specific .NET classes are being wrapped by their corresponding wrapper classes. Those wrapper classes HAVE to be defined in a separate file named ofter the R class. For example we have the R Simulation class that wraps an OSPSuite simulation and is defined in [simulation.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/simulation.R). 

Note that this class derives from `ObjectBase`, that is basically a `DotNetWrapper` with a Name and Id added to it:

[simulation.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/simulation.R)
```
Simulation <- R6::R6Class(
  "Simulation",
  cloneable = FALSE,
  inherit = ObjectBase,
  .
  .

```

[object-base.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/object-base.R)
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

Many times the basic access to the object methods and properties is not sufficient, and we need further functionalities on the objects. For this we create a functions that work on that objects and pack them in separate utilities files. For our example with simulation, we have [utilities-simulation.R](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/blob/develop/R/utilities-simulation.R). These utilities files contain R code that works on the created objects of the class, but also if necessary rClr calls to .NET functions that work on the objects. Note that rClr functions that just expose properties or methods of the objects do NOT belong here, but in the R wrapper class. 









--- in tests we have sample code




--- to also check: every class in R corresponding to a .NET class should implement a meaningful print method.(26')

(29') we do not always have a separate class in R for .NET objects. Sometimes there are "intermediate" objects that just get created and used in .NET and we let them just exist there. A good example for this is the dimension (also has_dimension in utilities units and the dimension_task)


### Tasks and taks cache
--- then we also have to check the dimensionTask in the OSPSuite Core end.

the communication between R and .NET is relatively slow, so we should also try to avoid passing objects from one to another of there is no explicit reason for this.
--especially for tasks.
that's why we are caching tasks for example and not creating or getting them anew every time we need them. we actually have a function that automatically checks if we have a task with that name in the cache, and if not we create it and add it to the cache.

also all internal functions to the package (meaning that they are not exposed to the user) are named beggining with a dot.

here example:

So also note and we need an example: in the init we establish the communication with the .NET dlls through rClr. also add a link to the ospsuite.R repository in Core.


## Updating Core dlls

The R package keeps local copies of the necessary dlls coming from OSPSuite.Core and PK-Sim that are necessary for it to function. When a newer version of teh .NET codebase is available, those dlls need to be updated manually. Those dlls reside under [OSPSuite-R/inst/lib/](https://github.com/Open-Systems-Pharmacology/OSPSuite-R/tree/develop/inst/lib). Let's take f.e. the case for updating the dlls for a change in OSPSuite.Core. [Appveyor](https://ci.appveyor.com/) (which is OSPSuite continuous integration tool) builds the nightly of the updated develop branch. The build of the nightly creates some artifacts, under which als exist the dlls that need to be copied to `OSPSuite-R/inst/lib/`:





inst/lib are the dlls. Most of them come from Core, 

...but there are a few PKSim ones ()
????.config nuget : not sure how this works, probably just for appveyor??? 

after updating you have to push


(55') also let's do screenshots for the nightly f.e.

and we have to check a bit what we do with the nuget versioning. 
we actually need the dlls in the package/repository, so we can make it work also without OSPSuite code. 

# Repository Submodules

Exactly the same as with PKSim and MoBi repositories, the OSPSuite.R repository shares some common submodules 

* [scripts](https://github.com/Open-Systems-Pharmacology/build-scripts) that contains scripts for bulding, updating and so on.

* [PK Parameters](https://github.com/Open-Systems-Pharmacology/OSPSuite.PKParameters) that contains a list of PK Parameters supported by the OSPSuite

* [Dimensions](https://github.com/Open-Systems-Pharmacology/OSPSuite.Dimensions) that contains a list of dimensions supported by the OSPSuite

Supported PK Parameters and Dimensions are read on loading of the R package from the xml file that comes from the submodules. This means that when for example a new supported dimension is to be added for the OSPSuite, it need to be added only to the subrepository and is automatically available in all other projects. 
