#Requires AutoHotkey v2.0.18+

;******************************************************************************
;
; ATTENTION : Ce fichier est #Include dans deux Process distincts : 
;               - LLM AutoHotkey Assistant.ahk
;               - Response Window.ahk
;
;******************************************************************************

; ----------------------------------------------------
; Input Window (for User Prompt, Send Message to All, Send Message to Prompt)
; ----------------------------------------------------

class InputWindow {

    static cMSGBOX_BTN_YES_NO :=  0x4
    static cMSGBOX_ICON_EXCLAMATION :=  0x30
    static cMSGBOX_WARNING :=  InputWindow.cMSGBOX_BTN_YES_NO | InputWindow.cMSGBOX_ICON_EXCLAMATION

    __New(windowTitle, skipConfirmation := false) {

        this.uniqueID := unset

        this.inputWindowSkipConfirmation := skipConfirmation

        this.selectedText := ""

        ; Create Input Window
        this.guiObj := Gui("Resize", windowTitle)
        this.guiObj.OnEvent("Close", this.closeButtonAction.Bind(this))
        this.guiObj.OnEvent("Escape", this.closeButtonAction.Bind(this))
        this.guiObj.OnEvent("Size", this.resizeAction.Bind(this))

        ; Set font before adding controls so initial metrics and dimensions are calculated with Segoe UI
        this.guiObj.SetFont("s14", "Segoe UI")

        ; Add controls
        this.EditControl := this.guiObj.Add("Edit", "x20 y+5 w500 h250 Multi +WantReturn")
        this.SendButton := this.guiObj.Add("Button", "x180 y+10 w160 h50 Default", "Send")
        this.ShortcutHint := this.guiObj.Add("Text", "x180 y+4 w160 Center", "(Ctrl+Enter)")

        ; Apply current theme
        this.applyTheme()
    }

    applyTheme() {
        effectiveTheme := getEffectiveTheme()

        ; Apply Windows 11 rounded corners (DWMWA_WINDOW_CORNER_PREFERENCE = 33, DWMWCP_ROUND = 2)
        DllCall("Dwmapi\DwmSetWindowAttribute", "ptr", this.guiObj.hWnd, "int", 33, "int*", 2, "int", 4)

        if (effectiveTheme = "Dark") {
            ; Effective theme is Dark

            ; Apply dark theme to window and controls
            this.guiObj.BackColor := "0x1E1E1E"
            this.EditControl.Opt("Background0x252526 cWhite")
            this.EditControl.SetFont("s14 cWhite", "Segoe UI")
            this.SendButton.SetFont("s14 Bold cWhite", "Segoe UI")
            this.ShortcutHint.SetFont("s9 c0x94A3B8", "Segoe UI")

            ; Apply dark mode to title bar
            DllCall("Dwmapi\DwmSetWindowAttribute", "ptr", this.guiObj.hWnd, "int", 20, "int*", true, "int", 4)

            ; Apply dark mode to Send button and Edit control
            for ctrl in [this.SendButton, this.EditControl] {
                DllCall("uxtheme\SetWindowTheme", "ptr", ctrl.hWnd, "str", "DarkMode_Explorer", "ptr", 0)
            }

        } else {
            ; Effective theme is not Dark (Light)

            ; Apply light theme to window and controls
            this.guiObj.BackColor := "0xF3F4F6"
            this.EditControl.Opt("Background0xFFFFFF c0x1E293B")
            this.EditControl.SetFont("s14 c0x1E293B", "Segoe UI")
            this.SendButton.SetFont("s14 Bold", "Segoe UI")
            this.ShortcutHint.SetFont("s9 c0x64748B", "Segoe UI")

            ; Apply light mode to title bar
            DllCall("Dwmapi\DwmSetWindowAttribute", "ptr", this.guiObj.hWnd, "int", 20, "int*", false, "int", 4)

            ; Apply light mode to Send button and Edit control
            for ctrl in [this.SendButton, this.EditControl] {
                DllCall("uxtheme\SetWindowTheme", "ptr", ctrl.hWnd, "str", "Explorer", "ptr", 0)
            }
        }

        return
    }

    showInputWindow(message := "", 
                    title := unset, 
                    inputWindowHwnd := unset,
                    isCustomPromptCursorAtEnd := true, 
                    selectedText := "") {

        this.selectedText := selectedText

        this.EditControl.Value := message

        if IsSet(title) {
            this.guiObj.Title := title
        }

        ; Refresh theme before showing
        this.applyTheme()

        this.EditControl.Focus()
        this.guiObj.Show("AutoSize")

        if IsSet(inputWindowHwnd) {

            if (isCustomPromptCursorAtEnd) {
                ; Move the cursor to the end of the text

                ; Select the whole text in the Edit control of the InputWindow
                ControlSend("^{End}", "Edit1", inputWindowHwnd)


            } else {
                ; Select the whole text

                ; Select the whole text in the Edit control of the InputWindow
                ControlSend("^+{End}", "Edit1", inputWindowHwnd)
            }
        }
    }

    validateInputAndHide(*) {

        global CLIPBOARD_WAIT_MS

        if !this.EditControl.Value {
            ; Edit control is empty

            if (this.selectedText == "") {
                ; No selected text
    
                ; Show error message and prevent closing the window
                MsgBox "Please enter a message or close the window.", "No text entered", "IconX"

                return false
            } else {
                ; There is a selected text

                ; NTD
            }

        } else {
            ; Edit control is not empty

            ; Backup clipboard before copying
            ClipSaved := ClipboardAll()   ; Save the entire clipboard to a variable of your choice.

            ; Put Edit value in Clipboard in order to be able to use it another time
            ; if you use the Windows multiple clipboard
            A_Clipboard := this.EditControl.Value
            Sleep(CLIPBOARD_WAIT_MS)

            ; Wait max 1s for Clipboard to be established with text
            ClipWait(1, 0)

            ; Restore clipboard
            A_Clipboard := ClipSaved   ; Restore the original clipboard. Note the use of A_Clipboard (not ClipboardAll).
            Sleep(CLIPBOARD_WAIT_MS)
            ClipSaved := ""  ; Free the memory in case the clipboard was very large.
        }

        ; Either clipboard or edit control has content

        ; Hide the input window
        this.guiObj.Hide

        return true
    }

    registerSendButtonAction(functionToCall) {

        ; Provide this (Input Window) as first parameter 
        boundFunc := functionToCall.Bind(this)

        ; Sur le click, appeler la fonction passée en paramètre
        this.SendButton.OnEvent("Click", boundFunc)
        this.ShortcutHint.OnEvent("Click", boundFunc)

        try {
            ; Limiter le raccourci clavier défini juste après, à la fenêtre qui l'a défini
            HotIfWinActive "ahk_id " this.guiObj.Hwnd

            ; Associer le raccourci clavier CTRL+Enter au clic sur le GuiControl
            Hotkey "^Enter", boundFunc

        } catch as e {
            MsgBox "Error setting hotkey: " e.Message
        }
    }

    closeButtonAction(*) {
        if this.inputWindowSkipConfirmation || (MsgBox("Close " this.guiObj.Title " window ?", this.guiObj.Title, InputWindow.cMSGBOX_WARNING) = "Yes") {
            this.EditControl.Value := ""
            this.guiObj.Hide
            return
        }

        return true
    }

    resizeAction(*) {
        AutoXYWH("wh", this.EditControl)
        AutoXYWH("x0.5 y", this.SendButton)
        AutoXYWH("x0.5 y", this.ShortcutHint)
    }

    setSkipConfirmation(value) {
        this.inputWindowSkipConfirmation := value
    }
}