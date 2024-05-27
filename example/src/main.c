/*************************************************
 * Copyright:   XT Tech. Co., Ltd.
 * File name:   main.c
 * Author:      xt
 * Version:     1.0.0
 * Date:        2022-01-17
 * Code:        UTF-8(No BOM)
 * Description: 主模块实现
*************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <tchar.h>
#include <Windows.h>
#include <CommCtrl.h>
#include "resource.h"

#define SIZEOF(x)               sizeof(x)/sizeof(x[0])
#define SP(...)                 _stprintf_s(info, SIZEOF(info), __VA_ARGS__)

TCHAR *g_title                  = _T("titlename");
HFONT  g_font                   = NULL;

/**
 * \brief   开始按钮
 * \param   [in]  HWND wnd 主窗s体句柄
 * \return  无
 */
void btn_start(HWND wnd)
{
}

/**
 * \brief   拖拽文件
 * \param   [in]  WPARAM w 拖拽句柄
 * \return  无
 */
void on_dropfiles(WPARAM w)
{
    HDROP drop = (HDROP)w;
    TCHAR name[512];
    int count = DragQueryFile(drop, 0xFFFFFFFF, NULL, 0); // 拖拽文件个数

    for (int i = 0; i < count; i++)
    {
        DragQueryFile(drop, i, name, MAX_PATH);
        MessageBox(NULL, name, g_title, MB_OK);
    }

    DragFinish(drop);
}

/**
 * \brief   创建消息处理函数
 * \param   [in]  HWND wnd 窗体句柄
 * \return  无
 */
void on_create(HWND wnd)
{
    HWND ctl = CreateWindow(WC_EDIT,                                // 控件类型
                _T(""),                                             // 名称
                WS_CHILD | WS_VISIBLE | WS_BORDER | ES_AUTOHSCROLL, // 属性
                0, 20,                                              // 在父窗口位置
                300, 25,                                            // 大小
                wnd,                                                // 父窗口句柄
                (HMENU)IDC_EDIT,                                    // 控件ID
                NULL,                                               // 实例
                NULL);                                              // 参数

    SendMessage(ctl, WM_SETFONT, (WPARAM)g_font, (LPARAM)TRUE);

    ctl = CreateWindow(WC_BUTTON,
                _T("start"),
                WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
                300, 20,
                100, 25,
                wnd,
                (HMENU)IDC_BTN_START,
                NULL,
                NULL);

    SendMessage(ctl, WM_SETFONT, (WPARAM)g_font, (LPARAM)TRUE);

    DragAcceptFiles(wnd, TRUE); // 属性WS_EX_ACCEPTFILES
}

/**
 * \brief   命令消息处理函数,菜单,按钮都会发此消息
 * \param   [in]  HWND   wnd    窗体句柄
 * \param   [in]  WPARAM w      消息参数
 * \return  无
 */
void on_command(HWND wnd, WPARAM w)
{
    int obj = LOWORD(w);
    int cmd = HIWORD(w);

    switch (obj)
    {
        case IDM_TEST:      MessageBox(NULL, _T("测试"), g_title, MB_OK); break;
        case IDM_HELP:      MessageBox(NULL, _T("帮助"), g_title, MB_OK); break;
        case IDM_EXIT:      PostMessage(wnd, WM_CLOSE, 0, 0);             break;
        case IDC_BTN_START: btn_start(wnd);                               break;
    }
}

/**
 * \brief   字符输入处理函数
 * \param   [in]  HWND   wnd    窗体句柄
 * \param   [in]  WPARAM w      字符
 * \return  无
 */
void on_char(HWND wnd, WPARAM w)
{
    TCHAR info[20];
    SP(_T("字符:%d"), (int)w);
    MessageBox(NULL, info, g_title, MB_ICONEXCLAMATION);
}

/**
 * \brief   鼠标左键按下处理函数
 * \param   [in]  HWND wnd 窗体句柄
 * \return  无
 */
