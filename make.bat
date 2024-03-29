::-----------------------------------------------------
:: Copyright:   XT Tech. Co., Ltd.
:: File:        make.bat
:: Author:      张海涛
:: Version:     2.0.0
:: Encode:      ANSI
:: Date:        2022-01-17
:: Description: 调用VS编译工程
::-----------------------------------------------------

:: 不显示命令字符串
echo off

:: 设置屏幕大小
mode con cols=100 lines=1000

:: 字体颜色
color 0A

:: 程序名称
set NAME=example

:: 程序类型:exe,dll,lib
set EXT=exe

:: 程序架构:x86,x64
set ARCH=x86

:: 是否调试:y,n
set DEBUG=n

:: 字符集:mbcs,unicode,utf8
set CHARSET=utf8

:: 源文件路径,可多个路径
set SRC=.

:: 资源描述文件
set RES=

:: 排除的文件,目录
set EXC=

:: 目标文件路径
set OUT=.

:: 临时文件路径
set TMP=.\tmp

:: 编译参数
set CF=

:: 链接参数
set LF=gdi32.lib User32.lib Advapi32.lib Shell32.lib

::-----------------------------------------------------
:: BAT参数

if "%1" == "" (echo "don't have make.ini path" && pause && exit)
if "%2" == "" (echo "don't have cmd (all|run|clean|[filename])" && pause && exit)

echo %1
echo %2

::-----------------------------------------------------
:: 读取配置文件make.ini

set MAKE_INI_PATH=%1

:: 将路径中的'\'替换成空格
set MAKE_INI_PATH=%MAKE_INI_PATH:\= %

:: 计算目录层数
for %%i in (%MAKE_INI_PATH%) do ( set /a DIR_NUM += 1 )

:: 延时变量扩展
setLocal EnableDelayedExpansion

:: 从子目录向上查找make.ini文件
for /l %%i in (%DIR_NUM%, -1, 1) do (
    set j=0
    set ROOT=
    for %%d in (%MAKE_INI_PATH%) do (
        set /a j+=1
        set ROOT=!ROOT!%%d\
        if "!j!" == "%%i" (
            if exist "!ROOT!make.ini" (echo !ROOT!make.ini && goto FIND_MAKE_INI)
        )
    )
)

echo "don't have make.ini"
pause
exit

:FIND_MAKE_INI

cd !ROOT!

:: 读取make.ini,以=分割字符,并设置变量
for /f "tokens=1,2 delims==" %%a in (make.ini) do (set "%%a=%%b" && echo %%a=%%b)

::-----------------------------------------------------
:: 编译工具

set TOOL_CC=cl.exe
set TOOL_ML=ml.exe
set TOOL_RC=rc.exe
set TOOL_LIB=lib.exe
set TOOL_LNK=link.exe
set MSVC_PATH_ROOT=D:\4.backup\coding\VS2022
set PATH_MSVC_BIN=%MSVC_PATH_ROOT%\MSVC\14.30.30705\bin\Hostx64\%ARCH%
set PATH_MSVC_INCLUDE=%MSVC_PATH_ROOT%\MSVC\14.30.30705\include
set PATH_MSVC_INCLUDE_MFC=%MSVC_PATH_ROOT%\MSVC\14.30.30705\atlmfc\include
set PATH_MSVC_LIB=%MSVC_PATH_ROOT%\MSVC\14.30.30705\lib\%ARCH%
set PATH_MSVC_LIB_MFC=%MSVC_PATH_ROOT%\MSVC\14.30.30705\atlmfc\lib\%ARCH%
set PATH_KITS_BIN=%MSVC_PATH_ROOT%\Windows Kits\10.0.22000.0\bin\%ARCH%
set PATH_KITS_INCLUDE_UM=%MSVC_PATH_ROOT%\Windows Kits\10.0.22000.0\Include\um
set PATH_KITS_INCLUDE_UCRT=%MSVC_PATH_ROOT%\Windows Kits\10.0.22000.0\Include\ucrt
set PATH_KITS_INCLUDE_SHARED=%MSVC_PATH_ROOT%\Windows Kits\10.0.22000.0\Include\shared
set PATH_KITS_LIB_UM=%MSVC_PATH_ROOT%\Windows Kits\10.0.22000.0\Lib\um\%ARCH%
set PATH_KITS_LIB_UCRT=%MSVC_PATH_ROOT%\Windows Kits\10.0.22000.0\Lib\ucrt\%ARCH%

::-----------------------------------------------------
:: 设置编译参数

:: 系统头文件路径
set INCLUDE=/I"%PATH_MSVC_INCLUDE%" /I"%PATH_MSVC_INCLUDE_MFC%" /I"%PATH_KITS_INCLUDE_UM%" /I"%PATH_KITS_INCLUDE_UCRT%" /I"%PATH_KITS_INCLUDE_SHARED%"

:: 编译参数
set CF=/nologo /c /Gd /FC /W3 /WX /GS- /sdl- /EHsc- /Gm- /permissive- /Zc:wchar_t /Zc:inline /Zc:forScope /fp:precise /diagnostics:column /errorReport:prompt /Fo:"%TMP%/" /Fd:"%TMP%/" %CF% %INCLUDE%

