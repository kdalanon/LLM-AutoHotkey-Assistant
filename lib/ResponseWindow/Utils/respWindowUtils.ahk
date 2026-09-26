#Requires AutoHotkey v2.0

; ----------------------------------------------------
; Debug State Management
; ----------------------------------------------------

loadDebugState() {
    global jsongo
    debugFilePath := getSessionDir() "\LLM_Ahk_DEBUG_LAST_SESSION.json"
    
    if !FileExist(debugFilePath)
        return

    try {
        debugData := jsongo.Parse(FileOpen(debugFilePath, "r", "UTF-8").Read())
        return debugData

    } catch {
        return
    }
}

; ----------------------------------------------------
; Manage Chat History requests
; ----------------------------------------------------

manageChatHistoryJSON(action, data := unset) {
    static chatHistoryAsJson := FileOpen(requestParams["chatHistoryJsonFilePath"], "r", "UTF-8-RAW").Read()

    switch action {
        case "get": return chatHistoryAsJson
        case "set": chatHistoryAsJson := data
    }
}

;--------------------------------------------------
; Combined state management for model history,
; chat history, and cURL process
;--------------------------------------------------

logStreamDebug(msg) {
    try {
        FileAppend(FormatTime(, "yyyy-MM-dd HH:mm:ss") " " msg "`n", getSessionDir() "\stream_debug.log", "UTF-8")
    }
}

manageState(component, action, data := {}) {

    static state := {
        modelHistory: [],
        chatHistory: { chatHistory: "", latestResponse: "" },
        cURLPID: 0,
        isStreaming: false,
        webPageReady: false,
        pendingStreamConfig: "",
        pendingRender: false
    }

    switch component {
        case "model":
            switch action {
                case "get": return state.modelHistory
                case "add": state.modelHistory.Push(data)
                case "remove": (state.modelHistory.Length) ? state.modelHistory.Pop() : ""
            }

        case "chat":
            switch action {
                case "get": return state.chatHistory
                case "set":
                    state.chatHistory.chatHistory := data.chatHistory
                    state.chatHistory.latestResponse := data.latestResponse
            }

        case "streaming":
            switch action {
                case "get": return state.isStreaming
                case "set": state.isStreaming := data
            }

        case "webPageReady":
            switch action {
                case "get": return state.webPageReady
                case "set": state.webPageReady := data
            }

        case "pendingStreamConfig":
            switch action {
                case "get": return state.pendingStreamConfig
                case "set": state.pendingStreamConfig := data
            }

        case "pendingRender":
            switch action {
                case "get": return state.pendingRender
                case "set": state.pendingRender := data
            }

        case "cURL":
            switch action {
                case "get": return state.cURLPID
                case "set": state.cURLPID := data
                case "close": ProcessClose(state.cURLPID), state.cURLPID := 0
            }
    }
}

; ----------------------------------------------------
; Start or stop loading cursor
; ----------------------------------------------------

setLoadingCursor(isLoading) {

    global responseWindow

    isLoading ? CustomMessages.notifyResponseWindowState(  CustomMessages.WM_RESPONSE_WINDOW_LOADING_START,
                                                           requestParams["uniqueID"], 
                                                           responseWindow.hWnd,
                                                           requestParams["mainScriptHiddenhWnd"]
                                                        )
            : CustomMessages.notifyResponseWindowState( CustomMessages.WM_RESPONSE_WINDOW_LOADING_FINISH,
                                                         requestParams["uniqueID"], 
                                                         responseWindow.hWnd,
                                                         requestParams["mainScriptHiddenhWnd"])
}

