===============================================================================
WebView2.ahk vs WebViewToo.ahk - Architecture & Role Overview
===============================================================================

In this project, Microsoft Edge WebView2 is used to render modern, HTML/CSS/JS-
based response windows ( Response Window.ahk) and maintain a background keep-
alive instance in LLM AutoHotkey Assistant.ahk.

Two COTS (Commercial Off-The-Shelf) libraries in this folder handle WebView2:
- WebView2.ahk
- WebViewToo.ahk

-------------------------------------------------------------------------------
1. SUMMARY OF DIFFERENCES
-------------------------------------------------------------------------------
- WebView2.ahk: Low-level driver / C++ & Win32 COM wrapper (the foundation).
- WebViewToo.ahk: High-level application framework / GUI wrapper (the toolkit).

Notice that WebViewToo.ahk directly includes WebView2.ahk (#Include WebView2.ahk)
and builds entirely on top of it.

-------------------------------------------------------------------------------
2. WebView2.ahk (by thqby)
-------------------------------------------------------------------------------
Author : thqby
Source : https://github.com/thqby/ahk2_lib/tree/master/WebView2
Role   : Low-level Win32 COM / C++ binding to Microsoft's WebView2Loader.dll.

What it does:
- Loads the native WebView2Loader.dll into memory (from 32bit\ or 64bit\).
- Defines the raw COM interfaces, VTables, struct definitions, and async
  promises (using Promise.ahk) for Microsoft Edge WebView2 (ICoreWebView2,
  ICoreWebView2Controller, ICoreWebView2Environment, etc.).
- Exposes direct 1:1 access to official Microsoft Win32 WebView2 APIs.

Why not use it alone?
Using raw WebView2.ahk directly requires significant boilerplate code:
you must manually create a Win32 window/Gui, handle Windows resize messages
(WM_SIZE), manage DPI scaling, handle window focus, and implement custom
bidirectional messaging between JavaScript and AutoHotkey.

-------------------------------------------------------------------------------
3. WebViewToo.ahk (by Ryan Dingman / Panaku / The-CoDingman)
-------------------------------------------------------------------------------
Author : Ryan Dingman (Panaku / The-CoDingman)
Source : https://github.com/The-CoDingman/WebViewToo
Role   : High-level GUI framework designed to make building web-based desktop
         UIs in AutoHotkey v2 as simple as using standard AHK Guis.

What it adds on top of WebView2.ahk:
1. Automatic GUI Management:
   - Automatically instantiates an AutoHotkey Gui container.
   - Automatically hooks the Size event to resize the WebView2 control
     whenever the window is resized.
2. Bidirectional Communication (AHK <-> JavaScript):
   - Injects the AHK component into the webpage DOM.
   - Provides AddCallbackToScript(name, fn) so JavaScript can directly call
     AutoHotkey functions (via window.chrome.webview.hostObjects / ahk).
3. Custom Caption / Borderless Windows:
   - Supports frameless windows (CustomCaption) with custom HTML/CSS buttons
     for Minimize, Maximize, Restore, and Close.
4. Simplified Navigation & Resource Loading:
   - Load(filePathOrUrl) handles relative paths and local resource loading.
   - Handles embedded resources in compiled mode (CreateFileFromResource).
5. Lifecycle Management:
   - Automatically registers OnExit handlers to clean up the WebView2 controller
     and child processes on exit (OnExit -> Destroy()).

-------------------------------------------------------------------------------
4. HOW THEY ARE USED IN THIS PROJECT
-------------------------------------------------------------------------------
- Response Window.ahk:
    Instantiates responseWindow := WebViewToo(...)
    It loads Response Window resources\index.html and communicates with
    JavaScript via callbacks and web messages.

- LLM AutoHotkey Assistant.ahk (Main Script):
    Instantiates a dormant, background WebViewToo instance via prewarmWebView2()
    in lib\MainScript\LLM\PrewarmWebView2.ahk. This keeps msedgewebview2.exe
    warm in RAM so opening response windows is instantaneous.
===============================================================================
