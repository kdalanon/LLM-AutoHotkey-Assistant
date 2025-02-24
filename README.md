<div align="center">

![bot](https://github.com/user-attachments/assets/fd5e1d8c-d19f-44f1-b590-2cc950ede6b9)

# LLM AutoHotkey Assistant

An AutoHotkey v2 application that utilizes [OpenRouter.ai](openrouter.ai/) to seamlessly integrate Large Language Models into your daily workflow. Process texts with customizable prompts by pressing a hotkey and interact with multiple AI models simultaneously.

![Release version](https://img.shields.io/github/v/release/kdalanon/LLM-AutoHotkey-Assistant?color=green&label=Download&style=for-the-badge)

</div>

## Key Features

### Text Processing with Hotkeys

Simply highlight text and press a hotkey to access AI-powered text processing.

#### Summarize

https://github.com/user-attachments/assets/c9bab953-ee7f-478a-b381-bbc39aeaa735

#### Translate

https://github.com/user-attachments/assets/b8f01752-0791-4332-a3ac-fac4b82bb74d

#### Define

https://github.com/user-attachments/assets/a9b43770-f7a3-4c24-9cfd-c9391be0abf6

#### Type custom prompts manually

Need to quickly type a prompt? Just choose the option to do so.

##### With copied text

https://github.com/user-attachments/assets/34da227d-e3ec-40e1-9084-432f75e3f99c

##### Without copied text

https://github.com/user-attachments/assets/5d1a16e6-0331-40a7-8490-8db0d8e5a19e

### Interactive Response Window

Chat with AI models, copy responses, retry requests, and view conversation history.

#### Chat

https://github.com/user-attachments/assets/2ffaf8e8-d07b-4ea1-a0e3-5c5fb850da4b

#### Copy

https://github.com/user-attachments/assets/1682f45e-f3ae-4740-9bd5-c82ee3e92f56

#### Retry

https://github.com/user-attachments/assets/0eb69c79-ede3-4a7c-a813-010caa7fc7d7

#### Chat History and Latest Response

https://github.com/user-attachments/assets/af0ba481-eea2-47d2-a6d2-ec33026fd3d6

### Auto-Paste Option

Automatically paste AI responses for seamless workflow integration.

https://github.com/user-attachments/assets/3818b83b-d1a1-4ca9-a1c2-adbae54f48d0

#### With custom prompt

https://github.com/user-attachments/assets/3723bb99-c44a-4431-8612-394d97fccf45

### Multi-Model Support

Use multiple AI models simultaneously.

https://github.com/user-attachments/assets/056f487f-d400-4772-9bb2-889bc1fa8a42

#### Reply to all option

https://github.com/user-attachments/assets/bf717dc8-387a-48e0-a48d-f1be2fbaa21b

#### Conversing with 4 models

https://github.com/user-attachments/assets/4653274f-a0d3-43eb-ab59-7d2d8cb4ce67

### Web search

https://github.com/user-attachments/assets/f960a7ef-9a6c-4217-8f86-44acfcea9122

## Getting Started

### Prerequisites

- [AutoHotkey v2](https://autohotkey.com/download/) (requires version `2.0.18` or later)
- Windows OS
- API key from [OpenRouter](https://openrouter.ai/settings/keys)

### Set up

1. Open the `lib` folder and edit the `SharedResources.ahk` script, then paste your API key inside the quotes.

![image](https://github.com/user-attachments/assets/de0fee67-8118-42a1-80d6-c435ad177b03)
  
2. Edit your prompts list and other options that you may need. See [Customization](#customization) below.

![image](https://github.com/user-attachments/assets/461364ea-f77f-488d-a364-18abde22da08)

3. Double-click `LLM AutoHotkey Assistant.ahk` to run the script. The app icon will appear in your system tray and will indicate that the script is running in the background.

![image](https://github.com/user-attachments/assets/93fa2fed-3222-494a-974c-5a037cf7e60d)

### Basic Usage

1. Highlight any text.
2. Press the backtick key to bring up the prompt menu.
3. Select a prompt to process the text.
4. View and interact with the AI response in the Response Window.
5. If you want to use the backtick character, you can press `CapsLock + Backtick` to suspend the script. A message will be displayed at the bottom indicating that the app is suspended.

![image](https://github.com/user-attachments/assets/e8611390-5fb3-4916-ac8f-774210b5a14d)

6. You can directly open the script or the `SharedResources` file through Notepad by right-clicking the tray icon.

![image](https://github.com/user-attachments/assets/f680e787-d048-4e20-9ccf-b25dbdb54e5a)

## Hotkeys

- `Backtick` Show prompt menu
- `Ctrl + S` Save and reload script (when editing)
- `CapsLock + backtick` Suspend/resume hotkeys
- `ESC` Cancel ongoing requests

## Customization

### Adding Custom Prompts

Edit the `prompts` array in the script to add your own prompts.

```autohotkey
prompts := [{
    promptName: "Your Prompt Name",
    menuText: "&1 - Menu Text",
    systemPrompt: "Your system prompt",
    APIModel: "model-name",
    isAutoPaste: true,
    isCustomPrompt: true
}]
```

**`promptName`** The name of the prompt. This will also be the Response Window title.

**`menuText`** The name of the prompt that will appear when your press the hotkey to bring up the menu. The ampersand (`&`) indicates that by pressing the character next to it after bringing up the menu, the prompt will be selected. In the example above, pressing the hotkey to bring up the menu (backtick) and then pressing number 1 will select that prompt.

**`systemPrompt`** This will be the initial prompt and will set the tone of the conversation.

**`APIModel`** Get your desired model from the [OpenRouter models website](https://openrouter.ai/models), click on the clipboard icon beside the name, and paste it here.

![image](https://github.com/user-attachments/assets/64f46a06-80ca-48b9-94bc-a57d3682a113)

Some example models:

- `openai/o3-mini-high`
- `anthropic/claude-3.5-sonnet`
- `google/gemini-2.0-flash-001`
- `deepseek/deepseek-r1`

In addition, you can also append `:online` to *any* model so that it will have the capability to do a web search. More on how it works [here](https://openrouter.ai/docs/features/web-search).

- `openai/o3-mini-high:online`
- `anthropic/claude-3.5-sonnet:online`
- `google/gemini-2.0-flash-001:online`
- `deepseek/deepseek-r1:online`

To enable multi-modal functionality, you can specify different API models, separating them with a comma and a space.

`openai/o3-mini-high, anthropic/claude-3.5-sonnet, google/gemini-2.0-flash-001:online, deepseek/deepseek-r1:online`

![image](https://github.com/user-attachments/assets/d878c9ab-6145-4aa3-a73c-463fee923459)

This will also enable the `Send message to all models` menu option after pressing the backtick hotkey.

![image](https://github.com/user-attachments/assets/93e3e62a-6fc7-4c0b-8f70-8d4416600ef4)

Special feature from OpenRouter: [Auto Router](https://openrouter.ai/openrouter/auto)

Your prompt will be processed by a meta-model and routed to one of dozens of models, optimizing for the best possible output. The APIModel is `openrouter/auto`

**isAutoPaste:** Setting this to `isAutoPaste: true` will paste the response from the LLM directly. Remove it if you don't need Auto Paste functionality.

**isCustomPrompt:** Setting this to `isCustomPrompt: true` will allow the prompt to show an input box to write custom messages. Remove it if you don't need Custom Prompt functionality.

**⚠ Important:** Make sure to add a comma at the end of the line before the Auto Paste or Custom Prompt functionality, like so:

![image](https://github.com/user-attachments/assets/ca0ce9a1-77ac-40a9-9eef-17de255ca599)

## Contributing

Contributions are welcome! Feel free to report bugs and suggest features.

## Credits

- [AutoHotkey](https://www.autohotkey.com/)
- [OpenRouter](https://openrouter.ai/)
- [Icon by Smashicons](https://www.flaticon.com/free-icon/bot_4712027)
- <a href="https://www.flaticon.com/free-icons/bot" title="bot icons">Bot icons created by Smashicons - Flaticon</a>

## Libraries used

- [AutoXYWH()](https://www.autohotkey.com/boards/viewtopic.php?t=1079) - Move control automatically when GUI resized ([converted to v2](https://www.autohotkey.com/boards/viewtopic.php?style=19&t=114445) by [Relayer](https://www.autohotkey.com/boards/memberlist.php?style=19&mode=viewprofile&u=97) and code improvements by [autoexec](https://www.autohotkey.com/boards/memberlist.php?style=19&mode=viewprofile&u=156305))
- [WebViewToo](https://github.com/The-CoDingman/WebViewToo/tree/main) by The-CoDingman -  Allows for use of the WebView2 Framework within AHK to create Web-based GUIs
- [DarkMsgBox](https://github.com/nperovic/DarkMsgBox) by nperovic -  Apply dark theme to your built-in MsgBox and InputBox
- [jsongo for AHKv2](https://github.com/GroggyOtter/jsongo_AHKv2) by GroggyOtter - JSON support for AHKv2 written completely in AHK
- [SystemThemeAwareToolTip](https://github.com/nperovic/SystemThemeAwareToolTip/) by nperovic - Make your ToolTip style conform to the current system theme
- [ToolTipEx](https://github.com/nperovic/ToolTipEx) by nperovic -  Enable the ToolTip to track the mouse cursor smoothly and permit the ToolTip to be moved by dragging
