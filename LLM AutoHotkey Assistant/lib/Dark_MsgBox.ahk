/************************************************************************
 * @description Apply dark theme to the built-in MsgBox and InputBox.
 * @file Dark_MsgBox.ahk
 * @link https://github.com/nperovic/DarkMsgBox
 * @author Nikola Perovic
 * @date 2024/06/16
 * @version 1.1.0
 ***********************************************************************/
#Requires AutoHotkey v2

#DllLoad gdi32.dll

class DarkMsgBox
{
    static __New()
    {
        /** Thanks to geekdude & Mr Doge for providing this method to rewrite built-in functions. */
        static _Msgbox   := MsgBox.Call.Bind(MsgBox)
        static _InputBox := InputBox.Call.Bind(InputBox)
        MsgBox.DefineProp("Call", {Call: CallNativeFunc})
        InputBox.DefineProp("Call", {Call: CallNativeFunc})

        CallNativeFunc(_this, params*)
        {
            static WM_COMMNOTIFY := 0x44
            static WM_INITDIALOG := 0x0110
            
            iconNumber := 1
            iconFile   := ""
            
            if (params.length = (_this.MaxParams + 2))
                iconNumber := params.Pop()
            
            if (params.length = (_this.MaxParams + 1)) 
                iconFile := params.Pop()
            
            SetThreadDpiAwarenessContext(-3)
    
            if InStr(_this.Name, "MsgBox")
                OnMessage(WM_COMMNOTIFY, ON_WM_COMMNOTIFY)
            else
                OnMessage(WM_INITDIALOG, ON_WM_INITDIALOG, -1)
    
            return _%_this.name%(params*)
    
            ON_WM_INITDIALOG(wParam, lParam, msg, hwnd)
            {
                OnMessage(WM_INITDIALOG, ON_WM_INITDIALOG, 0)
                WNDENUMPROC(hwnd)
            }
            
            ON_WM_COMMNOTIFY(wParam, lParam, msg, hwnd)
            {
                if (msg = 68 && wParam = 1027)
                    OnMessage(0x44, ON_WM_COMMNOTIFY, 0),                    
                    EnumThreadWindows(GetCurrentThreadId(), CallbackCreate(WNDENUMPROC), 0)
            }
    
            WNDENUMPROC(hwnd, *)
            {
                static SM_CICON         := "W" SysGet(11) " H" SysGet(12)
                static SM_CSMICON       := "W" SysGet(49) " H" SysGet(50)
                static ICON_BIG         := 1
                static ICON_SMALL       := 0
                static WM_SETICON       := 0x80
                static WS_CLIPCHILDREN  := 0x02000000
                static WS_CLIPSIBLINGS  := 0x04000000
                static WS_EX_COMPOSITED := 0x02000000
                static winAttrMap       := Map(10, true, 17, true, 20, true, 38, 4, 35, 0x2b2b2b)
    
                SetWinDelay(-1)
                SetControlDelay(-1)
                DetectHiddenWindows(true)
    
                if !WinExist("ahk_class #32770 ahk_id" hwnd)
                    return 1
    
                WinSetStyle("+" (WS_CLIPSIBLINGS | WS_CLIPCHILDREN))
                WinSetExStyle("+" (WS_EX_COMPOSITED))
                SetWindowTheme(hwnd, "DarkMode_Explorer")
    
                if iconFile {
                    hICON_SMALL := LoadPicture(iconFile, SM_CSMICON " Icon" iconNumber, &handleType)
                    hICON_BIG   := LoadPicture(iconFile, SM_CICON " Icon" iconNumber, &handleType)
                    PostMessage(WM_SETICON, ICON_SMALL, hICON_SMALL)
                    PostMessage(WM_SETICON, ICON_BIG, hICON_BIG)
                }
    
                for dwAttribute, pvAttribute in winAttrMap
                    DwmSetWindowAttribute(hwnd, dwAttribute, pvAttribute)
                
                GWL_WNDPROC(hwnd, hICON_SMALL?, hICON_BIG?)
                return 0
            }
            
            GWL_WNDPROC(winId := "", hIcons*)
            {
                static SetWindowLong     := DllCall.Bind(A_PtrSize = 8 ? "SetWindowLongPtr" : "SetWindowLong", "ptr",, "int",, "ptr",, "ptr")
                static BS_FLAT           := 0x8000
                static BS_BITMAP         := 0x0080
                static DPI               := (A_ScreenDPI / 96)
                static WM_CLOSE          := 0x0010
                static WM_CTLCOLORBTN    := 0x0135
                static WM_CTLCOLORDLG    := 0x0136
                static WM_CTLCOLOREDIT   := 0x0133
                static WM_CTLCOLORSTATIC := 0x0138
                static WM_DESTROY        := 0x0002
                static WM_SETREDRAW      := 0x000B
    
                SetControlDelay(-1)
    
                btns    := []
                btnHwnd := ""
    
                for ctrl in WinGetControlsHwnd(winId)
                {
                    classNN := ControlGetClassNN(ctrl)
                    SetWindowTheme(ctrl, !InStr(classNN, "Edit") ? "DarkMode_Explorer" : "DarkMode_CFD")
    
                    if InStr(classNN, "B") 
                        btns.Push(btnHwnd := ctrl)
                }
    
                WindowProcOld := SetWindowLong(winId, -4, CallbackCreate(WNDPROC))
                
                WNDPROC(hwnd, uMsg, wParam, lParam)
                {
                    static hbrush := []
                    SetWinDelay(-1)
                    SetControlDelay(-1)
                    
                    if !hbrush.Length
                        for clr in [0x202020, 0x2b2b2b]
                            hbrush.Push(CreateSolidBrush(clr))
    
                    switch uMsg {
                    case WM_CTLCOLORSTATIC: 
                    {
                        SelectObject(wParam, hbrush[2])
                        SetBkMode(wParam, 0)
                        SetTextColor(wParam, 0xFFFFFF)
                        SetBkColor(wParam, 0x2b2b2b)
    
                        for _hwnd in btns
                            PostMessage(WM_SETREDRAW,,,_hwnd)
    
                        GetClientRect(winId, rcC := this.RECT())
                        WinGetClientPos(&winX, &winY, &winW, &winH, winId)
                        ControlGetPos(, &btnY,, &btnH, btnHwnd)
                        hdc        := GetDC(winId)
                        rcC.top    := btnY - (rcC.bottom - (btnY+btnH))
                        rcC.bottom *= 2
                        rcC.right  *= 2
                        
                        SetBkMode(hdc, 0)
                        FillRect(hdc, rcC, hbrush[1])
                        ReleaseDC(winId, hdc)
    
                        for _hwnd in btns
                            PostMessage(WM_SETREDRAW, 1,,_hwnd)
    
                        return hbrush[2]
                    }
                    case WM_CTLCOLORBTN, WM_CTLCOLORDLG, WM_CTLCOLOREDIT: 
                    {         
                        brushIndex := !(uMsg = WM_CTLCOLORBTN)
                        SelectObject(wParam, brush := hbrush[brushIndex+1])
                        SetBkMode(wParam, 0)
                        SetTextColor(wParam, 0xFFFFFF)
                        SetBkColor(wParam, !brushIndex ? 0x202020 : 0x2b2b2b)
                        return brush
                    }
                    case WM_DESTROY: 
                    {
                        for v in hIcons
                            (v??0) && DestroyIcon(v)
    
                        while hbrush.Length
                            DeleteObject(hbrush.Pop())
                    }}
    
                    return CallWindowProc(WindowProcOld, hwnd, uMsg, wParam, lParam) 
                }
            }
    
            CreateSolidBrush(crColor) => DllCall('Gdi32\CreateSolidBrush', 'uint', crColor, 'ptr')
            
            CallWindowProc(lpPrevWndFunc, hWnd, uMsg, wParam, lParam) => DllCall("CallWindowProc", "Ptr", lpPrevWndFunc, "Ptr", hwnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam)
    
            DestroyIcon(hIcon) => DllCall("DestroyIcon", "ptr", hIcon)
    
            /** @see — https://learn.microsoft.com/en-us/windows/win32/api/dwmapi/ne-dwmapi-dwmwindowattribute */
            DWMSetWindowAttribute(hwnd, dwAttribute, pvAttribute, cbAttribute := 4) => DllCall("Dwmapi\DwmSetWindowAttribute", "Ptr" , hwnd, "UInt", dwAttribute, "Ptr*", &pvAttribute, "UInt", cbAttribute)
            
            DeleteObject(hObject) => DllCall('Gdi32\DeleteObject', 'ptr', hObject, 'int')
            
            EnumThreadWindows(dwThreadId, lpfn, lParam) => DllCall("User32\EnumThreadWindows", "uint", dwThreadId, "ptr", lpfn, "uptr", lParam, "int")
            
            FillRect(hDC, lprc, hbr) => DllCall("User32\FillRect", "ptr", hDC, "ptr", lprc, "ptr", hbr, "int")
            
            GetClientRect(hWnd, lpRect) => DllCall("User32\GetClientRect", "ptr", hWnd, "ptr", lpRect, "int")
            
            GetCurrentThreadId() => DllCall("Kernel32\GetCurrentThreadId", "uint")
            
            GetDC(hwnd := 0) => DllCall("GetDC", "ptr", hwnd, "ptr")
    
            ReleaseDC(hWnd, hDC) => DllCall("User32\ReleaseDC", "ptr", hWnd, "ptr", hDC, "int")
            
            SelectObject(hdc, hgdiobj) => DllCall('Gdi32\SelectObject', 'ptr', hdc, 'ptr', hgdiobj, 'ptr')
            
            SetBkColor(hdc, crColor) => DllCall('Gdi32\SetBkColor', 'ptr', hdc, 'uint', crColor, 'uint')
            
            SetBkMode(hdc, iBkMode) => DllCall('Gdi32\SetBkMode', 'ptr', hdc, 'int', iBkMode, 'int')
    
            SetTextColor(hdc, crColor) => DllCall('Gdi32\SetTextColor', 'ptr', hdc, 'uint', crColor, 'uint')
            
            SetThreadDpiAwarenessContext(dpiContext) => DllCall("SetThreadDpiAwarenessContext", "ptr", dpiContext, "ptr")
    
            SetWindowTheme(hwnd, pszSubAppName, pszSubIdList := "") => (!DllCall("uxtheme\SetWindowTheme", "ptr", hwnd, "ptr", StrPtr(pszSubAppName), "ptr", pszSubIdList ? StrPtr(pszSubIdList) : 0) ? true : false)
        }
    }

    class RECT extends Buffer {
        static ofst := Map("left", 0, "top", 4, "right", 8, "bottom", 12)

        __New(left := 0, top := 0, right := 0, bottom := 0) {
            super.__New(16)
            NumPut("int", left, "int", top, "int", right, "int", bottom, this)
        }

        __Set(Key, Params, Value) {
            if DarkMsgBox.RECT.ofst.Has(k := StrLower(key))
                NumPut("int", value, this, DarkMsgBox.RECT.ofst[k])
            else throw PropertyError
        }

        __Get(Key, Params) {
            if DarkMsgBox.RECT.ofst.Has(k := StrLower(key))
                return NumGet(this, DarkMsgBox.RECT.ofst[k], "int")
            throw PropertyError
        }

        width  => this.right - this.left
        height => this.bottom - this.top
    }
} 

; Example:
if (A_LineFile = A_ScriptFullPath && !A_IsCompiled) {
    ipb := InputBox("Enter something here`nAnd here.", "InputBox Title")
    MsgBox(123, "Your Input", "0x36")
    ExitApp()
}