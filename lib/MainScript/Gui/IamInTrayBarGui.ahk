#Requires AutoHotkey v2.0

animateIamInTrayBarGui(isAbout := false) {

    static isShowing := false
    if (isShowing)
        return
    isShowing := true

    try {
        iAmInTrayBarGui := Gui("-Caption +AlwaysOnTop +ToolWindow +Border")
        iAmInTrayBarGui.Title := gVersionStringSuffix

        effectiveTheme := getEffectiveTheme()
        isDark := (effectiveTheme = "Dark")

        if (isDark) {
            iAmInTrayBarGui.BackColor := "0x1E293B"
            textColor := "c0xF1F5F9"
            accentColor := "c0x38BDF8"
            subColor := "c0x94A3B8"
            mutedColor := "c0x64748B"
            warningColor := "c0xF87171"
            DllCall("Dwmapi\DwmSetWindowAttribute", "ptr", iAmInTrayBarGui.hWnd, "int", 20, "int*", true, "int", 4)
        } else {
            iAmInTrayBarGui.BackColor := "0xFFFFFF"
            textColor := "c0x1E293B"
            accentColor := "c0x0284C7"
            subColor := "c0x64748B"
            mutedColor := "c0x94A3B8"
            warningColor := "c0xDC2626"
            DllCall("Dwmapi\DwmSetWindowAttribute", "ptr", iAmInTrayBarGui.hWnd, "int", 20, "int*", false, "int", 4)
        }

        ; Windows 11 rounded corners (DWMWCP_ROUND = 2)
        DllCall("Dwmapi\DwmSetWindowAttribute", "ptr", iAmInTrayBarGui.hWnd, "int", 33, "int*", 2, "int", 4)

        iAmInTrayBarGui.MarginX := 24
        iAmInTrayBarGui.MarginY := 16

        ; Product title with application icon (yellow robot)
        iconPath := A_IsCompiled ? ("*Icon10 " A_ScriptFullPath) : (FileExist(A_ScriptDir "\icons\IconOn.ico") ? A_ScriptDir "\icons\IconOn.ico" : (A_LineFile "\..\..\..\..\icons\IconOn.ico"))
        picTitle := iAmInTrayBarGui.Add("Picture", "w24 h24", iconPath)

        iAmInTrayBarGui.SetFont("s13 Bold " accentColor, "Segoe UI")
        txtTitle := iAmInTrayBarGui.Add("Text", "yp", "LLM AutoHotkey Assistant")
        txtTitle.GetPos(, , &tw, &th)

        spacing := 10
        totalTitleW := 24 + spacing + tw
        startTitleX := Round(24 + (520 - totalTitleW) / 2)
        picTitle.Move(startTitleX, 16)
        txtTitle.Move(startTitleX + 24 + spacing, 16)

        ; Product version and author (restored from former title bar)
        iAmInTrayBarGui.SetFont("s9 " subColor, "Segoe UI")
        versionAuthorText := (IsSet(gAuthor) && gAuthor != "") ? (gVersion "  |  " gAuthor) : gVersion
        iAmInTrayBarGui.Add("Text", "xm w520 Center y+8", versionAuthorText)

        ; Main shortcut ("Raccourci principal : " in black/textColor with larger font, key in red)
        shortcutLabelColor := isDark ? textColor : "c0x000000"
        iAmInTrayBarGui.SetFont("s11 Bold " shortcutLabelColor, "Segoe UI")
        txtShortcutLabel := iAmInTrayBarGui.Add("Text", "xm y+10", "Raccourci principal  :  ")
        txtShortcutLabel.GetPos(, &yShortcut, &wLabel)

        iAmInTrayBarGui.SetFont("s11 Bold " warningColor, "Segoe UI")
        txtShortcutKey := iAmInTrayBarGui.Add("Text", "yp", "Alt + Maj + o")
        txtShortcutKey.GetPos(, , &wKey)

        totalShortcutW := wLabel + wKey
        startShortcutX := Round(24 + (520 - totalShortcutW) / 2)
        txtShortcutLabel.Move(startShortcutX, yShortcut)
        txtShortcutKey.Move(startShortcutX + wLabel, yShortcut)

        ; Notification body
        iAmInTrayBarGui.SetFont("s9 " subColor, "Segoe UI")
        iAmInTrayBarGui.Add("Text", "xm w520 Center y+8", "Actif dans la zone de notification (en bas à droite).")

        ; Commit hash and date, non-bold, without prefix
        commitInfo := getGitCommitInfo()
        if (commitInfo != "") {
            uncommittedSuffix := " (+ modifs NON commitées)"
            if InStr(commitInfo, uncommittedSuffix) {
                cleanCommit := StrReplace(commitInfo, uncommittedSuffix, "")
                iAmInTrayBarGui.SetFont("s7 " mutedColor, "Segoe UI")
                txtCommit := iAmInTrayBarGui.Add("Text", "xm y+10", cleanCommit)
                txtCommit.GetPos(, &yCommit, &wCommit)

                iAmInTrayBarGui.SetFont("s7 " warningColor, "Segoe UI")
                txtDirty := iAmInTrayBarGui.Add("Text", "yp", uncommittedSuffix)
                txtDirty.GetPos(, , &wDirty)

                totalW := wCommit + wDirty
                startX := Round(24 + (520 - totalW) / 2)
                txtCommit.Move(startX, yCommit)
                txtDirty.Move(startX + wCommit, yCommit)
            } else {
                iAmInTrayBarGui.SetFont("s7 " mutedColor, "Segoe UI")
                iAmInTrayBarGui.Add("Text", "xm w520 Center y+10", commitInfo)
            }
        }

        closedByUser := false
        closeAction := (*) => (closedByUser := true)

        if (isAbout) {
            ; Close button for About dialog (placed at the very bottom)
            iAmInTrayBarGui.SetFont("s9", "Segoe UI")
            btnClose := iAmInTrayBarGui.Add("Button", "w100 xm y+14 Default", "Fermer")
            btnX := Round(24 + (520 - 100) / 2)
            btnClose.GetPos(, &btnY)
            btnClose.Move(btnX, btnY)
            btnClose.OnEvent("Click", closeAction)
            iAmInTrayBarGui.OnEvent("Escape", closeAction)
        }

        iAmInTrayBarGui.Opt("+Owner")

        ; Show GUI centered horizontally
        xCurrent := A_ScreenWidth / 2
        yCurrent := A_ScreenHeight / 3
        if (isAbout) {
            iAmInTrayBarGui.Show("xCenter y" yCurrent)
        } else {
            iAmInTrayBarGui.Show("xCenter y" yCurrent " NA")
        }

        ; Display duration: 20s for About dialog, 3.5s for startup
        displayDuration := isAbout ? 20000 : 3500
        startTime := A_TickCount
        while ((A_TickCount - startTime) < displayDuration && !closedByUser) {
            Sleep(50)
        }

        ;
        ; Animation to trayling bar
        ;
        nbSteps := 20

        ; Récupérer la taille de la pop-up
        iAmInTrayBarGuiWidth := ""
        iAmInTrayBarGuiHeight := ""
        iAmInTrayBarGui.GetPos(, , &iAmInTrayBarGuiWidth, &iAmInTrayBarGuiHeight)

        ; Trayling bar approximative position
        xTraylingBar := A_ScreenWidth * 90/100
        yTraylingBar := A_ScreenHeight * 90/100

        ; Target width and height
        popupTargetWidth := 60
        popupTargetHeight := 40

        xStart := xCurrent - iAmInTrayBarGuiWidth/2
        yStart := yCurrent

        xDelta := (xTraylingBar - xCurrent) / nbSteps
        yDelta := (yTraylingBar - yCurrent) / nbSteps
        wDelta := (popupTargetWidth - iAmInTrayBarGuiWidth) / nbSteps
        hDelta := (popupTargetHeight - iAmInTrayBarGuiHeight) / nbSteps

        Loop nbSteps
        {
            ; iAmInTrayBarGui.Move(X, Y, Width, Height)
            iAmInTrayBarGui.Move(xStart + xDelta * A_Index
                            , yCurrent + yDelta * A_Index
                            , iAmInTrayBarGuiWidth + wDelta * A_Index
                            , iAmInTrayBarGuiHeight + hDelta * A_Index)

            Sleep(40 - A_Index*2)
        }
    } finally {
        try iAmInTrayBarGui.Hide()
        try iAmInTrayBarGui.Destroy()
        isShowing := false
    }
}
