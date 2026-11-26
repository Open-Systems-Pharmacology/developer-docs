# Developer Getting Started in C#

## Installing the prerequisites
1. Install the latest Visual Studio Community Edition or better. [Visual Studio Install](https://www.visualstudio.com/downloads/)

1. Install Ruby and Rake. [Ruby Install](https://rubyinstaller.org/downloads/)

1. Obtain Devexpress License and Install

   * DevExpress WinForms Controls and Libraries is used in the graphical user interface of the suite. You will need to obtain a license in order to work with the user interface.
 
   * DevExpress only provides trials on their current product offering, so you may have to acquire the license prior to downloading an older version if that's required to build the suite.
 
   * Obtain your license from DevExpress [DevExpress Order](https://www.devexpress.com/Support/Order/). Then get the installer for the version mentioned above that's required [DevExpress Install](https://www.devexpress.com/ClientCenter/DownloadManager/)
  
## Authenticating the OSP package feed

The suite uses GitHub Actions as a CI server, which also provides the NuGet feed that the OSP packages (e.g. `OSPSuite.Core`) are published to. GitHub Packages requires authentication even for public packages, so the feed must be registered on your system with your GitHub credentials before the solutions can restore their packages. Registering it once also prevents you from having to enter your GitHub credentials with each new instance of Visual Studio.

1. Create a [personal access token (classic)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) on GitHub with the `read:packages` scope.

1. Register the feed with your GitHub username and the token

   ```
   dotnet nuget add source --username <GITHUB USERNAME> --password <PERSONAL ACCESS TOKEN> --name OSP-GitHub-Packages "https://nuget.pkg.github.com/Open-Systems-Pharmacology/index.json"
   ```

   On Windows, the token is stored encrypted in your user-level NuGet configuration. Password encryption is not supported on Linux and macOS, so add `--store-password-in-clear-text` to the command there.

## Building and Running

1. Clone the repository locally (either from the open-systems-pharmacology organization or from your own fork)
   
1. For PK-Sim and MoBi, run the `postclean.bat` command
 
   There are several requirements to running the software that are not automatically performed when building with Visual Studio. An automated `postclean` batch file is used to take care of these tasks. 

1. Compile Source
  
1. Run Tests

1. Run the Application