void on_lbuttondown(HWND wnd)
{
    HDC dc = GetDC(wnd);
    SelectObject(dc, g_font);
    SetBkMode(dc, TRANSPARENT);
    TextOut(dc, 200, 0, _T("WM_LBUTTONDOWN"), lstrlen(_T("WM_LBUTTONDOWN")));
    ReleaseDC(wnd, dc);
}

/**
 * \brief   鼠标右键按下处理函数
 * \param   [in]  HWND wnd 窗体句柄
 * \return  无
 */
void on_rbuttondown(HWND wnd)
{
    RECT rc = { 200, 0, 400, 20};
    InvalidateRect(wnd, &rc, TRUE);
}

/**
 * \brief   绘图处理函数
 * \param   [in]  HWND wnd 窗体句柄
 * \return  无
 */
void on_paint(HWND wnd)
{
    TCHAR info[60];

#ifdef _WIN64
    _tcscpy_s(info, SIZEOF(info), _T("_WIN64 "));
#else
    _tcscpy_s(info, SIZEOF(info), _T("_WIN32 "));
#endif

#ifdef _DEBUG
    _tcscat_s(info, SIZEOF(info), _T("_DEBUG "));
#else
    _tcscat_s(info, SIZEOF(info), _T("NDEBUG "));
#endif

#ifdef _MBCS
    _tcscat_s(info, SIZEOF(info), _T("_MBCS "));
#else
    _tcscat_s(info, SIZEOF(info), _T("_UNICODE "));
#endif

    PAINTSTRUCT ps;
    HDC dc = BeginPaint(wnd, &ps);
    SelectObject(dc, g_font);
    SetBkMode(dc, TRANSPARENT);
    SetTextColor(dc, RGB(255, 0, 0));
    TextOut(dc, 0, 0, info, lstrlen(info));
    EndPaint(wnd, &ps);
}

/**
 * \brief   窗体关闭处理函数
            当用户点击窗体上的关闭按钮时,
            系统发出WM_CLOSE消息,自己执行DestroyWindow关闭窗口,
            然后发送WM_DESTROY消息,自己执行PostQuitMessage关闭应用程序,
            最后发出WM_QUIT消息来关闭消息循环
 * \param   [in]  HWND wnd 窗体句柄
 * \return  无
 */
void on_close(HWND wnd)
{
    int ret = MessageBox(NULL, _T("确定退出?"), g_title, MB_ICONQUESTION | MB_YESNO);

    if (IDYES == ret)
    {
        DestroyWindow(wnd);
    }
}

/**
 * \brief   窗体消毁处理函数
 * \param   [in]  HWND wnd 窗体句柄
 * \return  无
 */
void on_destory(HWND wnd)
{
    PostQuitMessage(0);
}

/**
 * \brief   窗体类消息处理回调函数
 * \param   [in]  HWND   wnd    窗体句柄
 * \param   [in]  UINT   msg    消息ID
 * \param   [in]  WPARAM w      消息参数
 * \param   [in]  LPARAM l      消息参数
 * \return  LRESULT 消息处理结果，它与发送的消息有关
 */
LRESULT CALLBACK window_proc(HWND wnd, UINT msg, WPARAM w, LPARAM l)
{
    switch(msg)
    {
        case WM_COMMAND:     on_command(wnd, w);    break;
        case WM_CREATE:      on_create(wnd);        break;
        case WM_CHAR:        on_char(wnd, w);       break;
        case WM_LBUTTONDOWN: on_lbuttondown(wnd);   break;
        case WM_RBUTTONDOWN: on_rbuttondown(wnd);   break;
        case WM_PAINT:       on_paint(wnd);         break;
        case WM_DROPFILES:   on_dropfiles(w);       break;
        case WM_CLOSE:       on_close(wnd);         return 0;
        case WM_DESTROY:     on_destory(wnd);       return 0;
    }

    return DefWindowProc(wnd, msg, w, l);
}

