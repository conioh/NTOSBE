@echo off

REM //
REM // SIZ_REPONAME: Name of the repository. This name is primarily used for determining the type
REM //               of the IDW to use.
REM //

set SIZ_REPONAME=NT45

REM //
REM // SIZ_NTROOT: Path to the NT 4.5 source root (e.g. W:\trunk.x86chk)
REM //

set SIZ_NTROOT=W:\Repositories\NT.trunk

REM //
REM // SIZ_NTTREE: Path to the NT 4.5 binary root (e.g. W:\bin)
REM //

set SIZ_NTTREE=W:\Binaries\NT.trunk

REM //
REM // SIZ_NTARCH: Target build architecture [x86, amd64, arm, mips, alpha, ppc]
REM //

set SIZ_NTARCH=x86

REM //
REM // SIZ_NTBLD: Target build type [fre, chk]
REM //

set SIZ_NTBLD=chk

REM //
REM // Repository-specific Parameters
REM //

REM //
REM // _NT_TARGET_VERSION: If the target repository version is not 4.5, set the following value.
REM //                     For building WRKRazzle, this value must be set to 0x0502 (5.2).
REM //

REM set _NT_TARGET_VERSION=0x0502

REM //
REM // Call sizzle
REM //

call sizzle.cmd
