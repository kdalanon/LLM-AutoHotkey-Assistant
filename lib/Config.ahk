#Requires AutoHotkey v2.0.18+

;******************************************************************************
;
; ATTENTION : Ce fichier est #Include dans deux Process distincts : 
;               - LLM AutoHotkey Assistant.ahk
;               - Response Window.ahk
;
;******************************************************************************

;******************************************************************************
;
; Global Variables and Configuration
;
;******************************************************************************

global gVersion := "2.1.0"
global gVersionStringPrefix := ""
global gVersionStringSuffix := ": (LLM AutoHotkey Assistant " gVersion ")"

; By default use OpenRouter API endpoint
global gLLM_BASE_URL := "https://openrouter.ai/api"

global APIKey := "none"

;
; Icons mapping numbers to paths
;

ICON_ON         := 10
ICON_OFF        := 11
ICON_ANTHROPIC  := 12
ICON_DEEPSEEK   := 13
ICON_GOOGLE     := 14
ICON_OPENAI     := 15
ICON_OPENROUTER := 16
ICON_PERPLEXITY := 17

gMapIconNb2IconPath := Map( 
                 ICON_ON, "icons\IconOn.ico"
                ,ICON_OFF, "icons\IconOff.ico"
                ,ICON_ANTHROPIC, "icons\anthropic.ico"
                ,ICON_DEEPSEEK, "icons\deepseek.ico"
                ,ICON_GOOGLE, "icons\google.ico"
                ,ICON_OPENAI, "icons\openai.ico"
                ,ICON_OPENROUTER, "icons\openrouter.ico"
                ,ICON_PERPLEXITY, "icons\perplexity.ico"
            )


; Include the Preferences file only if it exists => *i
#Include "*i ..\config\Preferences.ahk"

;******************************************************************************
;
; Includes and Libraries
;
;******************************************************************************

#Include Dark_MsgBox.ahk ; Enables dark mode MsgBox and InputBox. Remove this if you want light mode MsgBox and InputBox
#Include Dark_Menu.ahk ; Enables dark mode Menu. Remove this if you want light mode Menu
#Include SystemThemeAwareToolTip.ahk ; Enables dark mode tooltips. Remove this if you want light mode tooltips
#Include WebViewToo.ahk ; Allows for use of the WebView2 Framework within AHK to create Web-based GUIs
#Include jsongo.v2.ahk ; For JSON parsing
#Include AutoXYWH.ahk ; Enables auto-resizing of GUI controls. Does not include resizing of Response Window GUI elements, as it is handled by HTML and CSS
#Include ToolTipEx.ahk ; Enables the tooltip to track the mouse cursor smoothly and permit the tooltip to be moved by dragging
DetectHiddenWindows true ; Enables detection of hidden windows for inter-process communication

; ----------------------------------------------------
; Constants
; ----------------------------------------------------

global CLIPBOARD_WAIT_MS := 1000


; WARNING : Do not forget to update LLM AutoHotkey Assistant.ahk according to following numbers

getIconNb(iconName) {

    iconNb := -1

    For tmpIconNb, iconPath in gMapIconNb2IconPath {

        if (InStr(iconPath, iconName, false) > 0) {
            ; Icon found
            
            iconNb := tmpIconNb

            break
        } else {
            ; Icon not found
            
            ; Continue to look for
        }
    } ; for
    
    return iconNb
}

