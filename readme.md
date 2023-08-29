### 编译MFC程序需要将下面的代码加入代码中

```
#ifdef NMAKE
 // 来自于Microsoft Visual Studio\2022\VC\Tools\MSVC\14.30.30705\atlmfc\src\mfc\winmain.cpp
 int AFXAPI AfxWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, _In_ LPTSTR lpCmdLine, int nCmdShow)
 {
     ASSERT(hPrevInstance == NULL);

     int nReturnCode = -1;
     CWinThread* pThread = AfxGetThread();
     CWinApp* pApp = AfxGetApp();

     // AFX internal initialization
     if (!AfxWinInit(hInstance, hPrevInstance, lpCmdLine, nCmdShow))
         goto InitFailure;

     // App global initializations (rare)
     if (pApp != NULL && !pApp->InitApplication())
         goto InitFailure;

     // Perform specific initializations
     if (!pThread->InitInstance())
     {
         if (pThread->m_pMainWnd != NULL)
         {
             TRACE(traceAppMsg, 0, "Warning: Destroying non-NULL m_pMainWnd\n");
             pThread->m_pMainWnd->DestroyWindow();
         }
         nReturnCode = pThread->ExitInstance();
         goto InitFailure;
     }
     nReturnCode = pThread->Run();

 InitFailure:
 #ifdef _DEBUG
     // Check for missing AfxLockTempMap calls
     if (AfxGetModuleThreadState()->m_nTempMapLock != 0)
     {
         TRACE(traceAppMsg, 0, "Warning: Temp map lock count non-zero (%ld).\n", AfxGetModuleThreadState()->m_nTempMapLock);
     }
     AfxLockTempMaps();
     AfxUnlockTempMaps(-1);
 #endif

     AfxWinTerm();
     return nReturnCode;
 }

 // 来自于Microsoft Visual Studio\2022\VC\Tools\MSVC\14.30.30705\atlmfc\src\mfc\appmodule.cpp
 extern "C" int WINAPI _tWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, _In_ LPTSTR lpCmdLine, int nCmdShow)
 #pragma warning(suppress: 4985)
 {
     // call shared/exported WinMain
     return AfxWinMain(hInstance, hPrevInstance, lpCmdLine, nCmdShow);
 }
#endif

```
