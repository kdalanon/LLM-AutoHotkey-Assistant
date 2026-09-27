#Requires AutoHotkey v2.0

isCurrentResponseWindowActive() {
    isRespActive := IsSet(responseWindow) && WinActive(responseWindow.hWnd)
    isInputActive := IsSet(chatInputWindow) && WinActive(chatInputWindow.guiObj.hWnd)
    isActive := false

    if (isRespActive || isInputActive) {
        ; Current response window is active OU chat input window is active

        isActive := true

    } else {
        ; Current response window is not active ET chat input window is not active

        isActive := false
    }

    return isActive
}

isOnlyResponseWindowActive() {
    isRespActive := IsSet(responseWindow) && WinActive(responseWindow.hWnd)
    isInputActive := IsSet(chatInputWindow) && WinActive(chatInputWindow.guiObj.hWnd)
    isActive := false

    if (isRespActive && !isInputActive) {
        ; Current response window is active ET chat input window is not active

        isActive := true

    } else {
        ; Current response window is not active OU chat input window is active

        isActive := false
    }

    return isActive
}

respWindowHotkeyActions(action) {
    isRespActive := IsSet(responseWindow) && WinActive(responseWindow.hWnd)

    switch action {

        case "chatButton":
            if (isRespActive) {
                ; Response window is active

                ; Open chat input window
                buttonClickAction("chatButton")

            } else {
                ; Response window is not active

                ; NTD
            }

        case "retryButton":
            if (isRespActive) {
                ; Response window is active

                ; Retry request
                buttonClickAction("retryButton")

            } else {
                ; Response window is not active

                ; NTD
            }

        case "chatHistoryButton":
            if (isRespActive) {
                ; Response window is active

                ; Toggle chat history
                buttonClickAction("chatHistoryButton")

            } else {
                ; Response window is not active

                ; NTD
            }

        case "copyButton":
            if (isRespActive) {
                ; Response window is active

                ; Copy content
                buttonClickAction("copyButton")

            } else {
                ; Response window is not active

                ; NTD
            }

        case "pasteButton":
            if (isRespActive) {
                ; Response window is active

                ; Copy and paste
                buttonClickAction("pasteButton")

            } else {
                ; Response window is not active

                ; NTD
            }

        ; Handles request cancellation based on Response Window state:
        ;
        ; Background window: Stop request, keep window open
        ; Active window: Stop request, keep window open
        ; Hidden window: Stop request only
        case "Esc":
            switch {
                case manageState("streaming", "get"):
                    callWebJavaScriptFunction("abortStream")

                case WinExist(responseWindow.hWnd) && !(WinActive(responseWindow.hWnd))
                && ProcessExist(manageState("cURL", "get")):
                    manageState("cURL", "close")
                    callWebJavaScriptFunction("responseWindowButtonsEnabled", true)

                case WinActive(responseWindow.hWnd):
                    switch {
                        case ProcessExist(manageState("cURL", "get")):
                            manageState("cURL", "close")
                            callWebJavaScriptFunction("responseWindowButtonsEnabled", true)

                        Default:
                            buttonClickAction("Close")
                    }

                case ProcessExist(manageState("cURL", "get")):
                    manageState("cURL", "close")
            }

        case "closeWindows":
            if (isRespActive) {
                ; Response window is active

                ; Close response window
                buttonClickAction("Close")

            } else if (IsSet(chatInputWindow) && WinActive(chatInputWindow.guiObj.hWnd)) {
                ; Chat input window is active

                ; Close chat input window
                chatInputWindow.closeButtonAction()

            } else {
                ; Neither response window nor chat input window is active

                ; NTD
            }

        case "PgUp":
            if (isRespActive) {
                ; Response window is active

                ; Scroll content up
                try responseWindow.ExecuteScript("var c = document.getElementById('content'); if (c) c.scrollBy({ top: -c.clientHeight * 0.85, behavior: 'smooth' });")

            } else {
                ; Response window is not active

                ; NTD
            }

        case "PgDn":
            if (isRespActive) {
                ; Response window is active

                ; Scroll content down
                try responseWindow.ExecuteScript("var c = document.getElementById('content'); if (c) c.scrollBy({ top: c.clientHeight * 0.85, behavior: 'smooth' });")

            } else {
                ; Response window is not active

                ; NTD
            }

        Default:
            MsgBox("Unhandled key : (" action ")", "Error", 0x30)
    }
}
