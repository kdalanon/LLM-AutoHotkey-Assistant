#Requires AutoHotkey v2.0.18+
#Include <Dark_MsgBox> ; Enables dark mode MsgBox and InputBox. Remove this if you want light mode MsgBox and InputBox
#Include <Dark_Menu> ; Enables dark mode Menu. Remove this if you want light mode Menu
#Include <SystemThemeAwareToolTip> ; Enables dark mode tooltips. Remove this if you want light mode tooltips
#Include <WebViewToo> ; Allows for use of the WebView2 Framework within AHK to create Web-based GUIs
#Include <jsongo.v2> ; For JSON parsing
#Include <AutoXYWH> ; Enables auto-resizing of GUI controls. Does not include resizing of Response Window GUI elements, as it is handled by HTML and CSS
#Include <ToolTipEx> ; Enables the tooltip to track the mouse cursor smoothly and permit the tooltip to be moved by dragging
DetectHiddenWindows true ; Enables detection of hidden windows for inter-process communication

; ----------------------------------------------------
; OpenRouter
; ----------------------------------------------------

APIKey := "Your API Key here"

class OpenRouter {
    static cURLCommand :=
        'cURL.exe -s -X POST https://openrouter.ai/api/v1/chat/completions '
        . '-H "Authorization: Bearer {1}" '
        . '-H "HTTP-Referer: https://github.com/kdalanon/LLM-AutoHotkey-Assistant" '
        . '-H "X-Title: LLM AutoHotkey Assistant" '
        . '-H "Content-Type: application/json" '
        . '-d @"{2}" '
        . '-o "{3}"'

    __New(APIKey) {
        this.APIKey := APIKey
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

    getMessages(obj) {
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
        return Format(OpenRouter.cURLCommand, this.APIKey, chatHistoryJSONRequestFile, cURLOutputFile)
    }
}

; ----------------------------------------------------
; Input Window
; ----------------------------------------------------

class InputWindow {
    __New(windowTitle) {

        ; Create Input Window
        this.guiObj := Gui("Resize", windowTitle)
        this.guiObj.OnEvent("Close", this.closeButtonAction.Bind(this))
        this.guiObj.OnEvent("Escape", this.closeButtonAction.Bind(this))
        this.guiObj.OnEvent("Size", this.resizeAction.Bind(this))
        this.guiObj.BackColor := "0x212529"
        this.guiObj.SetFont("s14 cWhite", "Cambria")

        ; Add controls
        this.EditControl := this.guiObj.Add("Edit", "x20 y+5 w500 h250 Background0x212529")
        this.SendButton := this.guiObj.Add("Button", "x240 y+10 w80", "Send")

        ; Apply dark mode to title bar
        ; Reference: https://www.autohotkey.com/boards/viewtopic.php?p=422034#p422034
        DllCall("Dwmapi\DwmSetWindowAttribute", "ptr", this.guiObj.hWnd, "int", 20, "int*", true, "int", 4)

        ; Apply dark mode to Send button and Edit control
        for ctrl in [this.SendButton, this.EditControl] {
            DllCall("uxtheme\SetWindowTheme", "ptr", ctrl.hWnd, "str", "DarkMode_Explorer", "ptr", 0)
        }
    }

    showInputWindow(message := "", title := unset, windowID := unset) {
        this.EditControl.Value := message
        if IsSet(title) {
            this.guiObj.Title := title
        }

        this.EditControl.Focus()
        this.guiObj.Show("AutoSize")
        if IsSet(windowID) {
            ControlSend("^{End}", "Edit1", windowID)
        }
    }

    validateInputAndHide(*) {
        if !this.EditControl.Value {
            MsgBox "Please enter a message or close the window.", "No text entered", "IconX"
            return false
        }
        this.guiObj.Hide
        return true
    }

    sendButtonAction(functionToCall) {
        this.SendButton.OnEvent("Click", functionToCall.Bind(this))
    }

    closeButtonAction(*) {
        if (MsgBox("Close " this.guiObj.Title " window?", this.guiObj.Title, 308) = "Yes") {
            this.EditControl.Value := ""
            this.guiObj.Hide
        } else {
            return true
        }
    }

    resizeAction(*) {
        AutoXYWH("wh", this.EditControl)
        AutoXYWH("x0.5 y", this.SendButton)
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

    static notifyResponseWindowState(state, uniqueID, responseWindowhWnd := unset, mainScripthWnd := unset) {
        switch state {
            case this.WM_RESPONSE_WINDOW_OPENED, this.WM_RESPONSE_WINDOW_CLOSED:
                PostMessage(state, uniqueID, responseWindowhWnd, , "ahk_id " mainScripthWnd)
            case this.WM_SEND_TO_ALL_MODELS:
                PostMessage(state, uniqueID, 0, , "ahk_id " responseWindowhWnd)
            case this.WM_RESPONSE_WINDOW_LOADING_START, this.WM_RESPONSE_WINDOW_LOADING_FINISH:
                PostMessage(state, uniqueID, 0, , "ahk_id " mainScripthWnd)
        }
    }
}
