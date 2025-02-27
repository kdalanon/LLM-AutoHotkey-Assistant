#Include <Configs_and_Classes>
#SingleInstance

; ----------------------------------------------------
; Prompts
; ----------------------------------------------------

prompts := [{
    promptName: "Multi-model custom prompt",
    menuText: "&0 - Multi-model custom prompt",
    systemPrompt: "You are a helpful assistant. Follow the instructions that I will provide or answer any questions that I will ask. My first query is the following:",
    APIModel: "google/gemini-2.0-flash-thinking-exp:free, openai/gpt-4o, google/gemini-exp-1206:free, anthropic/claude-3.7-sonnet",
    isCustomPrompt: true
}, {
    promptName: "Rephrase",
    menuText: "&1 - Rephrase",
    systemPrompt: "Your task is to rephrase the following text or paragraph in English to ensure clarity, conciseness, and a natural flow. If there are abbreviations present, expand it when it's used for the first time, like so: OCR (Optical Character Recognition). The revision should preserve the tone, style, and formatting of the original text. If possible, split it into paragraphs to improve readability. Additionally, correct any grammar and spelling errors you come across. You should also answer follow-up questions if asked. Respond with the rephrased text only:",
    APIModel: "google/gemini-2.0-flash-thinking-exp:free"
}, {
    promptName: "Summarize",
    menuText: "&2 - Summarize",
    systemPrompt: "Your task is to summarize the following article in English to ensure clarity, conciseness, and a natural flow. If there are abbreviations present, expand it when it's used for the first time, like so: OCR (Optical Character Recognition). The summary should preserve the tone, style, and formatting of the original text, and should be in its original language. If possible, split it into paragraphs to improve readability. Additionally, correct any grammar and spelling errors you come across. You should also answer follow-up questions if asked. Respond with the rephrased text only:",
    APIModel: "google/gemini-2.0-flash-thinking-exp:free"
}, {
    promptName: "Translate to English",
    menuText: "&3 - Translate to English",
    systemPrompt: "Generate an English translation for the following text or paragraph, ensuring the translation accurately conveys the intended meaning or idea without excessive deviation. If there are abbreviations present, expand it when it's used for the first time, like so: OCR (Optical Character Recognition). The translation should preserve the tone, style, and formatting of the original text. If possible, split it into paragraphs to improve readability. Additionally, correct any grammar and spelling errors you come across. You should also answer follow-up questions if asked. Respond with the rephrased text only:",
    APIModel: "google/gemini-2.0-flash-thinking-exp:free"
}, {
    promptName: "Define",
    menuText: "&4 - Define",
    systemPrompt: "Provide and explain the definition of the following, providing analogies if needed. In addition, answer follow-up questions if asked:",
    APIModel: "google/gemini-2.0-flash-thinking-exp:free"
}, {
    promptName: "Auto-paste custom prompt",
    menuText: "&5 - Auto-paste custom prompt",
    systemPrompt: "You are a helpful assistant. Follow the instructions that I will provide or answer any questions that I will ask.",
    APIModel: "google/gemini-2.0-flash-thinking-exp:free",
    isCustomPrompt: true,
    isAutoPaste: true
}, {
    promptName: "Web search",
    menuText: "&6 - Web search",
    systemPrompt: "Provide the latest information and answer follow-up questions that I will ask. My first query is the following:",
    APIModel: "google/gemini-2.0-flash-thinking-exp:free:online"
}, {
    promptName: "Web search custom prompt",
    menuText: "&7 - Web search custom prompt",
    systemPrompt: "Provide the latest information and answer follow-up questions that I will ask. My first query is the following:",
    APIModel: "google/gemini-2.0-flash-thinking-exp:free:online",
    isCustomPrompt: true
}, {
    promptName: "Deep thinking multi-model custom prompt",
    menuText: "&8 - Deep thinking multi-model custom prompt",
    systemPrompt: "You are a helpful assistant. Follow the instructions that I will provide or answer any questions that I will ask. My first query is the following:",
    APIModel: "perplexity/r1-1776, openai/o3-mini-high, anthropic/claude-3.7-sonnet:thinking, google/gemini-2.0-flash-thinking-exp:free",
    isCustomPrompt: true,
    customPromptInitialMessage: "This is a message template."
}, {
    promptName: "Deep thinking multi-model web search custom prompt",
    menuText: "&9 - Deep thinking multi-model custom prompt web search",
    systemPrompt: "Provide information about the following. In addition, answer follow-up questions that I will ask or follow any instructions that I may provide:",
    APIModel: "perplexity/r1-1776:online, openai/o3-mini-high:online, anthropic/claude-3.7-sonnet:thinking:online, google/gemini-2.0-flash-thinking-exp:free:online",
    isCustomPrompt: true
}, {
    promptName: "Multi-line prompt example",
    menuText: "Multi-line prompt example",
    systemPrompt: "
    (
    This prompt is broken down into multiple lines.

    Here is the second sentence.

    And the third one.

    As long as the prompt is inside the quotes and the opening and closing parenthesis,

    it will be valid.
    )",
    APIModel: "google/gemini-2.0-flash-thinking-exp:free"
}]

