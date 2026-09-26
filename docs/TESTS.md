# Acceptance Test Plan and Testing Guide: LLM AutoHotkey Assistant

This document serves as a reference manual and validation checklist for testing **LLM AutoHotkey Assistant** during development, reviews, and releases.

---

## 1. Prerequisites & Test Environment

- **Operating System**: Windows 10 or Windows 11.
- **Interpreter**: AutoHotkey v2 (64-bit).
- **System Component**: Microsoft Edge WebView2 Runtime installed (bundled by default on Windows 10/11).
- **Configuration**:
  - Valid API key or reachable local/remote LLM server configured in `config/Preferences.ahk` / `config/Prompts.ahk`.
  - At least one active model declared in `config/Prompts.ahk`.

---

## 2. Acceptance Checklist

| # | Domain | Test Case | Status |
|---|---|---|---|
| **1.1** | Startup | Launch with no syntax errors or blocking dialogs | [ ] |
| **1.2** | Tray Menu | Access to system tray menu, submenus, and reload | [ ] |
| **1.3** | Options Menu | Submenu `&5 - Theme`, `&4 - View usage activity`, `&6 - Toggle Debug Mode` | [ ] |
| **2.1** | Invocation | Global shortcut with text selected (immediate query) | [ ] |
| **2.2** | Invocation | Global shortcut without text selected (opens `InputWindow`) | [ ] |
| **2.3** | Streaming | Progressive real-time response (SSE) in `Response Window` | [ ] |
| **2.4** | Interruption | Cancel active stream (`Esc` or Stop button) | [ ] |
| **3.1** | Navigation | Instant keyboard navigation and scrolling (`PgUp`, `PgDown`, `Home`, `End`) without mouse click | [ ] |
| **3.2** | Navigation | Button keyboard shortcuts (`Alt+T`, `Alt+R`, `Alt+H`, `Alt+S`, `Alt+L`, `Ctrl+W`) | [ ] |
| **3.3** | Code Rendering | Horizontal scrolling confined inside code blocks without window overflow | [ ] |
| **3.4** | Refresh | Pressing `F5` or `Ctrl+R`: content refreshed without blanking the page | [ ] |
| **4.1** | Sessions | Automatic session file persistence in `%APPDATA%\LLM AutoHotkey Assistant` | [ ] |
| **4.2** | Sessions | Reopening previous session from Sessions menu after script reload | [ ] |
| **4.3** | Sessions | Cold start: immediate text rendering without black or empty screen | [ ] |
| **4.4** | Sessions | Continuing conversation in a reopened session | [ ] |
| **5.1** | Themes | Dynamic theme switching (Dark / Light / System) from Options menu | [ ] |
| **5.2** | Themes | Real-time propagation across opened windows (DWM title bar + CSS + highlight.js) | [ ] |
| **5.3** | Themes | Persistence in `config/Preferences.ahk` across reloads | [ ] |
| **5.4** | Themes | Detection of Windows application theme (`AppsUseLightTheme`) in System mode | [ ] |

---

## 3. Detailed Test Scenarios

### Scenario 1: Startup, Taskbar Notification, and Menus

1. **Script Startup**:
   - Run `LLM AutoHotkey Assistant.ahk`.
   - **Expected Result**: Application icon appears in the system tray. Notification popup displays shortcut and tray location. No AHK error dialogs.
2. **Main Tray Menu**:
   - Right-click the system tray icon.
   - **Expected Result**: Menu opens with principal items (Prompts, Sessions, Options, Reload Script, Suspend Hotkeys, Exit).
3. **Options Submenu**:
   - Navigate into `Options`.
   - **Expected Result**:
     - `&4 - View usage activity`.
     - Separator.
     - `&5 - Theme` submenu with 3 options: `&1 - Dark`, `&2 - Light`, `&3 - System`. Active option is checked.
     - Separator.
     - `&6 - Toggle Debug Mode`.

---

### Scenario 2: Query Invocation and LLM Streaming

1. **With Selected Text**:
   - In any text editor or browser, select a sentence.
   - Trigger prompt shortcut (e.g., `Alt+Shift+O` or tray menu).
   - **Expected Result**: `Response Window` opens immediately with appropriate title. Response is streamed in real time (SSE).
