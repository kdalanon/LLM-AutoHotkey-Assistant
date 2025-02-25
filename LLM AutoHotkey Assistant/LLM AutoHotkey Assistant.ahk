#Requires AutoHotkey v2.0.18+
#SingleInstance
#Include <jsongo.v2> ; For JSON parsing
#Include <SharedResources> ; Resources used by both LLM AutoHotkey Assistant and Response Window
#Include <SystemThemeAwareToolTip> ; Enables dark mode tooltips. Remove this if you want light mode tooltips
#Include <Dark_MsgBox> ; Enables dark mode MsgBox and InputBox. Remove this if you want light mode MsgBox and InputBox
#Include <Dark_Menu> ; Enables dark mode Menu. Remove this if you want light mode Menu
#Include <ToolTipEx> ; Enables the tooltip to track the mouse cursor smoothly and permit the tooltip to be moved by dragging
DetectHiddenWindows true ; Enables detection of hidden windows for inter-process communication

; ----------------------------------------------------
; Prompts
; ----------------------------------------------------

prompts := [{
    promptName: "Custom prompt",
    menuText: "&0 - Custom prompt",
    systemPrompt: "You are a helpful assistant. Follow the instructions that I will provide or answer any questions that I will ask. My first query is the following:",
    APIModel: "openrouter/auto",
    isCustomPrompt: true
}, {
    promptName: "Rephrase",
    menuText: "&1 - Rephrase",
    systemPrompt: "Your task is to rephrase the following text or paragraph in English to ensure clarity, conciseness, and a natural flow. If there are abbreviations present, expand it when it's used for the first time, like so: OCR (Optical Character Recognition). The revision should preserve the tone, style, and formatting of the original text. If possible, split it into paragraphs to improve readability. Additionally, correct any grammar and spelling errors you come across. You should also answer follow-up questions if asked. Respond with the rephrased text only:",
    APIModel: "anthropic/claude-3.7-sonnet"
}, {
    promptName: "Summarize",
    menuText: "&2 - Summarize",
    systemPrompt: "Your task is to summarize the following article in English to ensure clarity, conciseness, and a natural flow. If there are abbreviations present, expand it when it's used for the first time, like so: OCR (Optical Character Recognition). The summary should preserve the tone, style, and formatting of the original text, and should be in its original language. If possible, split it into paragraphs to improve readability. Additionally, correct any grammar and spelling errors you come across. You should also answer follow-up questions if asked. Respond with the rephrased text only:",
    APIModel: "google/gemini-2.0-flash-001",
    isAutoPaste: true
}, {
    promptName: "Translate to English",
    menuText: "&3 - Translate to English",
    systemPrompt: "Generate an English translation for the following text or paragraph, ensuring the translation accurately conveys the intended meaning or idea without excessive deviation. If there are abbreviations present, expand it when it's used for the first time, like so: OCR (Optical Character Recognition). The translation should preserve the tone, style, and formatting of the original text. If possible, split it into paragraphs to improve readability. Additionally, correct any grammar and spelling errors you come across. You should also answer follow-up questions if asked. Respond with the rephrased text only:",
    APIModel: "google/gemini-2.0-flash-thinking-exp:free"
}, {
    promptName: "Define",
    menuText: "&4 - Define",
    systemPrompt: "Provide and explain the definition of the following, providing analogies if needed. In addition, answer follow-up questions if asked:",
    APIModel: "openai/chatgpt-4o-latest"
}, {
    promptName: "Web search",
    menuText: "&5 - Search for this topic online",
    systemPrompt: "Your task is to search for the following topic online:",
    APIModel: "perplexity/r1-1776:online"
}, {
    promptName: "Web search (Custom prompt)",
    menuText: "&6 - Web search (Custom prompt)",
    systemPrompt: "Your task is to search for the following topic online:",
    APIModel: "perplexity/r1-1776:online",
    isCustomPrompt: true
}, {
    promptName: "Auto Paste",
    menuText: "&7 - Auto Paste query here",
    systemPrompt: "You are a helpful assistant. Follow the instructions that I will provide or answer any questions that I will ask.",
    APIModel: "google/gemini-2.0-flash-001",
    isAutoPaste: true
}, {
    promptName: "Auto Paste (Custom prompt)",
    menuText: "&8 - Auto Paste (Custom prompt) query here",
    systemPrompt: "You are a helpful assistant. Follow the instructions that I will provide or answer any questions that I will ask.",
    APIModel: "google/gemini-2.0-flash-001",
    isCustomPrompt: true,
    isAutoPaste: true
}, {
    promptName: "Two models (Custom prompt)",
    menuText: "&9 - Two models (Custom prompt) query here",
    systemPrompt: "You are a helpful assistant. Follow the instructions that I will provide or answer any questions that I will ask. My first query is the following:",
    APIModel: "google/gemini-2.0-flash-thinking-exp:free, anthropic/claude-3.7-sonnet",
    isCustomPrompt: true
}, {
    promptName: "Two models (Custom prompt) web search",
    menuText: "&Q - Two models (Custom prompt) web search query here",
    systemPrompt: "Your task is to search for the following topic online:",
    APIModel: "google/gemini-2.0-flash-thinking-exp:free:online, anthropic/claude-3.7-sonnet:online",
    isCustomPrompt: true
}, {
    promptName: "Deep thinking (Custom prompt)",
    menuText: "&W - Deep thinking (Custom prompt) query here",
    systemPrompt: "You are a helpful assistant. Follow the instructions that I will provide or answer any questions that I will ask. My first query is the following:",
    APIModel: "perplexity/r1-1776, openai/o3-mini-high, openai/o1, google/gemini-2.0-flash-thinking-exp:free",
    isCustomPrompt: true
}, {
    promptName: "Long prompt here",
    menuText: "&E - Long prompt here",
    systemPrompt: "
    (
    This prompt is broken down into multiple lines.

    Here is the second sentence.

    And the third one.

    As long as the prompt is inside the quotes and the opening and closing parenthesis,

    it will be valid.

    The end.
    )",
    APIModel: "openrouter/auto"
}]