/**
 * \brief   窗体类程序主函数
 * \param   [in]  HINSTANCE hInstance       当前实例句柄
 * \param   [in]  HINSTANCE hPrevInstance   先前实例句柄
 * \param   [in]  LPSTR     lpCmdLine       命令行参数
 * \param   [in]  int       nCmdShow        显示状态(最小化,最大化,隐藏)
 * \return  int 程序返回值
 */
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
                   LPSTR lpCmdLine, int nCmdShow)
{
    // 字体
    LOGFONT lf;
    lf.lfWeight         = 400;  // 粗细程度,0到1000,正常400，粗体700
    lf.lfHeight         = 18;   // 高度
    lf.lfWidth          = 8;    // 宽度
    lf.lfEscapement     = 0;    // 行角度900为90度
    lf.lfOrientation    = 0;    // 字符角度
    lf.lfItalic         = 0;    // 斜体
    lf.lfUnderline      = 0;    // 下划线
    lf.lfStrikeOut      = 0;    // 删除线
    lf.lfOutPrecision   = 0;    // 输出精度
    lf.lfClipPrecision  = 0;    // 剪辑精度
    lf.lfQuality        = 0;    // 输出质量
    lf.lfPitchAndFamily = 0;    // 字符间距和族
    lf.lfCharSet        = DEFAULT_CHARSET;
    lstrcpy(lf.lfFaceName, _T("Courier New"));
    g_font = CreateFontIndirect(&lf);

    // 窗体类
    WNDCLASS wc;
    wc.cbClsExtra    = 0;
    wc.cbWndExtra    = 0;
    wc.style         = CS_HREDRAW | CS_VREDRAW;     // 类型属性
    wc.lpfnWndProc   = window_proc;                 // 窗体消息处理函数
    wc.lpszMenuName  = MAKEINTRESOURCE(IDC_MENU);   // 菜单,由rc文件声明
    wc.lpszClassName = _T("class_name");            // 类名称
    wc.hInstance     = hInstance;                   // 实例
    wc.hIcon         = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_GREEN)); // 图标
    wc.hCursor       = LoadCursor(NULL, IDC_CROSS);                     // 鼠标指针
    wc.hbrBackground = CreateSolidBrush(RGB(240, 240, 240));            // 背景刷
    RegisterClass(&wc);

    // 窗体居中
    int cx = 800;
    int cy = 600;
    int x = (GetSystemMetrics(SM_CXSCREEN) - cx) / 2;
    int y = (GetSystemMetrics(SM_CYSCREEN) - cy) / 2;

    // 创建窗体
    HWND wnd = CreateWindow(wc.lpszClassName,       // 类名称
                            g_title,                // 窗体名称
                            WS_OVERLAPPEDWINDOW,    // 窗体属性
                            x,  y,                  // 窗体位置
                            cx, cy,                 // 窗体大小
                            NULL,                   // 父窗句柄
                            NULL,                   // 菜单句柄
                            hInstance,              // 实例句柄
                            NULL);                  // 参数,给WM_CREATE的lParam的CREATESTRUCT

    // 显示窗体
    ShowWindow(wnd, SW_SHOWNORMAL);

    // 重绘窗体
    UpdateWindow(wnd);

    // 消息体
    MSG msg;

    // 加载快捷键表
    HACCEL accelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_ACCELE));

    // 消息循环,从消息队列中取得消息,只到WM_QUIT时退出
    while (GetMessage(&msg, NULL, 0, 0))
    {
        // 将WM_KEYDOWN或WM_SYSKEYDOWN消息翻译成一个WM_COMMAND或WM_SYSCOMMAND消息
        if (!TranslateAccelerator(msg.hwnd, accelTable, &msg))
        {
            TranslateMessage(&msg); // 将WM_KEYDOWN和WM_KEYUP转换为一条WM_CHAR消息
            DispatchMessage(&msg);  // 分派消息到窗口,内部调用窗体消息处理回调函数
        }
    }

    return (int)msg.lParam;
}