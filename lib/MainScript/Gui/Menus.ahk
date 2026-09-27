#Requires AutoHotkey v2.0

buildMenu(promptMenu) {

    ; Build Tags or Prompt menu (from Prompts.ahk)
    buildTagsAndPromptsMenuItems(promptMenu)

    ; Build "Help" menu
    buildHelpMenuItem(promptMenu)

    ; Build Options menu
    buildOptionsMenuItem(promptMenu)

    ;
    ; Build "Sessions" menu (includes saved sessions + active Response Windows)
    ;

    promptMenu.Add()

    buildSessionsMenu(promptMenu)

    ; Turn default menu item to Bold
    ; promptMenu.Default := "1&"                ; First menu item
    ; promptMenu.Default := "Language"          ; Menu item with name "Language"
}


;
; Build "Sessions" menu
; Includes saved sessions + active Response Windows (merged by uniqueID)
;
buildSessionsMenu(targetMenu) {

    global jsongo

    ; Get existing Sessions from disk
    sessions := getSessions()

    ; Build a set of uniqueIDs that are currently active
    activeWindowIDs := Map()
    activeWindowsCount := getMapId2ActiveResponseWindowParams().Count

    for uniqueID, activeResponseWindowParams in getMapId2ActiveResponseWindowParams() {
        activeWindowIDs[uniqueID] := activeResponseWindowParams
    }

    if (sessions.Length = 0) {
        targetMenu.Add("&No sessions found", (*) => {})
        return
    }

    sessionsMenu := Menu()

    ; Build menu items for each session (in reverse order)
    loop sessions.Length
    {
        session := sessions[sessions.Length - A_Index + 1]

        sessionSubMenu := Menu()

        ; Check if this session has an active window
        if (activeWindowIDs.Has(session.uniqueID)) {
            ; Session with active window: Send / Open / Minimize / Close / Toggle Favorite

            ; "Send Prompt" item
            sessionSubMenu.Add("Send &Prompt", sendToUniqueIDSession.Bind(session.uniqueID))

            ; "Send Prompt to all with same Prompt Name" item
            sessionSubMenu.Add("Send Prompt to &All : " session.promptName, sendToAllOpenWithSamePromptName.Bind(session.uniqueID, session.promptName))

            ; Separator
            sessionSubMenu.Add()

            ; "Open" item (brings window to foreground)
            sessionSubMenu.Add("&Open", managePromptWindows.Bind("activate", session.uniqueID))

            ; "Minimize" item
            sessionSubMenu.Add("&Minimize", managePromptWindows.Bind("minimize", session.uniqueID))

            ; "Close" item
            sessionSubMenu.Add("&Close", managePromptWindows.Bind("close", session.uniqueID))

            ; Separator
            sessionSubMenu.Add()

            ; "Toggle Favorite" item
            sessionSubMenu.Add("Toggle &Favorite", toggleFavoriteSession.Bind(,,, session.paramsForResponseWindowJsonFilePath))

        } else {
            ; Session without active window: Open / Toggle Favorite / Delete / Delete this and olders

            ; Item "Open"
            sessionSubMenu.Add("&Open", openSession.Bind(,,, session.paramsForResponseWindowJsonFilePath))

            ; Separator
            sessionSubMenu.Add()

            ; Item "Toggle Favorite"
            sessionSubMenu.Add("Toggle &Favorite", toggleFavoriteSession.Bind(,,, session.paramsForResponseWindowJsonFilePath))

            ; Separator
            sessionSubMenu.Add()

            ; Item "Delete"
            sessionSubMenu.Add("&Delete", deleteSession.Bind(,,, session.paramsForResponseWindowJsonFilePath))

            ; Item "Delete this and olders"
            sessionSubMenu.Add("De&lete this and olders", deleteOldersSessions.Bind(,,, session.paramsForResponseWindowJsonFilePath))
        }

        ; Add the session's sub-menu to the main Sessions menu
        sessionMenuItemName := buildMenuItemLabel(session.promptName, session.uniqueID, session.userPrompt, session.isFavorite, activeWindowIDs.Has(session.uniqueID))
        sessionsMenu.Add(sessionMenuItemName, sessionSubMenu)
    } ; loop

    ;
    ; "All open" submenu
    ;

    if (activeWindowsCount > 1) {
        ; Add a separator
        sessionsMenu.Add()

        ; Add "All open" menu
        allOpenSubMenu := Menu()
        allOpenSubMenu.Add("Send Prompt", sendToAllOpenSessions.Bind())
        allOpenSubMenu.Add()
        allOpenSubMenu.Add("Close", managePromptWindows.Bind("close", "All"))
        sessionsMenu.Add("All open", allOpenSubMenu)
    }

    ; Add the main Sessions menu to the target menu
    targetMenu.Add("&Sessions", sessionsMenu)
}


