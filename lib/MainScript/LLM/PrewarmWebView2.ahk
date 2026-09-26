#Requires AutoHotkey v2.0

; Global PID of the background satellite pre-warm process
global gPrewarmSatellitePID := 0

; Watchdog interval: check every 60 seconds that the satellite process is alive
global SATELLITE_WATCHDOG_INTERVAL_MS := 60000

/**
 * Launches and monitors a background satellite process to keep Edge WebView2 alive in RAM.
 * Running WebView2 in an independent satellite process ensures:
 * 1. Chromium and the network stack stay resident and warm for instant Response Window creation.
 * 2. The MainScript (tray icon, Win32 menus, hotkeys) is completely isolated from Chromium
 *    and immune to COM apartment, message pump, or modal loop crashes.
 * 3. An automatic watchdog continuously verifies the satellite is alive, restarting it if it crashes.
 */
prewarmWebView2() {
    global gPrewarmSatellitePID
    static restartTimestamps := []
    static MAX_RESTARTS_PER_MIN := 3
    static RESTART_WINDOW_MS := 60000
    static isWatchdogScheduled := false
    
    ; Ensure periodic watchdog is active
    if (!isWatchdogScheduled) {
        isWatchdogScheduled := true
        SetTimer(prewarmWebView2, SATELLITE_WATCHDOG_INTERVAL_MS)
        OnExit(cleanupPrewarmSatellite)
    }

    ; Satellite process is already alive and running
    if (gPrewarmSatellitePID && ProcessExist(gPrewarmSatellitePID))
        return

    ; Rate-limiting / anti-flapping guard (max 3 restarts per minute)
    currentTime := A_TickCount
    validTimestamps := []
    for ts in restartTimestamps {
        if ((currentTime - ts) < RESTART_WINDOW_MS) {
            validTimestamps.Push(ts)
        }
    }
    restartTimestamps := validTimestamps

    if (restartTimestamps.Length >= MAX_RESTARTS_PER_MIN) {
        OutputDebug("[PrewarmSatellite] Watchdog: restart rate limit exceeded (too many crashes), temporarily pausing.`n")
        return
    }

    try {
        ; Launch lib\prewarm_satellite.ahk hidden
        Run(getScriptRunCmd("lib\prewarm_satellite.ahk"), , "Hide", &gPrewarmSatellitePID)
        restartTimestamps.Push(currentTime)
    } catch as err {
        OutputDebug("[PrewarmSatellite] Launch failed: " . err.Message . "`n")
    }
}

/**
 * Terminates the satellite pre-warm process when MainScript exits.
 */
cleanupPrewarmSatellite(*) {
    global gPrewarmSatellitePID
    if (IsSet(gPrewarmSatellitePID) && gPrewarmSatellitePID && ProcessExist(gPrewarmSatellitePID)) {
        try {
            ; Ask satellite to close gracefully so its OnExit cleanup runs
            PostMessage(0x0012, 0, 0, , "ahk_pid " gPrewarmSatellitePID) ; WM_QUIT
            if (ProcessWaitClose(gPrewarmSatellitePID, 1) = 0) {
                ProcessClose(gPrewarmSatellitePID)
            }
        } catch {
            try ProcessClose(gPrewarmSatellitePID)
        }
        gPrewarmSatellitePID := 0
    }
}

