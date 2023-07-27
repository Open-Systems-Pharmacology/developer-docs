@echo off

rem -----------------------------------------------------------------------------------
rem adjust paths before execution
set pathToSchemaCrawler=C:\Dev\Install2Move\DBDocu\schemacrawler-16.20.3-bin\bin
set pathToPKSimDB=C:\SW-Dev\PK-Sim\branches\11.0\src\Db\PKSimDB.sqlite
rem -----------------------------------------------------------------------------------

set path=%pathToSchemaCrawler%;%path%
set scOptions=--server=sqlite --info-level=standard --command=schema --portable-names --no-info=true --database="%pathToPKSimDB%"

