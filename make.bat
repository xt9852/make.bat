::-----------------------------------------------------
:: File:        make.bat
:: Author:      �ź���
:: Version:     2.0.0
:: Encode:      GB2312
:: Date:        2022-01-17
:: Description: ����VS���빤��
::-----------------------------------------------------

:: ����ʾ�����ַ���
@echo off

:: UTF-8����ҳ,�����б������Ҽ�,����/����,Lucida Console,936-��������(GB2312)
@chcp 65001

:: ������ɫ
@color 0A

:: ���û�������С,���ô��ڴ�С,�����б������Ҽ�,����/����,���ڴ�С
@mode con COLS=100 LINES=1000

:: ��ʱ������չ,���������for�ı�������������
setLocal EnableDelayedExpansion

::----------------------------------------------------------------------------------------------------------

:: �ⲿ����
echo ARG=%*

if "%1" == "" (echo "Don't have make.ini path" && pause && exit)
if "%2" == "" (echo "Don't have {all|run|clean|[filename]}" && pause && exit)

::----------------------------------------------------------------------------------------------------------

:: ��������
set NAME=example

:: ��������:exe,dll,lib
set EXT=exe

:: ����ܹ�:x86,x64
set ARCH=x86

:: �Ƿ����:y,n
set DEBUG=n

:: �ַ���:mbcs,unicode,utf8
set CHARSET=utf8

:: Դ�ļ�Ŀ¼,���������ڵ�.c,.cpp�ļ�,�ɶ��
set SRC=.

:: Դ�ļ�,�ɶ��
set FILE=

:: ��Դ�����ļ�
set RES=

:: �ų����ļ�,Ŀ¼
set EXC=

:: Ŀ���ļ�·��
set OUT=.

:: ��ʱ�ļ�·��
set TMP=.\tmp

:: �������
set CF=/WX /DXT_LOG

:: ���Ӳ���
set LF=gdi32.lib User32.lib Advapi32.lib Shell32.lib

::----------------------------------------------------------------------------------------------------------
:: ���������ļ�make.ini

set MAKE_INI_PATH=%1

:: ��·���е�'\'�滻�ɿո�
set MAKE_INI_PATH=%MAKE_INI_PATH:\= %

:: ����Ŀ¼����
for %%i in (%MAKE_INI_PATH%) do ( set /a DIR_NUM += 1 )

:: ����Ŀ¼���ϲ���make.ini�ļ�
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
:: ��ȡ�����ļ�make.ini

:FIND_MAKE_INI

cd !ROOT!
echo cd !ROOT!

:: ��ȡmake.ini,��=�ָ��ַ�,�����ñ���
for /f "tokens=1,* delims==" %%a in (make.ini) do (set "%%a=%%b" && echo %%a=%%b)

::----------------------------------------------------------------------------------------------------------
::ִ������

if "%2" == "all" (del /q/s "%ROOT%%TMP%\*" >nul 2>nul)
if "%2" == "run" (cd %OUT% && start %NAME%.exe && exit)
if "%2" == "clean" (rd /q/s "%TMP%" && exit) else if not exist "%TMP%" (mkdir "%TMP%")

::----------------------------------------------------------------------------------------------------------
:: ���빤��

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
:: ���ñ������

:: ϵͳͷ�ļ�·��
set INCLUDE=/I"%PATH_MSVC_INCLUDE%" /I"%PATH_MSVC_INCLUDE_MFC%" /I"%PATH_KITS_INCLUDE_UM%" /I"%PATH_KITS_INCLUDE_UCRT%" /I"%PATH_KITS_INCLUDE_SHARED%"

:: �������
set CF=/nologo /c /Gd /FC /W3 /GS- /sdl- /EHsc- /Gm- /permissive- /Zc:wchar_t /Zc:inline /Zc:forScope /fp:precise /diagnostics:column /errorReport:prompt /Fo:"%TMP%/" /Fd:"%TMP%/" %CF% %INCLUDE%

