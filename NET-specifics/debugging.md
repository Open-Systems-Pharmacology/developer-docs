# Debugging

# Debugging in OSPSuite.Core

In order to be able to test some of the functionalities of the OSPSuite that reside in [OSPSuite.Core](https://github.com/Open-Systems-Pharmacology/OSPSuite.Core) there has been created in Core the OSPSuite.Starter project. You simply have to set it up as a startup project:

![Right click on OSPSuite.Starter project and select "Setup as startup project".](../assets/images/setting%20as%20startup%20project.png)

Then you can start with the debugger in Visual Studio:

![Start debugging.](../assets/images/starting%20with%20debugger.png)

As you can see in the window that appears you can test various Core functionalities both as a user and through breakpoints in code.

![The starter view.](../assets/images/starter%20view.png)

## Developing between solutions

For some tasks, it's necessary to implement partially in OSPSuite.Core and partially in MoBi or PK-Sim. In those cases, it can be tedious to create pull requests in OSPSuite.Core and get them merged, so you can use them to implement the feature in MoBi or PK-Sim. Then, if you find bugs or additional requirements as you code, you need to create more pull requests and wait for them to be merged.

To accommodate an all local workflow of creating local OSPSuite.Core and using it directly in your local PK-Sim or MoBi Visual Studio solutions, the following steps are needed once to set up your local environment:

1) Create a `nuget_repo` folder in the same directory as the `OSPSuite.Core.sln` file.
2) Add the nuget_repo folder as a nuget source in Visual Studio. To do that go to Tools -> Options -> NuGet Package Manager -> Package Sources and add the nuget_repo folder as a new source.
3) Arrange your working directories for `MoBi`, `PK-Sim` and `OSPSuite.Core` so they are all contained in the same parent directory.
4) Make sure the directories for `MoBi`, `PK-Sim` and `OSPSuite.Core` are named `MoBi`, `PK-Sim` and `OSPSuite.Core` respectively.

Then you can always update one or both applications with local versions of OSPSuite.Core using scripts:

1) mobi_nuget.bat to update only MoBi
2) mobi_pksim.bat to update only PK-Sim
3) nuget_to_both.bat to update both MoBi and PK-Sim
4) Rebuild the application solution with the new dependencies.

This workflow will change the .csproj files in the application solutions to use the local version of OSPSuite.Core. Those OSPSuite.Core builds will not be available for other users or AppVeyor of course, so you need a new OSPSuite.Core build from AppVeyor to finalize development. First create a pull request in OSPSuite.Core and get it merged. Then you need to update the dependencies in the application .csproj to use the new version of OSPSuite.Core as built by AppVeyor.

## Debugging between solutions
Beyond directly using the newly implemented code in OSPSuite.Core, you can also use the debugger to debug the code in Core from the other solutions. To do that you need to:

1) Set up your environment as above once
2) Update dependencies as above as needed
3) Start the application from Visual Studio without debugging
4) Attach the Visual Studio debugger from the OSPSuite.Core solution to the application process. You can now set breakpoints and debug the code in Core from the other solutions.

# Debugging from R script

You can also debug the OSPSuite.Core code from an R script. To do that you need to

1)  Build Core in the "Debug" configuration.

2) Copy the created dlls and associated .pdb files from "OSPSuite.Core\src\OSPSuite.R\bin\Debug\netstandard2.0\" to your OSPSuite.R installation directory and specifically in the "OSPSuite-R\inst\lib\" folder.

3) Start the OSPSuite.R project in R 
![Ospsuite.R RStudio project file.](../assets/images/![The starter view.](../assets/images/ospsuite-r-project.png)

4) Attach the Visual Studio debugger from the OSPSuite.Core solution to the RSession. Make sure to attach to rsession NOT to rstudio.exe.
![Attach to rsession.](../assets/images/![The starter view.](../assets/images/rsession.png)

5) Load using devtools and load_all to make sure the symbol files also get loaded:

```
devtools::load_all(".")
```
Now you can continue debugging. Note that if you have set a breakpoint in the part of the OSPSuite.Core code that gets called during the loading of OSPSuite.R, the debugger will already stop on it when you call `load_all(".")`. 

## Creating local nuget packages from Core

Sometimes just copying the dlls from Core to PK-Sim or MoBi is not enough. This is the case when you write e.g. a new interface in Core that you need to implement in PK-Sim or MoBi. So let's say you have done such a change to your local OSPSuite.Core code and now you want to continue coding in MoBi, but you are not yet finished or for some other reason you do not yet want to merge your changes to the `develop` branch of Core and then update your MoBi nuget packages from the AppVeyor build. For such cases you can create nuget packages from your edited OSPSuite.Core codebase and install them to the other solutions or to OSPSuite.R.

In order for this to work a few scripts have been developed that create the nuget packages locally under "OSPSuite.Core\nuget_repo" and also apply the changes in the respective solutions, provided that the repository folders are under the same root folder. 
Using the "pksim_nuget" batch file will create the nuget packages from the local OSPSuite.Core source code and update PK-Sim, "mobi_nuget" will do the same for MoBi, "nuget_to_both" creates nuget packages for and updates both PK-Sim and MoBi and finally "nuget_to_all" does this for PK-Sim, MoBi and OSPSuite.R.