; ----------------------------------------------------
; Hotkeys
; ----------------------------------------------------

`:: hotkeyFunctions("showPromptMenu")
~^s:: WinActive("LLM AutoHotkey Assistant.ahk") ? Reload() : ""
#SuspendExempt
CapsLock & `:: hotkeyFunctions("suspendHotkey")

hotkeyFunctions(action) {
    switch action {
        case "showPromptMenu":
            promptMenu := Menu()
            if (getActiveModels().Count > 1) {
                promptMenu.Add("&Send message to all models", (*) => sendToAllModelsInputWindow.showInputWindow())
                promptMenu.Add()
            }

            for index, prompt in managePromptState("prompts", "get") {
                promptMenu.Add(prompt.menuText, promptMenuHandler.Bind(index))
            }

            promptMenu.Add()
            promptMenu.Add("&Options", optionsMenu := Menu())
            optionsMenu.Add("&Edit prompts", (*) => Run("Notepad " A_ScriptFullPath))
            optionsMenu.Add("&Add API key", (*) => Run("Notepad " A_ScriptDir "\lib\Configs_and_Classes.ahk"))
            promptMenu.Show()

        case "suspendHotkey":
            KeyWait "CapsLock", "L"
            SetCapsLockState "Off"
            toggleSuspend(A_IsSuspended)
    }
}

; ----------------------------------------------------
; Script tray menu
; ----------------------------------------------------

trayMenuItems := [{
    menuText: "&Reload Script",
    function: (*) => Reload()
}, {
    menuText: "E&xit",
    function: (*) => ExitApp()
}]

; ----------------------------------------------------
; Generate tray menu dynamically
; ----------------------------------------------------

TraySetIcon("icons\IconOn.ico")
A_TrayMenu.Delete()

for index, item in trayMenuItems {
    A_TrayMenu.Add(item.menuText, item.function)
}

A_IconTip := "LLM AutoHotkey Assistant"

; ----------------------------------------------------
; Create new instance of OpenRouter class
; ----------------------------------------------------

router := OpenRouter(APIKey)

; ----------------------------------------------------
; Create Custom Prompt Input Window
; ----------------------------------------------------

customPromptInputWindow := InputWindow("Custom prompt")
customPromptInputWindow.sendButtonAction(customPromptSendButtonAction)

customPromptSendButtonAction(*) {
    if !customPromptInputWindow.validateInputAndHide() {
        return
    }

    selectedPrompt := managePromptState("selectedPrompt", "get")
    processInitialRequest(selectedPrompt.promptName, selectedPrompt.menuText, selectedPrompt.systemPrompt,
        selectedPrompt.APIModel, selectedPrompt.HasProp("isAutoPaste") && selectedPrompt.isAutoPaste,
        customPromptInputWindow.EditControl.Value)
}