;
; Send message to all open Response Windows
;
sendToAllOpenSessions(*) {

    if (getMapId2ActiveResponseWindowParams().Count = 0) {
        MsgBox "No Response Windows found. Message not sent.", "Send message to all open", "IconX"
        return
    }

    ; Show input window
    sendToAllModelsInputWindow.showInputWindow( , , , "ahk_id " sendToAllModelsInputWindow.guiObj.hWnd)
}

buildTagsAndPromptsMenuItems(promptMenu) {

    global MENU_LINE_SEPARATOR

    STEP_MENU_ITEMS := 1
    STEP_TAG_SUB_MENU := 2

    tagsMap := Map()

    Loop 2 ; for step = 1 to 2
    {
        step := A_Index ; step 1 = menu items, step 2 = tags sub-menu

        if (step = STEP_MENU_ITEMS) {
            ; 1st step

        } else {
            ; 2nd step
            
            ; Line separator before Tags menu
            promptMenu.Add()
        }

        for index, prompt in managePromptState("prompts", "get") {

            ; Check if prompt has tags
            hasTags := prompt.HasProp("tags") && prompt.tags && prompt.tags.Length > 0

            if !hasTags {
                ; No tags
                
                if (step = STEP_MENU_ITEMS) {
                    ; STEP_MENU_ITEMS
                    
                    ; Add directly to menu
                    addToPromptMenu(promptMenu, prompt, index)

                } else {
                    ; STEP_TAG_SUB_MENU
                    
                    ; Add directly to menu

                }

            } else {
                ; Prompt has tags

                ; Transform tags to menu item
                ; and add Prompt as sub-menu item
                for tag in prompt.tags {

                    if (step = STEP_MENU_ITEMS) {
                        ; STEP_MENU_ITEMS
                        
                        if (tag == "") {
                            ; tag is "" which means to add as direct menu item

                            ; Add directly to menu
                            addToPromptMenu(promptMenu, prompt, index)

                        } else {
                            ; There is a tag not "" which means need to add a tag menu
                            ; but only on step 2

                            ; NTD
                        }

                    } else {
                        ; STEP_TAG_SUB_MENU

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
                                ; Create Tag menu
                                ;

                                ; Create a tag map containing sub-menu and display name
                                tagsMap[normalizedTag] := { menu: Menu(), displayName: tag }

                                ; Create Menu for tag with its sub-menu
                                promptMenu.Add(tag, tagsMap[normalizedTag].menu)
                            }
                            
                            if (hasAllNeededForMenu(prompt)) {

                                ; Add Prompt SubMenu to Tag menu
                                addToPromptMenu(tagsMap[normalizedTag].menu, prompt, index)

                            } else {
                                ; There is NO menuText

                                ; NTD
                            }
                        }
                    }
                } ; for
            }
        } ; for
    } ; loop
}

buildHelpMenuItem(promptMenu) {
    
    ; Line separator before Options
    promptMenu.Add()

    ; promptMenu.Add("&Help", helpMenu := Menu())
    ; buildHelpMenuItem(helpMenu)
    promptMenu.Add("&Help", gHelpMenu)
}

