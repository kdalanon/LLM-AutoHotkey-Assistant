#Requires AutoHotkey v2.0

;
; Global Variables
;

; ----------------------------------------------------
; Base URL for the LLM API endpoint
; ----------------------------------------------------

; If not defined, OpenRouter API endpoint will be used
; gLLM_BASE_URL := "http://localhost:1234"

; ----------------------------------------------------
; Add custom icons
; ----------------------------------------------------

; ICON_XXX    := 18

; gMapIconNb2IconPath.Set(ICON_XXX, "icons\xxx.ico")

; ----------------------------------------------------
; Theme preference: "Dark", "Light", or "System"
; ----------------------------------------------------
global gTHEME := "System"

; ----------------------------------------------------
; WebView2 additional browser arguments
; ----------------------------------------------------
; Configure Chromium flags passed to the WebView2 runtime.
; To customize or bypass all proxies:
; gWEBVIEW2_ADDITIONAL_ARGS := "--disable-web-security --no-proxy-server"
; Or to configure proxy bypass domains:
; gWEBVIEW2_ADDITIONAL_ARGS := "--disable-web-security --proxy-bypass-list=`"localhost;127.0.0.1;<local>`""

; ----------------------------------------------------
; Text Editor for Prompts.ahk
; ----------------------------------------------------
; Path to your preferred editor (e.g. Notepad++, VSCode, etc.)
; If not defined, empty, or if the executable is not found, Windows Notepad will be used.
;
; Examples:
; global gEDITOR_PATH := "C:\Program Files\Notepad++\notepad++.exe"
; global gEDITOR_PATH := "C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe"
; global gEDITOR_PATH := "code"
;
; Optional command line arguments passed to the editor:
; Examples:
; global gEDITOR_ARGS := "-multiInst"
; global gEDITOR_ARGS := "-r"