; ----------------------------------------------------
; Create Send message to all models Window
; ----------------------------------------------------

sendToAllModelsInputWindow := InputWindow("Send message to all models")
sendToAllModelsInputWindow.sendButtonAction(sendToAllModelsSendButtonAction)

sendToAllModelsSendButtonAction(*) {
    if !sendToAllModelsInputWindow.validateInputAndHide() {
        return
    }

    ; The main script must know each Response Window's JSON file
    ; so it can read it, parse it, append the new
    ; user message, then write it back
    for uniqueID, modelData in getActiveModels() {
        if !modelData.HasProp("JSONFile") {
            continue
        }

        JSONFile := modelData.JSONFile
        if !FileExist(JSONFile) {
            continue
        }

        JSONStr := FileOpen(JSONFile, "r", "UTF-8").Read()
        router.appendToChatHistory("user", sendToAllModelsInputWindow.EditControl.Value, &JSONStr, JSONFile)

        ; Notify the Response Window to re-read the JSON file and call sendRequestToLLM() again
        responseWindowhWnd := modelData.hWnd
        CustomMessages.notifyResponseWindowState(CustomMessages.WM_SEND_TO_ALL_MODELS, uniqueID, responseWindowhWnd)
    }
}

; ----------------------------------------------------
; Initialize Suspend GUI
; ----------------------------------------------------

scriptSuspendStatus := Gui()
scriptSuspendStatus.SetFont("s10", "Cambria")
scriptSuspendStatus.Add("Text", "cBlack Center", "LLM AutoHotkey Assistant Suspended")
scriptSuspendStatus.BackColor := "0xFFDF00"
scriptSuspendStatus.Opt("-Caption +Owner -SysMenu +AlwaysOnTop")
scriptSuspendStatusWidth := ""
scriptSuspendStatus.GetPos(, , &scriptSuspendStatusWidth)

; ----------------------------------------------------
; Toggle Suspend
; ----------------------------------------------------

toggleSuspend(*) {
    Suspend -1
    if (A_IsSuspended) {
        TraySetIcon("icons\IconOff.ico", , 1)
        A_IconTip := "LLM AutoHotkey Assistant - Suspended)"

        ; Show GUI at the bottom, centered
        scriptSuspendStatus.Show("AutoSize x" (A_ScreenWidth - scriptSuspendStatusWidth) / 2.3 " y990 NA")
    } else {
        TraySetIcon("icons\IconOn.ico")
        A_IconTip := "LLM AutoHotkey Assistant"
        scriptSuspendStatus.Hide()
    }
}

; ----------------------------------------------------
; Prompt menu handler function
; ----------------------------------------------------

promptMenuHandler(index, *) {
    promptsList := managePromptState("prompts", "get")
    selectedPrompt := promptsList[index]
    if (selectedPrompt.HasProp("isCustomPrompt") && selectedPrompt.isCustomPrompt) {

        ; Save the prompt for future reference in customPromptSendButtonAction(*)
        managePromptState("selectedPrompt", "set", selectedPrompt)
        customPromptInputWindow.showInputWindow(selectedPrompt.HasProp("customPromptInitialMessage")
            ? selectedPrompt.customPromptInitialMessage : unset)
        if selectedPrompt.HasProp("customPromptInitialMessage") {
            ControlSend("^{End}", "Edit1", "ahk_id " customPromptInputWindow.guiObj.hWnd)
        }
    } else {
        processInitialRequest(selectedPrompt.promptName, selectedPrompt.menuText, selectedPrompt.systemPrompt,
            selectedPrompt.APIModel, selectedPrompt.HasProp("isAutoPaste") && selectedPrompt.isAutoPaste)
    }
}

; ----------------------------------------------------
; Manage prompt states
; ----------------------------------------------------

