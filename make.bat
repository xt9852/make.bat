::-----------------------------------------------------
:: File:        make.bat
:: Author:      张海涛
:: Version:     2.0.0
:: Encode:      GB2312
:: Date:        2022-01-17
:: Description: 调用VS编译工程
::-----------------------------------------------------

:: 不显示命令字符串
@echo off

:: UTF-8代码页,命令行标题栏右键,属性/字体,Lucida Console,936-简体中文(GB2312)
@chcp 65001

:: 字体颜色
@color 0A

:: 设置缓冲区大小,设置窗口大小,命令行标题栏右键,属性/布局,窗口大小
@mode con COLS=100 LINES=1000

:: 延时变量扩展,如果不设置for的变量将不起作用
setLocal EnableDelayedExpansion

::----------------------------------------------------------------------------------------------------------

:: 外部参数
echo ARG=%*

if "%1" == "" (echo "Don't have make.ini path" && pause && exit)
if "%2" == "" (echo "Don't have {all|run|clean|[filename]}" && pause && exit)

::----------------------------------------------------------------------------------------------------------

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

:: 源文件目录,将搜索其内的.c,.cpp文件,可多个
set SRC=.

:: 源文件,可多个
set FILE=

:: 资源描述文件
set RES=

:: 排除的文件,目录
set EXC=

:: 目标文件路径
set OUT=.

:: 临时文件路径
set TMP=.\tmp

:: 编译参数
set CF=/WX /DXT_LOG

:: 链接参数
set LF=gdi32.lib User32.lib Advapi32.lib Shell32.lib

::----------------------------------------------------------------------------------------------------------
:: 查找配置文件make.ini

set MAKE_INI_PATH=%1

:: 将路径中的'\'替换成空格
set MAKE_INI_PATH=%MAKE_INI_PATH:\= %

:: 计算目录层数
for %%i in (%MAKE_INI_PATH%) do ( set /a DIR_NUM += 1 )

:: 从子目录向上查找make.ini文件
for /l %%i in (%DIR_NUM%, -1, 1) do (
    set j=0
    set ROOT=
    for %%d in (%MAKE_INI_PATH%) do (
        set /a j+=1
        set ROOT=!ROOT!%%d\
        if "!j!" == "%%i" (
            if exist "!ROOT!make.ini" (echo INI=!ROOT!make.ini && goto FIND_MAKE_INI)
        )
    )
)

echo "Don't find make.ini"
pause
exit

::----------------------------------------------------------------------------------------------------------
:: 读取配置文件make.ini

:FIND_MAKE_INI

cd !ROOT!
echo cd !ROOT!

:: 读取make.ini,以=分割字符,并设置变量
for /f "tokens=1,* delims==" %%a in (make.ini) do (set "%%a=%%b" && echo %%a=%%b)

::----------------------------------------------------------------------------------------------------------
::执行命令

if "%2" == "all" (del /q/s "%ROOT%%TMP%\*" >nul 2>nul)
if "%2" == "run" (cd %OUT% && start %NAME%.exe && exit)
if "%2" == "clean" (rd /q/s "%TMP%" && exit) else if not exist "%TMP%" (mkdir "%TMP%")

::----------------------------------------------------------------------------------------------------------
:: 编译工具

set TOOL_CC=cl.exe
set TOOL_ML=ml.exe
set TOOL_RC=rc.exe
set TOOL_LIB=lib.exe
set TOOL_LNK=link.exe
set PATH_MSVC_ROOT=D:\4.backup\coding\VS2022
set MSVC_VER=14.30.30705
set PATH_KITS_ROOT=D:\4.backup\coding\VS2022
set KITS_VER=10.0.22000.0
set PATH_MSVC_BIN=%PATH_MSVC_ROOT%\VC\Tools\MSVC\%MSVC_VER%\bin\Hostx64\%ARCH%
set PATH_MSVC_INCLUDE=%PATH_MSVC_ROOT%\VC\Tools\MSVC\%MSVC_VER%\include
set PATH_MSVC_INCLUDE_MFC=%PATH_MSVC_ROOT%\VC\Tools\MSVC\%MSVC_VER%\atlmfc\include
set PATH_MSVC_LIB=%PATH_MSVC_ROOT%\VC\Tools\MSVC\%MSVC_VER%\lib\%ARCH%
set PATH_MSVC_LIB_MFC=%PATH_MSVC_ROOT%\VC\Tools\MSVC\%MSVC_VER%\atlmfc\lib\%ARCH%
set PATH_KITS_BIN=%PATH_KITS_ROOT%\Windows Kits\10\bin\%KITS_VER%\%ARCH%
set PATH_KITS_INCLUDE_UM=%PATH_KITS_ROOT%\Windows Kits\10\Include\%KITS_VER%\um
set PATH_KITS_INCLUDE_UCRT=%PATH_KITS_ROOT%\Windows Kits\10\Include\%KITS_VER%\ucrt
set PATH_KITS_INCLUDE_SHARED=%PATH_KITS_ROOT%\Windows Kits\10\Include\%KITS_VER%\shared
set PATH_KITS_LIB_UM=%PATH_KITS_ROOT%\Windows Kits\10\Lib\%KITS_VER%\um\%ARCH%
set PATH_KITS_LIB_UCRT=%PATH_KITS_ROOT%\Windows Kits\10\Lib\%KITS_VER%\ucrt\%ARCH%
set PATH=%PATH%;%PATH_MSVC_BIN%;%PATH_KITS_BIN%

::----------------------------------------------------------------------------------------------------------
:: 设置编译参数

