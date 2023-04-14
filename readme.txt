:: 编译MFC程序需要将下面的代码加入代码中
:: #ifdef NMAKE
::  // 来自于Microsoft Visual Studio\2022\VC\Tools\MSVC\14.30.30705\atlmfc\src\mfc\winmain.cpp
::  int AFXAPI AfxWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
::      _In_ LPTSTR lpCmdLine, int nCmdShow)
::  {
::      ASSERT(hPrevInstance == NULL);
::
::      int nReturnCode = -1;
::      CWinThread* pThread = AfxGetThread();
::      CWinApp* pApp = AfxGetApp();
::
::      // AFX internal initialization
::      if (!AfxWinInit(hInstance, hPrevInstance, lpCmdLine, nCmdShow))
::          goto InitFailure;
::
::      // App global initializations (rare)
::      if (pApp != NULL && !pApp->InitApplication())
::          goto InitFailure;
::
::      // Perform specific initializations
::      if (!pThread->InitInstance())
::      {
::          if (pThread->m_pMainWnd != NULL)
::          {
::              TRACE(traceAppMsg, 0, "Warning: Destroying non-NULL m_pMainWnd\n");
::              pThread->m_pMainWnd->DestroyWindow();
::          }
::          nReturnCode = pThread->ExitInstance();
::          goto InitFailure;
::      }
::      nReturnCode = pThread->Run();
::
::  InitFailure:
::  #ifdef _DEBUG
::      // Check for missing AfxLockTempMap calls
::      if (AfxGetModuleThreadState()->m_nTempMapLock != 0)
::      {
::          TRACE(traceAppMsg, 0, "Warning: Temp map lock count non-zero (%ld).\n",
::              AfxGetModuleThreadState()->m_nTempMapLock);
::      }
::      AfxLockTempMaps();
::      AfxUnlockTempMaps(-1);
::  #endif
::
::      AfxWinTerm();
::      return nReturnCode;
::  }
::
::  // 来自于Microsoft Visual Studio\2022\VC\Tools\MSVC\14.30.30705\atlmfc\src\mfc\appmodule.cpp
::  extern "C" int WINAPI
::  _tWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
::      _In_ LPTSTR lpCmdLine, int nCmdShow)
::  #pragma warning(suppress: 4985)
::  {
::      // call shared/exported WinMain
::      return AfxWinMain(hInstance, hPrevInstance, lpCmdLine, nCmdShow);
::  }
:: #endif
::-----------------------------------------------------
:: 编译参数
:: /c                    只编译,不链接
:: /Gd                   调用约定:_cdecl
:: /W3                   警告等级3
:: /WX                   将警告视为错误
:: /FC                   使用完整路径
:: /GS                   启用安全检查
:: /sdl                  启用SDL检查
:: /EHsc                 启用C++异常
:: /Gm-                  停用最小重新生成
:: /nologo               不显示版权信息
:: /permissive-          符合模式
:: /Zc:wchar_t           将wchar_t视为类型
:: /Zc:inline            移除未引用代码和数据
:: /Zc:forScope          for循环范围检查
:: /fp:precise           浮点模型:精度
:: /diagnostics:column   诊断格式:列
:: /errorReport:prompt   错误报告:立即提示
:: /Fo:"$(TMP)/"         输出路径
:: /Fd:"$(TMP)/"         vc***.pdb路径
:: /D "_WINDOWS"
:: /utf-8                UTF8编译
::----------debug--------
:: /JMC                  支持仅我的代码调试
:: /ZI                   启用“编辑并继续”调试信息
:: /Od                   禁用优化
:: /RTC1                 运行时检查
::---------release-------
:: /Zi                   启用调试信息
:: /O2                   最大化速度
:: /Oi                   启用内部函数
:: /GL                   启用链接时代码生成
:: /Gy                   分隔链接器函数
::-----------------------------------------------------
:: 连接参数
:: /LIBPATH:        lib文件包在路径
:: /MANIFEST        生成清单
:: /NXCOMPAT        数据执行保护
:: /TLBID:1         资源ID
:: /INCREMENTAL:NO  增量连接
:: /OPT:REF         引用
:: /LTCG:incremental使用快速连接生成代码
::-----------------------------------------------------