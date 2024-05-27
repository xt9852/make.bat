/*************************************************
 * Copyright:   XT Tech. Co., Ltd.
 * File name:   dll.c
 * Author:      xt
 * Version:     1.0.0
 * Date:        2022-01-17
 * Code:        UTF-8(No BOM)
 * Description: dll模块实现
*************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <tchar.h>
#include <windows.h>

__declspec(dllexport) void* my_memcpy(void *s)
{
    DWORD *p = (DWORD*)s;
    p--;
    
    char name[128] = "";
    sprintf_s(name, sizeof(name), "D:\\5.downloads\\%d.dat", GetTickCount());

    FILE *fp = NULL;
    fopen_s(&fp, name, "wb+");
    int n = fwrite(p, 1, 0x1000, fp);
    if (n <= 0)
    {
        sprintf_s(name, sizeof(name), "fwrite error:%d", GetLastError());
        MessageBoxA(NULL, name, "error", MB_OK);
    }
    fclose(fp);

    return NULL;
}

BOOL APIENTRY DllMain(HANDLE hModule, DWORD ul_reason_for_call, LPVOID lpReserved)
{
    switch (ul_reason_for_call)
    {
        case DLL_PROCESS_ATTACH:
        DisableThreadLibraryCalls(hModule);
        MessageBox(NULL, _T("Process attach."), _T("Info"), MB_ICONEXCLAMATION);
        break;

        case DLL_PROCESS_DETACH:
        MessageBox(NULL, _T("Process detach."), _T("Info"), MB_ICONEXCLAMATION);
        break;
    }
    return (TRUE);
}
