<div align="center">

![bot](https://github.com/user-attachments/assets/fd5e1d8c-d19f-44f1-b590-2cc950ede6b9)

# LLM AutoHotkey Assistant

An AutoHotkey v2 application that utilizes [OpenRouter.ai](https://openrouter.ai/) to seamlessly integrate Large Language Models into your daily workflow. Process texts with customizable prompts by pressing a hotkey and interact with multiple AI models simultaneously.



</div>

> [!NOTE] 
> Want to ask questions on how to use this app? [Download this documentation](https://github.com/kdalanon/LLM-AutoHotkey-Assistant/raw/refs/heads/main/README.md) and include it in your prompt when using your preferred AI chat app.

## 🔑 Key Features

### 1️⃣ Text Processing with Keyboard Hotkeys

Simply highlight any text and press [a hotkey](#hotkeys) to access AI-powered text processing.

#### Summarize

https://github.com/user-attachments/assets/c9bab953-ee7f-478a-b381-bbc39aeaa735

#### Translate

https://github.com/user-attachments/assets/b8f01752-0791-4332-a3ac-fac4b82bb74d

#### Define

https://github.com/user-attachments/assets/a9b43770-f7a3-4c24-9cfd-c9391be0abf6

#### Type custom prompts manually

##### With copied text

https://github.com/user-attachments/assets/34da227d-e3ec-40e1-9084-432f75e3f99c

##### Without copied text

https://github.com/user-attachments/assets/5d1a16e6-0331-40a7-8490-8db0d8e5a19e

### 2️⃣ Interactive Response Window

#### Chat

https://github.com/user-attachments/assets/2ffaf8e8-d07b-4ea1-a0e3-5c5fb850da4b

#### Copy

https://github.com/user-attachments/assets/1682f45e-f3ae-4740-9bd5-c82ee3e92f56

#### Retry

https://github.com/user-attachments/assets/0eb69c79-ede3-4a7c-a813-010caa7fc7d7

#### Chat History and Latest Response

https://github.com/user-attachments/assets/af0ba481-eea2-47d2-a6d2-ec33026fd3d6

### 3️⃣ Auto-Paste Option

https://github.com/user-attachments/assets/3818b83b-d1a1-4ca9-a1c2-adbae54f48d0

#### With custom prompt

https://github.com/user-attachments/assets/3723bb99-c44a-4431-8612-394d97fccf45

### 4️⃣ Multi-Model Support

https://github.com/user-attachments/assets/056f487f-d400-4772-9bb2-889bc1fa8a42

#### "Send message to all models" feature

https://github.com/user-attachments/assets/bf717dc8-387a-48e0-a48d-f1be2fbaa21b

#### Conversing with 10 models

https://github.com/user-attachments/assets/4e8a27cd-5a9f-4066-8bbd-3010dc635948

### 5️⃣ Web search

https://github.com/user-attachments/assets/f960a7ef-9a6c-4217-8f86-44acfcea9122

## 🚀 Getting Started

### Prerequisites

- [AutoHotkey v2](https://autohotkey.com/download/) (requires version `2.0.18` or later)
- Windows OS
- [API key](https://openrouter.ai/settings/keys) from [OpenRouter.ai](https://openrouter.ai)

### Set up

1. Open the `lib` folder and edit the `SharedResources.ahk` script, then paste your API key inside the quotes. Save the file afterwards.

![image](https://github.com/user-attachments/assets/de0fee67-8118-42a1-80d6-c435ad177b03)
  
2. Edit your prompts list and other options that you may need. See [Editing prompts](#editing-prompts) below.

![image](https://github.com/user-attachments/assets/461364ea-f77f-488d-a364-18abde22da08)

3. Double-click `LLM AutoHotkey Assistant.ahk` to run the script. The app icon will appear in your system tray and will indicate that the script is running in the background.

![image](https://github.com/user-attachments/assets/93fa2fed-3222-494a-974c-5a037cf7e60d)

## 🖱️ Usage

1. Highlight any text.
2. Press the backtick key to bring up the prompt menu.
3. Select a prompt to process the text.
4. View and interact with the AI response in the Response Window.
5. If you want to use the backtick character, you can press `CapsLock + Backtick` to suspend and unsuspend the script. A message will be displayed at the bottom indicating that the app is suspended.

![image](https://github.com/user-attachments/assets/e8611390-5fb3-4916-ac8f-774210b5a14d)

6. You can directly open the script or the `SharedResources` file through Notepad by right-clicking the tray icon.

![image](https://github.com/user-attachments/assets/f680e787-d048-4e20-9ccf-b25dbdb54e5a)

### Hotkeys

- `Backtick` Show prompt menu
- `Ctrl + S` Will automatically save and reload the script when editing in Notepad
- `CapsLock + backtick` Suspend/resume hotkeys
- `ESC` Cancel ongoing requests

### Running the script at startup

You can automatically run the script at startup by following the steps below:

1. Copy `LLM AutoHotkey Assistant.ahk`
2. Enter `shell:startup` at the File Explorer address bar and press `enter`.
3. Right-click ➡ Paste shortcut

### Editing prompts

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

#### promptName

The name of the prompt. This will also be the Response Window title, in addition to the chosen API model.

![image](https://github.com/user-attachments/assets/130f2147-352f-4bb1-8dd7-6788c58c2853)

### menuText

The name of the prompt that will appear when your press the hotkey to bring up the menu. The ampersand (`&`) is a shortcut key and indicates that by pressing the character next to it after bringing up the menu, the prompt will be selected.

![image](https://github.com/user-attachments/assets/36e9e74e-0885-42ae-9122-0f0a04d973b1)

#### systemPrompt

This will be the initial prompt and will set the tone of the conversation.

##### Splitting a long prompt into a series of multiple lines

Long prompts can be divided into new lines to improve readability.

```autohotkey
prompts := [{
    promptName: "Long prompt here",
    menuText: "&1 - Long prompt here",
    systemPrompt: "
    (
    This prompt is broken down into multiple lines.

    Here is the second sentence.

    And the third one.

    As long as the prompt is inside the quotes and the opening and closing parenthesis,

    it will be valid.

    The end.
    )",
    APIModel: "openrouter/auto"
}]
```

![image](https://github.com/user-attachments/assets/b3a78e61-f117-4ad0-af87-3c11a259e168)

#### APIModel

The API model that will be used to process the prompt.

Get your desired model from the [OpenRouter models website](https://openrouter.ai/models), click on the clipboard icon beside the name, and paste it here.

![image](https://github.com/user-attachments/assets/64f46a06-80ca-48b9-94bc-a57d3682a113)

Some example models:

- `openai/o3-mini-high`
- `anthropic/claude-3.5-sonnet`
- `google/gemini-2.0-flash-001`
- `deepseek/deepseek-r1`

In addition, you can also append `:online` to *any* model so that it will have the capability to do a web search. Check [here](https://openrouter.ai/docs/features/web-search) to learn how it works.

- `openai/o3-mini-high:online`
- `anthropic/claude-3.5-sonnet:online`
- `google/gemini-2.0-flash-001:online`
- `deepseek/deepseek-r1:online`

To enable multi-model functionality, you can specify different API models, separating them with a comma and a space.

`openai/o3-mini-high, anthropic/claude-3.5-sonnet, google/gemini-2.0-flash-001:online, deepseek/deepseek-r1:online`

![image](https://github.com/user-attachments/assets/d878c9ab-6145-4aa3-a73c-463fee923459)

This will also enable the `Send message to all models` menu option after pressing the backtick hotkey. The shortcut key is `S`.

![image](https://github.com/user-attachments/assets/93e3e62a-6fc7-4c0b-8f70-8d4416600ef4)

Since this app uses [OpenRouter.ai](https://openrouter.ai/) service, you get access to the latest models as soon as they're available.

##### Auto Router

Your prompt will be processed by a meta-model and [routed to one of dozens of models](https://openrouter.ai/openrouter/auto), optimizing for the best possible output. To use it, just enter `openrouter/auto` in the `APIModel` field.

#### isAutoPaste

Setting this to `isAutoPaste: true` will paste the response from the model directly in Markdown format. Remove it if you don't need Auto Paste functionality.

> [!NOTE]  
> The app will automatically disable the Auto Paste functionality if more than one model is set, and will show the Response Window instead.

Difference between `isAutoPaste: true` and `Copy`:

| Setting             | Format        |
|----------------------|---------------|
| `Copy` button from the Response Window | HTML          |
| `isAutoPaste: true`  | Markdown      |

#### isCustomPrompt

Setting this to `isCustomPrompt: true` will allow the prompt to show an input box to write custom prompts. Remove it if you don't need Custom Prompt functionality.

![image](https://github.com/user-attachments/assets/951a3133-bf21-44e6-8959-b98ab26bbbb1)

> [!IMPORTANT]  
> Make sure to add a comma at the end of the line before the Auto Paste or Custom Prompt functionality:

![image](https://github.com/user-attachments/assets/ca0ce9a1-77ac-40a9-9eef-17de255ca599)

## 🔒 Privacy policy

The app does not collect logs, prompts, or copied text. It simply bundles up the conversation between you and your chosen API model and sends the request to [OpenRouter.ai](https://openrouter.ai/). See their privacy policy [here](https://openrouter.ai/privacy). Adjust your OpenRouter privacy settings [here](https://openrouter.ai/settings/privacy).

4 temporary files are written to the `temp` folder (`C:\Users\username\AppData\Local\Temp`) after selecting a prompt for each API model:

![image](https://github.com/user-attachments/assets/a465eee3-de7d-4a20-9c89-e9e62e985318)

- `chatHistoryJSONRequest` contains the conversation between you and the model.

![image](https://github.com/user-attachments/assets/619fb67d-1ff4-44d3-9150-c50ff852368d)

- `cURLOutput` contains the model's response.

![image](https://github.com/user-attachments/assets/d66e709b-679a-44b9-bb80-80d1b9a1d72c)

- `responseWindowData` contains the data needed for Response Window to display and interact with the model's response.

![image](https://github.com/user-attachments/assets/8909cc50-7fe9-434a-ba40-fa2ae5556bce)

- `cURLCommand` contains the cURL command that will be executed to the API.

![image](https://github.com/user-attachments/assets/16daecd5-4b46-46ae-b375-951d8c1857d5)

These files will be kept open while the Response Window is active, and will be deleted after performing the following actions:

- Pasting the response when `isAutoPaste: true` is set
- Pressing `ESC` key *after* processing the first request but *before* getting the model's response (e.g. Response Window is not opened for the first time)
- Closing the Response Window

## ✅ Features planned on future releases

- Timestamp messages in Chat History
- File upload (e.g. `md`, `txt`, images, etc.)
- Have an option to select an area of the screen to automatically upload to Response Window as image
- Importing and exporting conversations
- Conversation log viewer
- Delete individual messages

## 🤝 Contributing

Contributions are welcome! Feel free to report bugs and suggest features.

## 🏅 Credits

- [AutoHotkey](https://www.autohotkey.com/)
- [OpenRouter](https://openrouter.ai/)
- [Icon by Smashicons](https://www.flaticon.com/free-icon/bot_4712027)

## 📦 Libraries used

- [AutoXYWH](https://www.autohotkey.com/boards/viewtopic.php?t=1079) - Move control automatically when GUI resizes ([converted to v2](https://www.autohotkey.com/boards/viewtopic.php?style=19&t=114445) by [Relayer](https://www.autohotkey.com/boards/memberlist.php?style=19&mode=viewprofile&u=97) and code improvements by [autoexec](https://www.autohotkey.com/boards/memberlist.php?style=19&mode=viewprofile&u=156305))
- [The-CoDingman/WebViewToo](https://github.com/The-CoDingman/WebViewToo/tree/main) - Allows for use of the WebView2 Framework within AHK to create Web-based GUIs
- [GroggyOtter/jsongo_AHKv2](https://github.com/GroggyOtter/jsongo_AHKv2) - JSON support for AHKv2 written completely in AHK
- [nperovic/DarkMsgBox](https://github.com/nperovic/DarkMsgBox) - Apply dark theme to your built-in MsgBox and InputBox
- [nperovic/SystemThemeAwareToolTip](https://github.com/nperovic/SystemThemeAwareToolTip/) - Make your ToolTip style conform to the current system theme
- [nperovic/ToolTipEx](https://github.com/nperovic/ToolTipEx) - Enable the ToolTip to track the mouse cursor smoothly and permit the ToolTip to be moved by dragging

## 💡 Inspiration - Similar apps with the same functionality written in AutoHotkey v2

- [overflowy/chat-key](https://github.com/overflowy/chat-key) - Supercharge your productivity with ChatGPT and AutoHotkey 🚀
- [ecornell/ai-tools-ahk](https://github.com/ecornell/ai-tools-ahk) - AI Tools - AutoHotkey - Enable global hotkeys to run custom OpenAI prompts on text in any window.
- [kdalanon/ChatGPT-AutoHotkey-Utility](https://github.com/kdalanon/ChatGPT-AutoHotkey-Utility) - An AutoHotkey script that uses ChatGPT API to process text.
