@echo off
set AEGISUB_AUTOMATION_DIR=E:\application\Aegisub\automation\
set AUTOLOAD=autoload
set INCLUDE=include
cd %AUTOLOAD%
for %%I in (*.lua) do (mklink /H %AEGISUB_AUTOMATION_DIR%\%AUTOLOAD%\%%I %%I)
cd ..
cd %INCLUDE%
for %%I in (*.lua) do (mklink /H %AEGISUB_AUTOMATION_DIR%\%INCLUDE%\%%I %%I)
cd ..
pause