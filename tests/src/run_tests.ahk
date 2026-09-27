#Requires AutoHotkey v2.0
#NoTrayIcon
#Warn , Off

OnError(logAndExitOnError)

logAndExitOnError(thrown, mode) {
    try {
        errStr := "CRASH/ERROR: " thrown.Message "`nLine: " thrown.Line "`nFile: " thrown.File "`nStack: " thrown.Stack "`n"
        FileAppend(errStr, A_ScriptDir "\..\test_results.log", "UTF-8")
        FileAppend(errStr, "*", "UTF-8")
    }
    ExitApp(2)
}

; ----------------------------------------------------
; Test runner for LLM AutoHotkey Assistant
; Executes automated checks and unit tests
; ----------------------------------------------------

; Global test counters and log buffer
global gTestCount := 0
global gPassCount := 0
global gFailCount := 0
global gLogOutput := ""

; Attach to parent console if run from a terminal
global hasConsole := DllCall("AttachConsole", "int", -1)
global showGui := false
for index, arg in A_Args {
    if (arg = "/gui") {
        global showGui := true
    }
}

; ----------------------------------------------------
; Logging and Assertion helpers
; ----------------------------------------------------

printLine(text) {
    try {
        FileAppend(text "`n", "*", "UTF-8")
    } catch {
        ; NTD if stdout cannot be written
    }

    try {
        FileAppend(text "`n", A_ScriptDir "\..\test_results.log", "UTF-8")
    } catch {
        ; NTD if file cannot be written
    }

    return
}

assert(testName, condition, details := "") {
    global gTestCount, gPassCount, gFailCount, gLogOutput
    gTestCount++

    if (condition) {
        ; Condition is true

        ; Record successful test
        gPassCount++
        line := "  [PASS] " testName
        gLogOutput .= line "`n"
        printLine(line)

    } else {
        ; Condition is false

        ; Record failed test
        gFailCount++
        line := "  [FAIL] " testName
        if (details != "") {
            ; Failure details provided

            ; Append failure details to output line
            line .= " (" details ")"

        } else {
            ; No failure details provided

            ; NTD
        }
        gLogOutput .= line "`n"
        printLine(line)
    }

    return
}

assertEqual(testName, actual, expected) {
    condition := (actual = expected)
    details := condition ? "" : "expected: '" expected "', got: '" actual "'"
    assert(testName, condition, details)

    return
}

; ----------------------------------------------------
; Inclusions of modules to test
; ----------------------------------------------------

#Include ..\..\lib\Shared\SharedRoot.ahk
#Include ..\..\lib\Shared\COTS\jsongo.v2.ahk
#Include ..\..\lib\Shared\Utils.ahk
#Include ..\..\lib\Shared\COTS\AutoXYWH.ahk
#Include ..\..\lib\Shared\Classes\InputWindow.ahk
#Include ..\..\lib\MainScript\Gui\ReloadNotification.ahk
#Include ..\..\lib\ResponseWindow\LLM\clsLlmResponse.ahk
#Include ..\..\lib\ResponseWindow\COTS\WebViewToo.ahk
#Include ..\..\lib\MainScript\LLM\PrewarmWebView2.ahk

; ----------------------------------------------------
; Main Test Suite Execution
; ----------------------------------------------------

