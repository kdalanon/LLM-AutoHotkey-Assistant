#Requires AutoHotkey v2

/**
 * Creates a Pop-up Tooltip window that follows the mouse movement.
 * @param {any} [Text]
 * > If omitted, the existing tooltip (if any) will be hidden. Otherwise,
 * this parameter is the text to display in the tooltip.
 * @param {number} [TimeOut=5]
 * > The tooltip will be hidden after the set number of seconds.  
 * > If you do not want the tooltip to be hidden automatically after a timeout, set this parameter to 0.
 * @param {number} [WhichToolTip]
 * > Omit this parameter if you don't need multiple tooltips to appear simultaneously.  
 * > Otherwise, this is a number between 1 and 20 to indicate which tooltip window to operate upon.  
 * > If unspecified, that number is 1 (the first).
 * @param {integer} [ClickMode=false]  
 * > When the `ClickMode` is `true`, the following features will be enable:  
 *  > - Holding LButton to move the ToolTip.  
 *  > - Doble click to close the ToolTip.
 * 
 * > **NOTE**: The `Tooltip` will **NOT** follow the mouse movement if `ClickMode` is on.
 * @param {integer} [x]
 * > If omitted, the tooltip will be shown near the mouse cursor.  
 * > Otherwise, specify the X and Y position of the tooltip relative to the active window's client area (use `CoordMode "ToolTip"` to change to screen coordinates).  
 * 
 * > **NOTE**: This parameter will **NOT** be used if `ClickMode` is off.
 * @param {integer} [y]
 * > If omitted, the tooltip will be shown near the mouse cursor.  
 * > Otherwise, specify the X and Y position of the tooltip relative to the active window's client area (use `CoordMode "ToolTip"` to change to screen coordinates).  
 * 
 * > **NOTE**: This parameter will **NOT** be used if `ClickMode` is off.
 * @returns {void}
 * @author nperovic
 * @see https://github.com/nperovic/ToolTipEx
 */
ToolTipEX(Text?, TimeOut := 5, WhichToolTip?, ClickMode := false, X?, Y?) 
{
    static stackTT := Map()
    static _       := (GroupAdd("ToolTips", "ahk_class tooltips_class32 ahk_exe" A_AhkPath))
    
    SetWinDelay(-1)

    ProcessSetPriority("High")

	if !IsSet(Text)  
        return !IsSet(WhichToolTip) ? WinClose("ahk_group ToolTips") : ToolTip(,,, WhichToolTip?)

    if !ClickMode
    {
        tOut := !TimeOut ? 0 : A_TickCount + timeout * 1000
        tt   := ToolTip(Text?,,, WhichToolTip?)
        SetTimer(stackTT[tt] := Updating.Bind(tt, tOut), -1)
    }
    else
    {
        for _hWnd in WinGetList("ahk_group ToolTips") {
            if stackTT.Has(_hWnd)
                SetTimer(stackTT[_hWnd], 0)
        }
        else
            for msg in [0x2, 0x201, 0x203]
                OnMessage(msg, OnMsg)

        tt := ToolTip(Text?, X?, Y?, WhichToolTip?)

        if TimeOut
            SetTimer(stackTT[tt] := CloseTT.Bind(tt), TimeOut * -1000)
    }

    return tt

    CloseTT(hWnd)
    {
        if WinExist(hWnd)
            try WinClose(hWnd)
        stackTT.Delete(hwnd)
    }

	Updating(hwnd, _timeout)
	{
        static pX := 0
        static pY := 0

		SetWinDelay(-1)

        if !WinExist(hwnd)
            return pX := pY := 0

        newX := newY := 0

		if (_timeout && A_TickCount >= _timeout) || !CalculatePopupWindowPosition(hwnd) {
			try WinClose(hwnd)
            stackTT.Delete(hwnd)
            return pX := pY := 0
        }

        if (pX != newX || pY != newY) 
            try WinMove(pX := newX, pY := newY)
        
        SetTimer(stackTT[hwnd], -1)

        CalculatePopupWindowPosition(hwnd)
        {
            static flags := (VerCompare(A_OSVersion, "6.2") < 0 ? 0 : 0x10000)
    
            CoordMode("Mouse")
            try {
                MouseGetPos(&x, &y)
                NumPut("int", x+16, "int", y+16, anchorPt := Buffer(8))
                NumPut("int", x-3, "int", y-3, "int", x+3, "int", y+3, excludeRect := Buffer(16))
                DllCall("GetClientRect", "ptr", hwnd, "ptr", winRect := Buffer(16))
                DllCall("CalculatePopupWindowPosition", "ptr", anchorPt, "ptr", winRect.ptr+8, "uint", flags, "ptr", excludeRect, "ptr", outRect := Buffer(16))
                newX := NumGet(outRect, 0, 'int')
                newY := NumGet(outRect, 4, 'int')
                return true
            } 
            return false
        }
	}

    OnMsg(wParam, lParam, msg, hwnd)
    {
        static WM_LBUTTONDBLCLK := 0x203
        static WM_LBUTTONDOWN   := 0x201
        static WM_NCLBUTTONDOWN := 0xA1
        static WM_DESTROY       := 0x2

        SetWinDelay(-1)

        if WinExist("ahk_group ToolTips ahk_id" hwnd) {
            switch msg {
            case WM_LBUTTONDOWN  : PostMessage(WM_NCLBUTTONDOWN, 2)
            case WM_LBUTTONDBLCLK, WM_DESTROY: 
                for msg in [0x2, 0x201, 0x203]
                    OnMessage(msg, OnMsg, 0)
                try WinClose(hWnd)
                if stackTT.Has(hwnd)
                    stackTT.Delete(hwnd)
            } return 0
        }
    }
}
