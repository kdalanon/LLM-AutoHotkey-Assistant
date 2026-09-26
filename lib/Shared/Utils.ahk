#Requires AutoHotkey v2.0

; ----------------------------------------------------
; Session directory management
; ----------------------------------------------------

/**
 * Returns the path to the user's LLM AutoHotkey Assistant session directory.
 * Creates the directory if it doesn't exist.
 * Path: %APPDATA%\LLM AutoHotkey Assistant
 */
getSessionDir() {
    static sessionDir := ""
    
    if (sessionDir = "") {
        sessionDir := EnvGet("APPDATA") "\LLM AutoHotkey Assistant"
        try {
            if !DirExist(sessionDir)
                DirCreate(sessionDir)
        } catch {
            ; Silently fail if directory cannot be created
        }
    }
    
    return sessionDir
}

/**
 * Find the paramsForResponseWindow.json file for a given uniqueID
 * Uses native AutoHotkey file search
 */
findParamsFileByUniqueID(sessionDir, uniqueID) {

    ; Search for files matching the pattern using native AutoHotkey Loop
    pattern := sessionDir "\LLM_Ahk_" uniqueID "*_paramsForResponseWindow.json"
    
    fileList := ""
    
    Loop Files, pattern {

        fileList := A_LoopFileFullPath

        break
    }

    return fileList
}

/**
/**
 * Reads the current gTHEME preference directly from config\Preferences.ahk on disk.
 */