buildOptionsMenuItem(promptMenu) {

    ; Line separator before Options
    promptMenu.Add()

    ; Refresh checkmarks on theme menu
    updateThemeMenuChecks(gThemeMenu)

    promptMenu.Add("&Options", optionsMenu := Menu())
    optionsMenu.Add("&1 - Edit prompts", (*) => openPromptsInEditor())
    optionsMenu.Add()
    optionsMenu.Add("&2 - View available models", (*) => Run(gLLM_BASE_URL "/v1/models"))
    optionsMenu.Add("&3 - View available credits", (*) => Run(gLLM_BASE_URL "/v1/credits"))
    optionsMenu.Add("&4 - View usage activity", (*) => Run(gLLM_BASE_URL "/v1/activity"))
    optionsMenu.Add()
    optionsMenu.Add("&5 - Theme", gThemeMenu)
    optionsMenu.Add()
    optionsMenu.Add("&6 - Toggle Debug Mode", (*) => toggleDebugMode())
}

;
; After Tag or Prompt menu items, 
; add menu items ("Activate", "Minimize", "Close") that manages Response Windows 
;
buildManageResponseWindowsMenuItems(promptMenu) {

    ; Get count of active Response Windows
    activeResponseWindowsCount := getMapId2ActiveResponseWindowParams().Count

    if (activeResponseWindowsCount > 0) {
        ; There are open Response Windows
        
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
            for uniqueID, activeResponseWindowParams in getMapId2ActiveResponseWindowParams() {
                actionSubMenu.Add(activeResponseWindowParams["promptName"]
                                ; , managePromptWindows.Bind(actionKey, activeResponseWindowParams["promptName"])
                                , managePromptWindows.Bind(actionKey, uniqueID)
                                )
            }
    
            ; If there are more than one Response Windows, add "All" menu option
            if (activeResponseWindowsCount > 1) {
                actionSubMenu.Add("All", managePromptWindows.Bind(actionKey))
            }
        }
    }
}

buildTrayMenu(trayMenuItems) {

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
}


buildHelpMenu(helpMenu) {
    helpMenu.Add("Open README.pdf", (*) => openHelpPdf())
    helpMenu.Add()
    helpMenu.Add("Press CTRL+click on a menu item, to invert use of Selection or Chat window", (*) => {})
    helpMenu.Add()
    helpMenu.Add("&À propos...", (*) => animateIamInTrayBarGui(true))
}

buildThemeMenu(themeMenu) {
    themeMenu.Add("&Dark", (*) => onThemeMenuSelect("Dark"))
    themeMenu.Add("&Light", (*) => onThemeMenuSelect("Light"))
    themeMenu.Add("&System", (*) => onThemeMenuSelect("System"))

    updateThemeMenuChecks(themeMenu)
}

updateThemeMenuChecks(themeMenu) {
    themeMenu.Uncheck("&Dark")
    themeMenu.Uncheck("&Light")
    themeMenu.Uncheck("&System")

    currentTheme := IsSet(gTHEME) ? gTHEME : "Dark"

    if (currentTheme = "Light") {
        ; Current theme is Light

        ; Check Light item
        themeMenu.Check("&Light")

    } else if (currentTheme = "System") {
        ; Current theme is System

        ; Check System item
        themeMenu.Check("&System")

    } else {
        ; Current theme is Dark OU any other value

        ; Check Dark item
        themeMenu.Check("&Dark")
    }
}

