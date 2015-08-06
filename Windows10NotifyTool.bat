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
title 移除 Windows 10 更新通知程式
echo =============================================
echo.
echo 此腳本可以移除 " Windows 10 更新通知程式 " 的系統更新 ( KB3035583 )
echo 移除 Windows 10 的更新通知，來避免頻繁通知而干擾日常操作。
echo 同時可以自動解除安裝及避免日後意外重新安裝此更新程式後造成的困擾
echo 僅適用於 Windows 7 SP1 / 8.1
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
  echo 此操作需要系統管理員權限，若要繼續執行請按下任意鍵之後允許以管理員權限執行
  pause>nul
  echo Call UAC Shell
  cscript.exe /E:Jscript /nologo %0 %0 %*
  exit
)

color 7
ver | find "6.1.7601" > NUL && goto START
ver | find "6.3.9600" > NUL && goto START

:VNC
title 無法使用
echo 本 Windows 不能使用此腳本。
echo 此腳本僅供 Windows 7 SP1 / 8.1 使用。
echo 30 秒後自動關閉本腳本。
ping localhost -n 30 > nul
goto exit

:START
set ps_download_file="https://raw.githubusercontent.com/Haraguroicha/Windows10NotifyRemoval/master/downloadFile.ps1"
set removePS1=0
if not exist "%~dp0downloadFile.ps1" (
  set removePS1=1
  echo 準備檔案中...
  powershell -ExecutionPolicy Unrestricted -Command "& { (New-Object System.Net.WebClient).DownloadFile('%ps_download_file%','%~dp0downloadFile.ps1') }"
)
set no_recovery=0
set recovery_flag=R
set recovery_message=按 R 還原更新與取得恢復方式，

set no_removal=0
set removal_flag=Y
set removal_message=按 Y 開始移除與防護，

if "%1"=="/force" goto ignoreCheck

echo 擷取 KB2919355 安裝資訊中...
wmic qfe get hotfixid /value | findstr = | findstr KB2919355
if %errorlevel%==1 (
  echo 找不到已安裝 KB2919355 的資訊，停用還原功能
  set no_recovery=1
  set recovery_flag= 
  set recovery_message= 
)

echo 擷取 KB3035583 安裝資訊中...
wmic qfe get hotfixid /value | findstr = | findstr KB3035583
if %errorlevel%==1 (
  echo 找不到已安裝 KB3035583 的資訊，停用移除功能
  set no_removal=1
  set removal_flag= 
  set removal_message= 
)

:ignoreCheck
echo.

set choice_items=%removal_flag%%recovery_flag%N
set choice_message="%removal_message%%recovery_message%按 N 取消操作"

CHOICE /C %choice_items% /M %choice_message%
set selected=%errorlevel%
set /a selected=%selected%+%no_removal%+%no_recovery%
if %selected%==1 GOTO yes
if %selected%==2 GOTO Recovery
if %selected%==3 GOTO _EOF
goto NA

:yes
title [執行中] 移除 Windows 10 更新通知程式
echo 移除 KB3035583 中...
wusa /uninstall /kb:3035583 /quiet /norestart
echo 建立防護資訊中...
cd /d "%windir%\System32" >nul 1>nul 2>nul
mkdir "GWX" >nul 1>nul 2>nul
icacls GWX /inheritance:r >nul 1>nul 2>nul
icacls GWX /setowner "NT SERVICE\TrustedInstaller" /q /c >nul 1>nul 2>nul
cacls GWX /e /p everyone:n >nul 1>nul 2>nul
echo 處理完成!!
goto end

:Recovery
echo 正在移除 KB3035583 的防止更新資訊中...
cd /d "%windir%\System32"
takeown /f GWX >nul 1>nul 2>nul
cacls GWX /e /p everyone:f >nul 1>nul 2>nul
icacls GWX /inheritance:e >nul 1>nul 2>nul
rmdir GWX >nul 1>nul 2>nul
echo 移除完成!!
echo.
echo 正在重新下載 KB3035583 更新檔案中...
powershell -ExecutionPolicy Unrestricted -File "%~dp0downloadFile.ps1" %msu_url% "%temp%\KB3035583.msu"
if exist "%temp%\KB3035583.msu" (
  echo 下載完成!
  goto installKB
)
echo.
goto _EOF

:installKB
echo 解包中...
start /wait wusa "%temp%\KB3035583.msu" /extract:"%temp%\KB3035583.msu.tmp"
echo 開始更新...
for /f %%i in ('dir /b "%temp%\KB3035583.msu.tmp\*-KB3035583-*.cab"') do set cabFile=%%i
set cabFile=%temp%\KB3035583.msu.tmp\%cabFile%
echo 安裝包路徑: %cabFile%
dism /NoRestart /Online /Add-Package /PackagePath:%cabFile%
echo 更新完成!! 建議立即重新開機以便生效!!
echo.
goto _EOF

:na
echo 輸入錯誤，請重新輸入。
goto START

:end
echo =============================================
echo.
dir /a "%windir%\System32\GWX" >nul 1>nul 2>nul
if %errorlevel%==0 (
  title [失敗] 移除 Windows 10 更新通知程式
  color 0c
  echo " Windows 10 更新通知程式 " 移除失敗
) else (
  title [成功] 移除 Windows 10 更新通知程式
  color 0b 
  echo " Windows 10 更新通知程式 " 移除成功
)
echo.
echo =============================================
echo.

:_EOF
if %removePS1%==1 del "%~dp0downloadFile.ps1" >nul 1>nul 2>nul
echo 感謝您的使用!!
echo 請按任意鍵即可關閉視窗
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