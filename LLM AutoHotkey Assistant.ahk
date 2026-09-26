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

;
; Global Variables
global gIsDebugMode := false


#Include lib\Shared\SharedRoot.ahk

#Include lib\MainScript\Utils\Utils.ahk
#Include lib\MainScript\Utils\Sessions.ahk
#Include lib\MainScript\Gui\Menus.ahk
#Include lib\MainScript\Gui\IamInTrayBarGui.ahk
#Include lib\MainScript\Gui\ReloadNotification.ahk
#Include lib\MainScript\Gui\Handlers\ScriptHotkeyActions.ahk
#Include lib\MainScript\Gui\Handlers\InputWindowButtonActions.ahk
#Include lib\MainScript\LLM\StartResponseWindow.ahk
#Include lib\MainScript\LLM\PrewarmWebView2.ahk
#Include lib\MainScript\CallBack\CallBackFunctions.ahk

#Include config\Prompts.ahk

#SingleInstance Force
SetTitleMatchMode 2

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

MENU_LINE_SEPARATOR := "---"

; ----------------------------------------------------
; Tray menu
; ----------------------------------------------------

; Create Help Menu Item
gHelpMenu := Menu()
buildHelpMenu(gHelpMenu)

; Create Theme Menu Item
global gThemeMenu := Menu()
buildThemeMenu(gThemeMenu)

; Create Suspend Item
suspendMenu := {
    menuText: "&Suspend Assistant",
    function: (*) => mainScriptHotkeyActions("suspendHotkey")
    }

; Create Tray Menu Items
trayMenuItems := [
    {
    menuText: "&Show menus",
    function: (*) => mainScriptHotkeyActions("showPromptMenu")
    }
   ,{
    menuText: "",
    function: (*) => {}
    }
   ,{
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
   ,suspendMenu
   ,{
    menuText: "E&xit",
    function: (*) => ExitApp()
    }


]

; Generate Tray Menu from trayMenuItems

buildTrayMenu(trayMenuItems)

TraySetIconEmbed(ICON_ON)

; ----------------------------------------------------
; Create new instance of OpenRouter class
; ----------------------------------------------------

router := OpenRouter(gLLM_BASE_URL, APIKey)

; ----------------------------------------------------
; Create Input Windows & Register sendButtonActions
; ----------------------------------------------------

customPromptInputWindow := InputWindow("Custom prompt")
customPromptInputWindow.registerSendButtonAction(customPromptSendButtonAction)

sendToPromptNameInputWindow := InputWindow("Send message to all with same prompt name")
sendToPromptNameInputWindow.registerSendButtonAction(sendToAllOpenWithSamePromptNameSendButtonAction)

sendToAllModelsInputWindow := InputWindow("Send message to all")
sendToAllModelsInputWindow.registerSendButtonAction(sendToAllModelsSendButtonAction)

sendToUniqueIDInputWindow := InputWindow("Send message to session")
sendToUniqueIDInputWindow.registerSendButtonAction(sendToUniqueIDSendButtonAction)


; ----------------------------------------------------
; Initialize Suspend GUI
; ----------------------------------------------------

scriptSuspendStatus := Gui("-Caption +Owner -SysMenu +AlwaysOnTop +Border")
scriptSuspendStatus.MarginX := 20
scriptSuspendStatus.MarginY := 10
scriptSuspendStatus.BackColor := "0x18181B"
scriptSuspendStatus.SetFont("s10 Bold c0xF59E0B", "Segoe UI")
scriptSuspendStatus.Add("Text", "Center", "⏸  LLM AutoHotkey Assistant Suspendu")
DllCall("Dwmapi\DwmSetWindowAttribute", "ptr", scriptSuspendStatus.hWnd, "int", 33, "int*", 2, "int", 4)
scriptSuspendStatusWidth := ""
scriptSuspendStatus.GetPos(, , &scriptSuspendStatusWidth)

; ----------------------------------------------------
; Custom messages and handlers for detecting
; Response Window states
; ----------------------------------------------------

CustomMessages.registerHandlers("mainScript", onResponseWindowStateChanged)

; Reconnect to existing Response Windows (rebuild mapId2ActiveResponseWindowParams)
reconnectToExistingResponseWindows()

; ----------------------------------------------------
; Initialize Notification or "I'm in Trayling bar" GUI
; ----------------------------------------------------

if (checkAndClearPromptsReloadedFlag()) {
    ; Script was reloaded due to Prompts update or reload request

    ; Display auto-dismissing confirmation MsgBox with 3s timeout
    showPromptsReloadedMsgBox(3)

} else {
    ; Script was not reloaded from Prompts.ahk (initial startup or tray menu reload)

    ; Initialize "I'm in Trayling bar" GUI
    animateIamInTrayBarGui()
}

; ----------------------------------------------------
; Pre-warm WebView2 runtime in background
; ----------------------------------------------------
SetTimer(prewarmWebView2, -300)
