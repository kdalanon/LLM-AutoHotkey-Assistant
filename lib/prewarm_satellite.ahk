#Requires AutoHotkey v2.0
#NoTrayIcon
#SingleInstance Force
Persistent()

#Include Shared\SharedRoot.ahk
#Include ResponseWindow\COTS\WebViewToo.ahk

global gPrewarmedWebViewToo := ""

try {
    ; Create a dormant WebViewToo instance (hidden)
    gPrewarmedWebViewToo := WebViewToo("", , ,)
    
    ; Ensure Gui is hidden and has no taskbar entry
    if (HasProp(gPrewarmedWebViewToo, "Gui") && gPrewarmedWebViewToo.Gui) {
        gPrewarmedWebViewToo.Gui.Opt("+ToolWindow -Caption")
    }

    ; Warm up network connection to LLM endpoint (primes DNS, TCP, and TLS)
    if (IsSet(gLLM_BASE_URL) && (gLLM_BASE_URL != "") && HasProp(gPrewarmedWebViewToo, "wv") && gPrewarmedWebViewToo.wv) {
        try {
            gPrewarmedWebViewToo.wv.Navigate(gLLM_BASE_URL . "/v1/models")
        }
    }
} catch as err {
    OutputDebug("[PrewarmSatellite] Error: " . err.Message)
}

cleanupSatellite(*) {
    global gPrewarmedWebViewToo
    try {
        if (gPrewarmedWebViewToo && HasProp(gPrewarmedWebViewToo, "wvc") && gPrewarmedWebViewToo.wvc) {
            browserPID := 0
            try {
                browserPID := gPrewarmedWebViewToo.BrowserProcessId
            }
            try {
                gPrewarmedWebViewToo.wvc.Close()
            }
            gPrewarmedWebViewToo := ""
            if (browserPID && ProcessExist(browserPID)) {
                ProcessClose(browserPID)
            }
        }
    }
}
OnExit(cleanupSatellite)

