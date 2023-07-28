# Debugging

# Debugging in OSPSuite.Core

In order to be able to test some of the functionalities of the OSPSuite that reside in [OSPSuite.Core](https://github.com/Open-Systems-Pharmacology/OSPSuite.Core) there has been created in Core the OSPSuite.Starter project. You simply have to set it up as a startup project:

![Right click on OSPSuite.Starter project and select "Setup as startup project".](../assets/images/setting%20as%20startup%20project.png)

Then you can start with the debugger in Visual Studio:

![Start debugging.](../assets/images/starting%20with%20debugger.png)

As you can see in the window that appears you can test various Core functionalities both as a user and through breakpoints in code.

![The starter view.](../assets/images/starter%20view.png)

## Debugging between solutions

Apart from normally debugging through visual studio, sometimes there is the need to debug code that exists in OSPSuite.Core when running PKSim or MoBi. In order to do that you need to build OSPSuite.Core in the debug configuration. Then go to the solution folder and run "copy_to_pksim" or "copy_to_mobi" batch according to which solution you want to debug from core. 
You need to have the corresponding solution folder under the same parent directory, let's call it ROOT. So your OSPSuite.Core path would look lie this "..\ROOT\OSPSuite.Core". 
Then go to "ROOT\PK-Sim\src\PKSim\bin\Debug\net472" and start the PKSim.exe. When the application has started attach the debugger from Core to the process.

For MoBi you have to go to "ROOT\MoBi\src\MoBi\bin\Debug\net472", start "MoBi.exe" and accordingly attach the debugger from Core to the MoBi process.

# Debugging from R script

You can also debug the OSPSuite.Core code from an R script. To do that you need to

1)  Build Core in the "Debug" configuration.

2) Copy the created dlls and associated .pdb files from "OSPSuite.Core\src\OSPSuite.R\bin\Debug\netstandard2.0\" to the your OSPSuite.R installation directory and specifically in the "OSPSuite-R\inst\lib\" folder.

3) Start the OSPSuite.R project in R 
![Ospsuite.R RStudio project file.](../assets/images/![The starter view.](../assets/images/starter%20view.png)

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
