@if (1==1) @if(1==0) @ELSE
@echo off&SETLOCAL ENABLEEXTENSIONS
if "%~d0"=="\\" goto wrapUNC
goto init

:wrapUNC
copy %0 "%temp%\%~nx0" >nul 1>nul 2>nul
call "%temp%\%~nx0" %*
goto _EOF

:init
cls
title ���� Windows 10 ��s�q���{��
echo =============================================
echo.
echo ���}���i�H���� " Windows 10 ��s�q���{�� " ���t�Χ�s ( KB3035583 )
echo ���� Windows 10 ����s�q���A���קK�W�c�q���Ӥz�Z��`�ާ@�C
echo �P�ɥi�H�۰ʸѰ��w�ˤ��קK���N�~���s�w�˦���s�{����y�����x�Z
echo �ȾA�Ω� Windows 7 SP1 / 8.1
echo.
echo =============================================
echo.

for /f "delims=- tokens=1" %%i in ('wmic OS get OSArchitecture ^| findstr bit') do set arch=%%i
set msu_7_0_x86="http://download.windowsupdate.com/c/msdownload/update/software/updt/2015/03/windows6.1-kb3035583-x86_457fc816e5855c206303bfe9ed14240eb701e5d2.msu"
set msu_7_0_x64="http://download.windowsupdate.com/d/msdownload/update/software/updt/2015/07/windows6.1-kb3035583-x64_064250ac098e19c70ceacf4ef8a293fbacdad888.msu"
set msu_8_1_x86="http://download.windowsupdate.com/c/msdownload/update/software/updt/2015/03/windows8.1-kb3035583-x86_c3cca41f70e4735fa71cc1ceacbf3701b87a655c.msu"
set msu_8_1_x64="http://download.windowsupdate.com/d/msdownload/update/software/updt/2015/07/windows8.1-kb3035583-x64_dee17c3446210b00e106a9fbb2f4aa0696902825.msu"
set msu_url=""

ver | find "6.1.7601" > NUL && goto UAC1
ver | find "6.3.9600" > NUL && goto UAC2
goto VNC

:UAC1
if "%arch%"=="64" (
  set msu_url=%msu_7_0_x64%
) else (
  set msu_url=%msu_7_0_x86%
)
goto UAC

:UAC2
if "%arch%"=="64" (
  set msu_url=%msu_8_1_x64%
) else (
  set msu_url=%msu_8_1_x86%
)
goto UAC

:UAC
net file 1>nul 2>nul
if "%errorlevel%" == "0" (
  color 2
  echo UAC Authorized
) else (
  color 42
  echo Need UAC Authorize
  echo ���ާ@�ݭn�t�κ޲z���v���A�Y�n�~�����Ы��U���N�䤧�᤹�\�H�޲z���v������
  pause>nul
  echo Call UAC Shell
  cscript.exe /E:Jscript /nologo %0 %0 %*
  exit
)

color 7
ver | find "6.1.7601" > NUL && goto START
ver | find "6.3.9600" > NUL && goto START

:VNC
title �L�k�ϥ�
echo �� Windows ����ϥΦ��}���C
echo ���}���Ȩ� Windows 7 SP1 / 8.1 �ϥΡC
echo 30 ���۰��������}���C
ping localhost -n 30 > nul
goto exit

:START
set ps_download_file="https://raw.githubusercontent.com/Haraguroicha/Windows10NotifyRemoval/master/downloadFile.ps1"
set removePS1=0
if not exist "%~dp0downloadFile.ps1" (
  set removePS1=1
  echo �ǳ��ɮפ�...
  powershell -ExecutionPolicy Unrestricted -Command "& { (New-Object System.Net.WebClient).DownloadFile('%ps_download_file%','%~dp0downloadFile.ps1') }"
)
set no_recovery=0
set recovery_flag=R
set recovery_message=�� R �٭��s�P���o��_�覡�A

set no_removal=0
set removal_flag=Y
set removal_message=�� Y �}�l�����P���@�A

if "%1"=="/force" goto ignoreCheck

echo �^�� KB2919355 �w�˸�T��...
wmic qfe get hotfixid /value | findstr = | findstr KB2919355
if %errorlevel%==1 (
  echo �䤣��w�w�� KB2919355 ����T�A�����٭�\��
  set no_recovery=1
  set recovery_flag= 
  set recovery_message= 
)

echo �^�� KB3035583 �w�˸�T��...
wmic qfe get hotfixid /value | findstr = | findstr KB3035583
if %errorlevel%==1 (
  echo �䤣��w�w�� KB3035583 ����T�A���β����\��
  set no_removal=1
  set removal_flag= 
  set removal_message= 
)

:ignoreCheck
echo.

set choice_items=%removal_flag%%recovery_flag%N
set choice_message="%removal_message%%recovery_message%�� N �����ާ@"

CHOICE /C %choice_items% /M %choice_message%
set selected=%errorlevel%
set /a selected=%selected%+%no_removal%+%no_recovery%
if %selected%==1 GOTO yes
if %selected%==2 GOTO Recovery
if %selected%==3 GOTO _EOF
goto NA

:yes
title [���椤] ���� Windows 10 ��s�q���{��
echo ���� KB3035583 ��...
wusa /uninstall /kb:3035583 /quiet /norestart
echo �إߨ��@��T��...
cd /d "%windir%\System32" >nul 1>nul 2>nul
mkdir "GWX" >nul 1>nul 2>nul
icacls GWX /inheritance:r >nul 1>nul 2>nul
icacls GWX /setowner "NT SERVICE\TrustedInstaller" /q /c >nul 1>nul 2>nul
cacls GWX /e /p everyone:n >nul 1>nul 2>nul
echo �B�z����!!
goto end

:Recovery
echo ���b���� KB3035583 �������s��T��...
cd /d "%windir%\System32"
takeown /f GWX >nul 1>nul 2>nul
cacls GWX /e /p everyone:f >nul 1>nul 2>nul
icacls GWX /inheritance:e >nul 1>nul 2>nul
rmdir GWX >nul 1>nul 2>nul
echo ��������!!
echo.
echo ���b���s�U�� KB3035583 ��s�ɮפ�...
powershell -ExecutionPolicy Unrestricted -File "%~dp0downloadFile.ps1" %msu_url% "%temp%\KB3035583.msu"
if exist "%temp%\KB3035583.msu" (
  echo �U������!
  goto installKB
)
echo.
goto _EOF

:installKB
echo �ѥ]��...
start /wait wusa "%temp%\KB3035583.msu" /extract:"%temp%\KB3035583.msu.tmp"
echo �}�l��s...
for /f %%i in ('dir /b "%temp%\KB3035583.msu.tmp\*-KB3035583-*.cab"') do set cabFile=%%i
set cabFile=%temp%\KB3035583.msu.tmp\%cabFile%
echo �w�˥]���|: %cabFile%
dism /NoRestart /Online /Add-Package /PackagePath:%cabFile%
echo ��s����!! ��ĳ�ߧY���s�}���H�K�ͮ�!!
echo.
goto _EOF

:na
echo ��J���~�A�Э��s��J�C
goto START

:end
echo =============================================
echo.
dir /a "%windir%\System32\GWX" >nul 1>nul 2>nul
if %errorlevel%==0 (
  title [����] ���� Windows 10 ��s�q���{��
  color 0c
  echo " Windows 10 ��s�q���{�� " ��������
) else (
  title [���\] ���� Windows 10 ��s�q���{��
  color 0b 
  echo " Windows 10 ��s�q���{�� " �������\
)
echo.
echo =============================================
echo.

:_EOF
if %removePS1%==1 del "%~dp0downloadFile.ps1" >nul 1>nul 2>nul
echo �P�±z���ϥ�!!
echo �Ы����N��Y�i��������
del "%temp%\%~nx0" >nul 1>nul 2>nul & pause > nul

@goto :EOF
@end @ELSE
var args = WScript.Arguments;
var shellPath = ""
var params = [];
if(args.length > 0) shellPath = args.Item(0);
if(args.length > 1) {
	for(var i = 1; i < args.length; i++) {
		params.push(args.Item(i));
	}
}
if(shellPath != "") {
	var UAC = WSH.CreateObject("Shell.Application");
	UAC.ShellExecute(shellPath, params.join(' '), "", "runas", 1);
} else {
	WScript.Echo("Error of usage.");
}
@end