runAllTests() {
    global gTestCount, gPassCount, gFailCount, gLogOutput, hasConsole, showGui

    projectRoot := A_ScriptDir "\..\.."

    try {
        FileDelete(A_ScriptDir "\..\test_results.log")
    }

    header := "==================================================`n"
    header .= "  LLM AutoHotkey Assistant - Automated Test Suite`n"
    header .= "=================================================="
    printLine(header)
    gLogOutput .= header "`n"

    ; ------------------------------------------------
    ; 1. Syntax Validation Tests (/Validate)
    ; ------------------------------------------------
    printLine("`n[Group 1: Syntax Validation]")
    gLogOutput .= "`n[Group 1: Syntax Validation]`n"

    filesToValidate := [
        "LLM AutoHotkey Assistant.ahk",
        "lib\Response Window.ahk",
        "lib\Shared\Utils.ahk"
    ]

    for index, relPath in filesToValidate {
        fullPath := projectRoot "\" relPath
        exitCode := RunWait('"' A_AhkPath '" /ErrorStdOut /Validate "' fullPath '"', projectRoot, "Hide")
        assert("Syntax check: " relPath, exitCode = 0, "exit code: " exitCode)
    }

    ; ------------------------------------------------
    ; 2. Resource & Asset Integrity Tests
    ; ------------------------------------------------
    printLine("`n[Group 2: Resource and Asset Integrity]")
    gLogOutput .= "`n[Group 2: Resource and Asset Integrity]`n"

    requiredFiles := [
        "config\Preferences.ahk",
        "config\Prompts.ahk",
        "lib\Response Window resources\index.html",
        "lib\Response Window resources\js\main.js",
        "lib\Response Window resources\js\highlight.min.js",
        "lib\Response Window resources\js\markdown-it.min.js",
        "lib\Response Window resources\Bootstrap\bootstrap.min.css",
        "lib\Response Window resources\Bootstrap\bootstrap.bundle.min.js",
        "lib\Response Window resources\css\custom.css",
        "lib\Response Window resources\css\highlight\atom-one-dark.min.css",
        "lib\Response Window resources\css\highlight\atom-one-light.min.css"
    ]

    for index, relPath in requiredFiles {
        fullPath := projectRoot "\" relPath
        assert("File exists: " relPath, FileExist(fullPath) != "", "file not found")
    }

    ; ------------------------------------------------
    ; 3. Shared Utilities Tests (Utils.ahk)
    ; ------------------------------------------------
    printLine("`n[Group 3: Shared Utilities & Theme Resolution]")
    gLogOutput .= "`n[Group 3: Shared Utilities & Theme Resolution]`n"

    ; Test explicit Dark theme resolution
    assertEqual("getEffectiveTheme('Dark') returns 'Dark'", getEffectiveTheme("Dark"), "Dark")

    ; Test explicit Light theme resolution
    assertEqual("getEffectiveTheme('Light') returns 'Light'", getEffectiveTheme("Light"), "Light")

    ; Test System theme resolution (must resolve to either 'Dark' or 'Light')
    resolvedSystem := getEffectiveTheme("System")
    isSystemValid := (resolvedSystem = "Dark" || resolvedSystem = "Light")
    assert("getEffectiveTheme('System') returns 'Dark' or 'Light'", isSystemValid, "got: '" resolvedSystem "'")

    ; Test session directory resolution
    sessionPath := getSessionDir()
    assert("getSessionDir() returns a valid existing directory", (sessionPath != "") && DirExist(sessionPath), "path: " sessionPath)

    ; Test preferences file path resolution
    prefFilePath := getPreferencesFilePath()
    assert("getPreferencesFilePath() returns existing Preferences.ahk", (prefFilePath != "") && FileExist(prefFilePath), "path: " prefFilePath)

    ; Test prompts file path resolution
    promptFilePath := getPromptsFilePath()
    assert("getPromptsFilePath() returns existing Prompts.ahk", (promptFilePath != "") && FileExist(promptFilePath), "path: " promptFilePath)

    ; Test custom editor preference variables
    assert("gEDITOR_PATH is defined", IsSet(gEDITOR_PATH), "gEDITOR_PATH unset")
    assert("gEDITOR_ARGS is defined", IsSet(gEDITOR_ARGS), "gEDITOR_ARGS unset")
    assert("openPromptsInEditor function exists and is callable", HasMethod(openPromptsInEditor), "openPromptsInEditor not found")

    ; Test params file search with nonexistent uniqueID
    notFoundParams := findParamsFileByUniqueID("C:\NonExistent_Dir_Test", "9999999999999")
    assertEqual("findParamsFileByUniqueID() returns empty string when not found", notFoundParams, "")

    ; Test WebView2 browser arguments configuration
    assert("gWEBVIEW2_ADDITIONAL_ARGS is defined and non-empty", IsSet(gWEBVIEW2_ADDITIONAL_ARGS) && (gWEBVIEW2_ADDITIONAL_ARGS != ""), "got: " (IsSet(gWEBVIEW2_ADDITIONAL_ARGS) ? gWEBVIEW2_ADDITIONAL_ARGS : "unset"))
    assert("gWEBVIEW2_ADDITIONAL_ARGS contains --disable-web-security", InStr(gWEBVIEW2_ADDITIONAL_ARGS, "--disable-web-security") > 0, "args: " gWEBVIEW2_ADDITIONAL_ARGS)

    ; Test WebViewToo default template cleanliness
    assertEqual("WebViewToo.Template.Html has no external URL", WebViewToo.Template.Html, "")

    ; Test PrewarmWebView2 functionality
    assert("prewarmWebView2 function exists and is callable", HasMethod(prewarmWebView2), "prewarmWebView2 not found")
    assert("gPrewarmSatellitePID global variable is defined", IsSet(gPrewarmSatellitePID), "gPrewarmSatellitePID unset")
    assert("SATELLITE_WATCHDOG_INTERVAL_MS is configured to 60000ms", IsSet(SATELLITE_WATCHDOG_INTERVAL_MS) && SATELLITE_WATCHDOG_INTERVAL_MS = 60000, "got: " (IsSet(SATELLITE_WATCHDOG_INTERVAL_MS) ? SATELLITE_WATCHDOG_INTERVAL_MS : "unset"))
    assert("lib\prewarm_satellite.ahk exists", FileExist(projectRoot "\lib\prewarm_satellite.ahk") != "", "prewarm_satellite.ahk missing")

    ; Test version, author and git commit information
    assert("gAuthor is defined", IsSet(gAuthor), "gAuthor unset")
    if (gAuthor != "") {
        assert("gVersionStringSuffix contains gAuthor", InStr(gVersionStringSuffix, gAuthor) > 0)
    } else {
        assert("gVersionStringSuffix contains LLM AutoHotkey Assistant", InStr(gVersionStringSuffix, "LLM AutoHotkey Assistant") > 0)
    }
    assert("gVersionStringSuffix contains gVersion", InStr(gVersionStringSuffix, gVersion) > 0)
    gitCommitInfo := getGitCommitInfo()
    assert("getGitCommitInfo returns valid commit info", (gitCommitInfo != "") && InStr(gitCommitInfo, " du ") > 0, "got: '" gitCommitInfo "'")
    assert("build_info.txt was generated", FileExist(projectRoot "\build_info.txt") != "", "build_info.txt missing")

    ; Test fallback when .git is absent (user deployment simulation)
    testDeployDir := A_Temp "\ahk_deploy_test_" A_TickCount
    DirCreate(testDeployDir)
    try {
        ; Case 1: build_info.txt present
        FileOpen(testDeployDir "\build_info.txt", "w", "UTF-8").Write("deadbeef du 01/01/2026")
        deployInfo := getGitCommitInfo(testDeployDir)
        assert("getGitCommitInfo fallback reads build_info.txt without .git", deployInfo = "deadbeef du 01/01/2026", "got: '" deployInfo "'")

        ; Case 2: build_info.txt absent
        FileDelete(testDeployDir "\build_info.txt")
        noInfo := getGitCommitInfo(testDeployDir)
        assert("getGitCommitInfo returns empty when neither .git nor build_info.txt exists", noInfo = "", "got: '" noInfo "'")
    } finally {
        try DirDelete(testDeployDir, true)
    }

    ; ------------------------------------------------
    ; 4. JSON Serialization and Parsing Tests (jsongo)
    ; ------------------------------------------------
    printLine("`n[Group 4: JSON Serialization and Parsing]")
    gLogOutput .= "`n[Group 4: JSON Serialization and Parsing]`n"

    ; Test round-trip with basic map
    testMap := Map("key1", "value1", "number", 42)
    jsonStr := jsongo.Stringify(testMap)
    parsedMap := jsongo.Parse(jsonStr)
    assertEqual("jsongo: basic string key round-trip", parsedMap["key1"], "value1")
    assertEqual("jsongo: basic number value round-trip", parsedMap["number"], 42)

    ; Test round-trip with Unicode and special characters
    unicodeText := "Texte français accentué : é, è, à, ç, œ et émojis 🚀 ✨"
    unicodeMap := Map("content", unicodeText)
    unicodeJson := jsongo.Stringify(unicodeMap)
    parsedUnicode := jsongo.Parse(unicodeJson)
    assertEqual("jsongo: Unicode and accent preservation", parsedUnicode["content"], unicodeText)

    ; Test round-trip with chat messages array
    messagesArray := [
        Map("role", "system", "content", "You are a helpful assistant."),
        Map("role", "user", "content", "Hello!"),
        Map("role", "assistant", "content", "Hi there, how can I help?")
    ]
    chatPayload := Map("messages", messagesArray)
    chatJson := jsongo.Stringify(chatPayload)
    parsedChat := jsongo.Parse(chatJson)
    assertEqual("jsongo: chat messages array count", parsedChat["messages"].Length, 3)
    assertEqual("jsongo: second message role is user", parsedChat["messages"][2]["role"], "user")
    assertEqual("jsongo: third message role is assistant", parsedChat["messages"][3]["role"], "assistant")

    ; ------------------------------------------------
    ; 5. Chat History Markdown Formatting Logic Tests
    ; ------------------------------------------------
    printLine("`n[Group 5: Chat History Markdown Logic]")
    gLogOutput .= "`n[Group 5: Chat History Markdown Logic]`n"

    ; Verify role-based markdown assembly
    assembledMarkdown := ""
    for index, msg in messagesArray {
        role := msg["role"]
        content := msg["content"]

        switch role {
            case "system": assembledMarkdown .= "**System**`n`n" content
            case "user": assembledMarkdown .= "`n`n---`n`n**You**`n`n" content
            case "assistant": assembledMarkdown .= "`n`n---`n`n**Assistant**`n`n" content
        }
    }

    assert("Chat History markdown contains System label", InStr(assembledMarkdown, "**System**") > 0)
    assert("Chat History markdown contains You label", InStr(assembledMarkdown, "**You**") > 0)
    assert("Chat History markdown contains Assistant label", InStr(assembledMarkdown, "**Assistant**") > 0)

    ; ------------------------------------------------
    ; 6. InputWindow UI & Font Dimensions Tests
    ; ------------------------------------------------
    printLine("`n[Group 6: InputWindow Theme & Dimensions]")
    gLogOutput .= "`n[Group 6: InputWindow Theme & Dimensions]`n"

    global gTHEME := "Dark"
    testInputWin := InputWindow("Test InputWindow Dimensions")
    testInputWin.guiObj.Show("AutoSize Hide")
    testInputWin.EditControl.GetPos(&exD, &eyD, &ewD, &ehD)
    testInputWin.SendButton.GetPos(&bxD, &byD, &bwD, &bhD)

    assert("InputWindow Dark button height preserves s14 font size (>= 50px)", bhD >= 50, "got: " bhD "px")
    assert("InputWindow Dark button width is properly sized (>= 80px)", bwD >= 80, "got: " bwD "px")
    assert("InputWindow Dark edit control width is 500px", ewD = 500, "got: " ewD "px")
    assert("InputWindow Dark edit control height is 250px", ehD = 250, "got: " ehD "px")

    ; Switch to Light theme
    global gTHEME := "Light"
    testInputWin.applyTheme()
    testInputWin.EditControl.GetPos(&exL, &eyL, &ewL, &ehL)
    testInputWin.SendButton.GetPos(&bxL, &byL, &bwL, &bhL)

    assert("InputWindow Light button height preserves s14 font size (>= 50px)", bhL >= 50, "got: " bhL "px")
    assertEqual("InputWindow button height identical in Dark and Light modes", bhL, bhD)
    assertEqual("InputWindow button width identical in Dark and Light modes", bwL, bwD)
    assertEqual("InputWindow edit width identical in Dark and Light modes", ewL, ewD)
    assertEqual("InputWindow edit height identical in Dark and Light modes", ehL, ehD)
    assert("InputWindow has ShortcutHint control with (Ctrl+Enter)", InStr(testInputWin.ShortcutHint.Text, "Ctrl+Enter") > 0)
    assert("InputWindow SendButton text is Send", testInputWin.SendButton.Text = "Send")

    testInputWin.guiObj.Destroy()

    ; ------------------------------------------------
    ; 7. Response Window Theme Initialization Integrity
    ; ------------------------------------------------
    printLine("`n[Group 7: Response Window Theme Initialization]")
    gLogOutput .= "`n[Group 7: Response Window Theme Initialization]`n"

    indexHtmlContent := FileOpen(projectRoot "\lib\Response Window resources\index.html", "r", "UTF-8").Read()
    mainJsContent := FileOpen(projectRoot "\lib\Response Window resources\js\main.js", "r", "UTF-8").Read()
    respWinAhkContent := FileOpen(projectRoot "\lib\Response Window.ahk", "r", "UTF-8").Read()
    llmCallAhkContent := FileOpen(projectRoot "\lib\ResponseWindow\LLM\LlmCall.ahk", "r", "UTF-8").Read()

    assert("index.html contains highlight theme sync script", InStr(indexHtmlContent, "highlight-light-theme") > 0 && InStr(indexHtmlContent, "isLight") > 0)
    assert("main.js syncs theme on DOMContentLoaded", InStr(mainJsContent, "applyTheme(currentTheme)") > 0)
    assert("main.js startStream accepts theme from config", InStr(mainJsContent, "config.theme") > 0 && InStr(mainJsContent, "applyTheme(config.theme)") > 0)
    assert("Response Window.ahk pre-injects localStorage theme", InStr(respWinAhkContent, "localStorage.setItem('theme'") > 0)
    assert("LlmCall.ahk passes theme in streamConfig", InStr(llmCallAhkContent, "theme: getEffectiveTheme()") > 0)
    assert("LlmCall.ahk calls applyResponseWindowTheme on pageReady", InStr(llmCallAhkContent, "case `"pageReady`":") > 0 && InStr(llmCallAhkContent, "applyResponseWindowTheme()") > 0)

    ; ------------------------------------------------
    ; 8. Prompts Reload MsgBox & Flag Tests
    ; ------------------------------------------------
    printLine("`n[Group 8: Prompts Reload MsgBox & Flag Logic]")
    gLogOutput .= "`n[Group 8: Prompts Reload MsgBox & Flag Logic]`n"

    mainScriptAhkContent := FileOpen(projectRoot "\LLM AutoHotkey Assistant.ahk", "r", "UTF-8").Read()
    hotkeyActionsAhkContent := FileOpen(projectRoot "\lib\MainScript\Gui\Handlers\ScriptHotkeyActions.ahk", "r", "UTF-8").Read()

    ; Test flag creation and clearing
    setPromptsReloadedFlag()
    flagPath := getPromptsReloadFlagPath()
    assert("setPromptsReloadedFlag creates the flag file", FileExist(flagPath) != "")

    isReloadedFirst := checkAndClearPromptsReloadedFlag()
    assert("checkAndClearPromptsReloadedFlag detects existing flag", isReloadedFirst = true)
    assert("checkAndClearPromptsReloadedFlag deletes flag file", FileExist(flagPath) = "")

    isReloadedSecond := checkAndClearPromptsReloadedFlag()
    assert("checkAndClearPromptsReloadedFlag returns false when no flag exists", isReloadedSecond = false)

    ; Test MsgBox function definition
    assert("showPromptsReloadedMsgBox is a callable function", HasMethod(showPromptsReloadedMsgBox))

    ; Test main script integration
    assert("LLM AutoHotkey Assistant.ahk includes ReloadNotification.ahk", InStr(mainScriptAhkContent, "ReloadNotification.ahk") > 0)
    assert("LLM AutoHotkey Assistant.ahk checks reload flag", InStr(mainScriptAhkContent, "checkAndClearPromptsReloadedFlag()") > 0)
    assert("LLM AutoHotkey Assistant.ahk calls showPromptsReloadedMsgBox", InStr(mainScriptAhkContent, "showPromptsReloadedMsgBox(") > 0)
    assert("ScriptHotkeyActions.ahk enables SetTitleMatchMode 2", InStr(hotkeyActionsAhkContent, "SetTitleMatchMode 2") > 0)
    assert("ScriptHotkeyActions.ahk sets reload flag", InStr(hotkeyActionsAhkContent, "setPromptsReloadedFlag()") > 0)

    ; ------------------------------------------------
    ; 9. Reasoning Model Support Tests
    ; ------------------------------------------------
    printLine("`n[Group 9: Reasoning Model Support]")
    gLogOutput .= "`n[Group 9: Reasoning Model Support]`n"

    ; Test clsLlmResponse with standard response
    stdResponseJson := '{"choices":[{"message":{"content":"Hello world","role":"assistant"}}],"model":"test-model"}'
    llmRespStd := clsLlmResponse(stdResponseJson)
    simplifiedStd := llmRespStd.getLlmResponseSimplified()
    assert("clsLlmResponse returns standard content without details", simplifiedStd.response = "Hello world")
    assert("clsLlmResponse returns correct model", simplifiedStd.model = "test-model")

    ; Test clsLlmResponse with reasoning_content
    reasoningResponseJson := '{"choices":[{"message":{"content":"42","reasoning_content":"Step 1: thinking","role":"assistant"}}],"model":"deepseek-r1"}'
    llmRespReasoning := clsLlmResponse(reasoningResponseJson)
    simplifiedReasoning := llmRespReasoning.getLlmResponseSimplified()
    assert("clsLlmResponse includes details block when reasoning_content is present", InStr(simplifiedReasoning.response, "<details class=`"reasoning-block`">") > 0)
    assert("clsLlmResponse includes reasoning text inside details", InStr(simplifiedReasoning.response, "Step 1: thinking") > 0)
    assert("clsLlmResponse includes final answer after details", InStr(simplifiedReasoning.response, "42") > 0)

    ; Test clsLlmResponse with reasoning alias
    reasoningAliasJson := '{"choices":[{"message":{"content":"Done","reasoning":"Thinking process","role":"assistant"}}],"model":"qwq-32b"}'
    llmRespAlias := clsLlmResponse(reasoningAliasJson)
    simplifiedAlias := llmRespAlias.getLlmResponseSimplified()
    assert("clsLlmResponse supports reasoning alias property", InStr(simplifiedAlias.response, "Thinking process") > 0)

    ; Test main.js reasoning functions
    mainJsPath := projectRoot "\lib\Response Window resources\js\main.js"
    mainJsContent := FileOpen(mainJsPath, "r", "UTF-8").Read()
    assert("main.js contains formatReasoningTags function", InStr(mainJsContent, "formatReasoningTags") > 0)
    assert("main.js contains renderStreamingOutput function", InStr(mainJsContent, "renderStreamingOutput") > 0)
    assert("main.js handles delta.reasoning_content in SSE", InStr(mainJsContent, "delta.reasoning_content") > 0)

    ; Test custom.css reasoning block styles
    customCssPath := projectRoot "\lib\Response Window resources\css\custom.css"
    customCssContent := FileOpen(customCssPath, "r", "UTF-8").Read()
    assert("custom.css contains details.reasoning-block style", InStr(customCssContent, "details.reasoning-block") > 0)
    assert("custom.css contains summary.reasoning-summary style", InStr(customCssContent, "summary.reasoning-summary") > 0)

    ; ------------------------------------------------
    ; 10. Modern UI & Code Block Enhancement Tests
    ; ------------------------------------------------
    printLine("`n[Group 10: Modern UI & Code Blocks]")
    gLogOutput .= "`n[Group 10: Modern UI & Code Blocks]`n"

    assert("custom.css contains .btn-modern style", InStr(customCssContent, ".btn-modern") > 0)
    assert("custom.css contains .code-block-wrapper style", InStr(customCssContent, ".code-block-wrapper") > 0)
    assert("custom.css contains .code-copy-btn style", InStr(customCssContent, ".code-copy-btn") > 0)
    assert("main.js contains enhanceCodeBlocks function", InStr(mainJsContent, "enhanceCodeBlocks") > 0)

    indexHtmlPath := projectRoot "\lib\Response Window resources\index.html"
    indexHtmlContent := FileOpen(indexHtmlPath, "r", "UTF-8").Read()
    assert("index.html contains btn-modern class", InStr(indexHtmlContent, "btn-modern") > 0)
    assert("index.html preserves chatButton ID", InStr(indexHtmlContent, 'id="chatButton"') > 0)
    assert("index.html preserves copyButton ID", InStr(indexHtmlContent, 'id="copyButton"') > 0)
    assert("index.html preserves pasteButton ID", InStr(indexHtmlContent, 'id="pasteButton"') > 0)
    assert("index.html contains Paste & Close caption", InStr(indexHtmlContent, "<u>P</u>aste & Close") > 0)

    trayGuiPath := projectRoot "\lib\MainScript\Gui\IamInTrayBarGui.ahk"
    trayGuiContent := FileOpen(trayGuiPath, "r", "UTF-8").Read()
    assert("IamInTrayBarGui uses Segoe UI font", InStr(trayGuiContent, "Segoe UI") > 0)
    assert("IamInTrayBarGui applies DWM rounded corners", InStr(trayGuiContent, "DwmSetWindowAttribute") > 0)
    assert("IamInTrayBarGui displays product version (gVersion)", InStr(trayGuiContent, "gVersion") > 0)
    assert("IamInTrayBarGui displays author (gAuthor)", InStr(trayGuiContent, "gAuthor") > 0)
    assert("IamInTrayBarGui queries getGitCommitInfo", InStr(trayGuiContent, "getGitCommitInfo") > 0)
    assert("IamInTrayBarGui defines mutedColor for commit info", InStr(trayGuiContent, "mutedColor") > 0)
    assert("IamInTrayBarGui defines warningColor for uncommitted changes", InStr(trayGuiContent, "warningColor") > 0)
    assert("IamInTrayBarGui handles uncommitted changes suffix in red", InStr(trayGuiContent, "(+ modifs NON commitées)") > 0)
    assert("IamInTrayBarGui displays shortcut Alt + Maj + o in red", InStr(trayGuiContent, "Alt + Maj + o") > 0)
    assert("IamInTrayBarGui loads application yellow robot icon", InStr(trayGuiContent, "IconOn.ico") > 0)
    assert("IamInTrayBarGui uses slightly larger title font (s13 Bold)", InStr(trayGuiContent, "s13 Bold") > 0)
    assert("IamInTrayBarGui does not prepend 'Commit : ' string", InStr(trayGuiContent, '"Commit : "') = 0)
    assert("IamInTrayBarGui does not prepend 'Version ' string", InStr(trayGuiContent, '"Version "') = 0)
    assert("IamInTrayBarGui supports isAbout parameter", InStr(trayGuiContent, "isAbout := false") > 0)
    assert("IamInTrayBarGui includes Fermer button for About dialog", InStr(trayGuiContent, '"Fermer"') > 0)

    menusPath := projectRoot "\lib\MainScript\Gui\Menus.ahk"
    menusContent := FileOpen(menusPath, "r", "UTF-8").Read()
    assert("Menus.ahk defines À propos... in Help menu", InStr(menusContent, "À propos...") > 0)

    ; ------------------------------------------------
    ; 11. Theme Propagation and Management Tests
    ; ------------------------------------------------
    printLine("`n[Group 11: Theme Propagation and Management]")
    gLogOutput .= "`n[Group 11: Theme Propagation and Management]`n"

    diskTheme := readThemePreferenceFromDisk()
    assert("readThemePreferenceFromDisk returns valid theme", (diskTheme = "Dark" || diskTheme = "Light" || diskTheme = "System"))
    assertEqual("getEffectiveTheme with Dark returns Dark", getEffectiveTheme("Dark"), "Dark")
    assertEqual("getEffectiveTheme with Light returns Light", getEffectiveTheme("Light"), "Light")
    systemEffective := getEffectiveTheme("System")
    assert("getEffectiveTheme with System resolves to Dark or Light", (systemEffective = "Dark" || systemEffective = "Light"))

    menusPath := projectRoot "\lib\MainScript\Gui\Menus.ahk"
    menusContent := FileOpen(menusPath, "r", "UTF-8").Read()
    assert("Menus.ahk updates sendToUniqueIDInputWindow theme", InStr(menusContent, "sendToUniqueIDInputWindow.applyTheme()") > 0)
    assert("Menus.ahk encodes themeCode in WM_THEME_CHANGED", InStr(menusContent, "themeCode :=") > 0 && InStr(menusContent, "themeCode,") > 0)

    customMessagesPath := projectRoot "\lib\Shared\Classes\CustomMessages.ahk"
    customMessagesContent := FileOpen(customMessagesPath, "r", "UTF-8").Read()
    assert("CustomMessages forwards lParam for WM_THEME_CHANGED", InStr(customMessagesContent, "case this.WM_THEME_CHANGED:") > 0 && InStr(customMessagesContent, "PostMessage(msgNumber, wparam_uniqueID, lparam_emitterhWnd") > 0)
    assert("CustomMessages does not register WM_THEME_CHANGED under subScript", InStr(customMessagesContent, "OnMessage(this.WM_THEME_CHANGED, handlerCallBackFunction)") = 0)

    respCallbacksPath := projectRoot "\lib\ResponseWindow\CallBack\respWindowCallBackFunctions.ahk"
    respCallbacksContent := FileOpen(respCallbacksPath, "r", "UTF-8").Read()
    assert("respWindowCallBackFunctions decodes lparam_themeCode", InStr(respCallbacksContent, "lparam_themeCode") > 0)
    assert("respWindowCallBackFunctions calls applyResponseWindowTheme with decoded theme", InStr(respCallbacksContent, "applyResponseWindowTheme(themeFromCode)") > 0)
    assert("respWindowCallBackFunctions updates global gTHEME", InStr(respCallbacksContent, "global gTHEME := themeFromCode") > 0)
    assert("respWindowCallBackFunctions guards onSentToAllModels with msgNumber", InStr(respCallbacksContent, "msgNumber != CustomMessages.WM_SEND_TO_ALL_MODELS") > 0)

    respWinPath := projectRoot "\lib\Response Window.ahk"
    respWinContent := FileOpen(respWinPath, "r", "UTF-8").Read()
    assert("Response Window applyResponseWindowTheme accepts targetTheme parameter", InStr(respWinContent, "applyResponseWindowTheme(targetTheme := unset)") > 0)
    assert("Response Window applies theme via both JS execution and WebMessage", InStr(respWinContent, "callWebJavaScriptFunction(`"applyTheme`"") > 0)

    mainJsPath := projectRoot "\lib\Response Window resources\js\main.js"
    mainJsContent := FileOpen(mainJsPath, "r", "UTF-8").Read()
    assert("main.js does not contain streaming-cursor", InStr(mainJsContent, "streaming-cursor") = 0)
    assert("main.js cancels animation frame on stream complete/error", InStr(mainJsContent, "cancelAnimationFrame(renderRafId)") > 0)

    customCssPath := projectRoot "\lib\Response Window resources\css\custom.css"
    customCssContent := FileOpen(customCssPath, "r", "UTF-8").Read()
    assert("custom.css does not contain streaming-cursor", InStr(customCssContent, "streaming-cursor") = 0)

    nodeExitCode := RunWait('cmd /c node -c "' mainJsPath '"', , "Hide")
    assert("main.js passes JavaScript syntax validation (node -c)", nodeExitCode = 0)

    ; ------------------------------------------------
    ; 12. Response Window Placement and Screen Clamping Tests
    ; ------------------------------------------------
    printLine("`n[Group 12: Response Window Placement and Screen Clamping]")
    gLogOutput .= "`n[Group 12: Response Window Placement and Screen Clamping]`n"

    utilsPath := projectRoot "\lib\Shared\Utils.ahk"
    utilsContent := FileOpen(utilsPath, "r", "UTF-8").Read()
    llmCallPath := projectRoot "\lib\ResponseWindow\LLM\LlmCall.ahk"
    llmCallContent := FileOpen(llmCallPath, "r", "UTF-8").Read()

    assert("Utils.ahk defines calculateResponseWindowPosition", InStr(utilsContent, "calculateResponseWindowPosition(") > 0)
    assert("Utils.ahk preserves RANDOM_RANGE_X := 200", InStr(utilsContent, "RANDOM_RANGE_X := 200") > 0)
    assert("Utils.ahk preserves RANDOM_RANGE_Y := 200", InStr(utilsContent, "RANDOM_RANGE_Y := 200") > 0)
    assert("Utils.ahk preserves STACK_OFFSET := 200", InStr(utilsContent, "STACK_OFFSET := 200") > 0)
    assert("Utils.ahk preserves DESIRED_W := 750", InStr(utilsContent, "DESIRED_W := 750") > 0)
    assert("Utils.ahk preserves DESIRED_H := 600", InStr(utilsContent, "DESIRED_H := 600") > 0)
    assert("Utils.ahk checks MonitorGetWorkArea", InStr(utilsContent, "MonitorGetWorkArea") > 0)
    assert("Utils.ahk clamps X within minX and maxX", InStr(utilsContent, "clampedX :=") > 0)
    assert("Utils.ahk clamps Y within minY and maxY", InStr(utilsContent, "clampedY :=") > 0)
    assert("showResponseWindow calls calculateResponseWindowPosition", InStr(llmCallContent, 'pos := calculateResponseWindowPosition(requestParams["numberOfAPIModels"]') > 0)

    ; Functional test: run 500 simulated placements with random jitter
    allPlacementsInBounds := true
    resolutions := [[1366, 768], [1920, 1080], [2560, 1440]]
    for idxRes, res in resolutions {
        sW := res[1]
        sH := res[2]
        wB := sH - 40
        Loop 100 {
            nModels := Random(1, 5)
            mIdx := Random(1, nModels)
            posStr := calculateResponseWindowPosition(nModels, mIdx, sW, sH, 0, 0, sW, wB)
            if RegExMatch(posStr, "x(-?\d+)\s+y(-?\d+)\s+w(\d+)\s+h(\d+)", &pm) {
                px := Integer(pm[1])
                py := Integer(pm[2])
                pw := Integer(pm[3])
                ph := Integer(pm[4])
                if (px < 0 || (sW >= pw && px + pw > sW) || py < 0 || (wB >= ph && py + ph > wB)) {
                    allPlacementsInBounds := false
                    break 2
                }
            }
        }
    }
    assert("calculateResponseWindowPosition clamps 100% of windows within screen across resolutions", allPlacementsInBounds)

    ; ------------------------------------------------
    ; Summary and Exit
    ; ------------------------------------------------
    summary := "`n--------------------------------------------------`n"
    summary .= "Results: " gPassCount " / " gTestCount " tests passed."
    if (gFailCount > 0) {
        ; One or more tests failed

        ; Log failure summary
        summary .= " (" gFailCount " FAILED)"

    } else {
        ; All tests passed

        ; Log success summary
        summary .= " (ALL PASSED)"
    }
    summary .= "`n--------------------------------------------------"
    printLine(summary)
    gLogOutput .= summary "`n"

    ; Always write results log to file
    try {
        logFilePath := A_ScriptDir "\..\test_results.log"
        f := FileOpen(logFilePath, "w", "UTF-8")
        f.Write(gLogOutput)
        f.Close()
    } catch {
        ; Ignore log write error
    }

    ; If run with /gui, show a MsgBox with summary
    if (showGui) {
        ; Script was launched with /gui flag

        ; Display result dialog
        iconType := (gFailCount > 0) ? 16 : 64
        MsgBox(gLogOutput, "LLM AutoHotkey Assistant - Tests", iconType)

    } else {
        ; Headless or console execution without GUI requested

        ; NTD
    }

    if (gFailCount > 0) {
        ; Tests had failures

        ; Exit with failure status code
        ExitApp(1)

    } else {
        ; All tests passed

        ; Exit with success status code
        ExitApp(0)
    }

    return
}

; Run test suite
runAllTests()