readThemePreferenceFromDisk() {
    prefsPath := getPreferencesFilePath()
    if (FileExist(prefsPath)) {
        try {
            content := FileRead(prefsPath, "UTF-8")
            if (RegExMatch(content, "m)^\s*global\s+gTHEME\s*:=\s*[`"']([^`"']+)[`"']", &match)) {
                return match[1]
            }
        }
    }
    return "Dark"
}

/**
 * Returns the effective theme ("Dark" or "Light") based on current preference.
 * Resolves "System" by checking the Windows registry setting.
 */
getEffectiveTheme(themeName := unset, reloadFromDisk := false) {
    if (reloadFromDisk) {
        global gTHEME := readThemePreferenceFromDisk()
    }
    targetTheme := IsSet(themeName) ? themeName : (IsSet(gTHEME) ? gTHEME : readThemePreferenceFromDisk())
    effectiveTheme := "Dark"

    if (targetTheme = "System") {
        ; Target theme is System

        ; Read Windows system theme from registry
        isWindowsLight := 0
        try {
            isWindowsLight := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme", 0)
        }

        if (isWindowsLight = 1) {
            ; Windows is configured for light theme

            ; Use light theme
            effectiveTheme := "Light"

        } else {
            ; Windows is not configured for light theme

            ; Use dark theme
            effectiveTheme := "Dark"
        }

    } else if (targetTheme = "Light") {
        ; Target theme is Light

        ; Use light theme
        effectiveTheme := "Light"

    } else {
        ; Target theme is Dark OU any other value

        ; Use dark theme
        effectiveTheme := "Dark"
    }

    return effectiveTheme
}

/**
 * Returns the path to config\Preferences.ahk regardless of calling process location.
 */
getPreferencesFilePath() {
    static prefsPath := ""

    if (prefsPath = "") {
        ; Preferences path has not been computed yet

        ; Compute absolute path based on Utils.ahk location
        SplitPath(A_LineFile, , &sharedDir)
        prefsPath := sharedDir "\..\..\config\Preferences.ahk"

    } else {
        ; Preferences path is already computed

        ; NTD
    }

    return prefsPath
}

/**
 * Returns the path to config\Prompts.ahk regardless of calling process location.
 */
getPromptsFilePath() {
    static promptsPath := ""

    if (promptsPath = "") {
        ; Prompts path has not been computed yet

        ; Compute absolute path based on Utils.ahk location
        SplitPath(A_LineFile, , &sharedDir)
        promptsPath := sharedDir "\..\..\config\Prompts.ahk"

    } else {
        ; Prompts path is already computed

        ; NTD
    }

    return promptsPath
}

/**
 * Opens config\Prompts.ahk in the configured text editor (gEDITOR_PATH) or falls back to Notepad.
 */
openPromptsInEditor() {
    promptsPath := getPromptsFilePath()
    editorPath := (IsSet(gEDITOR_PATH) ? Trim(gEDITOR_PATH, ' "' . "`t") : "")
    editorArgs := (IsSet(gEDITOR_ARGS) ? Trim(gEDITOR_ARGS) : "")

    if (editorPath != "") {
        ; If path contains a directory separator, check whether the file actually exists
        if ((InStr(editorPath, "\") || InStr(editorPath, "/")) && !FileExist(editorPath)) {
            ; Specified editor file does not exist, fallback to Notepad
            Run('notepad.exe "' promptsPath '"')
            return
        }

        ; Build command line: "<editor>" [args] "<promptsPath>"
        cmd := '"' editorPath '"' (editorArgs != "" ? ' ' editorArgs : '') ' "' promptsPath '"'
        try {
            Run(cmd)
            return
        } catch {
            ; Failed to launch configured editor, fallback to Notepad
        }
    }

    ; Default fallback: Windows Notepad
    Run('notepad.exe "' promptsPath '"')
}

/**
 * Persists the theme preference ("Dark", "Light", or "System") into config\Preferences.ahk.
 */
persistThemePreference(newTheme) {
    prefsPath := getPreferencesFilePath()
    fileContent := ""

    if (FileExist(prefsPath)) {
        ; Preferences file exists

        ; Read existing file content
        fileContent := FileRead(prefsPath, "UTF-8")

    } else {
        ; Preferences file does not exist

        ; Initialize minimal content
        fileContent := "#Requires AutoHotkey v2.0`n"
    }

    themeLine := 'global gTHEME := "' newTheme '"'

    if (RegExMatch(fileContent, "m)^\s*global\s+gTHEME\s*:=.*$")) {
        ; gTHEME setting is present in file

        ; Replace existing line
        fileContent := RegExReplace(fileContent, "m)^\s*global\s+gTHEME\s*:=.*$", themeLine)

    } else {
        ; gTHEME setting is not present in file

        ; Append setting to file
        fileContent := RTrim(fileContent, "`r`n") "`n`n; Theme preference: `"Dark`", `"Light`", or `"System`"`n" themeLine "`n"
    }

    ; Write updated content to file
    try {
        fileObj := FileOpen(prefsPath, "w", "UTF-8")
        fileObj.Write(fileContent)
        fileObj.Close()
    }

    return true
}

/**
 * Returns the short git commit hash and commit date (e.g. "472461e du 16/09/2026").
 * On a dev workstation (when git responds), appends " (+ modifs NON commitées)" if there are uncommitted changes,
 * and creates or updates "build_info.txt" at the repository root.
 * If git is unavailable (e.g. user deployment without .git), reads from "build_info.txt".
 * Returns an empty string if no commit info is available.
 */
getGitCommitInfo(repoPath := "") {
    static cachedInfo := ""
    isDefaultRepo := (repoPath == "")

    if (isDefaultRepo && cachedInfo != "") {
        return cachedInfo
    }

    if (repoPath == "") {
        SplitPath(A_LineFile, , &utilsDir)
        repoPath := utilsDir "\..\.."
    }

    buildInfoFile := repoPath "\build_info.txt"
    gitDir := repoPath "\.git"
    resultInfo := ""

    ; 1. Attempt to query git dynamically if .git exists
    if (DirExist(gitDir) || FileExist(gitDir)) {
        tempFile := A_Temp "\ahk_git_info_" A_TickCount ".txt"
        cmd := A_ComSpec ' /c git -C "' repoPath '" log -1 --format="%h du %cd" --date=format:"%d/%m/%Y" > "' tempFile '" 2>nul'
        exitCode := RunWait(cmd, repoPath, "Hide")

        if (exitCode == 0 && FileExist(tempFile)) {
            try {
                info := Trim(FileRead(tempFile, "UTF-8"), " `r`n`t")
                if (info != "") {
                    ; Check for uncommitted tracked modifications (ignoring untracked files)
                    statusCmd := A_ComSpec ' /c git -C "' repoPath '" status --porcelain -uno > "' tempFile '" 2>nul'
                    statusExit := RunWait(statusCmd, repoPath, "Hide")
                    if (statusExit == 0 && FileExist(tempFile)) {
                        statusOutput := Trim(FileRead(tempFile, "UTF-8"), " `r`n`t")
                        if (statusOutput != "") {
                            info .= " (+ modifs NON commitées)"
                        }
                    }
                    resultInfo := info

                    ; Create or update build_info.txt
                    try {
                        fileObj := FileOpen(buildInfoFile, "w", "UTF-8")
                        fileObj.Write(resultInfo)
                        fileObj.Close()
                    }
                }
            }
        }

        if FileExist(tempFile) {
            try FileDelete(tempFile)
        }

        ; Fallback if git CLI was not available or failed: parse .git files directly
        if (resultInfo == "") {
            try {
                headPath := gitDir "\HEAD"
                if FileExist(headPath) {
                    headContent := Trim(FileRead(headPath, "UTF-8"), " `r`n`t")
                    commitHash := ""
                    refFile := ""

                    if RegExMatch(headContent, "^ref:\s*(.+)$", &refMatch) {
                        refRelPath := StrReplace(refMatch[1], "/", "\")
                        refFile := gitDir "\" refRelPath
                        if FileExist(refFile) {
                            commitHash := SubStr(Trim(FileRead(refFile, "UTF-8"), " `r`n`t"), 1, 7)
                        } else if FileExist(gitDir "\packed-refs") {
                            packed := FileRead(gitDir "\packed-refs", "UTF-8")
                            if RegExMatch(packed, "m)^([0-9a-fA-F]{40})\s+" . RegExReplace(refMatch[1], "([\\^$.*+?()[\]{}|])", "\$1") . "$", &packedMatch) {
                                commitHash := SubStr(packedMatch[1], 1, 7)
                            }
                        }
                    } else if (StrLen(headContent) >= 7) {
                        commitHash := SubStr(headContent, 1, 7)
                    }

                    if (commitHash != "") {
                        timeTarget := (refFile != "" && FileExist(refFile)) ? refFile : headPath
                        fileTime := FileGetTime(timeTarget)
                        formattedDate := SubStr(fileTime, 7, 2) "/" SubStr(fileTime, 5, 2) "/" SubStr(fileTime, 1, 4)
                        resultInfo := commitHash " du " formattedDate

                        try {
                            fileObj := FileOpen(buildInfoFile, "w", "UTF-8")
                            fileObj.Write(resultInfo)
                            fileObj.Close()
                        }
                    }
                }
            }
        }
    }

    ; 2. Fallback if git did not respond or .git does not exist (user deployment)
    if (resultInfo == "" && FileExist(buildInfoFile)) {
        try {
            content := Trim(FileRead(buildInfoFile, "UTF-8"), " `r`n`t")
            if (content != "") {
                resultInfo := content
            }
        }
    }

    if (isDefaultRepo) {
        cachedInfo := resultInfo
    }

    return resultInfo
}

;
; Compute and clamp the Response Window position to ensure it stays fully within screen boundaries
;
calculateResponseWindowPosition(numberOfAPIModels, apiModelsIndex, screenW := unset, screenH := unset, workLeft := unset, workTop := unset, workRight := unset, workBottom := unset) {

    ; Response Window dimensions and layout constants
    Local DESIRED_W := 750                      ; Default width (pixels) of a Response Window
    Local DESIRED_H := 600                      ; Default height (pixels) of a Response Window
    Local CENTER_OFFSET_X := 100               ; Horizontal shift to the left for a single window layout
    Local Y_CENTER_DIVISOR := 4                ; Divisor placing the top edge in the upper area of the screen
    Local TWO_WINDOWS_MULTIPLIER := 1.3        ; Width multiplier shifting the left window when 2 models are displayed
    Local THREE_WINDOWS_LEFT_MULTIPLIER := 1.6  ; Width multiplier shifting window #1 to the left when 3+ models are displayed
    Local THREE_WINDOWS_RIGHT_MULTIPLIER := 0.4 ; Width multiplier shifting window #3 to the right when 3+ models are displayed
    Local RANDOM_RANGE_X := 200                 ; Maximum horizontal random jitter (+/- pixels) to prevent exact overlaps
    Local RANDOM_RANGE_Y := 200                 ; Maximum vertical random jitter (+/- pixels) to prevent exact overlaps
    Local RANDOM_RANGE_Y_STACK := 20           ; Reduced vertical jitter (+/- pixels) for stacked windows (4+ models)
    Local STACK_OFFSET := 200                   ; Vertical step (pixels) applied for each additional stacked window beyond 3

    ; Determine screen dimensions
    screenWidth := IsSet(screenW) ? screenW : A_ScreenWidth
    screenHeight := IsSet(screenH) ? screenH : A_ScreenHeight

    ; Determine screen work area bounds (accounting for taskbar)
    wLeft := IsSet(workLeft) ? workLeft : 0
    wTop := IsSet(workTop) ? workTop : 0
    wRight := IsSet(workRight) ? workRight : screenWidth
    wBottom := IsSet(workBottom) ? workBottom : screenHeight

    if (!IsSet(workLeft) || !IsSet(workRight)) {
        try {
            primaryMon := MonitorGetPrimary()
            if MonitorGetWorkArea(primaryMon, &mLeft, &mTop, &mRight, &mBottom) {
                wLeft := mLeft
                wTop := mTop
                wRight := mRight
                wBottom := mBottom
            }
        }
    }

    ; Define base X and Y coordinate variables
    X := (screenWidth - DESIRED_W) // 2
    Y := (screenHeight - DESIRED_H) // Y_CENTER_DIVISOR

    targetX := X
    targetY := Y

    ; Compute the arrangement of Response Windows based on the number of models:
    ; If there is one Response Window, it will be in the center
    ; If there are two, they will be side by side in the center
    ; If there are three, they will be arranged in the center
    ; If there are more than three, it will be the same as three for the first three,
    ; then additional windows will be in the center as a stack and have a slight downward offset
    switch numberOfAPIModels {
        case 1:
            targetX := X - CENTER_OFFSET_X + Random(-RANDOM_RANGE_X, RANDOM_RANGE_X)
            targetY := Y + Random(-RANDOM_RANGE_Y, RANDOM_RANGE_Y)

        case 2:
            baseX := (apiModelsIndex = 1) ? (screenWidth // 2) - (DESIRED_W * TWO_WINDOWS_MULTIPLIER) : (screenWidth // 2)
            targetX := baseX + Random(-RANDOM_RANGE_X, RANDOM_RANGE_X)
            targetY := Y + Random(-RANDOM_RANGE_Y, RANDOM_RANGE_Y)

        case 3:
            switch apiModelsIndex {
                case 1:
                    ; Left
                    baseX := (screenWidth // 2) - (DESIRED_W * THREE_WINDOWS_LEFT_MULTIPLIER)

                case 2:
                    ; Center
                    baseX := (screenWidth - DESIRED_W) // 2

                default:
                    ; Right
                    baseX := (screenWidth // 2) + (DESIRED_W * THREE_WINDOWS_RIGHT_MULTIPLIER)
            }

            targetX := baseX + Random(-RANDOM_RANGE_X, RANDOM_RANGE_X)
            targetY := Y + Random(-RANDOM_RANGE_Y, RANDOM_RANGE_Y)

        default:
            if (apiModelsIndex < 4) {
                switch apiModelsIndex {
                    case 1: baseX := (screenWidth // 2) - (DESIRED_W * THREE_WINDOWS_LEFT_MULTIPLIER)
                    case 2: baseX := (screenWidth - DESIRED_W) // 2
                    case 3: baseX := (screenWidth // 2) + (DESIRED_W * THREE_WINDOWS_RIGHT_MULTIPLIER)
                }
                targetX := baseX + Random(-RANDOM_RANGE_X, RANDOM_RANGE_X)
                targetY := Y + Random(-RANDOM_RANGE_Y, RANDOM_RANGE_Y)
            } else {
                baseX := (screenWidth - DESIRED_W) // 2
                stackY := Y + (apiModelsIndex - 3) * STACK_OFFSET
                targetX := baseX + Random(-RANDOM_RANGE_X, RANDOM_RANGE_X)
                targetY := stackY + Random(-RANDOM_RANGE_Y_STACK, RANDOM_RANGE_Y_STACK)
            }
    }

    ; Clamp target coordinates to keep the window fully inside the screen work area
    minX := wLeft
    maxX := Max(minX, wRight - DESIRED_W)
    minY := wTop
    maxY := Max(minY, wBottom - DESIRED_H)

    clampedX := Max(minX, Min(targetX, maxX))
    clampedY := Max(minY, Min(targetY, maxY))

    return Format("x{} y{} w{} h{}", clampedX, clampedY, DESIRED_W, DESIRED_H)
}
