@echo off

midl /client none /server none -I %NTROOT%\public\sdk\inc %*
del *.c