; ----------------------------------------------------
; Function to get selected text
; ----------------------------------------------------
getSelectedText() {

    global CLIPBOARD_WAIT_MS

    ; manageCursorAndToolTip("Loading")

    ; Backup clipboard before copying
    ClipSaved := ClipboardAll()   ; Save the entire clipboard to a variable of your choice.

    ; Copy of the selected text in the clipboard
    A_Clipboard := ""
    Sleep(CLIPBOARD_WAIT_MS)

    Send("^c")

    ; Ce Sleep est indispensable (Le ClipWait(1, 0) n'a pas l'air d'attendre que le Ctrl+C soit établi !)
    Sleep(CLIPBOARD_WAIT_MS)

    if !ClipWait(2, 0) {
        ; Clipboard did not receive any text within 1 second.
        
        selectedText := ""
        
    } else {
        
        selectedText := Trim(A_Clipboard, OmitChars := " `t`r`n")
    }

    ; Restore clipboard
    A_Clipboard := ClipSaved    ; Restore the original clipboard. Note the use of A_Clipboard (not ClipboardAll).
    Sleep(CLIPBOARD_WAIT_MS)
    ClipSaved := ""             ; Free the memory in case the clipboard was very large.
    
    ; manageCursorAndToolTip("Reset")
    
    ; Return the selected text
    return selectedText
}

getRessourcePath(ressourcePath) {

    Return (!A_IsCompiled) 
                ? 
                ; The script is not compiled, run the script directly with AHK path
                A_WorkingDir '\' ressourcePath
                : 
                ; The script is compiled, run the script with /script and "*" to tell that the script is embedded in the executable
                "*" ressourcePath
}

TraySetIconEmbed(iconNb) {

    if (!A_IsCompiled) {
        ; Script mode

        ; Use icon's relative path
        TraySetIcon((A_ScriptName = "Response Window.ahk" ? "..\" : "") gMapIconNb2IconPath[iconNb])

    } else {
        ; Compiled mode

        ; Use negative icon's Number 
        ; (see ahk v2 documentation : "If negative, the absolute value is assumed to be the resource ID of an icon within an executable file")
        TraySetIcon(A_ScriptFullPath, -1 * iconNb)
    }
}

; ----------------------------------------------------
; OpenRouter
; ----------------------------------------------------

class OpenRouter {

    __New(llmBaseUrl, APIKey) {

        this.APIKey := APIKey

        this.cURLCommand :=
        'cURL.exe ' llmBaseUrl '/v1/chat/completions'
        . ' --silent'
        . ' --request POST'
        . ' -H "Authorization: Bearer {1}"'
        . ' -H "HTTP-Referer: https://github.com/kdalanon/LLM-AutoHotkey-Assistant"'
        . ' -H "X-Title: LLM AutoHotkey Assistant"'
        . ' -H "Content-Type: application/json"'
        . ' --data @"{2}"'
        . ' --output "{3}"' 
    }

    createJSONRequest(APIModel, systemPrompt, userPrompt) {
        requestObj := {}
        requestObj.model := APIModel
        requestObj.messages := [{
            role: "system",
            content: systemPrompt
        }, {
            role: "user",
            content: userPrompt
        }]
        return jsongo.Stringify(requestObj)
    }

    extractJSONResponse(var) {
        response := var.Get("choices")[1].Get("message").Get("content")
        model := var.Get("model")
        return {
            response: response,
            model: model
        }
    }

    extractErrorResponse(var) {
        error := var.Get("error").Get("message")
        code := var.Get("error").Get("code")
        return {
            error: error,
            code: code,
        }
    }

    appendToChatHistory(role, message, &chatHistoryJSONRequest, chatHistoryJSONRequestFile) {
        obj := jsongo.Parse(chatHistoryJSONRequest)
        obj["messages"].Push({
            role: role,
            content: message
        })
        chatHistoryJSONRequest := jsongo.Stringify(obj)
        FileOpen(chatHistoryJSONRequestFile, "w", "UTF-8-RAW").Write(chatHistoryJSONRequest)
    }

    getChatHistoryMessages(obj) {
        messages := []
        for i in obj["messages"] {
            messages.Push({
                role: i["role"],
                content: i["content"]
            })
        }
        return messages
    }

    removeLastAssistantMessage(&chatHistoryJSONRequest) {
        obj := jsongo.Parse(chatHistoryJSONRequest)
        messagesArray := obj["messages"]
        lastIndex := messagesArray.Length
        if (messagesArray[lastIndex]["role"] = "assistant") {
            messagesArray.RemoveAt(lastIndex)
        }
        chatHistoryJSONRequest := jsongo.Stringify(obj)
    }

    buildcURLCommand(chatHistoryJSONRequestFile, cURLOutputFile) {
        return Format(this.cURLCommand, this.APIKey, chatHistoryJSONRequestFile, cURLOutputFile)
    }
}

; ----------------------------------------------------
; Input Window (for User Prompt, Send Message to All, Send Message to Prompt)
; ----------------------------------------------------

class InputWindow {

    static cMSGBOX_BTN_YES_NO :=  0x4
    static cMSGBOX_ICON_EXCLAMATION :=  0x30
    static cMSGBOX_WARNING :=  InputWindow.cMSGBOX_BTN_YES_NO | InputWindow.cMSGBOX_ICON_EXCLAMATION

    __New(windowTitle, skipConfirmation := false) {

        this.inputWindowSkipConfirmation := skipConfirmation

        ; Selected text before opening pop-up
        this.selectedText := ""

        ; Create Input Window
        this.guiObj := Gui("Resize", windowTitle)
        this.guiObj.OnEvent("Close", this.closeButtonAction.Bind(this))
        this.guiObj.OnEvent("Escape", this.closeButtonAction.Bind(this))
        this.guiObj.OnEvent("Size", this.resizeAction.Bind(this))
        this.guiObj.BackColor := "0x212529"
        this.guiObj.SetFont("s14 cWhite", "Arial")

        ; Add controls
        this.EditControl := this.guiObj.Add("Edit", "x20 y+5 w500 h250 Background0x212529")
        this.SendButton := this.guiObj.Add("Button", "x220 y+10 w80", "Send (Ctrl+Enter)")

        ; Apply dark mode to title bar
        ; Reference: https://www.autohotkey.com/boards/viewtopic.php?p=422034#p422034
        DllCall("Dwmapi\DwmSetWindowAttribute", "ptr", this.guiObj.hWnd, "int", 20, "int*", true, "int", 4)

        ; Apply dark mode to Send button and Edit control
        for ctrl in [this.SendButton, this.EditControl] {
            DllCall("uxtheme\SetWindowTheme", "ptr", ctrl.hWnd, "str", "DarkMode_Explorer", "ptr", 0)
        }
    }

    showInputWindow(message := "", title := unset, windowID := unset, isCustomPromptCursorAtEnd := true, selectedText := "") {

        ; Retrieve the selected text before the pop-up opens
        this.selectedText := selectedText

        this.EditControl.Value := message

        if IsSet(title) {
            this.guiObj.Title := title
        }

        this.EditControl.Focus()
        this.guiObj.Show("AutoSize")

        if IsSet(windowID) {

            if (isCustomPromptCursorAtEnd) {
                ; Move the cursor to the end of the text

                ; Select the whole text in the Edit control of the InputWindow
                ControlSend("^{End}", "Edit1", windowID)


            } else {
                ; Select the whole text

                ; Select the whole text in the Edit control of the InputWindow
                ControlSend("^+{End}", "Edit1", windowID)
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

            ; manageCursorAndToolTip("Loading")

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
        
            ; manageCursorAndToolTip("Reset")
        }

        ; Either clipboard or edit control has content

        ; Hide the input window
        this.guiObj.Hide

        return true
    }

    registerSendButtonAction(functionToCall) {

        boundFunc := functionToCall.Bind(this)

        ; Sur le click, appeler la fonction passée en paramètre
        this.SendButton.OnEvent("Click", boundFunc)

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
    }

    setSkipConfirmation(value) {
        this.inputWindowSkipConfirmation := value
    }
}

; ----------------------------------------------------
; Custom messages
; ----------------------------------------------------

class CustomMessages {
    static WM_RESPONSE_WINDOW_OPENED := 0x400 + 125
    static WM_RESPONSE_WINDOW_CLOSED := 0x400 + 126
    static WM_SEND_TO_ALL_MODELS := 0x400 + 127
    static WM_RESPONSE_WINDOW_LOADING_START := 0x400 + 123
    static WM_RESPONSE_WINDOW_LOADING_FINISH := 0x400 + 124

    static registerHandlers(origin, handle) {
        switch origin {
            case "mainScript":
                for msg in [this.WM_RESPONSE_WINDOW_OPENED, this.WM_RESPONSE_WINDOW_CLOSED, this.WM_RESPONSE_WINDOW_LOADING_START,
                    this.WM_RESPONSE_WINDOW_LOADING_FINISH]
                    OnMessage(msg, handle)

            case "subScript": OnMessage(this.WM_SEND_TO_ALL_MODELS, handle)
        }
    }

    static notifyResponseWindowState(state, uniqueID, responseWindowhWnd := unset, mainScriptHiddenhWnd := unset) {
        switch state {
            case this.WM_RESPONSE_WINDOW_OPENED, this.WM_RESPONSE_WINDOW_CLOSED:
                PostMessage(state, uniqueID, responseWindowhWnd, , "ahk_id " mainScriptHiddenhWnd)
            case this.WM_SEND_TO_ALL_MODELS:
                PostMessage(state, uniqueID, 0, , "ahk_id " responseWindowhWnd)
            case this.WM_RESPONSE_WINDOW_LOADING_START, this.WM_RESPONSE_WINDOW_LOADING_FINISH:
                PostMessage(state, uniqueID, 0, , "ahk_id " mainScriptHiddenhWnd)
        }
    }
}
