@echo off
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
cd godot-4.4-dev3
scons platform=windows vsproj=yes dev_build=yes vsproj_gen_only=no module_mono_enabled=yes 

:: Generate the glue
bin\godot.windows.editor.dev.x86_64.mono.console.exe --headless --generate-mono-glue modules/mono/glue

:: Building the managed libraries
python modules/mono/build_scripts/build_assemblies.py --godot-output-dir=./bin --godot-platform=windows

:: Go back to the directory where the batch file is located
cd ..

:: Always create or replace the godot.exe.lnk shortcut
echo Creating or replacing the shortcut for the Godot editor...
powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%cd%\godot.exe.lnk');$s.TargetPath='%cd%\godot-4.4-dev3\bin\godot.windows.editor.dev.x86_64.mono.exe';$s.Save()"

echo Done building Godot Engine. If it does not work, please check for errors above and send them to Wridzer.
pause