:: ����ܹ�����:x64,x86
if "%ARCH%" == "x64" (set CF=%CF% /D"_WINDOWS" /D"_WIN64" /D"X64") else (set CF=%CF% /D"_WINDOWS" /D"_WIN32" /D"WIN32")

:: ��������:debug,release
if "%DEBUG%" == "y" (set CF=%CF% /D"_DEBUG" /JMC /ZI /Od /RTC1) else (set CF=%CF% /D"NDEBUG" /Zi /O2 /Oi /GL /Gy)

:: �ַ�������:mbcs,unicode,utf8
if "%CHARSET%" == "mbcs" (set CF=%CF% /D"_MBCS") else if "%CHARSET%" == "unicode" (set CF=%CF% /D"_UNICODE" /D"UNICODE") else (set CF=%CF% /D"_UNICODE" /D"UNICODE" /utf-8)

:: ������Դ����
set RF=%INCLUDE% /nologo /fo"%TMP%\%NAME%.res" "%RES%"

::----------------------------------------------------------------------------------------------------------
:: �������Ӳ���

:: ϵͳ��·��
set LIB=/LIBPATH:"%PATH_MSVC_LIB%" /LIBPATH:"%PATH_MSVC_LIB_MFC%" /LIBPATH:"%PATH_KITS_LIB_UM%" /LIBPATH:"%PATH_KITS_LIB_UCRT%"

:: ���Ӳ���
set LF=/NOLOGO /MANIFEST /NXCOMPAT /ERRORREPORT:PROMPT /TLBID:1 %LIB% %LF%

:: ��������:debug,release
if "%DEBUG%" == "y" (set LF=/DEBUG /INCREMENTAL %LF%) else (set LF=/INCREMENTAL:NO /OPT:REF /LTCG %LF%)

:: Ŀ������:exe,dll,lib
if "%EXT%" == "exe" (set LF=/OUT:"%TMP%\%NAME%.exe" %LF%) else if "%EXT%" == "dll" (set LF=/OUT:"%TMP%\%NAME%.dll" /DLL %LF%) else if "%EXT%" == "lib" (set LF=/OUT:"%TMP%\%NAME%.lib" && set TOOL_LNK=%TOOL_LIB%) else (echo EXT="%EXT% error" && pause && exit)

::----------------------------------------------------------------------------------------------------------
:: ������Դ�ļ�
if "%RES%" neq "" (%TOOL_RC% %RF% && set OBJ=%TMP%\%NAME%.res)

::----------------------------------------------------------------------------------------------------------
:: �����ļ�,���ԴĿ¼

for %%D in (%SRC%) do (
    for /f %%F in ('dir /s/b %%D') do (
        set PROC=

        :: �Ƚ���չ��
        if "%%~xF" == ".c"   (set PROC=1)
        if "%%~xF" == ".cpp" (set PROC=1)

        if "!PROC!" == "1" (
            set FULLNAME=%%F

            ::�õ��ļ����·����
            set FILENAME=!FULLNAME:%ROOT%=!

            :: �õ���һ��Ŀ¼��
            for /f "delims=\" %%E in ('echo !FILENAME!') do (set HEAD=%%E)

            :: ���Ŀ¼�Ƿ���Ҫ�ų�
            echo %EXC% | findstr !HEAD! > nul && (echo !FILENAME! exclude dir && set PROC=0)

            :: ����ļ��Ƿ���Ҫ�ų�
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

:: ���ӵ��ļ�
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
:: �����ļ�
set LNK=%TOOL_LNK% %LF% %OBJ%

%LNK%

if %errorlevel% neq 0 (
    echo %LNK%
    pause
    exit
)

::----------------------------------------------------------------------------------------------------------
:: �ƶ��ļ�

set MOVE=move /y "%TMP%\%NAME%.%EXT%" "%OUT%"

echo !MOVE!

!MOVE!

if %errorlevel% neq 0 (
    pause
)
