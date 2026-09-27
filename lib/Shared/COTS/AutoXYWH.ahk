; original by tmplinshi, modified by toralf, Alguimist: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=1079
; converted to v2 by Relayer: https://www.autohotkey.com/boards/viewtopic.php?f=83&t=114445

AutoXYWH(DimSize, cList*)
{
	Static cInfo := Map()
	If DimSize = 'reset'
		Return cInfo := Map()
	For Ctrl in cList
	{
		Ctrl.Gui.GetPos(,, &gw, &gh)
		If !cInfo.Has(Ctrl)
		{
			Ctrl.GetPos(&x, &y, &w, &h)
			fx := fy := fw := fh := 0
			For dim in StrSplit(RegExReplace(DimSize, 'i)[^xywh]'))
				f%dim% := RegExMatch(DimSize, 'i)' dim '\s*\K[\d.-]+', &m) ? m[] : 1
			If InStr(DimSize, 't')
			{
				Hwnd := DllCall('GetParent', 'Ptr', Ctrl.Hwnd, 'Ptr')
				DllCall('GetWindowRect', 'Ptr', Hwnd, 'Ptr', RECT := Buffer(16, 0))
				DllCall('MapWindowPoints', 'Ptr', 0, 'Ptr', DllCall('GetParent', 'Ptr', Hwnd, 'Ptr'), 'Ptr', RECT, 'UInt', 2)
				x -= NumGet(RECT, 'Int') * 96 // A_ScreenDPI
				y -= NumGet(RECT, 4, 'Int') * 96 // A_ScreenDPI
			}
			cInfo[Ctrl] := Map('x', x, 'fx', fx, 'y', y, 'fy', fy, 'w', w, 'fw', fw, 'h', h, 'fh', fh, 'gw', gw, 'gh', gh, 'm', !!InStr(DimSize, '*'))
		}
		Else
		{
			dgw := gw - cInfo[Ctrl]['gw'], dgh := gh - cInfo[Ctrl]['gh']
			Ctrl.Move(cInfo[Ctrl]['fx'] ? dgw * cInfo[Ctrl]['fx'] + cInfo[Ctrl]['x'] : unset
				, cInfo[Ctrl]['fy'] ? dgh * cInfo[Ctrl]['fy'] + cInfo[Ctrl]['y'] : unset
				, cInfo[Ctrl]['fw'] ? dgw * cInfo[Ctrl]['fw'] + cInfo[Ctrl]['w'] : unset
				, cInfo[Ctrl]['fh'] ? dgh * cInfo[Ctrl]['fh'] + cInfo[Ctrl]['h'] : unset)
			If cInfo[Ctrl]['m']
				Ctrl.Redraw()
		}
	}
}