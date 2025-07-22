#Requires AutoHotkey v2.0

;******************************************************************************
;
; Compilation directives
;
;******************************************************************************

; ;@Ahk2Exe-Base %A_AhkPath%

; ;@Ahk2Exe-AddResource %A_ScriptName%
;@Ahk2Exe-AddResource lib\Response Window.ahk, lib\Response Window.ahk
;@Ahk2Exe-AddResource lib\simulate_select.ahk, lib\simulate_select.ahk


; WARNING : Do not forget to update lib\Config.ahk according to following numbers

;@Ahk2Exe-AddResource icons\IconOn.ico,     10
;@Ahk2Exe-AddResource icons\IconOff.ico,    11
;@Ahk2Exe-AddResource icons\anthropic.ico,  12
;@Ahk2Exe-AddResource icons\deepseek.ico,   13
;@Ahk2Exe-AddResource icons\google.ico,     14
;@Ahk2Exe-AddResource icons\openai.ico,     15
;@Ahk2Exe-AddResource icons\openrouter.ico, 16
;@Ahk2Exe-AddResource icons\perplexity.ico, 17

#Include lib\Config.ahk

#Include config\Prompts.ahk

#SingleInstance

; ----------------------------------------------------
; Hotkeys
; ----------------------------------------------------

;
; Custom Hotkeys to call AI Assistant
;

`:: mainScriptHotkeyActions("showPromptMenu")
~^s:: mainScriptHotkeyActions("saveAndReloadScript")
~^w:: mainScriptHotkeyActions("closeWindows")

#SuspendExempt
CapsLock & `:: mainScriptHotkeyActions("suspendHotkey")

; ----------------------------------------------------
; Auto-execute Section
; ----------------------------------------------------

