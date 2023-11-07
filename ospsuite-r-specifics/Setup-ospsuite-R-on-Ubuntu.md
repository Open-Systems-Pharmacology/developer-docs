Install on Ubuntu 18.04

# GIT
```
sudo apt install git
```

# NUGET
```
sudo apt install nuget
sudo nuget update -self
```

# LIBS
```
sudo apt update
sudo apt-get install libcurl4-openssl-dev
sudo apt-get install libssl-dev
sudo apt install libxml2-dev
```

# MONO

```
sudo apt install gnupg ca-certificates
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic/snapshots/5.18 main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
sudo apt update
sudo apt install mono-complete
```

Check version with `mono -V`. It should read `5.18.xxx`


# .NET CORE SDK (For ubuntu 18.04..). 

Install vary based on system. see https://learn.microsoft.com/en-us/dotnet/core/install/linux
(e.g. https://docs.microsoft.com/en-us/dotnet/core/install/linux-package-manager-ubuntu-1910)


```
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb

sudo add-apt-repository universe
sudo apt-get update
sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install dotnet-sdk-3.1
```

Check version with `dotnet --version`. It should read `3.1.xxx`

# Install R

```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo apt-get update
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
sudo apt install r-base
```


# Install R Packages

Within a R session in a terminal

```
install.package('devtools')
devtools::install_github("Open-Systems-Pharmacology/rClr")
```

If you need to install package from folder do the following
```
git clone https://github.com/Open-Systems-Pharmacology/rClr.git
cd rClr
```

Within a R session in a terminal
```
devtools::install_local("PATH TO INSTALL")
```

Download ospsuite-r_9.0.18.zip package and unzip  it
then from within a R session (replace with the path of the package)

```
devtools::install_local("/home/michael/Desktop/ospsuite_9.0.18/ospsuite")
```

Install remaining dependencies for Reporting Engine
```
devtools::install_github("Open-Systems-Pharmacology/TLF-Library")
devtools::install_github("Open-Systems-Pharmacology/OSPSuite.ReportingEngine")
```

# Start R Studio with the updated lib path

```
export LD_LIBRARY_PATH=~/OSPSuite-R/inst/lib/:LD_LIBRARY_PATH
```