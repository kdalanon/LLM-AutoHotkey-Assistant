#Requires AutoHotkey v2.0

; ----------------------------------------------------
; Call main.js functions
; ----------------------------------------------------

callWebJavaScriptFunction(target, data := unset) {
    
    global JSON_INDENT_SPACER

    msgObj := { target: target }

    ; If data is provided, add it to the message object
    msgObj.data := IsSet(data) ? data : unset

    ; jsonStr := jsongo.Stringify(msgObj, , JSON_INDENT_SPACER)
    jsonStr := jsongo.Stringify(msgObj)
    
    logStreamDebug("[AHK] callWebJavaScriptFunction -> " target)
    responseWindow.PostWebMessageAsJSON(jsonStr)
}

