@echo off
call "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat"
cd godot-4.3
scons platform=windows vsproj=yes dev_build=yes
msbuild godot.sln

:: Go back to the directory where the batch file is located
cd ..

:: Check if godot.exe.lnk already exists
if not exist godot.exe.lnk (
    :: Create a shortcut to the Godot editor
    echo Creating a shortcut for the Godot editor...
    powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%cd%\godot.exe.lnk');$s.TargetPath='%cd%\godot-4.3\bin\godot.windows.editor.dev.x86_64.exe';$s.Save()"
) else (
    echo godot.exe shortcut already exists.
)

pause