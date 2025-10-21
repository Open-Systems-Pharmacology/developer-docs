# Developer Getting Started in C#

## Installing the prerequisites
1. Install the latest Visual Studio Community Edition or better. [Visual Studio Install](https://www.visualstudio.com/downloads/)

1. Install Ruby and Rake. [Ruby Install](https://rubyinstaller.org/downloads/)

1. Obtain Devexpress License and Install

   * DevExpress WinForms Controls and Libraries is used in the graphical user interface of the suite. You will need to obtain a license in order to work with the user interface.
 
   * DevExpress only provides trials on their current product offering, so you may have to acquire the license prior to downloading an older version if that's required to build the suite.
 
   * Obtain your license from DevExpress [DevExpress Order](https://www.devexpress.com/Support/Order/). Then get the installer for the version mentioned above that's required [DevExpress Install](https://www.devexpress.com/ClientCenter/DownloadManager/)
  
1. Install nuget.exe and ensure that it is in your `PATH` variable [NuGet Install](https://dist.nuget.org/index.html)

1. Add `OSPSuite.Core` as a nuget source using the following command
```
  nuget sources add -name OSP-GitHub-Packages -source https://nuget.pkg.github.com/Open-Systems-Pharmacology/index.json
```

## Building and Running

1. Clone the repository locally (either from the open-systems-pharmacology organization or from your own fork)
   
1. For PK-Sim and MoBi, run the `postclean.bat` command
 
   There are several requirements to running the software that are not automatically performed when building with Visual Studio. An automated `postclean` batch file is used to take care of these tasks. 

1. Compile Source
  
1. Run Tests

1. Run the Application

## Useful Tips

1. The suite is using GitHub Actions as a CI server which also provides a nuget feed that should be registered on your system. This will prevent you from having to enter GitHub password with each new instance of Visual Studio.

```
nuget sources add -Name OSP-GitHub-Packages -source https://nuget.pkg.github.com/Open-Systems-Pharmacology/index.json -User <GITHUB USERNAME> -Password <PERSONAL ACCESS TOKEN>
```

or

```
dotnet nuget add source --username <GITHUB USERNAME> --password <PERSONAL ACCESS TOKEN> --store-password-in-clear-text --name OSP-GitHub-Packages "https://nuget.pkg.github.com/Open-Systems-Pharmacology/index.json"
```