:: 系统头文件路径
set INCLUDE=/I"%PATH_MSVC_INCLUDE%" /I"%PATH_MSVC_INCLUDE_MFC%" /I"%PATH_KITS_INCLUDE_UM%" /I"%PATH_KITS_INCLUDE_UCRT%" /I"%PATH_KITS_INCLUDE_SHARED%"

:: 编译参数
set CF=/nologo /c /Gd /FC /W3 /GS- /sdl- /EHsc- /Gm- /permissive- /Zc:wchar_t /Zc:inline /Zc:forScope /fp:precise /diagnostics:column /errorReport:prompt /Fo:"%TMP%/" /Fd:"%TMP%/" %CF% %INCLUDE%

:: 程序架构类型:x64,x86
if "%ARCH%" == "x64" (set CF=%CF% /D"_WINDOWS" /D"_WIN64" /D"X64") else (set CF=%CF% /D"_WINDOWS" /D"_WIN32" /D"WIN32")

:: 构建类型:debug,release
if "%DEBUG%" == "y" (set CF=%CF% /D"_DEBUG" /JMC /ZI /Od /RTC1) else (set CF=%CF% /D"NDEBUG" /Zi /O2 /Oi /GL /Gy)

:: 字符集类型:mbcs,unicode,utf8
if "%CHARSET%" == "mbcs" (set CF=%CF% /D"_MBCS") else if "%CHARSET%" == "unicode" (set CF=%CF% /D"_UNICODE" /D"UNICODE") else (set CF=%CF% /D"_UNICODE" /D"UNICODE" /utf-8)

:: 编译资源参数
set RF=%INCLUDE% /nologo /fo"%TMP%\%NAME%.res" "%RES%"

::----------------------------------------------------------------------------------------------------------
:: 设置连接参数

:: 系统库路径
set LIB=/LIBPATH:"%PATH_MSVC_LIB%" /LIBPATH:"%PATH_MSVC_LIB_MFC%" /LIBPATH:"%PATH_KITS_LIB_UM%" /LIBPATH:"%PATH_KITS_LIB_UCRT%"

:: 连接参数
set LF=/NOLOGO /MANIFEST /NXCOMPAT /ERRORREPORT:PROMPT /TLBID:1 %LIB% %LF%

:: 构建类型:debug,release
if "%DEBUG%" == "y" (set LF=/DEBUG /INCREMENTAL %LF%) else (set LF=/INCREMENTAL:NO /OPT:REF /LTCG %LF%)

:: 目标类型:exe,dll,lib
if "%EXT%" == "exe" (set LF=/OUT:"%TMP%\%NAME%.exe" %LF%) else if "%EXT%" == "dll" (set LF=/OUT:"%TMP%\%NAME%.dll" /DLL %LF%) else if "%EXT%" == "lib" (set LF=/OUT:"%TMP%\%NAME%.lib" && set TOOL_LNK=%TOOL_LIB%) else (echo EXT="%EXT% error" && pause && exit)

::----------------------------------------------------------------------------------------------------------
:: 编译资源文件
if "%RES%" neq "" (%TOOL_RC% %RF% && set OBJ=%TMP%\%NAME%.res)

::----------------------------------------------------------------------------------------------------------
:: 编译文件,多个源目录

for %%D in (%SRC%) do (
    for /f %%F in ('dir /s/b %%D') do (
        set PROC=

        :: 比较扩展名
        if "%%~xF" == ".c"   (set PROC=1)
        if "%%~xF" == ".cpp" (set PROC=1)

        if "!PROC!" == "1" (
            set FULLNAME=%%F

            ::得到文件相对路径名
            set FILENAME=!FULLNAME:%ROOT%=!

            :: 得到第一个目录名
            for /f "delims=\" %%E in ('echo !FILENAME!') do (set HEAD=%%E)

            :: 检查目录是否需要排除
            echo %EXC% | findstr !HEAD! > nul && (echo !FILENAME! exclude dir && set PROC=0)

            :: 检查文件是否需要排除
            echo %EXC% | findstr %%~nxF > nul && (echo !FILENAME! exclude file && set PROC=0)
        )

        if "!PROC!" == "1" (
            set PROC=
            if "%2" == "all" (set PROC=1)
            if "%2" == "%%F" (set PROC=1)
            set "OBJ=!OBJ! %TMP%\%%~nF.obj"
        )

        if "!PROC!" == "1" (
            set CMP=%TOOL_CC% "%%F" %CF%
            !CMP!
            if !errorlevel! neq 0 ( echo !CMP! && pause && exit )
        )
    )
)

:: 附加的文件
for %%F in (%FILE%) do (
    set PROC=
    if "%2" == "all" (set PROC=1)
    if "%2" == "%%F" (set PROC=1)
    set "OBJ=!OBJ! %TMP%\%%~nF.obj"

    if "!PROC!" == "1" (
        set CMP=%TOOL_CC% "%%F" %CF%
        !CMP!
        if !errorlevel! neq 0 ( echo !CMP! && pause && exit )
    )
)

::----------------------------------------------------------------------------------------------------------
:: 连接文件
set LNK=%TOOL_LNK% %LF% %OBJ%

%LNK%

if %errorlevel% neq 0 (
    echo %LNK%
    pause
    exit
)

::----------------------------------------------------------------------------------------------------------
:: 移动文件

set MOVE=move /y "%TMP%\%NAME%.%EXT%" "%OUT%"

echo !MOVE!

!MOVE!

if %errorlevel% neq 0 (
    pause
)
