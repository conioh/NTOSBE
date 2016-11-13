@echo off

REM ///////////////////////////////////////////////////////////////////////////
REM  buildrepoidw.cmd
REM ///////////////////////////////////////////////////////////////////////////

pushd %~dp0

REM //
REM // Verify that the script is running under the sizzle environment.
REM //

if [%NTROOT%] equ [] (
    echo You must run this script under the sizzle environment.
    goto End
)

REM //
REM // Display build information.
REM //

echo Building repository-specific IDW tools from the source tree SDKTOOLS project.
echo.

echo Repository Name            = %NTREPO%
echo SDKTOOLS Project Path      = %NTROOT%\sdktools
echo Repository IDW Path        = %BEREPOIDW%
echo.

REM //
REM // Check for existing IDW path.
REM //

if exist "%BEREPOIDW%" (
    REM Check for the -y switch before attempting to delete the repository IDW directory.
    if not [%1] equ [-y] (
        echo Repository IDW path already exists.
        echo Please specify -y switch if you would like to rebuild the repository-specific IDW.
        
        goto End
    )
    
    REM Delete the existing repository IDW directory.
    rmdir /s /q "%BEREPOIDW%"
)

REM //
REM // Create the repository IDW directory.
REM //

mkdir "%BEREPOIDW%"

REM //
REM // Build repository IDW tools.
REM //

call :Build ztools sdktools\ztools
if errorlevel 1 goto Error

call :Build generr sdktools\generr idw\generr.exe generr.exe
if errorlevel 1 goto Error

call :Build genlvl sdktools\genlvl bldtools\genlvl.exe genlvl.exe
if errorlevel 1 goto Error

call :Build gensrv sdktools\gensrv idw\gensrv.exe gensrv.exe
if errorlevel 1 goto Error

call :Build genxx base\tools\genxx idw\genxx.exe genxx.exe
if errorlevel 1 goto Error

call :Build hdivide sdktools\hdivide bldtools\hdivide.exe hdivide.exe
if errorlevel 1 goto Error

call :Build hextract sdktools\hextract bldtools\hextract.exe hextract.exe
if errorlevel 1 goto Error

call :Build hsplit sdktools\hsplit bldtools\hsplit.exe hsplit.exe
if errorlevel 1 goto Error

call :Build munge sdktools\munge idw\munge.exe munge.exe
if errorlevel 1 goto Error

call :Build wcshdr sdktools\wcshdr bldtools\wcshdr.exe wcshdr.exe
if errorlevel 1 goto Error

call :Build wmimofck sdktools\wmimofck mstools\wmimofck.exe wmimofck.exe
if errorlevel 1 goto Error

call :Build zwapi sdktools\zwapi bldtools\zwapi.exe zwapi.exe
if errorlevel 1 goto Error

REM //
REM // Done.
REM //

echo.
echo Build successfully completed! Done.
goto End

REM //
REM // Error.
REM //

:Error
echo.
echo Error! Build aborted.

REM //
REM // End.
REM //

:End

popd

exit /b 0

REM //
REM // ** Build Function **
REM //
REM // %~1 = Tool name
REM // %~2 = Relative source directory path under %NTROOT%
REM // %~3 = Relative binary path under %NTTREE%
REM // %~4 = Relative binary path under %BEREPOIDW%
REM //

:Build
echo.
echo [%~1]

REM //
REM // Verify that the source directory for the specified tool exists.
REM //

if not exist "%NTROOT%\%~2" (
    echo %~1 does not exist in the local source tree. Skipping %~1 build.
    exit /b
)

cd "%NTROOT%\%~2"

REM //
REM // Perform build.
REM //

build -c
if errorlevel 1 (
    echo Build command failed for %~1.
    exit /b 1
)

REM //
REM // Copy the built tool to the repository idw directory.
REM //

if not [%~3] equ [] (
    copy /y "%NTTREE%\%~3" "%BEREPOIDW%\%~4"
    if errorlevel 1 (
        echo Failed to copy %~1 to tools directory.
        exit /b 2
    )
)

exit /b 0
