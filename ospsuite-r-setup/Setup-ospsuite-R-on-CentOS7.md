# Install tools and libraries
```
yum update
yum install yum-utils
yum install libxml2-devel git nuget
```

# Install Mono 5.18 
```
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
yum-config-manager --add-repo http://repo1.xorcom.com/repos/mono-project/mono-project/
yum install mono-complete-0:5.18.0.240-0.xamarin.2.epel7.x86_64
```
**Note: other Mono versions will not work! If you have a newer Mono version already installed - deinstall it first.**

# Install .NET 
```
rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm
yum install https://packages.microsoft.com/centos/7/prod/netstandard-targeting-pack-2.1.0-x64.rpm
yum install dotnet-sdk-3.1
```

# Install R
## Alternative 1: install the latest R version
```
yum install epel-release
yum install R
```

## Alternative 2: install a specific R version 
Download R version of interest from https://cran.r-project.org/src/base/R-3/ (e.g. R-3.5.2.tar.gz), then execute
```
tar xvzf R-3.5.2.tar.gz
cd R-3.5.2
yum groupinstall "Development Tools"
yum install ncurses-devel zlib-devel texinfo gtk+-devel gtk2-devel qt-devel tcl-devel tk-devel kernel-headers kernel-devel readline-devel bzip2-devel java-11-openjdk-devel
./configure --with-x=no --enable-R-shlib=yes CFLAGS=-fPIC CXXPICFLAGS=-fPIC SHLIB_CFLAGS=-fPIC CPICFLAGS=-fPIC CPPFLAGS=-fPIC CXXFLAGS=-fPIC OBJCFLAGS=-fPIC
make
make install
```

# Install R packages
1. Download **rClr_X.Y.Z_CentOS7.tar.gz** from<br> https://github.com/Open-Systems-Pharmacology/rClr/releases/latest
2. Download **ospsuite_x.y.z_centOS7.tar.gz** from<br> https://github.com/Open-Systems-Pharmacology/OSPSuite-R/releases/latest
3. Start R and install the packages (replace x.y.z with your package versions)
```
install.packages("rClr_X.Y.Z_CentOS7.tar.gz")
install.packages("ospsuite_x.y.z_centOS7.tar.gz")
```

# Adjust LD_LIBRARY_PATH
Before ospsuite-R package can be used in R, LD_LIBRARY_PATH environment variable must be extended with `<R_Lib_Path>/ospsuite/lib`, e.g.: <br>

`export LD_LIBRARY_PATH=/usr/local/lib64/R/library/ospsuite/lib:$LD_LIBRARY_PATH`