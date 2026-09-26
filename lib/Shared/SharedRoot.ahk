#Requires AutoHotkey v2.0.18+

;******************************************************************************
;
; ATTENTION: This file is #Include in two separate Processes:
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
global gAuthor := ""
global gVersionStringPrefix := ""
global gVersionStringSuffix := "LLM AutoHotkey Assistant (" gVersion ")" . (gAuthor != "" ? " | " gAuthor : "")

; By default use OpenRouter API endpoint
global gLLM_BASE_URL := "https://openrouter.ai/api"

global APIKey := "none"

global CLIPBOARD_WAIT_MS := 50

; Default additional browser arguments for WebView2 runtime
global gWEBVIEW2_ADDITIONAL_ARGS := "--disable-web-security"


; Spacer used in jsongo.Stringify()
;
;    "" => json as one line (for performance)
;    4  => json indented with 4 spaces (readable by humans)

;global JSON_INDENT_SPACER := ""
global JSON_INDENT_SPACER := 4

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
#Include "*i ..\..\config\Preferences.ahk"

; ----------------------------------------------------
; Utilities
; ----------------------------------------------------

#Include Utils.ahk

if (!IsSet(gTHEME)) {
    ; gTHEME is not defined

    ; Default to System theme
    global gTHEME := "System"

} else {
    ; gTHEME is defined

    ; NTD
}

if (!IsSet(gEDITOR_PATH)) {
    ; gEDITOR_PATH is not defined

    ; Default to empty (Notepad fallback)
    global gEDITOR_PATH := ""

} else {
    ; gEDITOR_PATH is defined

    ; NTD
}

if (!IsSet(gEDITOR_ARGS)) {
    ; gEDITOR_ARGS is not defined

    ; Default to empty
    global gEDITOR_ARGS := ""

} else {
    ; gEDITOR_ARGS is defined

    ; NTD
}

;******************************************************************************
;
; Includes and Libraries
;
;******************************************************************************

#Include COTS\Dark_MsgBox.ahk ; Enables dark mode MsgBox and InputBox. Remove this if you want light mode MsgBox and InputBox
#Include COTS\Dark_Menu.ahk ; Enables dark mode Menu. Remove this if you want light mode Menu

if (getEffectiveTheme() = "Light") {
    ; Effective theme is Light

    ; Set menu theme to Light (0)
    Dark_Menu.SetMode(0)

} else {
    ; Effective theme is not Light (Dark)

    ; Set menu theme to Dark (1)
    Dark_Menu.SetMode(1)
}

#Include COTS\SystemThemeAwareToolTip.ahk ; Enables dark mode tooltips. Remove this if you want light mode tooltips
; #Include COTS\WebViewToo.ahk ; Allows for use of the WebView2 Framework within AHK to create Web-based GUIs
#Include COTS\jsongo.v2.ahk ; For JSON parsing
#Include COTS\AutoXYWH.ahk ; Enables auto-resizing of GUI controls. Does not include resizing of Response Window GUI elements, as it is handled by HTML and CSS
#Include COTS\ToolTipEx.ahk ; Enables the tooltip to track the mouse cursor smoothly and permit the tooltip to be moved by dragging

; ----------------------------------------------------
; Includes
; ----------------------------------------------------

#Include Classes\OpenRouter.ahk
#Include Classes\clsChatHistory.ahk
#Include Classes\InputWindow.ahk
#Include Classes\CustomMessages.ahk

DetectHiddenWindows true ; Enables detection of hidden windows for inter-process communication

; ----------------------------------------------------
; Global Variables
; ----------------------------------------------------

chatHistorySingleton := clsChatHistory()

; ----------------------------------------------------
; Functions
; ----------------------------------------------------

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
        TraySetIcon((A_ScriptName = "Response Window.ahk" ? "..\" : "") gMapIconNb2IconPath[iconNb], 1, true)

    } else {
        ; Compiled mode

        ; Use negative icon's Number 
        ; (see ahk v2 documentation : "If negative, the absolute value is assumed to be the resource ID of an icon within an executable file")
        TraySetIcon(A_ScriptFullPath, -1 * iconNb, true)
    }

    ; Tray icon tooltip
    A_IconTip := "LLM AutoHotkey Assistant"
}