onThemeMenuSelect(newTheme) {
    global gTHEME := newTheme

    ; Update menu checkmarks
    if (IsSet(gThemeMenu)) {
        ; Theme menu is set

        ; Update checkmarks
        updateThemeMenuChecks(gThemeMenu)

    } else {
        ; Theme menu is not set

        ; NTD
    }

    ; Persist theme preference to Preferences.ahk
    persistThemePreference(newTheme)

    ; Update context menu dark/light mode
    effectiveTheme := getEffectiveTheme()
    if (effectiveTheme = "Light") {
        ; Effective theme is Light

        ; Set menu theme to Light (0)
        Dark_Menu.SetMode(0)

    } else {
        ; Effective theme is not Light (Dark)

        ; Set menu theme to Dark (1)
        Dark_Menu.SetMode(1)
    }

    ; Update active InputWindow instances in MainScript
    if (IsSet(customPromptInputWindow)) {
        ; customPromptInputWindow is set

        ; Apply theme
        customPromptInputWindow.applyTheme()

    } else {
        ; customPromptInputWindow is not set

        ; NTD
    }

    if (IsSet(sendToPromptNameInputWindow)) {
        ; sendToPromptNameInputWindow is set

        ; Apply theme
        sendToPromptNameInputWindow.applyTheme()

    } else {
        ; sendToPromptNameInputWindow is not set

        ; NTD
    }

    if (IsSet(sendToAllModelsInputWindow)) {
        ; sendToAllModelsInputWindow is set

        ; Apply theme
        sendToAllModelsInputWindow.applyTheme()

    } else {
        ; sendToAllModelsInputWindow is not set

        ; NTD
    }

    if (IsSet(sendToUniqueIDInputWindow)) {
        ; sendToUniqueIDInputWindow is set

        ; Apply theme
        sendToUniqueIDInputWindow.applyTheme()

    } else {
        ; sendToUniqueIDInputWindow is not set

        ; NTD
    }

    ; Encode theme: 1 = Dark, 2 = Light, 3 = System
    themeCode := (newTheme = "Light") ? 2 : ((newTheme = "System") ? 3 : 1)

    ; Notify all active Response Windows of theme change
    for uniqueID, responseWindowParams in getMapId2ActiveResponseWindowParams() {
        if (responseWindowParams.Has("hWnd") && WinExist("ahk_id " responseWindowParams["hWnd"])) {
            ; Active Response Window exists

            ; Post theme change message with themeCode in lParam
            CustomMessages.notifyResponseWindowState(CustomMessages.WM_THEME_CHANGED, 
                                                     uniqueID, 
                                                     themeCode, 
                                                     responseWindowParams["hWnd"])

        } else {
            ; Active Response Window does not exist

            ; NTD
        }
    }
}


; ----------------------------------------------------------------------------------------
; Utility for menus
; ----------------------------------------------------------------------------------------

;
; Send message to a single session by uniqueID
;
sendToUniqueIDSession(uniqueID, *) {

    managePromptState("uniqueIDToSendMessageTo", "set", uniqueID)

    ; Bring the target window to foreground
    managePromptWindows("activate", uniqueID)

    selectedText := getSelectedText()

    ; Show InputWindow
    sendToUniqueIDInputWindow.showInputWindow(  , 
                                                "Send message to session", 
                                                "ahk_id " sendToUniqueIDInputWindow.guiObj.hWnd,
                                                ,
                                                selectedText
                                            )
}

sendToAllOpenWithSamePromptName(uniqueID, promptName, *) {

    promptsList := managePromptState("prompts", "get")

    ; Find the prompt with the matching promptName
    for _, prompt in promptsList {

        ; Check if the prompt has the same name as the one we're looking for
        if (HasProp(prompt, "promptName") && (prompt.promptName = promptName)) {
            selectedPrompt := prompt
            break
        }
    }

    managePromptState("promptNameToSendMessageTo", "set", promptName)

    ; Check if the prompt has skipConfirmation property and set accordingly
    sendToPromptNameInputWindow.setSkipConfirmation(selectedPrompt.HasProp("skipConfirmation") ? selectedPrompt.skipConfirmation : false)
    
    menuLabel := promptName

    ; Display InputWindow with title indicating Prompt Name to send to
    selectedText := getSelectedText()
    sendToPromptNameInputWindow.showInputWindow( , 
                                                "Send message to all : " menuLabel, 
                                                "ahk_id " sendToPromptNameInputWindow.guiObj.hWnd,
                                                 ,
                                                  selectedText
                                                )
}