:: 程序架构类型:x64,x86
if "%ARCH%" == "x64" (set CF=%CF% /D"_WINDOWS" /D"_WIN64" /D"X64") else (set CF=%CF% /D"_WINDOWS" /D"_WIN32" /D"WIN32")

:: 构建类型:debug,release
if "%DEBUG%" == "y" (set CF=%CF% /D"_DEBUG" /JMC /ZI /Od /RTC1) else (set CF=%CF% /D"NDEBUG" /Zi /O2 /Oi /GL /Gy)

:: 字符集类型:mbcs,unicode,utf8
if "%CHARSET%" == "mbcs" (set CF=%CF% /D"_MBCS") else if "%CHARSET%" == "unicode" (set CF=%CF% /D"_UNICODE" /D"UNICODE") else (set CF=%CF% /D"_UNICODE" /D"UNICODE" /utf-8)

:: 编译资源参数
set RF=%INCLUDE% /nologo /fo"%TMP%\%NAME%.res" "%RES%"

::-----------------------------------------------------
:: 设置连接参数

:: 系统库路径
set LIB=/LIBPATH:"%PATH_MSVC_LIB%" /LIBPATH:"%PATH_MSVC_LIB_MFC%" /LIBPATH:"%PATH_KITS_LIB_UM%" /LIBPATH:"%PATH_KITS_LIB_UCRT%"

:: 连接参数
set LF=%LF% %LIB% /nologo /MANIFEST /NXCOMPAT /ERRORREPORT:PROMPT /TLBID:1

:: 构建类型:debug,release
if "%DEBUG%" == "y" (set LF=%LF% /DEBUG /INCREMENTAL) else (set LF=%LF% /INCREMENTAL:NO /OPT:REF /LTCG:incremental)

:: 目标类型:exe,dll,lib
if "%EXT%" == "exe" (set LF=%LF% /OUT:%TMP%\%NAME%.exe) else if "%EXT%" == "dll" (set LF=%LF% /OUT:%TMP%\%NAME%.dll /DLL) else if "%EXT%" == "lib" (set LF=/nologo /OUT:%TMP%\%NAME%.lib && set TOOL_LNK=%TOOL_LIB%) else (echo EXT="%EXT% error" && pause && exit)

::-----------------------------------------------------
::执行命令

if "%2" == "all" (del /q/s "%ROOT%%TMP%\*")
if "%2" == "run" (cd %OUT% && start %NAME%.exe && exit)
if "%2" == "clean" (rd /q/s "%TMP%" && exit)

if not exist "%TMP%" (mkdir "%TMP%")

::-----------------------------------------------------
:: 编译文件

set PATH=%PATH%;%PATH_MSVC_BIN%;%PATH_KITS_BIN%

:: 编译资源文件
if "%RES%" neq "" (%TOOL_RC% %RF% && set OBJ=%TMP%\%NAME%.res)

:: 编译文件,多个源目录
for %%D in (%SRC%) do (
    for /f %%F in ('dir /s/b %%D') do (
        set COMPILE=

        :: 比较扩展名
        if "%%~xF" == ".c"   (set COMPILE=1)
        if "%%~xF" == ".cpp"   (set COMPILE=1)

        if "!COMPILE!" == "1" (
            set FILE=%%F

            ::得到文件相对路径名
            set FILENAME=!FILE:%ROOT%=!

            :: 得到第一个目录名,检查是否需要排除
            for /f "delims=\" %%E in ('echo !FILENAME!') do (set DIR=%%E)
            echo %EXC% | findstr !DIR! > nul && (echo !FILENAME! exclude dir && set COMPILE=0)
            echo %EXC% | findstr %%~nxF > nul && (echo !FILENAME! exclude file && set COMPILE=0)
        )

        if "!COMPILE!" == "1" (
            set COMPILE=
            if "%2" == "all" (set COMPILE=1)
            if "%2" == "!FILE!" (set COMPILE=1)

            set "OBJ=!OBJ! %TMP%\%%~nF.obj"
        )

        if "!COMPILE!" == "1" (
            for /f "tokens=*" %%a in ('%TOOL_CC% "!FILE!" %CF%') do (echo %%a && set RET=%%a)

            if "!RET!" neq "%%~nxF" (echo %TOOL_CC% "!FILE!" %CF% && pause && exit)
        )
    )
)

::-----------------------------------------------------
:: 连接文件
%TOOL_LNK% %OBJ% %LF%

:: 不成功暂停
if %errorlevel% neq 0 (echo %TOOL_LNK% %OBJ% %LF% && pause && exit)

::-----------------------------------------------------
::移动文件到输出目录

::move失败返回的errorlevel也是0
for /f "tokens=2 delims= " %%i in ('move /y "%TMP%\%NAME%.%EXT%" "%OUT%"') do (set RET=%%i)

if "!RET!" neq "1" (echo move /y "%TMP%\%NAME%.%EXT%" "%OUT%" 失败 && pause && exit)