2. **Without Selected Text**:
   - Ensure no text is selected and trigger prompt.
   - **Expected Result**: Centered `InputWindow` opens with focus on the text area.
   - Type a question and confirm (`Ctrl+Enter` or Send button).
   - **Expected Result**: `Response Window` takes over and streams response.
3. **Stream Interruption**:
   - While response is being generated, press `Esc` or click `Stop`.
   - **Expected Result**: Streaming stops immediately, partial response is retained, and action buttons are re-enabled.

---

### Scenario 3: Ergonomics, Scrolling, and Response Window Shortcuts

1. **Keyboard Navigation (Without Mouse)**:
   - Open a long response (or an existing multi-turn session).
   - **Without clicking anywhere with the mouse**, press `PgDown`, then `PgUp`.
   - **Expected Result**: Window scrolls up and down immediately.
   - Test `End` (scrolls to bottom) and `Home` (scrolls to top).
2. **Horizontal Code Block Scrolling**:
   - Ask LLM to generate a very long code line or broad Markdown table.
   - **Expected Result**: Code block `<pre><code>` has its own horizontal scrollbar. Main window does not scroll horizontally, and top toolbar buttons remain visible and properly aligned.
3. **Page Refresh (`F5` / `Ctrl+R`)**:
   - In a response window containing text, press `F5` or `Ctrl+R`.
   - **Expected Result**: Content is not cleared. Text remains intact and styling / Markdown rendering is re-applied cleanly.
4. **Action Shortcuts**:
   - `Alt+T`: Focuses input area for a follow-up question.
   - `Alt+H`: Toggles between conversation history and latest response.
   - `Alt+R`: Regenerates latest response.
   - `Alt+S`: Saves session.
   - `Ctrl+W` / `Esc`: Closes response window.

---

### Scenario 4: Session Management and Cold Start

1. **Session Persistence**:
   - Perform a conversation turn with the LLM.
   - Check directory `%APPDATA%\LLM AutoHotkey Assistant`.
   - **Expected Result**: Timestamped JSON session file is saved.
2. **Cold Start Reopening**:
   - Reload script via tray menu (*Reload Script*).
   - Without opening any new query window first, navigate to `Sessions` menu and select an older session.
   - **Expected Result**: Window opens with configured theme, and complete Markdown text displays immediately without blank/black screen.
3. **Follow-up in Reopened Session**:
   - In reopened session, click `Ask follow-up question` (`Alt+T`).
   - Enter a question and submit.
   - **Expected Result**: LLM response incorporates previous conversation context and appends to the thread.

---

### Scenario 5: Color Themes (Dark / Light / System)

1. **Dark Theme**:
   - Menu `Options` > `&5 - Theme` > `&1 - Dark`.
   - **Expected Result**: Title bar turns dark (DWM attribute), window background turns dark, and syntax highlighting switches to `atom-one-dark`.
2. **Light Theme**:
   - Menu `Options` > `&5 - Theme` > `&2 - Light`.
   - **Expected Result**: Title bar turns light, window background turns light, and syntax highlighting switches to `atom-one-light`.
3. **System Theme**:
   - Menu `Options` > `&5 - Theme` > `&3 - System`.
   - **Expected Result**: Automatically adopts Windows application theme (`AppsUseLightTheme`).
4. **Theme Persistence**:
   - Select a theme, then reload the script (*Reload Script*).
   - Inspect `config/Preferences.ahk`.
   - **Expected Result**: Constant `global gTHEME := "..."` preserves selected value across reloads.

---

## 4. Running the Automated Test Suite

To run automated unit tests and syntax validation:

```powershell
& "Path\To\AutoHotkey64.exe" "tests\src\run_tests.ahk"
```

The automated test suite verifies:
- Syntax integrity of all AHK files via `/Validate`.
- Physical presence of all Web/CSS/JS assets.
- Theme resolution and persistence logic.
- JSON serialization and deserialization via `jsongo`.
- Chat history Markdown generation and role formatting.
- Screen boundary clamping and positioning logic.