; Dispatch hotkey actions
mainScriptHotkeyActions(action) {

    MENU_LINE_SEPARATOR := "---"

    ; Get count of active models (= Open Response Windows)
    activeModelsCount := getActiveModels().Count

    switch action {

        case "showPromptMenu":
            promptMenu := Menu()
            tagsMap := Map()

            if (activeModelsCount > 0) {
                ; There are open Response Windows

                ;
                ; Build "Send message to" menu
                ;

                ; Process all open Response Windows once to build prompt maps
                for uniqueID, modelData in getActiveModels() {
                    getActiveModels().%modelData.promptName% := true
                }

                ; Add "Send message to" menu
                sendToMenu := Menu()
                promptMenu.Add("Send message to", sendToMenu)

                ; Create a sub-item (with the prompt name) for each open Response Window
                ; TODO TW m 2025_06_20 If two Response Windows have the same prompt name, only one will be shown in the menu.
                for uniqueID, modelData in getActiveModels() {
                    sendToMenu.Add(modelData.promptName, sendToPromptGroupHandler.Bind(modelData.promptName))
                }

                ; If there are more than one Response Windows, add "All" menu option
                if (activeModelsCount > 1) {
                    sendToMenu.Add("All", (*) => sendToAllModelsInputWindow.showInputWindow(, , "ahk_id " sendToAllModelsInputWindow.guiObj.hWnd))
                }

                ; Line separator after Activate and Send message to
                promptMenu.Add()
            }

            ;
            ; Build Tags or Prompt menu (from Prompts.ahk)
            ;

            Loop 2 ; for step = 1 to 2
            {
                step := A_Index ; step 1 = menu items, step 2 = tags sub-menu


                if (step = 1) {
                    ; 1st step

                } else {
                    ; 2nd step
                    
                    ; Line separator before Tags menu
                    promptMenu.Add()
                }

                for index, prompt in managePromptState("prompts", "get") {

                    hasPromptName := prompt.HasProp("promptName") && prompt.promptName && prompt.promptName != ""

                    if (hasPromptName and prompt.promptName == MENU_LINE_SEPARATOR) {
                        ; Line separator

                        if (step = 1) {
                            ; 1st step

                            ; Line separator before Tags menu
                            promptMenu.Add()

                        } else {
                            ; 2nd step
                            
                        }

                    } else {
                        ; Not a line separator

                        ; Check if prompt has tags
                        hasTags := prompt.HasProp("tags") && prompt.tags && prompt.tags.Length > 0

                        if !hasTags {
                            ; No tags
                            
                            if (step = 1) {
                                ; 1st step
                                
                                ; Add directly to menu
                                ; promptMenu.Add(prompt.menuText, promptMenuHandler.Bind(index))
                                addToPromptMenu(promptMenu, prompt, index)

                            } else {

                            }

                        } else {
                            ; Prompt has tags

                            ; Transform tags to menu item
                            ; and add Prompt as sub-menu item
                            for tag in prompt.tags {

                                if (step = 1) {
                                    ; 1st step
                                    
                                    if (tag == "") {
                                        ; tag is "" which means to add as direct menu item
        
                                        ; Add directly to menu
                                        ; promptMenu.Add(prompt.menuText, promptMenuHandler.Bind(index))
                                        addToPromptMenu(promptMenu, prompt, index)
        
                                    } else {
                                        ; There is a tag not "" which means need to add a tag menu
                                        ; but only on step 2

                                        ; NTD
                                    }

                                } else {
                                    ; 2nd step

                                    if (tag == "") {
                                        ; tag is empty

                                        ; NTD, because already done on step 1
        
                                    } else if (tag == MENU_LINE_SEPARATOR) {
                                        ; Line separator

                                        ; Add a Tag line separator to menu
                                        promptMenu.Add()

                                    } else {
                                        ; Normal tag

                                        normalizedTag := StrLower(Trim(tag))
                                        
                                        if !tagsMap.Has(normalizedTag) {
                                            ; First time this Tag is seen
            
                                            ;
                                            ; Create tag menu
                                            ;
            
                                            ; Create a tag map containing sub-menu and display name
                                            tagsMap[normalizedTag] := { menu: Menu(), displayName: tag }
            
                                            ; Create Menu for tag with its sub-menu
                                            promptMenu.Add(tag, tagsMap[normalizedTag].menu)
                                        }
                                        
                                        if (hasAllNeededForMenu(prompt)) {
                                            ; There is a menuText

                                            ; Add prompt to tag menu
                                            tagsMap[normalizedTag].menu.Add(prompt.menuText, promptMenuHandler.Bind(index))
            
                                        } else {
                                            ; There is NO menuText

                                            ; NTD
                                        }
                                    }
                                }

                            } ; for
                        }
                    }
                } ; for
            } ; loop


            if (activeModelsCount > 0) {
                ; There are open Response Windows
                
                ;
                ; After Tag or Prompt menu items, 
                ; add menu items ("Activate", "Minimize", "Close") that manages Response Windows 
                ;
    
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

            ;
            ; Build "Help" menu
            ;
            
            ; Line separator before Options
            promptMenu.Add()

            ; promptMenu.Add("&Help", helpMenu := Menu())
            ; buildHelpMenu(helpMenu)
            promptMenu.Add("&Help", gHelpMenu)

            ;
            ; Build Options menu
            ;
            
            ; Line separator before Options
            promptMenu.Add()

            promptMenu.Add("&Options", optionsMenu := Menu())
            optionsMenu.Add("&1 - Edit prompts", (*) => Run("Notepad " A_ScriptDir "\config\Prompts.ahk"))
            optionsMenu.Add("&2 - View available models", (*) => Run(gLLM_BASE_URL "/v1/models"))
            optionsMenu.Add("&3 - View available credits", (*) => Run(gLLM_BASE_URL "/v1/credits"))
            optionsMenu.Add("&4 - View usage activity", (*) => Run(gLLM_BASE_URL "/v1/activity"))

            ; Turn default menu item to Bold
            ; promptMenu.Default := "1&"                ; First menu item
            ; promptMenu.Default := "Language"          ; Menu item with name "Language"

            ; Launch a secondary script to simulate Down key press to select 
            ; the first menu item. 
            ; This method is mandatory because .show() blocks execution of all threads in the script
            ; Only another Process can interact with the GUI while the main script is paused
            RunScript("Lib\simulate_select.ahk")

            ; Display the menu
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
            Sleep 1000

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

addToPromptMenu(promptMenu, prompt, index) {

    if (hasAllNeededForMenu(prompt)) {
        ; There is all needed info

        ; Add directly to menu and continue
        promptMenu.Add(prompt.menuText, promptMenuHandler.Bind(index))
        
    } else {
        ; There is NO menuText

        MsgBox("SYNTAX ERROR : In Prompt n° " index)
    }
}

hasAllNeededForMenu(prompt) {

    hasPromptName := prompt.HasProp("promptName") && prompt.promptName && prompt.promptName != ""
    hasMenuText := prompt.HasProp("menuText") && prompt.menuText && prompt.menuText != ""
    hasSystemPrompt := prompt.HasProp("systemPrompt") && prompt.systemPrompt && prompt.systemPrompt != ""
    hasAPIModels := prompt.HasProp("APIModels") && prompt.APIModels && prompt.APIModels != ""

    hasAllNeeded := hasPromptName and hasMenuText and hasSystemPrompt and hasAPIModels

    return hasAllNeeded
}

RunScript(scriptPath) {

    Run(getScriptRunCmd(scriptPath))
}

getScriptRunCmd(scriptPath) {

    Return (!A_IsCompiled) 
                ? 
                ; The script is not compiled, run the script directly with AHK path
                A_AhkPath ' ' '"' getRessourcePath(scriptPath) '"'
                : 
                ; The script is compiled, run the script with /script and "*" to tell that the script is embedded in the executable
                A_AhkPath ' /script ' '"' getRessourcePath(scriptPath) '"'
}


; ----------------------------------------------------
; Script tray menu
; ----------------------------------------------------

; Create Help Menu
gHelpMenu := Menu()
buildHelpMenu(gHelpMenu)

buildHelpMenu(helpMenu) {
    helpMenu.Add("Open README.pdf", (*) => openHelpPdf())
    helpMenu.Add("Press CTRL+click on a menu item, to invert use of Selection or Chat window", (*) => {})
    helpMenu.Add("About : " gVersionStringPrefix " " gVersionStringSuffix, (*) => {})
}

openHelpPdf() {
    Run(A_ScriptDir "\README.pdf")
}


trayMenuItems := [
    {
    menuText: "&Help",
    function: gHelpMenu
    }
   ,{
    menuText: "",
    function: (*) => {}
    }
   ,{
    menuText: "&Reload Script",
    function: (*) => Reload()
    }
   ,{
    menuText: "",
    function: (*) => {}
    }
   ,{
    menuText: "&Suspend Assistant",
    function: (*) => mainScriptHotkeyActions("suspendHotkey")
    }
   ,{
    menuText: "E&xit",
    function: (*) => ExitApp()
    }
]

; ----------------------------------------------------
; Generate tray menu dynamically
; ----------------------------------------------------

TraySetIconEmbed(ICON_ON)

A_TrayMenu.Delete()

for index, item in trayMenuItems {
    if (item.menuText != "") {
        ; There is a menu text
        
        ; Add it to the tray menu
        A_TrayMenu.Add(item.menuText, item.function)

    } else {
        ; There is NO menu text
        
        ; Add a separator to the tray menu
        A_TrayMenu.Add()
    }
}
A_IconTip := "LLM AutoHotkey Assistant"

; ----------------------------------------------------
; Create new instance of OpenRouter class
; ----------------------------------------------------

router := OpenRouter(gLLM_BASE_URL, APIKey)

; ----------------------------------------------------
; Create Input Windows
; ----------------------------------------------------

customPromptInputWindow := InputWindow("Custom prompt")
sendToAllModelsInputWindow := InputWindow("Send message to all")
sendToPromptNameInputWindow := InputWindow("Send message to prompt")

; ----------------------------------------------------
; Register sendButtonActions
; ----------------------------------------------------

customPromptInputWindow.registerSendButtonAction(customPromptSendButtonAction)
sendToAllModelsInputWindow.registerSendButtonAction(sendToAllModelsSendButtonAction)
sendToPromptNameInputWindow.registerSendButtonAction(sendToGroupSendButtonAction)

; ----------------------------------------------------
; Input Window actions
; ----------------------------------------------------

customPromptSendButtonAction(*) {

    if !customPromptInputWindow.validateInputAndHide() {
        return
    }

    selectedPrompt := managePromptState("selectedPrompt", "get")
    processInitialRequest(selectedPrompt.promptName
                        , selectedPrompt.menuText
                        , selectedPrompt.systemPrompt
                        , selectedPrompt.APIModels
                        , selectedPrompt.HasProp("copyAsMarkdown") && selectedPrompt.copyAsMarkdown
                        , selectedPrompt.HasProp("isAutoPaste") && selectedPrompt.isAutoPaste
                        , selectedPrompt.HasProp("skipConfirmation") && selectedPrompt.skipConfirmation
                        , customPromptInputWindow.EditControl.Value
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
    
    sendToPromptNameInputWindow.showInputWindow(, "Send message to " promptName, "ahk_id " sendToPromptNameInputWindow.guiObj.hWnd)
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
        TraySetIconEmbed(ICON_OFF)
        A_IconTip := "LLM AutoHotkey Assistant - (Suspended)"

        ; Show GUI at the bottom, centered
        scriptSuspendStatus.Show("AutoSize x" (A_ScreenWidth - scriptSuspendStatusWidth) / 2.3 " y990 NA")
    } else {
        TraySetIconEmbed(ICON_ON)
        A_IconTip := "LLM AutoHotkey Assistant"
        scriptSuspendStatus.Hide()
    }
}

; ----------------------------------------------------
; Prompt menu handler function
;
; If needed, show a Custom Prompt Window Else send the request
; ----------------------------------------------------

promptMenuHandler(index, *) {
    
    ; Get CTRL key state
    ctrlPressed := GetKeyState("Ctrl", "P")
    
    ; Get the list of prompts and the selected prompt
    promptsList := managePromptState("prompts", "get")
    selectedPrompt := promptsList[index]

    ; Determine if we should show the prompt input window based on the prompt properties
    shallShowPromptInputWindow :=   (   selectedPrompt.HasProp("isCustomPrompt") 
                                        && selectedPrompt.isCustomPrompt
                                    )

    ; Invert if CTRL is pressed
    shallShowPromptInputWindow := ctrlPressed ? !shallShowPromptInputWindow : shallShowPromptInputWindow

    if (shallShowPromptInputWindow) or (getSelectedText() == "") {
        ; Selected prompt ask for a custom prompt or no text is selected

        ; Save the prompt for future reference in customPromptSendButtonAction(*)
        managePromptState("selectedPrompt", "set", selectedPrompt)

        ; Set skipConfirmation property based on the prompt
        customPromptInputWindow.setSkipConfirmation(selectedPrompt.HasProp("skipConfirmation") ? selectedPrompt.skipConfirmation : false)

        ; Show InputWindow for custom prompt
        customPromptInputWindow.showInputWindow(selectedPrompt.HasProp("customPromptInitialMessage") ? selectedPrompt.customPromptInitialMessage : unset
                                              , selectedPrompt.promptName
                                              , "ahk_id " customPromptInputWindow.guiObj.hWnd
                                              , selectedPrompt.HasProp("isCustomPromptCursorAtEnd") ? selectedPrompt.isCustomPromptCursorAtEnd : true)

    } else {
        ; Selected prompt does NOT ask for a custom prompt

        ; Process initial request with the selected prompt details
        processInitialRequest(selectedPrompt.promptName, 
            selectedPrompt.menuText, 
            selectedPrompt.systemPrompt,
            selectedPrompt.APIModels, selectedPrompt.HasProp("copyAsMarkdown") && selectedPrompt.copyAsMarkdown,
            selectedPrompt.HasProp("isAutoPaste") && selectedPrompt.isAutoPaste,
            selectedPrompt.HasProp("skipConfirmation") && selectedPrompt.skipConfirmation
        )
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

processInitialRequest(  promptName, 
                        menuText, 
                        systemPrompt, 
                        APIModels, 
                        copyAsMarkdown, 
                        isAutoPaste, 
                        skipConfirmation, 
                        customPromptMessage := unset) {

    ; Récupérer le texte sélectionné
    selectedText := getSelectedText()

    if (selectedText == "") {
        ; No selected text

        if IsSet(customPromptMessage) {
            ; There is a custom prompt

            ; Use custom prompt message without copied text
            userPrompt := customPromptMessage

        } else {
            ; Copy failed and there is no custom prompt

            ; Reset Tooltip
            manageCursorAndToolTip("Reset")

            MsgBox "The attempt to copy text onto the clipboard failed.", "No text copied", "IconX"
            return
        }
    } else if IsSet(customPromptMessage) {
        ; Copy succeeded and there is a custom prompt

        ; Use custom prompt message with copied text
        userPrompt := customPromptMessage "`n`n" selectedText

    } else {
        ; Copy succeeded and there is no custom prompt

        ; Use copied text as prompt without any additional message
        userPrompt := selectedText
    }

    ; Removes newlines, spaces, and splits by comma
    APIModels := StrSplit(RegExReplace(APIModels, "\s+", ""), ",")

    ; Automatically disables isAutoPaste if more than one model is present
    isAutoPaste := (APIModels.Length > 1) ? false : isAutoPaste

    ; Loop to call all Models in APIModels list
    for i, fullAPIModelName in APIModels {

        if (fullAPIModelName != "") {
            ; There is a valid API Model Name

            ;
            ; Generate sanitized filenames for chat history, cURL command, and cURL output files
            ;
    
            ; Use current timestamp as unique identifier for filenames
            uniqueID := A_TickCount
            
            ; Get text before forward slash as providerName
            providerName := SubStr(fullAPIModelName, 1, InStr(fullAPIModelName, "/") - 1)
    
            ; Get text after forward slash as singleAPIModelName
            singleAPIModelName := SubStr(fullAPIModelName, InStr(fullAPIModelName, "/") + 1)
    
            ; Create a prefix for filenames        
            prefix := "LLM_Ahk_" uniqueID "_" promptName "_" singleAPIModelName
            
            ; Define forbidden characters for filenames that must be replaced with underscores
            forbiddenChars := "[\/\\:*?`"<>| ]"
            
            ; Use prefix ans number in order to easily sort files
            dataObjToJSONStrFile :=         A_Temp "\" RegExReplace(prefix "_" "1_responseWindowData.json",  forbiddenChars, "_")
            chatHistoryJSONRequestFile :=   A_Temp "\" RegExReplace(prefix "_" "2_chatHistoryJSONRequest.json", forbiddenChars, "_")
            cURLCommandFile :=              A_Temp "\" RegExReplace(prefix "_" "3_cURLCommand.bat", forbiddenChars, "_")
            cURLOutputFile :=               A_Temp "\" RegExReplace(prefix "_" "4_cURLOutput.json",    forbiddenChars, "_")
            
            ;
            ; Write Chat History JSON request to files
            ;
            
            ; Create the chatHistoryJSONRequest
            chatHistoryJSONRequest := router.createJSONRequest(fullAPIModelName, systemPrompt, userPrompt)
    
            FileOpen(chatHistoryJSONRequestFile, "w", "UTF-8-RAW").Write(chatHistoryJSONRequest)
    
            ;
            ; Write cURL command to file
            ;
            
            cURLCommand := router.buildcURLCommand(chatHistoryJSONRequestFile, cURLOutputFile)
    
		    ; Write cURL command to file
		    ; Before running manually this bat file for debug in a cmd.exe window,
		    ; change the code page of the cmd.exe to UTF-8 with the following command : chcp 65001
		    FileOpen(cURLCommandFile, "w", "UTF-8").Write(cURLCommand)
            
            ;
            ; Maintain a reference in the global map
            ;
    
            getActiveModels()[uniqueID] := {
                promptName: promptName,
                menuText: menuText,
                name: singleAPIModelName,
                userPrompt: userPrompt,
                systemPrompt: systemPrompt,
                provider: router,
                JSONFile: chatHistoryJSONRequestFile,
                cURLFile: cURLCommandFile,
                outputFile: cURLOutputFile,
                isLoading: false
            }
    
            ;
            ; Create an object containing all values for the Response Window
            ;
    
            responseWindowDataObj := {
                chatHistoryJSONRequestFile: chatHistoryJSONRequestFile,
                cURLCommandFile: cURLCommandFile,
                cURLOutputFile: cURLOutputFile,
                providerName: providerName,
                copyAsMarkdown: copyAsMarkdown,
                isAutoPaste: isAutoPaste,
                skipConfirmation: skipConfirmation,
                mainScriptHiddenhWnd: A_ScriptHwnd,
                callingWindowHwnd: WinActive("A"),
                responseWindowTitle: gVersionStringPrefix " " promptName " [" singleAPIModelName "]" " : " gVersionStringSuffix,
                singleAPIModelName: singleAPIModelName,
                numberOfAPIModels: APIModels.Length,
                APIModelsIndex: i,
                uniqueID: uniqueID
            }
    
            ;
            ; Write the object to a file named responseWindowData and run
            ; Response Window.ahk while passing the location of that file
            ; through dataObjToJSONStrFile as the first argument
            ;
    
            dataObjToJSONStr := jsongo.Stringify(responseWindowDataObj)
            FileOpen(dataObjToJSONStrFile, "w", "UTF-8-RAW").Write(dataObjToJSONStr)
            getActiveModels()[uniqueID].JSONFile := chatHistoryJSONRequestFile
    
            if (!A_IsCompiled)
            {
                ; On est en mode script
                ; A_AhkPath pointe vers AutoHotkeyU64.exe
                
                ; Lancer Response Window.ahk dans un Process séparé
                Run(A_AhkPath . " " . "`"lib\Response Window.ahk`"" . " " . "`"" . dataObjToJSONStrFile . "`"")
                
            } else {
                ; On est en mode compilé
                ; A_AhkPath pointe vers l'exe du script principal commpilé
    
                ; Lancer Response Window.ahk (Embedded, d'où la nécessité d'une étoile "*" devant le nom de la ressource) dans un Process séparé
                Run(A_AhkPath . " /script " . "`"*lib\Response Window.ahk`"" . " " . "`"" . dataObjToJSONStrFile . "`"")
            }

        } else {
            ; There is NO API Model Name

            ; Eventually, I think it's better to simply ignore it
            ; ; Display error message
            ; MsgBox("SYNTAX ERROR : In Prompt [" promptName "] on API Model n° " i)
        }
    }
}

; ----------------------------------------------------
; Tracks active models (i.e. Opened Response Windows)
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

            ; Singular and plural forms of the word "prompt"
            if (activeCount > 1) {
                toolTipMessage .= "s"
            }

            toolTipMessage .= " (Press ESC to cancel):"
            for key, data in getActiveModels() {
                if (data.isLoading) {
                    toolTipMessage .= "`n- " StrReplace(data.menuText,  "&", "") " `"" SubStr(data.userPrompt, 1 , 50) "...`"" " [" data.name "]"
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
