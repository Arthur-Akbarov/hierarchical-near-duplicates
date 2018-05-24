@echo off
setlocal EnableDelayedExpansion

for %%i in ("%~dp0") do set utilsDir=%%~dpi
for %%i in ("%utilsDir:~0,-1%") do set rootDir=%%~dpi
set webDir=%rootDir%web

for /d %%d in ("%webDir%\html\*") do (
    set docDir=%%~d

    for %%i in (auto manual) do (
        set methodDir=!docDir!\%%i
        if not exist "!methodDir!\" mkdir "!methodDir!"

        for %%j in (css images js) do (
            set junctionPoint=!methodDir!\%%j

            if exist "!junctionPoint!" rmdir /s /q "!junctionPoint!"
            mklink /j "!junctionPoint!" "%webDir%\%%j"
        )
    )
)

echo %CmdCmdLine% | find /i "%~0" > nul
if not ErrorLevel 1 pause