; ----------------------------------------------------
; Hotkeys
; ----------------------------------------------------

`:: hotkeyFunctions("showPromptMenu")

~^s:: hotkeyFunctions("saveScriptAndReload")

#SuspendExempt
CapsLock & `:: hotkeyFunctions("suspendHotkey")

hotkeyFunctions(action) {
    switch action {
        case "showPromptMenu":
            if (getActiveModels().Count > 1) {

                ; Adds a menu that includes "Send message to all models"
                ; in addition to existing prompt menu
                sendToAllModelsMenu := Menu()
                sendToAllModelsMenu.Add("&Send message to all models", (*) => sendToAllModelsInputWindow.showInputWindow())
                sendToAllModelsMenu.Add()

                ; Copy the existing prompt menu
                for index, prompt in managePromptState("prompts", "get") {
                    sendToAllModelsMenu.Add(prompt.menuText, promptMenuHandler.Bind(index))
                }

                sendToAllModelsMenu.Show()
            } else {
                promptMenu.Show()
            }

        case "saveScriptAndReload": WinActive("LLM AutoHotkey Assistant.ahk") ? Reload() : ""
        case "suspendHotkey":
            KeyWait "CapsLock", "L"
            KeyWait "``", "L"
            SetCapsLockState "Off"
            toggleSuspend(A_IsSuspended)
    }
}

; ----------------------------------------------------
; Script tray menu
; ----------------------------------------------------

trayMenuItems := [{
    menuText: "Op&en this AHK script in Notepad",
    function: (*) => Run("Notepad " A_ScriptFullPath)
}, {
    menuText: "Open SharedResources AHK script in Notepad",
    function: (*) => Run("Notepad 'lib\SharedResources.ahk'")
}, {
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
; Generate prompt menu dynamically by using PromptMenuHandler
; to pass the index to the handler function
; ----------------------------------------------------

promptMenu := Menu()
for index, prompt in managePromptState("prompts", "get") {
    promptMenu.Add(prompt.menuText, promptMenuHandler.Bind(index))
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
        customPromptInputWindow.showInputWindow()
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
            copiedText := customPromptMessage
        } else {
            manageCursorAndToolTip("Reset")
            MsgBox "The attempt to copy text onto the clipboard failed.", "No text copied", "IconX"
            return
        }
    } else if IsSet(customPromptMessage) {
        copiedText := customPromptMessage "`n`n" A_Clipboard
    } else {
        copiedText := A_Clipboard
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
        chatHistoryJSONRequest := router.createJSONRequest(singleAPIModel, systemPrompt, copiedText)

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

        ; Maintain a reference in the global map to use with sendToAllModelsSendButtonAction
        getActiveModels()[uniqueID] := {
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
        Run "Response Window.ahk " "`"" dataObjToJSONStrFile
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

            toolTipMessage := "Retrieving response from the following model"

            ; Singular and plural forms of the word "model"
            if (activeCount > 1) {
                toolTipMessage .= "s"
            }

            toolTipMessage .= " (Press ESC to cancel):"
            for key, data in getActiveModels() {
                if (data.isLoading) {
                    toolTipMessage .= "`n- " data.name
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
