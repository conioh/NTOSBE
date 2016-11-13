@echo off

REM ///////////////////////////////////////////////////////////////////////////
REM  sizzle.cmd
REM ///////////////////////////////////////////////////////////////////////////

REM //
REM // Verify sizzle environment variables
REM //

REM // SIZ_REPONAME
if [%SIZ_REPONAME%] equ [] (
    echo SIZ_REPONAME environment variable is not set.
    goto End
)

REM // SIZ_NTROOT
if [%SIZ_NTROOT%] equ [] (
    echo SIZ_NTROOT environment variable is not set.
    goto End
)

REM // SIZ_NTTREE
if [%SIZ_NTTREE%] equ [] (
    echo SIZ_NTTREE environment variable is not set.
    goto End
)

REM // SIZ_NTARCH
if [%SIZ_NTARCH%] equ [] (
    echo SIZ_NTARCH environment variable is not set.
    goto End
)

REM // SIZ_NTBLD
if [%SIZ_NTBLD%] equ [] (
    echo SIZ_NTBLD environment variable is not set.
    goto End
)

REM //
REM // Print logo
REM //

echo.
echo       ____                   _   ________   ____               _           __ 
echo      / __ \____  ___  ____  / ^| / /_  __/  / __ \_________    (_)__  _____/ /_
echo     / / / / __ \/ _ \/ __ \/  ^|/ / / /    / /_/ / ___/ __ \  / / _ \/ ___/ __/
echo    / /_/ / /_/ /  __/ / / / /^|  / / /    / ____/ /  / /_/ / / /  __/ /__/ /_  
echo    \____/ .___/\___/_/ /_/_/ ^|_/ /_/    /_/   /_/   \____/_/ /\___/\___/\__/  
echo        /_/                                              /___/                 
echo.
echo.

REM //
REM // Call ntenv.cmd
REM //

call ntenv.cmd %SIZ_REPONAME% %SIZ_NTROOT% %SIZ_NTTREE% %SIZ_NTARCH% %SIZ_NTBLD%
echo.
echo.

REM //
REM // Set window and prompt style
REM //

title NTOSBE: %NTTARGET% [%NTROOT%]
prompt [%COMPUTERNAME%: %USERNAME% // %NTTARGET%] $d$s$t$_$p$_$_$+$g

REM //
REM // Invoke shell
REM //

cd /d %NTROOT%
cmd

REM //
REM // End
REM //

:End
