#Requires AutoHotkey v2.0.18+

;******************************************************************************
;
; ATTENTION : Ce fichier est #Include dans deux Process distincts : 
;               - LLM AutoHotkey Assistant.ahk
;               - Response Window.ahk
;
;******************************************************************************

; ----------------------------------------------------
; Custom messages exchanged between MainScript and Response Window.ahk
; ----------------------------------------------------

class CustomMessages {

    ; Events for Main Script
    static WM_RESPONSE_WINDOW_OPENED := 0x400 + 125
    static WM_RESPONSE_WINDOW_CLOSED := 0x400 + 126
    static WM_RESPONSE_WINDOW_LOADING_START := 0x400 + 123
    static WM_RESPONSE_WINDOW_LOADING_FINISH := 0x400 + 124
    static WM_RESPONSE_WINDOW_RESTORED := 0x400 + 129

    ; Events for SubScript (= Response Window.ahk)
    static WM_SEND_TO_ALL_MODELS := 0x400 + 127
    static WM_RESPONSE_WINDOW_PING := 0x400 + 128
    static WM_THEME_CHANGED := 0x400 + 130

    ; Register handler (Callback function) to be triggered when receiving some  Events
    ; handlerCallBackFunction is like callBackFunName(wparam wparam_uniqueID, lparam emithWnd, msgNumber, targethWnd)
    ; TODO TW m 2026_06_17 : This method should be extracted from the class, split in two parts, one in MainScript, the other in ResponseWindow and remove the switch and param origin which become useless
    static registerHandlers(origin, handlerCallBackFunction) {
        switch origin {
            case "mainScript": ; = LLM AutoHotkey Assistant.ahk
                ; Register the handler for each msgNumber
                for msgNumber in [
                            this.WM_RESPONSE_WINDOW_OPENED, 
                            this.WM_RESPONSE_WINDOW_CLOSED, 
                            this.WM_RESPONSE_WINDOW_LOADING_START,
                            this.WM_RESPONSE_WINDOW_LOADING_FINISH,
                            this.WM_RESPONSE_WINDOW_RESTORED
                        ]
                    OnMessage(msgNumber, handlerCallBackFunction)

            case "subScript": ; = one of the many Response Window.ahk windows
                ; Register the handler for subscript messages
                OnMessage(this.WM_SEND_TO_ALL_MODELS, handlerCallBackFunction)
        }
    }

    ; Send Event (through a PostMessage) to main script to tell the ResponseWindow state
    static notifyResponseWindowState(msgNumber, 
                                     wparam_uniqueID, 
                                     lparam_emitterhWnd := unset,   ; Src
                                     targethWnd := unset            ; Target
                                    ) {
        try {
            switch msgNumber {
                case this.WM_RESPONSE_WINDOW_OPENED, this.WM_RESPONSE_WINDOW_CLOSED:
                    PostMessage(msgNumber, wparam_uniqueID, lparam_emitterhWnd, , "ahk_id " targethWnd)
    
                case this.WM_RESPONSE_WINDOW_RESTORED:
                    PostMessage(msgNumber, wparam_uniqueID, lparam_emitterhWnd, , "ahk_id " targethWnd)
    
                case this.WM_RESPONSE_WINDOW_LOADING_START, this.WM_RESPONSE_WINDOW_LOADING_FINISH:
                    PostMessage(msgNumber, wparam_uniqueID, 0, , "ahk_id " targethWnd)
    
                case this.WM_SEND_TO_ALL_MODELS:
                    PostMessage(msgNumber, wparam_uniqueID, 0, , "ahk_id " targethWnd)
    
                case this.WM_RESPONSE_WINDOW_PING:
                    PostMessage(msgNumber, wparam_uniqueID, lparam_emitterhWnd, , "ahk_id " targethWnd)

                case this.WM_THEME_CHANGED:
                    PostMessage(msgNumber, wparam_uniqueID, lparam_emitterhWnd, , "ahk_id " targethWnd)
            }
        } catch Error as e {
            
            ; TODO TW M 2026_06_23 : Perform a log
        }
    }
}