managePromptState(component, action, data := {}) {
    static state := {
        prompts: prompts,
        selectedPrompt: {}
    }

    switch component {
        case "prompts":
            switch action {
                case "get": return state.prompts
                case "set": state.prompts := data
            }
        case "selectedPrompt":
            switch action {
                case "get": return state.selectedPrompt
                case "set": state.selectedPrompt := data
            }
    }
}

; ----------------------------------------------------
; Connect to LLM API and process request
; ----------------------------------------------------

processInitialRequest(promptName, menuText, systemPrompt, APIModel, isAutoPaste, customPromptMessage := unset) {

    ; Handle the copied text
    clipboardBeforeCopy := A_Clipboard
    A_Clipboard := ""
    Send("^c")

    if !ClipWait(1) {
        if IsSet(customPromptMessage) {
            userPrompt := customPromptMessage
        } else {
            manageCursorAndToolTip("Reset")
            MsgBox "The attempt to copy text onto the clipboard failed.", "No text copied", "IconX"
            return
        }
    } else if IsSet(customPromptMessage) {
        userPrompt := customPromptMessage "`n`n" A_Clipboard
    } else {
        userPrompt := A_Clipboard
    }

    A_Clipboard := clipboardBeforeCopy

    ; Split API models by comma
    APIModels := StrSplit(APIModel, ",")

    ; Automatically disables isAutoPaste if more than one model is present
    isAutoPaste := (APIModels.Length > 1) ? false : isAutoPaste

    for i, singleAPIModel in APIModels {

        ; Remove leading and trailing spaces
        singleAPIModel := Trim(singleAPIModel)

        if !singleAPIModel {
            continue
        }

        uniqueID := A_TickCount

        ; Create the chatHistoryJSONRequest
        chatHistoryJSONRequest := router.createJSONRequest(singleAPIModel, systemPrompt, userPrompt)

        ; Get text before forward slash as providerName
        providerName := SubStr(singleAPIModel, 1, InStr(singleAPIModel, "/") - 1)

        ; Get text after forward slash as singleAPIModel and replace colon (:) with dash (-)
        singleAPIModel := StrReplace(SubStr(singleAPIModel, InStr(singleAPIModel, "/") + 1), ":", "-")

        ; Generate sanitized filenames for chat history, cURL command, and cURL output files
        chatHistoryJSONRequestFile := A_Temp "\" RegExReplace("chatHistoryJSONRequest_" promptName "_" singleAPIModel "_" uniqueID ".json",
            "[\/\\:*?`"<>|]", "")
        cURLCommandFile := A_Temp "\" RegExReplace("cURLCommand_" promptName "_" singleAPIModel "_" uniqueID ".txt",
            "[\/\\:*?`"<>|]", "")
        cURLOutputFile := A_Temp "\" RegExReplace("cURLOutput_" promptName "_" singleAPIModel "_" uniqueID ".json",
            "[\/\\:*?`"<>|]", "")

        ; Write the JSON request and cURL command to files
        FileOpen(chatHistoryJSONRequestFile, "w", "UTF-8-RAW").Write(chatHistoryJSONRequest)
        cURLCommand := router.buildcURLCommand(chatHistoryJSONRequestFile, cURLOutputFile)
        FileOpen(cURLCommandFile, "w").Write(cURLCommand)

        ; Maintain a reference in the global map
        getActiveModels()[uniqueID] := {
            promptName: promptName,
            name: singleAPIModel,
            provider: router,
            JSONFile: chatHistoryJSONRequestFile,
            cURLFile: cURLCommandFile,
            outputFile: cURLOutputFile,
            isLoading: false
        }

        ; Create an object containing all values for the Response Window
        responseWindowDataObj := {
            chatHistoryJSONRequestFile: chatHistoryJSONRequestFile,
            cURLCommandFile: cURLCommandFile,
            cURLOutputFile: cURLOutputFile,
            providerName: providerName,
            isAutoPaste: isAutoPaste,
            mainScripthWnd: A_ScriptHwnd,
            responseWindowTitle: promptName " [" singleAPIModel "]",
            singleAPIModel: singleAPIModel,
            numberOfAPIModels: APIModels.Length,
            APIModelsIndex: i,
            uniqueID: uniqueID
        }

        ; Write the object to a file named responseWindowData and run
        ; Response Window.ahk while passing the location of that file
        ; through dataObjToJSONStrFile as the first argument
        dataObjToJSONStr := jsongo.Stringify(responseWindowDataObj)
        dataObjToJSONStrFile := A_Temp "\" RegExReplace("responseWindowData_" promptName "_" singleAPIModel "_" A_TickCount ".json",
            "[\/\\:*?`"<>|]", "")
        FileOpen(dataObjToJSONStrFile, "w", "UTF-8-RAW").Write(dataObjToJSONStr)
        getActiveModels()[uniqueID].JSONFile := chatHistoryJSONRequestFile
        Run(A_ScriptDir "\Response Window.ahk " "`"" dataObjToJSONStrFile)
    }
}

