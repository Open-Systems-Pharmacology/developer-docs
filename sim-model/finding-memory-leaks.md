# Introduction

The [OSPSuite.SimModel](https://github.com/Open-Systems-Pharmacology/OSPSuite.SimModel) is a the component of the OSPSuite, written mainly in C++, that reads the model description in its XML format, creates a differential equations system from it and solves it. In this part of the documentation we will describe how to use the Visual Leak Detector to detect memory leaks in the C++ code.

# Using the Visual Leak Detector
Looking for memory leaks in SimModel when used in PK-Sim (MoBi, etc. - same procedure)
1. Install **Visual Leak Detector for Visual C++** (VLD) from ~https://github.com/KindDragon/vld/releases~
<br>EDIT 2022: VLD development continues now here: [https://github.com/Azure/vld](https://github.com/Azure/vld) (latest release: [https://github.com/Azure/vld/releases](https://github.com/Azure/vld/releases))
2. Open SimModel solution in Visual Studio and uncomment the line `#include <vld.h>` in **src/OSPSuite.SimModelNative/src/Simulation.cpp**
3. If VLD was installed NOT into the default path: open project settings of **OSPSuite.SimModelNative** and adjust the paths in the Debug-configuration
![grafik](https://user-images.githubusercontent.com/25061876/74615676-4154c080-5123-11ea-9d2a-b8db8732d4cf.png)
4. Build the Debug version of **OSPSuite.SimModelNative**
5. Copy **OSPSuite.SimModelNative.dll** and **OSPSuite.SimModelNative.pdb** from _<SimModel_SolutionDir>\Build\\**Debug**\x64_ into the PK-Sim folder
6. Copy the **_Debug_** version of **OSPSuite.FuncParserNative.dll** and **OSPSuite.FuncParserNative.pdb** from the corresponding Nuget package into the PK-Sim folder
7. Copy the **_Debug_** version of **OSPSuite.SimModelSolver_CVODES.dll** and **OSPSuite.SimModelSolver_CVODES.pdb** from the corresponding Nuget package into the PK-Sim folder
8. Open "**C:\Program Files (x86)\Visual Leak Detector\vld.ini**" in a text editor and set
* `AggregateDuplicates = yes`
* `ForceIncludeModules = <list of additional C++ libs to include> `<br>
E.g. to profile FuncParser as well: `ForceIncludeModules = OSPSuite.FuncParserNative.dll`
* `ReportFile = <path to report file>` Leak report will be created here<br>
E.g. `ReportFile = C:\Temp\SimModelLeaks.txt`
* `ReportTo = file` or `ReportTo = both`
* `StackWalkMethod = fast`
9. Start PK-Sim and perform actions you would like to profile (run individual/population simulations, perform sensitivity analysis, parameter identifications, ...)
10. Close PK-Sim. Leak report is now available in the `<path to report file>` defined in vld.ini

<details><summary><b>Example vld.ini</b></summary>

```
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Visual Leak Detector - Initialization/Configuration File
;;  Copyright (c) 2005-2017 VLD Team
;;
;;  This library is free software; you can redistribute it and/or
;;  modify it under the terms of the GNU Lesser General Public
;;  License as published by the Free Software Foundation; either
;;  version 2.1 of the License, or (at your option) any later version.
;;
;;  This library is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;  Lesser General Public License for more details.
;;
;;  You should have received a copy of the GNU Lesser General Public
;;  License along with this library; if not, write to the Free Software
;;  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
;;
;;  See COPYING.txt for the full terms of the GNU Lesser General Public License.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Any options left blank or not present will revert to their default values.
[Options]

; The main on/off switch. If off, Visual Leak Detector will be completely
; disabled. It will do nothing but print a message to the debugger indicating
; that it has been turned off.
;
;  Valid Values: on, off
;  Default: on
;
VLD = on

; If yes, duplicate leaks (those that are identical) are not shown individually.
; Only the first such leak is shown, along with a number indicating the total
; number of duplicate leaks.
;
;   Valid Values: yes, no
;   Default: no
;
AggregateDuplicates = yes

; Lists any additional modules to be included in memory leak detection. This can
; be useful for checking for memory leaks in debug builds of 3rd party modules
; which can not be easily rebuilt with '#include "vld.h"'. This option should be
; used only if absolutely necessary and only if you really know what you are
; doing.
;
;   CAUTION: Avoid listing any modules that link with the release CRT libraries.
;     Only modules that link with the debug CRT libraries should be listed here.
;     Doing otherwise might result in false memory leak reports or even crashes.
;
;   Valid Values: Any list containing module names (i.e. names of EXEs or DLLs)
;   Default: None.
;
ForceIncludeModules = OSPSuite.FuncParserNative.dll

; Maximum number of data bytes to display for each leaked block. If zero, then
; the data dump is completely suppressed and only call stacks are shown.
; Limiting this to a low number can be useful if any of the leaked blocks are
; very large and cause unnecessary clutter in the memory leak report.
;
;   Value Values: 0 - 4294967295
;   Default: 256
;
MaxDataDump = 

; Maximum number of call stack frames to trace back during leak detection.
; Limiting this to a low number can reduce the CPU utilization overhead imposed
; by memory leak detection, especially when using the slower "safe" stack
; walking method (see StackWalkMethod below).
;
;   Valid Values: 1 - 4294967295
;   Default: 64
;
MaxTraceFrames = 

; Sets the type of encoding to use for the generated memory leak report. This
; option is really only useful in conjuction with sending the report to a file.
; Sending a Unicode encoded report to the debugger is not useful because the
; debugger cannot display Unicode characters. Using Unicode encoding might be
; useful if the data contained in leaked blocks is likely to consist of Unicode
; text.
;
;   Valid Values: ascii, unicode
;   Default: ascii
;
ReportEncoding = ascii

; Sets the report file destination, if reporting to file is enabled. A relative
; path may be specified and is considered relative to the process' working
; directory.
;
;   Valid Values: Any valid path and filename.
;   Default: .\memory_leak_report.txt
;
ReportFile = C:\Temp\SimModelLeaks.txt

; Sets the report destination to either a file, the debugger, or both. If
; reporting to file is enabled, the report is sent to the file specified by the
; ReportFile option.
;
;   Valid Values: debugger, file, both
;   Default: debugger
;
ReportTo = both

; Turns on or off a self-test mode which is used to verify that VLD is able to
; detect memory leaks in itself. Intended to be used for debugging VLD itself,
; not for debugging other programs.
;
;   Valid Values: on, off
;   Default: off
;
SelfTest = off

; Selects the method to be used for walking the stack to obtain stack traces for
; allocated memory blocks. The "fast" method may not always be able to
; successfully trace completely through all call stacks. In such cases, the
; "safe" method may prove to more reliably obtain the full stack trace. The
; disadvantage is that the "safe" method is significantly slower than the "fast"
; method and will probably result in very noticeable performance degradation of
; the program being debugged.
;
;   Valid Values: fast, safe
;   Default: fast
; 
StackWalkMethod = fast

; Determines whether memory leak detection should be initially enabled for all
; threads, or whether it should be initially disabled for all threads. If set
; to "yes", then any threads requiring memory leak detection to be enabled will
; need to call VLDEnable at some point to enable leak detection for those
; threads.
;
;   Valid Values: yes, no
;   Default: no
;
StartDisabled = no

; Determines whether or not all frames, including frames internal to the heap,
; are traced. There will always be a number of frames internal to Visual Leak
; Detector and C/C++ or Win32 heap APIs that aren't generally useful for
; determining the cause of a leak. Normally these frames are skipped during the
; stack trace, which somewhat reduces the time spent tracing and amount of data
; collected and stored in memory. Including all frames in the stack trace, all
; the way down into VLD's own code can, however, be useful for debugging VLD
; itself.
;
;   Valid Values: yes, no
;   Default: no
;
TraceInternalFrames = no

; Determines whether or not report memory leaks when missing HeapFree calls.
;
;   Valid Values: yes, no
;   Default: no
;
SkipHeapFreeLeaks = no

; Determines whether or not report memory leaks generated from crt startup code.
; These are not actual memory leaks as they are freed by crt after the VLD object
; has been destroyed.
;
;   Valid Values: yes, no
;   Default: yes
;
SkipCrtStartupLeaks = yes
```
</details>

<details><summary><b>Example VLD report (no leaks)</b></summary>

```
Visual Leak Detector Version 2.5.1 installed.
    Aggregating duplicate leaks.
    Forcing inclusion of these modules in leak detection: ospsuite.simmodelnative.dll
    Outputting the report to the debugger and to C:\Temp\SimModelLeaks.txt
No memory leaks detected.
Visual Leak Detector is now exiting.
```
</details>

<details><summary><b>Example VLD report (leaks detected)</b></summary>

```
Visual Leak Detector Version 2.5.1 installed.
    Aggregating duplicate leaks.
    Forcing inclusion of these modules in leak detection: ospsuite.simmodelnative.dll
    Outputting the report to the debugger and to C:\Temp\SimModelLeaks.txt
WARNING: Visual Leak Detector detected memory leaks!
---------- Block 2591982 at 0x00000000D10D0C40: 16 bytes ----------
  Leak Hash: 0x9F3C55E1, Count: 8, Total 128 bytes
  Call Stack:
    ucrtbased.dll!realloc()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Include\SimModel\TObjectVector.h (44): OSPSuite.SimModelNative.dll!SimModelNative::TObjectVector<SimModelNative::ValuePoint>::push_back() + 0x1E bytes
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\TableFormula.cpp (413): OSPSuite.SimModelNative.dll!SimModelNative::TableFormula::SetTablePoints()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Parameter.cpp (283): OSPSuite.SimModelNative.dll!SimModelNative::Parameter::SetTablePoints()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Simulation.cpp (1332): OSPSuite.SimModelNative.dll!SimModelNative::Simulation::SetParametersValues()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\src\PInvokeSimulation.cpp (841): OSPSuite.SimModelNative.dll!SetParameterValues()
    (Module name unavailable)!0x00007FFA2DD726FF()
  Data:
    30 20 7F F7    8C 01 00 00    90 20 7F F7    8C 01 00 00     0....... ........


---------- Block 2591983 at 0x00000000DC3CBA00: 16 bytes ----------
  Leak Hash: 0x109A42D6, Count: 8, Total 128 bytes
  Call Stack:
    ucrtbased.dll!malloc()
    d:\agent\_work\3\s\src\vctools\crt\vcstartup\src\heap\new_array.cpp (29): OSPSuite.SimModelNative.dll!operator new[]()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\TableFormula.cpp (99): OSPSuite.SimModelNative.dll!SimModelNative::TableFormula::CacheValues() + 0x3A bytes
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\TableFormula.cpp (416): OSPSuite.SimModelNative.dll!SimModelNative::TableFormula::SetTablePoints()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Parameter.cpp (283): OSPSuite.SimModelNative.dll!SimModelNative::Parameter::SetTablePoints()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Simulation.cpp (1332): OSPSuite.SimModelNative.dll!SimModelNative::Simulation::SetParametersValues()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\src\PInvokeSimulation.cpp (841): OSPSuite.SimModelNative.dll!SetParameterValues()
    (Module name unavailable)!0x00007FFA2DD726FF()
  Data:
    00 00 00 00    00 00 00 00    00 00 00 00    10 0D 20 41     ........ .......A


---------- Block 2584297 at 0x00000000EFF88190: 176 bytes ----------
  Leak Hash: 0xAE6CF1B2, Count: 8, Total 1408 bytes
  Call Stack:
    ucrtbased.dll!malloc()
    d:\agent\_work\3\s\src\vctools\crt\vcstartup\src\heap\new_scalar.cpp (35): OSPSuite.SimModelNative.dll!operator new() + 0xA bytes
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Parameter.cpp (274): OSPSuite.SimModelNative.dll!SimModelNative::Parameter::SetTablePoints() + 0xA bytes
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Simulation.cpp (1332): OSPSuite.SimModelNative.dll!SimModelNative::Simulation::SetParametersValues()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\src\PInvokeSimulation.cpp (841): OSPSuite.SimModelNative.dll!SetParameterValues()
    (Module name unavailable)!0x00007FFA2DD726FF()
  Data:
    60 FE FC 45    FA 7F 00 00    FF FF FF FF    CD CD CD CD     `..E.... ........
    40 87 D6 F7    8C 01 00 00    00 CD CD CD    CD CD CD CD     @....... ........
    CD CD CD CD    CD CD CD CD    00 00 00 00    00 00 00 00     ........ ........
    0F 00 00 00    00 00 00 00    20 8E D6 F7    8C 01 00 00     ........ ........
    00 CD CD CD    CD CD CD CD    CD CD CD CD    CD CD CD CD     ........ ........
    00 00 00 00    00 00 00 00    0F 00 00 00    00 00 00 00     ........ ........
    70 89 D6 F7    8C 01 00 00    70 8E D6 F7    8C 01 00 00     p....... p.......
    78 8E D6 F7    8C 01 00 00    78 8E D6 F7    8C 01 00 00     x....... x.......
    00 CD CD CD    02 00 00 00    60 8A D6 F7    8C 01 00 00     ........ `.......
    60 85 D6 F7    8C 01 00 00    F0 86 D6 F7    8C 01 00 00     `....... ........
    B0 94 D6 F7    8C 01 00 00    02 00 00 00    CD CD CD CD     ........ ........


---------- Block 2591895 at 0x00000000F77EF330: 24 bytes ----------
  Leak Hash: 0xEF90F768, Count: 16, Total 384 bytes
  Call Stack:
    ucrtbased.dll!malloc()
    d:\agent\_work\3\s\src\vctools\crt\vcstartup\src\heap\new_scalar.cpp (35): OSPSuite.SimModelNative.dll!operator new() + 0xA bytes
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\TableFormula.cpp (412): OSPSuite.SimModelNative.dll!SimModelNative::TableFormula::SetTablePoints() + 0xA bytes
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Parameter.cpp (283): OSPSuite.SimModelNative.dll!SimModelNative::Parameter::SetTablePoints()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Simulation.cpp (1332): OSPSuite.SimModelNative.dll!SimModelNative::Simulation::SetParametersValues()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\src\PInvokeSimulation.cpp (841): OSPSuite.SimModelNative.dll!SetParameterValues()
    (Module name unavailable)!0x00007FFA2DD726FF()
  Data:
    00 00 00 00    00 00 00 00    00 10 05 D3    2E 92 99 3F     ........ .......?
    00 CD CD CD    CD CD CD CD                                   ........ ........


---------- Block 2584175 at 0x00000000F7D65EF0: 16 bytes ----------
  Leak Hash: 0xD6B4DD11, Count: 8, Total 128 bytes
  Call Stack:
    ucrtbased.dll!malloc()
    d:\agent\_work\3\s\src\vctools\crt\vcstartup\src\heap\new_scalar.cpp (35): OSPSuite.SimModelNative.dll!operator new() + 0xA bytes
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\xmemory (49): OSPSuite.SimModelNative.dll!std::_Default_allocate_traits::_Allocate()
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\xmemory (178): OSPSuite.SimModelNative.dll!std::_Allocate<16,std::_Default_allocate_traits,0>() + 0xA bytes
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\xmemory (867): OSPSuite.SimModelNative.dll!std::allocator<std::_Container_proxy>::allocate()
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\xmemory (1202): OSPSuite.SimModelNative.dll!std::_Container_base12::_Alloc_proxy<std::allocator<std::_Container_proxy> >() + 0xF bytes
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\xstring (2242): OSPSuite.SimModelNative.dll!std::basic_string<char,std::char_traits<char>,std::allocator<char> >::basic_string<char,std::char_traits<char>,std::allocator<char> >() + 0x39 bytes
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\ObjectBase.cpp (15): OSPSuite.SimModelNative.dll!SimModelNative::ObjectBase::ObjectBase() + 0x2A bytes
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Formula.cpp (11): OSPSuite.SimModelNative.dll!SimModelNative::Formula::Formula() + 0xA bytes
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\TableFormula.cpp (9): OSPSuite.SimModelNative.dll!SimModelNative::TableFormula::TableFormula() + 0xA bytes
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Parameter.cpp (274): OSPSuite.SimModelNative.dll!SimModelNative::Parameter::SetTablePoints() + 0x21 bytes
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Simulation.cpp (1332): OSPSuite.SimModelNative.dll!SimModelNative::Simulation::SetParametersValues()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\src\PInvokeSimulation.cpp (841): OSPSuite.SimModelNative.dll!SetParameterValues()
    (Module name unavailable)!0x00007FFA2DD726FF()
  Data:
    A0 90 F8 EF    8C 01 00 00    00 00 00 00    00 00 00 00     ........ ........


---------- Block 2584177 at 0x00000000F7D65F40: 16 bytes ----------
  Leak Hash: 0x575112C8, Count: 8, Total 128 bytes
  Call Stack:
    ucrtbased.dll!malloc()
    d:\agent\_work\3\s\src\vctools\crt\vcstartup\src\heap\new_scalar.cpp (35): OSPSuite.SimModelNative.dll!operator new() + 0xA bytes
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\xmemory (49): OSPSuite.SimModelNative.dll!std::_Default_allocate_traits::_Allocate()
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\xmemory (178): OSPSuite.SimModelNative.dll!std::_Allocate<16,std::_Default_allocate_traits,0>() + 0xA bytes
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\xmemory (867): OSPSuite.SimModelNative.dll!std::allocator<std::_Container_proxy>::allocate()
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\xmemory (1202): OSPSuite.SimModelNative.dll!std::_Container_base12::_Alloc_proxy<std::allocator<std::_Container_proxy> >() + 0xF bytes
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\vector (369): OSPSuite.SimModelNative.dll!std::vector<double,std::allocator<double> >::vector<double,std::allocator<double> >() + 0x26 bytes
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\TableFormula.cpp (9): OSPSuite.SimModelNative.dll!SimModelNative::TableFormula::TableFormula() + 0x2B bytes
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Parameter.cpp (274): OSPSuite.SimModelNative.dll!SimModelNative::Parameter::SetTablePoints() + 0x21 bytes
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Simulation.cpp (1332): OSPSuite.SimModelNative.dll!SimModelNative::Simulation::SetParametersValues()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\src\PInvokeSimulation.cpp (841): OSPSuite.SimModelNative.dll!SetParameterValues()
    (Module name unavailable)!0x00007FFA2DD726FF()
  Data:
    F0 90 F8 EF    8C 01 00 00    00 00 00 00    00 00 00 00     ........ ........


---------- Block 2584184 at 0x00000000F7D65FE0: 8 bytes ----------
  Leak Hash: 0xE4893551, Count: 8, Total 64 bytes
  Call Stack:
    ucrtbased.dll!malloc()
    d:\agent\_work\3\s\src\vctools\crt\vcstartup\src\heap\new_scalar.cpp (35): OSPSuite.SimModelNative.dll!operator new() + 0xA bytes
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\xmemory (49): OSPSuite.SimModelNative.dll!std::_Default_allocate_traits::_Allocate()
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\xmemory (178): OSPSuite.SimModelNative.dll!std::_Allocate<16,std::_Default_allocate_traits,0>() + 0xA bytes
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\xmemory (867): OSPSuite.SimModelNative.dll!std::allocator<double>::allocate()
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\vector (697): OSPSuite.SimModelNative.dll!std::vector<double,std::allocator<double> >::_Emplace_reallocate<double const &>() + 0xF bytes
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\vector (661): OSPSuite.SimModelNative.dll!std::vector<double,std::allocator<double> >::emplace_back<double const &>() + 0x1F bytes
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\vector (671): OSPSuite.SimModelNative.dll!std::vector<double,std::allocator<double> >::push_back()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\TableFormula.cpp (124): OSPSuite.SimModelNative.dll!SimModelNative::TableFormula::CacheValues()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\TableFormula.cpp (416): OSPSuite.SimModelNative.dll!SimModelNative::TableFormula::SetTablePoints()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Parameter.cpp (283): OSPSuite.SimModelNative.dll!SimModelNative::Parameter::SetTablePoints()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Simulation.cpp (1332): OSPSuite.SimModelNative.dll!SimModelNative::Simulation::SetParametersValues()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\src\PInvokeSimulation.cpp (841): OSPSuite.SimModelNative.dll!SetParameterValues()
    (Module name unavailable)!0x00007FFA2DD726FF()
  Data:
    00 00 00 00    00 00 00 00                                   ........ ........


---------- Block 2584176 at 0x00000000F7D66D50: 16 bytes ----------
  Leak Hash: 0x9FD38EF2, Count: 8, Total 128 bytes
  Call Stack:
    ucrtbased.dll!malloc()
    d:\agent\_work\3\s\src\vctools\crt\vcstartup\src\heap\new_scalar.cpp (35): OSPSuite.SimModelNative.dll!operator new() + 0xA bytes
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\xmemory (49): OSPSuite.SimModelNative.dll!std::_Default_allocate_traits::_Allocate()
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\xmemory (178): OSPSuite.SimModelNative.dll!std::_Allocate<16,std::_Default_allocate_traits,0>() + 0xA bytes
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\xmemory (867): OSPSuite.SimModelNative.dll!std::allocator<std::_Container_proxy>::allocate()
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\xmemory (1202): OSPSuite.SimModelNative.dll!std::_Container_base12::_Alloc_proxy<std::allocator<std::_Container_proxy> >() + 0xF bytes
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.22.27905\include\xstring (2242): OSPSuite.SimModelNative.dll!std::basic_string<char,std::char_traits<char>,std::allocator<char> >::basic_string<char,std::char_traits<char>,std::allocator<char> >() + 0x39 bytes
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\ObjectBase.cpp (16): OSPSuite.SimModelNative.dll!SimModelNative::ObjectBase::ObjectBase()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Formula.cpp (11): OSPSuite.SimModelNative.dll!SimModelNative::Formula::Formula() + 0xA bytes
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\TableFormula.cpp (9): OSPSuite.SimModelNative.dll!SimModelNative::TableFormula::TableFormula() + 0xA bytes
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Parameter.cpp (274): OSPSuite.SimModelNative.dll!SimModelNative::Parameter::SetTablePoints() + 0x21 bytes
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Simulation.cpp (1332): OSPSuite.SimModelNative.dll!SimModelNative::Simulation::SetParametersValues()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\src\PInvokeSimulation.cpp (841): OSPSuite.SimModelNative.dll!SetParameterValues()
    (Module name unavailable)!0x00007FFA2DD726FF()
  Data:
    C8 90 F8 EF    8C 01 00 00    00 00 00 00    00 00 00 00     ........ ........


---------- Block 2591998 at 0x00000000F7D68560: 16 bytes ----------
  Leak Hash: 0x09C82FE1, Count: 8, Total 128 bytes
  Call Stack:
    ucrtbased.dll!malloc()
    d:\agent\_work\3\s\src\vctools\crt\vcstartup\src\heap\new_array.cpp (29): OSPSuite.SimModelNative.dll!operator new[]()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\TableFormula.cpp (100): OSPSuite.SimModelNative.dll!SimModelNative::TableFormula::CacheValues() + 0x3A bytes
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\TableFormula.cpp (416): OSPSuite.SimModelNative.dll!SimModelNative::TableFormula::SetTablePoints()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Parameter.cpp (283): OSPSuite.SimModelNative.dll!SimModelNative::Parameter::SetTablePoints()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Simulation.cpp (1332): OSPSuite.SimModelNative.dll!SimModelNative::Simulation::SetParametersValues()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\src\PInvokeSimulation.cpp (841): OSPSuite.SimModelNative.dll!SetParameterValues()
    (Module name unavailable)!0x00007FFA2DD726FF()
  Data:
    7D DF 1D A2    2D 40 E8 3F    CB FE 56 62    38 3F E8 3F     }...-@.? ..Vb8?.?


---------- Block 2591999 at 0x00000000F7D686F0: 8 bytes ----------
  Leak Hash: 0x1E0D575D, Count: 8, Total 64 bytes
  Call Stack:
    ucrtbased.dll!malloc()
    d:\agent\_work\3\s\src\vctools\crt\vcstartup\src\heap\new_array.cpp (29): OSPSuite.SimModelNative.dll!operator new[]()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\TableFormula.cpp (138): OSPSuite.SimModelNative.dll!SimModelNative::TableFormula::CacheValues() + 0x3D bytes
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\TableFormula.cpp (416): OSPSuite.SimModelNative.dll!SimModelNative::TableFormula::SetTablePoints()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Parameter.cpp (283): OSPSuite.SimModelNative.dll!SimModelNative::Parameter::SetTablePoints()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\Src\Simulation.cpp (1332): OSPSuite.SimModelNative.dll!SimModelNative::Simulation::SetParametersValues()
    C:\SW-Dev\SimModel\src\OSPSuite.SimModelNative\src\PInvokeSimulation.cpp (841): OSPSuite.SimModelNative.dll!SetParameterValues()
    (Module name unavailable)!0x00007FFA2DD726FF()
  Data:
    AE 90 1C 18    06 8F EE BD                                   ........ ........


Visual Leak Detector detected 88 memory leaks (7264 bytes).
Largest number used: 28604617 bytes.
Total allocations: 203291523 bytes.
Visual Leak Detector is now exiting.

```
</details>

### Remarks
* For additional included C++ modules: in order to get readable stack trace, _Whole Program Optimization_ (**/GL**) Compiler option must be set