;
; Generic function to perform an operation on prompt windows
;
; Parameters:
; - operation (activate, minimize, close): The operation to perform
; - uniqueID_or_promptName: If a number, it's a uniqueID for a single window. If a string, it's a promptName or "All"
;
managePromptWindows(operation, uniqueID_or_promptName, *) {

    ; Create a list of window handles that match our criteria
    hWndsToManage := []

    ; Check if the second param is a uniqueID (number) or a promptName
    if (uniqueID_or_promptName = "All") {
        ; Multiple windows by promptName or "All"

        ; Add all open Response Windows
        for uniqueID, activeResponseWindowParams in getMapId2ActiveResponseWindowParams() {
            hWndsToManage.Push(activeResponseWindowParams["hWnd"])
        }
    } else {
        ; Single window by uniqueID

        if getMapId2ActiveResponseWindowParams().Has(uniqueID_or_promptName) {
            ; Add opened Response Window whose uniqueID matches

            hWndsToManage.Push(getMapId2ActiveResponseWindowParams()[uniqueID_or_promptName]["hWnd"])
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


openHelpPdf() {
    Run(A_ScriptDir "\README.pdf")
}

startSelectFirstMenuItemProcess() {

    ; Launch a secondary script to simulate Down key press to select 
    ; the first menu item.
    ; This method is mandatory because .show() blocks execution of all threads in the script
    ; Only another Process can interact with the GUI while the main script is paused
    RunScript("Lib\simulate_select.ahk")
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


addToPromptMenu(promptMenu, prompt, index) {

    if (hasAllNeededForMenu(prompt)) {
        ; There is all needed info

        if (isMenuLineSeparator(prompt)) {
            ; Line separator

            ; Line separator before Tags menu
            promptMenu.Add()

        } else {
            ; Not a line separator

            ; Add directly to menu and continue
            promptMenu.Add(prompt.menuText, promptMenuHandler.Bind(index))
        }
        } else {
            ; There is NO menuText

            MsgBox("SYNTAX ERROR: In Prompt n° " index)
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

    if (isApplicationLauncher(selectedPrompt)) {
        ; Shall launch an Application

        ; Launch App defined by selectedPrompt
        launchApp(selectedPrompt)

    } else {
        ; Shall call a LLM

        ; Determine if we should show the prompt input window based on the prompt properties
        shallShowPromptInputWindow :=   (   selectedPrompt.HasProp("isCustomPrompt") 
                                            && selectedPrompt.isCustomPrompt
                                        )
    
        ; Invert if CTRL is pressed
        shallShowPromptInputWindow := ctrlPressed ? !shallShowPromptInputWindow : shallShowPromptInputWindow
    
        selectedText := getSelectedText()
    
        if (shallShowPromptInputWindow) or (selectedText == "") {
            ; Selected prompt ask for a custom prompt or no text is selected
    
            ; Save the prompt for future reference in customPromptSendButtonAction(*)
            managePromptState("selectedPrompt", "set", selectedPrompt)
    
            ; Set skipConfirmation property based on the prompt
            ; TODO TW M 2026_06_24 : Remplacer les .HasProp par .Has
            customPromptInputWindow.setSkipConfirmation(selectedPrompt.HasProp("skipConfirmation") ? selectedPrompt.skipConfirmation : false)
    
            ; Show InputWindow for custom prompt
            customPromptInputWindow.showInputWindow(selectedPrompt.HasProp("customPromptInitialMessage") ? selectedPrompt.customPromptInitialMessage : unset
                                                  , selectedPrompt.promptName
                                                  , "ahk_id " customPromptInputWindow.guiObj.hWnd
                                                  , selectedPrompt.HasProp("isCustomPromptCursorAtEnd") ? selectedPrompt.isCustomPromptCursorAtEnd : true
                                                  , selectedText)
    
        } else {
            ; Selected prompt does NOT ask for a custom prompt & there is a selected text
    
            ; Process initial request with the selected prompt details
            makeParamFilesAndStartResponseWindow(   selectedPrompt.promptName, 
                                                    selectedPrompt.menuText, 
                                                    selectedPrompt.systemPrompt,
                                                    selectedPrompt.APIModels, 
                                                    selectedPrompt.HasProp("copyAsMarkdown") && selectedPrompt.copyAsMarkdown,
                                                    selectedPrompt.HasProp("isAutoPaste") && selectedPrompt.isAutoPaste,
                                                    selectedPrompt.HasProp("skipConfirmation") && selectedPrompt.skipConfirmation,
                                                    selectedText
            )
        }
    }
}

launchApp(selectedPrompt) {

    if (isApplicationLauncher(selectedPrompt)) {
        ; Shall launch an Application

        appWorkingDir := ""

        if selectedPrompt.HasProp("appWorkingDir") {

            appWorkingDir := selectedPrompt.appWorkingDir
        } else {

            ; NTD
        }

        appWindowLaunchMode := ""

        if selectedPrompt.HasProp("appWindowLaunchMode") {

            appWindowLaunchMode := selectedPrompt.appWindowLaunchMode
        } else {

            ; NTD
        }

        try {
            ; OutputDebug("appWorkingDir => " appWorkingDir)
            ; OutputDebug("appFullPath => " selectedPrompt.appFullPath)
            ; OutputDebug("appParams => " selectedPrompt.appParams)
            
            appExpandedAppCmdLine := ExpandEnvVars(selectedPrompt.appFullPath " " selectedPrompt.appParams)
            appExpandedWorkingDir := ExpandEnvVars(appWorkingDir)

            Run(  appExpandedAppCmdLine
                , appExpandedWorkingDir
                , appWindowLaunchMode
                , &OutputVarPID)
    
            ; OutputDebug("OutputVarPID => " OutputVarPID)

        } catch Error as err {
            
            MsgBox( "Error while running : `n`n" appExpandedAppCmdLine "`n`nin directory :`n`n" appExpandedWorkingDir "`n`nError msg : `n`n" err.Message
                    ,"Launch Application"
                    , "Iconx")

        } else {
            ; NTD

        } finally {
            ; NTD

        }

    } else {

        MsgBox("This prompt is not an Application Launcher. Nothing has been launched.")
    }
}


hasAllNeededForMenu(prompt) {

    return hasAllNeededForPromptMenu(prompt) 
        or hasAllNeededForAppLauncherMenu(prompt)
        or isMenuLineSeparator(prompt)
}


isMenuLineSeparator(prompt) {

    return prompt.HasProp("promptName") && prompt.promptName && prompt.promptName == MENU_LINE_SEPARATOR
}

isApplicationLauncher(prompt) {

    return prompt.HasProp("isApplicationLauncher") && prompt.isApplicationLauncher && prompt.isApplicationLauncher = true
}

hasAllNeededForPromptMenu(prompt) {

    ; Check if all needed properties are present and not
    hasPromptName := prompt.HasProp("promptName") && prompt.promptName && prompt.promptName != ""
    hasMenuText := prompt.HasProp("menuText") && prompt.menuText && prompt.menuText != ""
    hasSystemPrompt := prompt.HasProp("systemPrompt") && prompt.systemPrompt && prompt.systemPrompt != ""
    hasAPIModels := prompt.HasProp("APIModels") && prompt.APIModels && prompt.APIModels != ""

    hasAllNeeded := hasPromptName && hasMenuText && hasSystemPrompt && hasAPIModels

    return hasAllNeeded
}

hasAllNeededForAppLauncherMenu(prompt) {

    ; Check if all needed properties are present and not

    hasAppFullPath := prompt.HasProp("appFullPath") && prompt.appFullPath && prompt.appFullPath != ""
    ; hasAppParams := prompt.HasProp("appParams") && prompt.appParams && prompt.appParams != ""

    hasAllNeeded := isApplicationLauncher(prompt) && hasAppFullPath

    return hasAllNeeded
}


buildMenuItemLabel(promptName, uniqueID, userPrompt := "", isFavorite := false, isActive := false) {
    
    favoritePrefix := isFavorite ? "★ " : "☆ "
    activePrefix := isActive ? "✓ " : "    "

    if (userPrompt = "") {
        return activePrefix favoritePrefix promptName " (" uniqueID ")"
    }
    
    return activePrefix favoritePrefix uniqueID " : " promptName " - `"" SubStr(userPrompt, 1, 50) "`""
}


;
; Replaces Environment Variables in a string with their values
;
; Ex. "C:\NoSave\%USERNAME%\toto" => "C:\NoSave\dupont\toto"
;
ExpandEnvVars(Str)
{
    spo := 1
    out := ""
    while (fpo:=RegexMatch(Str, "(%(.*?)%)|``(.)", &m, spo))
    {
        out .= SubStr(Str, spo, fpo-spo)
        spo := fpo + StrLen(m[0])
        if (m[1]) {

            out .= EnvGet(m[2])
            
        } else {

            out .= m[3]
        }
    }
    return out SubStr(Str, spo)
}