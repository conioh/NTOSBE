@echo off

REM ///////////////////////////////////////////////////////////////////////////
REM  ntswitch.cmd
REM ///////////////////////////////////////////////////////////////////////////

REM //
REM // Verify that the script is running under the sizzle environment.
REM //

if [%NTROOT%] equ [] (
    echo You must run this script under the sizzle environment.
    goto End
)

REM //
REM // Re-initialise the sizzle environment.
REM //

call ntenv.cmd %NTROOT% %NTBINROOT% %1 %2

:End
