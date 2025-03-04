; ----------------------------------------------------
; OpenRouter API Key
; ----------------------------------------------------

APIKey := "Your API Key here"

; ----------------------------------------------------
; Prompts
; ----------------------------------------------------

prompts := [{
    promptName: "Multi-model custom prompt",
    menuText: "&1 - Gemini, GPT-4o, Claude",
    systemPrompt: "You are a helpful assistant. Follow the instructions that I will provide or answer any questions that I will ask. My first query is the following:",
    APIModels: "
    (
    google/gemini-2.0-flash-thinking-exp:free,
    openai/gpt-4o,
    anthropic/claude-3.7-sonnet
    )",
    isCustomPrompt: true,
    customPromptInitialMessage: "How can I leverage the power of AI in my everyday tasks?",
    tags: ["&Custom prompts", "&Multi-models"]
}, {
    promptName: "Rephrase",
    menuText: "&1 - Rephrase",
    systemPrompt: "Your task is to rephrase the following text or paragraph in English to ensure clarity, conciseness, and a natural flow. If there are abbreviations present, expand it when it's used for the first time, like so: OCR (Optical Character Recognition). The revision should preserve the tone, style, and formatting of the original text. If possible, split it into paragraphs to improve readability. Additionally, correct any grammar and spelling errors you come across. You should also answer follow-up questions if asked. Respond with the rephrased text only:",
    APIModels: "
    (
    google/gemini-2.0-flash-thinking-exp:free
    )",
    tags: ["&Text manipulation"]
}, {
    promptName: "Summarize",
    menuText: "&2 - Summarize",
    systemPrompt: "Your task is to summarize the following article in English to ensure clarity, conciseness, and a natural flow. If there are abbreviations present, expand it when it's used for the first time, like so: OCR (Optical Character Recognition). The summary should preserve the tone, style, and formatting of the original text, and should be in its original language. If possible, split it into paragraphs to improve readability. Additionally, correct any grammar and spelling errors you come across. You should also answer follow-up questions if asked. Respond with the rephrased text only:",
    APIModels: "
    (
    google/gemini-2.0-flash-thinking-exp:free
    )",
    tags: ["&Text manipulation", "&Articles"]
}, {
    promptName: "Translate to English",
    menuText: "&3 - Translate to English",
    systemPrompt: "Generate an English translation for the following text or paragraph, ensuring the translation accurately conveys the intended meaning or idea without excessive deviation. If there are abbreviations present, expand it when it's used for the first time, like so: OCR (Optical Character Recognition). The translation should preserve the tone, style, and formatting of the original text. If possible, split it into paragraphs to improve readability. Additionally, correct any grammar and spelling errors you come across. You should also answer follow-up questions if asked. Respond with the rephrased text only:",
    APIModels: "
    (
    google/gemini-2.0-flash-thinking-exp:free
    )",
    tags: ["&Text manipulation", "Language"]
}, {
    promptName: "Define",
    menuText: "&4 - Define",
    systemPrompt: "Provide and explain the definition of the following, providing analogies if needed. In addition, answer follow-up questions if asked:",
    APIModels: "
    (
    google/gemini-2.0-flash-thinking-exp:free
    )",
    tags: ["&Text manipulation", "Learning"]
}, {
    promptName: "Auto-paste custom prompt",
    menuText: "&5 - Auto-paste custom prompt",
    systemPrompt: "You are a helpful assistant. Follow the instructions that I will provide or answer any questions that I will ask.",
    APIModels: "
    (
    google/gemini-2.0-flash-thinking-exp:free
    )",
    isCustomPrompt: true,
    isAutoPaste: true,
    tags: ["&Custom prompts", "&Auto paste"]
}, {
    promptName: "Web search",
    menuText: "&6 - Web search",
    systemPrompt: "Provide the latest information and answer follow-up questions that I will ask. My first query is the following:",
    APIModels: "
    (
    google/gemini-2.0-flash-thinking-exp:free:online
    )",
    tags: ["&Web search", "Learning"]
}, {
    promptName: "Web search custom prompt",
    menuText: "&7 - Web search custom prompt",
    systemPrompt: "Provide the latest information and answer follow-up questions that I will ask. My first query is the following:",
    APIModels: "
    (
    google/gemini-2.0-flash-thinking-exp:free:online
    )",
    isCustomPrompt: true,
    tags: ["&Web search", "&Custom prompts"]
}, {
    promptName: "Deep thinking multi-model custom prompt",
    menuText: "&1 - Deep thinking multi-model custom prompt",
    systemPrompt: "You are a helpful assistant. Follow the instructions that I will provide or answer any questions that I will ask. My first query is the following:",
    APIModels: "
    (
    perplexity/r1-1776,
    openai/o3-mini-high,
    anthropic/claude-3.7-sonnet:thinking,
    google/gemini-2.0-flash-thinking-exp:free
    )",
    isCustomPrompt: true,
    customPromptInitialMessage: "This is a message template."
}, {
    promptName: "Deep thinking multi-model web search custom prompt",
    menuText: "&2 - Deep thinking multi-model custom prompt web search",
    systemPrompt: "Provide information about the following. In addition, answer follow-up questions that I will ask or follow any instructions that I may provide:",
    APIModels: "
    (
    perplexity/r1-1776:online,
    openai/o3-mini-high:online,
    anthropic/claude-3.7-sonnet:thinking:online,
    google/gemini-2.0-flash-thinking-exp:free:online
    )",
    isCustomPrompt: true
}, {
    promptName: "Multi-line prompt example",
    menuText: "Multi-line prompt example",
    systemPrompt: "
    (
    This prompt is broken down into multiple lines.

    Here is the second sentence.

    And the third one.

    As long as the prompt is inside the quotes and the opening and closing parenthesis,

    it will be valid.
    )",
    APIModels: "
    (
    google/gemini-2.0-flash-thinking-exp:free
    )"
}]