; ----------------------------------------------------
; Tracks active models
; ----------------------------------------------------

getActiveModels() {
    static activeModels := Map()
    return activeModels
}

; ----------------------------------------------------
; Custom messages and handlers for detecting
; Response Window states
; ----------------------------------------------------

CustomMessages.registerHandlers("mainScript", responseWindowState)

responseWindowState(uniqueID, responseWindowhWnd, state, mainScripthWnd) {
    static responseWindowLoadingCount := 0

    switch state {
        case CustomMessages.WM_RESPONSE_WINDOW_OPENED:
            getActiveModels()[uniqueID].hWnd := responseWindowhWnd

        case CustomMessages.WM_RESPONSE_WINDOW_CLOSED:
            if getActiveModels().Has(uniqueID) {
                getActiveModels().Delete(uniqueID)
                manageCursorAndToolTip("Update")
            }

        case CustomMessages.WM_RESPONSE_WINDOW_LOADING_START:
            getActiveModels()[uniqueID].isLoading := true
            responseWindowLoadingCount++
            if (responseWindowLoadingCount = 1) {
                manageCursorAndToolTip("Loading")
            }

            manageCursorAndToolTip("Update")

        case CustomMessages.WM_RESPONSE_WINDOW_LOADING_FINISH:
            if (responseWindowLoadingCount > 0 && getActiveModels().Has(uniqueID)) {
                responseWindowLoadingCount--
                getActiveModels()[uniqueID].isLoading := false
                if (responseWindowLoadingCount = 0) {
                    manageCursorAndToolTip("Reset")
                } else {
                    manageCursorAndToolTip("Update")
                }
            }
    }
}

; ----------------------------------------------------
; Cursor and Tooltip management
; ----------------------------------------------------

manageCursorAndToolTip(action) {
    switch action {
        case "Update":
            activeCount := 0
            for key, data in getActiveModels() {
                if data.isLoading {
                    activeCount++
                }
            }

            if (activeCount = 0) {
                ToolTip
                return
            }

            toolTipMessage := "Retrieving response for the following prompt"

            ; Singular and plural forms of the word "model"
            if (activeCount > 1) {
                toolTipMessage .= "s"
            }

            toolTipMessage .= " (Press ESC to cancel):"
            for key, data in getActiveModels() {
                if (data.isLoading) {
                    toolTipMessage .= "`n- " data.promptName " [" data.name "]"
                }
            }

            ToolTipEX(toolTipMessage, 0)

        case "Loading":
            ; Change default arrow cursor (32512) to "working in background" cursor (32650)
            ; Ensure that other cursors remain unchanged to preserve their functionality
            Cursor := DllCall("LoadCursor", "uint", 0, "uint", 32650)
            DllCall("SetSystemCursor", "Ptr", Cursor, "UInt", 32512)

        case "Reset":
            ToolTip
            DllCall("SystemParametersInfo", "UInt", 0x57, "UInt", 0, "Ptr", 0, "UInt", 0)
    }
}
