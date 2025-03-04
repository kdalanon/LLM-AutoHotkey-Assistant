#Include <Config>
#SingleInstance

; ----------------------------------------------------
; Hotkeys
; ----------------------------------------------------

`:: mainScriptHotkeyActions("showPromptMenu")
~^s:: mainScriptHotkeyActions("saveAndReloadScript")
~^w:: mainScriptHotkeyActions("closeWindows")

#SuspendExempt
CapsLock & `:: mainScriptHotkeyActions("suspendHotkey")

mainScriptHotkeyActions(action) {
    activeModelsCount := getActiveModels().Count

    switch action {
        case "showPromptMenu":
            promptMenu := Menu()
            tagsMap := Map()

            ; Process all active models once to build prompt maps
            if (activeModelsCount > 0) {

                for uniqueID, modelData in getActiveModels() {
                    getActiveModels().%modelData.promptName% := true
                }

                ; Send message to menu
                sendToMenu := Menu()
                promptMenu.Add("Send message to", sendToMenu)

                for uniqueID, modelData in getActiveModels() {
                    sendToMenu.Add(modelData.promptName, sendToPromptGroupHandler.Bind(modelData.promptName))
                }

                ; If there are more than one Response Windows, add "All" menu option
                if (activeModelsCount > 1) {
                    sendToMenu.Add("All", (*) => sendToAllModelsInputWindow.showInputWindow(, , "ahk_id " sendToAllModelsInputWindow
                        .guiObj.hWnd))
                }

                ; Line separator after Activate and Send message to
                promptMenu.Add()
            }

            ; Normal prompts
            for index, prompt in managePromptState("prompts", "get") {

                ; Check if prompt has tags
                hasTags := prompt.HasProp("tags") && prompt.tags && prompt.tags.Length > 0

                ; If no tags, add directly to menu and continue
                if !hasTags {
                    promptMenu.Add(prompt.menuText, promptMenuHandler.Bind(index))
                    continue
                }

                ; Process tags
                for tag in prompt.tags {
                    normalizedTag := StrLower(Trim(tag))

                    ; Create tag menu if doesn't exist
                    if !tagsMap.Has(normalizedTag) {
                        tagsMap[normalizedTag] := { menu: Menu(), displayName: tag }
                        promptMenu.Add(tag, tagsMap[normalizedTag].menu)
                    }

                    ; Add prompt to tag menu
                    tagsMap[normalizedTag].menu.Add(prompt.menuText, promptMenuHandler.Bind(index))
                }
            }

            ; Add menus ("Activate", "Minimize", "Close") that manages Response Windows
            ; after normal prompts if there are active models
            if (activeModelsCount > 0) {

                ; Line separator before managing Response Window menu
                promptMenu.Add()

                ; Define the action types
                actionTypes := ["Activate", "Minimize", "Close"]

                ; Create submenus for each action type
                for _, actionType in actionTypes {

                    ; Convert to lowercase for function names
                    actionKey := StrLower(actionType)

                    actionSubMenu := Menu()
                    promptMenu.Add(actionType, actionSubMenu)

                    ; Add menu items for each active model
                    for uniqueID, modelData in getActiveModels() {
                        actionSubMenu.Add(modelData.promptName, managePromptWindows.Bind(actionKey, modelData.promptName
                        ))
                    }

                    ; If there are more than one Response Windows, add "All" menu option
                    if (activeModelsCount > 1) {
                        actionSubMenu.Add("All", managePromptWindows.Bind(actionKey))
                    }
                }
            }

            ; Line separator before Options
            promptMenu.Add()

            ; Options menu
            promptMenu.Add("&Options", optionsMenu := Menu())
            optionsMenu.Add("&1 - Edit prompts", (*) => Run("Notepad " A_ScriptDir "\Prompts.ahk"))
            optionsMenu.Add("&2 - View available models", (*) => Run("https://openrouter.ai/models"))
            optionsMenu.Add("&3 - View available credits", (*) => Run("https://openrouter.ai/credits"))
            optionsMenu.Add("&4 - View usage activity", (*) => Run("https://openrouter.ai/activity"))
            promptMenu.Show()

        case "suspendHotkey":
            KeyWait "CapsLock", "L"
            SetCapsLockState "Off"
            toggleSuspend(A_IsSuspended)

        case "saveAndReloadScript":
            if !WinActive("Prompts.ahk") {
                return
            }

            ; Small delay to ensure file operations are complete
            Sleep 100

            if (activeModelsCount > 0) {
                MsgBox("Script will automatically reload once all Response Windows are closed.",
                    "LLM AutoHotkey Assistant", 64)
                responseWindowState(0, 0, "reloadScript", 0)
            } else {
                Reload()
            }

        case "closeWindows":
            switch WinActive("A") {
                case customPromptInputWindow.guiObj.hWnd: customPromptInputWindow.closeButtonAction()
                case sendToPromptNameInputWindow.guiObj.hWnd: sendToPromptNameInputWindow.closeButtonAction()
                case sendToAllModelsInputWindow.guiObj.hWnd: sendToAllModelsInputWindow.closeButtonAction()
            }
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
; Create Input Windows
; ----------------------------------------------------

customPromptInputWindow := InputWindow("Custom prompt")
sendToAllModelsInputWindow := InputWindow("Send message to all")
sendToPromptNameInputWindow := InputWindow("Send message to prompt")

; ----------------------------------------------------
; Register sendButtonActions
; ----------------------------------------------------

customPromptInputWindow.sendButtonAction(customPromptSendButtonAction)
sendToAllModelsInputWindow.sendButtonAction(sendToAllModelsSendButtonAction)
sendToPromptNameInputWindow.sendButtonAction(sendToGroupSendButtonAction)

; ----------------------------------------------------
; Input Window actions
; ----------------------------------------------------

customPromptSendButtonAction(*) {
    if !customPromptInputWindow.validateInputAndHide() {
        return
    }

    selectedPrompt := managePromptState("selectedPrompt", "get")
    processInitialRequest(selectedPrompt.promptName, selectedPrompt.menuText, selectedPrompt.systemPrompt,
        selectedPrompt.APIModels,
        selectedPrompt.HasProp("copyAsMarkdown") && selectedPrompt.copyAsMarkdown,
        selectedPrompt.HasProp("isAutoPaste") && selectedPrompt.isAutoPaste,
        selectedPrompt.HasProp("skipConfirmation") && selectedPrompt.skipConfirmation,
        customPromptInputWindow.EditControl.Value
    )
    customPromptInputWindow.EditControl.Value := ""
}

sendToAllModelsSendButtonAction(*) {
    if (getActiveModels().Count = 0) {
        MsgBox "No Response Windows found. Message not sent.", "Send message to all models", "IconX"
        sendToAllModelsInputWindow.guiObj.Hide
        return
    }

    if !sendToAllModelsInputWindow.validateInputAndHide() {
        return
    }

    ; The main script must know each Response Window's JSON file
    ; so it can read it, parse it, append the new
    ; user message, then write it back
    for uniqueID, modelData in getActiveModels() {
        JSONStr := FileOpen(modelData.JSONFile, "r", "UTF-8").Read()
        router.appendToChatHistory("user", sendToAllModelsInputWindow.EditControl.Value, &JSONStr, modelData.JSONFile)

        ; Notify the Response Window to re-read the JSON file and call sendRequestToLLM() again
        responseWindowhWnd := modelData.hWnd
        CustomMessages.notifyResponseWindowState(CustomMessages.WM_SEND_TO_ALL_MODELS, uniqueID, responseWindowhWnd
        )
    }
}

sendToGroupSendButtonAction(*) {
    if (getActiveModels().Count = 0) {
        MsgBox "No Response Windows found. Message not sent.", "Send message to all models", "IconX"
        sendToAllModelsInputWindow.guiObj.Hide
        return
    }

    if !sendToPromptNameInputWindow.validateInputAndHide() {
        return
    }

    if (!targetPromptName := managePromptState("selectedPromptForMessage", "get")) {
        return
    }

    ; Send message only to active models that belong to this prompt
    for uniqueID, modelData in getActiveModels() {

        ; Check if this model belongs to the selected prompt
        if (modelData.promptName != targetPromptName) {
            continue
        }

        JSONStr := FileOpen(modelData.JSONFile, "r", "UTF-8").Read()
        router.appendToChatHistory("user", sendToPromptNameInputWindow.EditControl.Value, &JSONStr, modelData.JSONFile)

        ; Notify the Response Window to re-read the JSON file and call sendRequestToLLM() again
        responseWindowhWnd := modelData.hWnd
        CustomMessages.notifyResponseWindowState(CustomMessages.WM_SEND_TO_ALL_MODELS, uniqueID, responseWindowhWnd)
    }

    sendToPromptNameInputWindow.EditControl.Value := ""
}

sendToPromptGroupHandler(promptName, *) {
    promptsList := managePromptState("prompts", "get")

    ; Find the prompt with the matching promptName
    for _, prompt in promptsList {

        ; Check if the prompt has the same name as the one we're looking for
        if (prompt.promptName = promptName) {
            selectedPrompt := prompt
            break
        }
    }

    managePromptState("selectedPromptForMessage", "set", promptName)

    ; Check if the prompt has skipConfirmation property and set accordingly
    sendToPromptNameInputWindow.setSkipConfirmation(selectedPrompt.HasProp("skipConfirmation") ? selectedPrompt.skipConfirmation : false)
    sendToPromptNameInputWindow.showInputWindow(, "Send message to " promptName, "ahk_id " sendToPromptNameInputWindow.guiObj
        .hWnd
    )
}

; Generic function to perform an operation on prompt windows
;
; Parameters:
; - operation (activate, minimize, close): The operation to perform
; - promptName: Optional. If provided, only windows for this prompt will be affected
managePromptWindows(operation, promptName := "", *) {

    ; Create a list of window handles that match our criteria
    hWndsToManage := []

    ; Iterate through all active models
    for uniqueID, modelData in getActiveModels() {
        if (promptName = "All" || modelData.promptName = promptName) {
            hWndsToManage.Push(modelData.hWnd)
        }
    }

    ; Perform the requested operation on each window
    for _, hWnd in hWndsToManage {
        switch operation {
            case "activate": WinActivate("ahk_id " hWnd)
            case "minimize": WinMinimize("ahk_id " hWnd)
            case "close": WinClose("ahk_id " hWnd)
        }
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

        ; Set skipConfirmation property based on the prompt
        customPromptInputWindow.setSkipConfirmation(selectedPrompt.HasProp("skipConfirmation") ? selectedPrompt.skipConfirmation : false)

        customPromptInputWindow.showInputWindow(selectedPrompt.HasProp("customPromptInitialMessage")
            ? selectedPrompt.customPromptInitialMessage : unset, selectedPrompt.promptName, "ahk_id " customPromptInputWindow
        .guiObj.hWnd)
    } else {
        processInitialRequest(selectedPrompt.promptName, selectedPrompt.menuText, selectedPrompt.systemPrompt,
            selectedPrompt.APIModels, selectedPrompt.HasProp("copyAsMarkdown") && selectedPrompt.copyAsMarkdown,
            selectedPrompt.HasProp("isAutoPaste") && selectedPrompt.isAutoPaste,
            selectedPrompt.HasProp("skipConfirmation") && selectedPrompt.skipConfirmation)
    }
}

; ----------------------------------------------------
; Manage prompt states
; ----------------------------------------------------

managePromptState(component, action, data := {}) {
    static state := {
        prompts: prompts,
        selectedPrompt: {},
        selectedPromptForMessage: {}
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

        case "selectedPromptForMessage":
            switch action {
                case "get": return state.selectedPromptForMessage
                case "set": state.selectedPromptForMessage := data
            }
    }
}

; ----------------------------------------------------
; Connect to LLM API and process request
; ----------------------------------------------------

processInitialRequest(promptName, menuText, systemPrompt, APIModels, copyAsMarkdown, isAutoPaste, skipConfirmation,
    customPromptMessage := unset) {

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

    ; Removes newlines, spaces, and splits by comma
    APIModels := StrSplit(RegExReplace(APIModels, "\s+", ""), ",")

    ; Automatically disables isAutoPaste if more than one model is present
    isAutoPaste := (APIModels.Length > 1) ? false : isAutoPaste

    for i, fullAPIModelName in APIModels {

        ; Get text before forward slash as providerName
        providerName := SubStr(fullAPIModelName, 1, InStr(fullAPIModelName, "/") - 1)

        ; Get text after forward slash as singleAPIModelName
        singleAPIModelName := SubStr(fullAPIModelName, InStr(fullAPIModelName, "/") + 1)

        uniqueID := A_TickCount

        ; Create the chatHistoryJSONRequest
        chatHistoryJSONRequest := router.createJSONRequest(fullAPIModelName, systemPrompt, userPrompt)

        ; Generate sanitized filenames for chat history, cURL command, and cURL output files
        chatHistoryJSONRequestFile := A_Temp "\" RegExReplace("chatHistoryJSONRequest_" promptName "_" singleAPIModelName "_" uniqueID ".json",
            "[\/\\:*?`"<>|]", "")
        cURLCommandFile := A_Temp "\" RegExReplace("cURLCommand_" promptName "_" singleAPIModelName "_" uniqueID ".txt",
            "[\/\\:*?`"<>|]", "")
        cURLOutputFile := A_Temp "\" RegExReplace("cURLOutput_" promptName "_" singleAPIModelName "_" uniqueID ".json",
            "[\/\\:*?`"<>|]", "")

        ; Write the JSON request and cURL command to files
        FileOpen(chatHistoryJSONRequestFile, "w", "UTF-8-RAW").Write(chatHistoryJSONRequest)
        cURLCommand := router.buildcURLCommand(chatHistoryJSONRequestFile, cURLOutputFile)
        FileOpen(cURLCommandFile, "w").Write(cURLCommand)

        ; Maintain a reference in the global map
        getActiveModels()[uniqueID] := {
            promptName: promptName,
            name: singleAPIModelName,
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
            copyAsMarkdown: copyAsMarkdown,
            isAutoPaste: isAutoPaste,
            skipConfirmation: skipConfirmation,
            mainScriptHiddenhWnd: A_ScriptHwnd,
            responseWindowTitle: promptName " [" singleAPIModelName "]",
            singleAPIModelName: singleAPIModelName,
            numberOfAPIModels: APIModels.Length,
            APIModelsIndex: i,
            uniqueID: uniqueID
        }

        ; Write the object to a file named responseWindowData and run
        ; Response Window.ahk while passing the location of that file
        ; through dataObjToJSONStrFile as the first argument
        dataObjToJSONStr := jsongo.Stringify(responseWindowDataObj)
        dataObjToJSONStrFile := A_Temp "\" RegExReplace("responseWindowData_" promptName "_" singleAPIModelName "_" A_TickCount ".json",
            "[\/\\:*?`"<>|]", "")
        FileOpen(dataObjToJSONStrFile, "w", "UTF-8-RAW").Write(dataObjToJSONStr)
        getActiveModels()[uniqueID].JSONFile := chatHistoryJSONRequestFile
        Run("lib\Response Window.ahk " "`"" dataObjToJSONStrFile)
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
responseWindowState(uniqueID, responseWindowhWnd, state, mainScriptHiddenhWnd) {
    static responseWindowLoadingCount := 0
    static reloadScript := false

    switch state {
        case CustomMessages.WM_RESPONSE_WINDOW_OPENED:
            getActiveModels()[uniqueID].hWnd := responseWindowhWnd

        case CustomMessages.WM_RESPONSE_WINDOW_CLOSED:
            if getActiveModels().Has(uniqueID) {
                getActiveModels().Delete(uniqueID)
                manageCursorAndToolTip("Update")
            }

            if (getActiveModels().Count = 0) && reloadScript {
                Reload()
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

        case "reloadScript": reloadScript := true
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
