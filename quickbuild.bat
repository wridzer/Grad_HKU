@echo off
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

:: Building Godot with parallel jobs and ccache enabled
cd godot-4.3
scons platform=windows vsproj=yes dev_build=yes vsproj_gen_only=no module_mono_enabled=yes CC="ccache cl" -j8

:: Conditionally generate the Mono glue if necessary
IF NOT EXIST "modules\mono\glue\mono_glue.gen.cpp" (
    echo Generating Mono glue files...
    bin\godot.windows.editor.dev.x86_64.mono.console.exe --headless --generate-mono-glue modules/mono/glue
)

:: Only rebuild the managed libraries if source files have changed
forfiles /p "modules\mono" /m *.cs /d -1 /c "cmd /c exit 1" >nul 2>&1
IF ERRORLEVEL 1 (
    echo Managed libraries changed, rebuilding assemblies...
    python modules\mono\build_scripts\build_assemblies.py --godot-output-dir=./bin --godot-platform=windows
)

cd ..

:: Create or replace the Godot editor shortcut only if it doesn't already exist
IF NOT EXIST "godot.exe.lnk" (
    echo Creating the shortcut for the Godot editor...
    powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%cd%\godot.exe.lnk');$s.TargetPath='%cd%\godot-4.3\bin\godot.windows.editor.dev.x86_64.mono.exe';$s.Save()"
)

echo Done building Godot Engine. If it does not work, please check for errors above and send them to Wridzer.
pause
