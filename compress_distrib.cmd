@echo off
pushd %~dp0

set "GAME=Halloween Trouble"

rem set ARC="C:\Program Files\7-Zip\7z.exe" a -tzip -mx=9
set ARC="C:\Program Files\7-Zip\7z.exe" a -t7z -mx=9 -myx=9

if not exist _export (
	echo No _export found!
)

echo ===== Compressing Win-64 =====
%ARC% "_export\%GAME% x64.7z" .\_export\*x64.exe .\_export\*x64.pck

echo ===== Compressing Win-32 =====
%ARC% "_export\%GAME% x86.7z" .\_export\*x86.exe .\_export\*x86.pck

popd
echo ===== FINISHED =====
