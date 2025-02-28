<div align="center">

![bot](https://github.com/user-attachments/assets/fd5e1d8c-d19f-44f1-b590-2cc950ede6b9)

# LLM AutoHotkey Assistant

An AutoHotkey v2 application that utilizes [OpenRouter.ai](https://openrouter.ai/) to seamlessly integrate Large Language Models into your daily workflow. Process texts with customizable prompts by pressing a hotkey and interact with multiple AI models simultaneously.

[![Download](https://img.shields.io/github/v/release/kdalanon/LLM-AutoHotkey-Assistant?style=for-the-badge&color=blue&label=Download%20here!)](https://github.com/kdalanon/LLM-AutoHotkey-Assistant/releases/latest)

![Total downloads](https://img.shields.io/github/downloads/kdalanon/LLM-AutoHotkey-Assistant/total?style=for-the-badge&color=blue&label=Total%20Downloads)

</div>

> [!TIP] 
> Want to ask questions on how to use this app? [Download this documentation](https://github.com/kdalanon/LLM-AutoHotkey-Assistant/raw/refs/heads/main/README.md) and include it in your prompt when using your preferred AI chat app!
>
> Navigate through this page by clicking on the menu button at the upper-right corner.
> ![image](https://github.com/user-attachments/assets/eddb0216-f0db-4ecf-9231-81592d4aa454)

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

#### Conversing with 10 models at once

https://github.com/user-attachments/assets/62a6959a-e7b7-4379-b1c3-e82f131686ed

### 5️⃣ Web search

https://github.com/user-attachments/assets/f960a7ef-9a6c-4217-8f86-44acfcea9122

## 🚀 Getting Started

### Prerequisites

- [AutoHotkey v2](https://autohotkey.com/download/) (requires version `2.0.18` or later)
- Windows OS
- [API key](https://openrouter.ai/settings/keys) from [OpenRouter.ai](https://openrouter.ai)

### Set up

1. Run the `LLM AutoHotkey Assistant.ahk` script and press the `backtick` hotkey.
2. Select `Options` ➡ `Add API Key`

![image](https://github.com/user-attachments/assets/2aabef64-9695-410e-8f33-0058163ebad3)

3. Paste your [OpenRouter.ai API key](https://openrouter.ai/settings/keys) inside the quotes. Save the file afterwards, then press the `backtick` hotkey again and select `Options` ➡ `Reload script` 

![image](https://github.com/user-attachments/assets/13b2a4e8-afcb-4929-9055-5850a0ad7566)

4. You can now use the app! If you want to further enhance your experience and customize your prompts, press the `backtick` hotkey and select `Options` ➡ `Edit prompts`. See [Editing prompts](#editing-prompts) for more info.

> [!NOTE]
> The app icon will appear in your system tray and will indicate that the script is running in the background.
> To terminate the script, right-click the icon and select `Exit`.

![image](https://github.com/user-attachments/assets/93fa2fed-3222-494a-974c-5a037cf7e60d)

## 🖱️ Usage

1. Highlight any text.
2. Press the `backtick` hotkey to bring up the prompt menu.
3. Select a prompt to process the text.
4. View and interact with the AI response in the Response Window.
5. If you want to use the `backtick` character, you can press `CapsLock + Backtick` to suspend and unsuspend the script. A message will be displayed at the bottom indicating that the app is suspended.

![image](https://github.com/user-attachments/assets/e8611390-5fb3-4916-ac8f-774210b5a14d)

### Hotkeys

- `Backtick` Show prompt menu
- `Ctrl + S` Will automatically save and reload the script when editing in Notepad (or any other editing tool that matches `LLM AutoHotkey Assistant.ahk` title window)
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
    copyAsMarkdown: true,
    isAutoPaste: true,
    isCustomPrompt: true,
    customPromptInitialMessage: "Initial message that will show on Custom Prompt window"
}]
```

#### promptName

The name of the prompt. This will also be shown in the tooltip and the Response Window title, in addition to the chosen API model.

![image](https://github.com/user-attachments/assets/5bb775b0-3309-4395-9ea7-7075da490107)

![image](https://github.com/user-attachments/assets/af1c530c-7354-43f7-a62a-192d6d023e24)

### menuText

The name of the prompt that will appear when your press the hotkey to bring up the menu. The ampersand (`&`) is a shortcut key and indicates that by pressing the character next to it after bringing up the menu, the prompt will be selected.

![image](https://github.com/user-attachments/assets/309c7959-250c-4178-8b1f-94a62f913ee1)

> [!NOTE]
> You can have duplicate shortcut keys for the prompts. Pressing the shortcut key will highlight the first prompt, and pressing the shortcut key again will highlight the second prompt. Pressing `Enter` afterwards will select the prompt and initiate the request.

#### systemPrompt

This will be the initial prompt and will set the tone of the conversation.

##### Splitting a long prompt into a series of multiple lines

Long prompts can be divided into new lines to improve readability.

```autohotkey
prompts := [{
    promptName: "Multi-line prompt here",
    menuText: "&1 - Multi-line prompt here",
    systemPrompt: "
    (
    This prompt is broken down into multiple lines.

    Here is the second sentence.

    And the third one.

    As long as the prompt is inside the quotes and the opening and closing parenthesis,

    it will be valid.
    )",
    APIModel: "openrouter/auto"
}]
```

![image](https://github.com/user-attachments/assets/8f9b16a4-8e07-4618-9b6c-ea9122766f3f)

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

![image](https://github.com/user-attachments/assets/a450ea0e-8954-41d0-b25f-34b8a9c2e213)

Since this app uses [OpenRouter.ai](https://openrouter.ai/) service, you get access to the latest models as soon as they're available.

> [!TIP]
> You can control which API models are selected by adding a semicolon (`;`) to the beginning of any `APIModel` entry that you want to disable.

![image](https://github.com/user-attachments/assets/bd48bfcf-fda8-42c3-9802-ea2b7001c4a1)

The `APIModel: "google/gemini-2.0-flash-thinking-exp:free"` above `isCustomPrompt: true` is the one that will be enabled. All other lines will be disabled. This feature is helpful for managing multiple API model configurations and easily switching between them.

This is also applicable to all the values inside the `prompts` array, such as `promptName`, `menuText`, `systemPrompt`, etc.

> [!TIP]
> Feeling overwhelmed by the number of models to choose from? Take a look at [OpenRouter.ai's ranking page](https://openrouter.ai/rankings) to discover the best models for each task. You can also find benchmarks across various models at [LiveBench.ai](https://livebench.ai/#/).

##### Auto Router

Your prompt will be processed by a meta-model and [routed to one of dozens of models](https://openrouter.ai/openrouter/auto), optimizing for the best possible output. To use it, just enter `openrouter/auto` in the `APIModel` field.

#### copyAsMarkdown

Setting `copyAsMarkdown: true` will enable the `Copy` button in the Response Window to copy content in Markdown format. This is especially useful for responses that need markdown content such as codes for programming.

If you’d rather copy the response as plain text or HTML-formatted text (default behavior), simply remove this setting.

#### isAutoPaste

Enabling `isAutoPaste: true` will automatically paste the model's response in Markdown format. Disable this feature if you do not require auto-paste functionality.

> [!NOTE]  
> The app will automatically disable the Auto Paste functionality if more than one model is set, and will show the Response Window instead.

Default behavior of copied content between `isAutoPaste: true` and `Copy`:

| Setting             | Format        |
|----------------------|---------------|
| `Copy` button from the Response Window | HTML          |
| `isAutoPaste: true`  | Markdown      |

#### isCustomPrompt

Setting this to `isCustomPrompt: true` will allow the prompt to show an input box to write custom prompts. Remove it if you don't need Custom Prompt functionality.

![image](https://github.com/user-attachments/assets/951a3133-bf21-44e6-8959-b98ab26bbbb1)

##### customPromptInitialMessage

An optional message that you can set to be displayed when the Custom Prompt window is shown.

![image](https://github.com/user-attachments/assets/7aeb1a40-8bbd-4aae-bf44-fb417c5f366c)

https://github.com/user-attachments/assets/d8f70927-2544-4c8e-a856-b4569d89263e

> [!TIP]
> You can also split a long message into a series of multiple lines.
> See [Splitting a long prompt into a series of multiple lines](#Splitting-a-long-prompt-into-a-series-of-multiple-lines) for more info.

> [!IMPORTANT]  
> Make sure to add a comma at the end of the line before the Auto Paste, Custom Prompt, `copyAsMarkdown`, etc. functionality:

![image](https://github.com/user-attachments/assets/ca0ce9a1-77ac-40a9-9eef-17de255ca599)

## 📣 Share prompts and settings

Do you have prompts and settings you'd like to share? [Check here](https://github.com/kdalanon/LLM-AutoHotkey-Assistant/discussions/7) to share your prompts!

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

These files will be created after you select a prompt and will be deleted when any of the following actions are performed:

- Pasting the response when `isAutoPaste: true` is set
- Pressing the `ESC` key _after_ selecting a prompt but _before_ receiving the model's response (for example, if the Response Window has not yet opened)
- Closing the Response Window

## 💬 Frequently-asked questions

### Can I use my Anthropic/OpenAI/Google/Other provider's API?

Yes, you can use your own keys, but there is a caveat: You _must_ use OpenRouter's API keys in the app, _then_ configure your provider's API settings on the [Integrations](https://openrouter.ai/settings/integrations) page. This ensures OpenRouter will prioritize using your key.

![Image](https://github.com/user-attachments/assets/506c2cf7-f056-43e2-b418-740254482e24)

![Image](https://github.com/user-attachments/assets/c0aadd8a-2757-4e07-8145-62cfe111fecf)

![Image](https://github.com/user-attachments/assets/a5345e61-9149-4bf1-b66f-122d727f79d6)

More information [here](https://openrouter.ai/docs/use-cases/byok).

### How much is the usage cost per prompt?

The usage costs varies per model. The model's input/output token price is indicated below its name.

![image](https://github.com/user-attachments/assets/67ac3208-4f82-4267-b967-923c80cfc09d)

> [!TIP]
> Search for [free models](https://openrouter.ai/models?q=free) to avoid any charges on your credits when using the app. These free models are particularly helpful when you want to explore the app’s features or experiment with different models.

### Are there any rate limits?

See [OpenRouter's documentation](https://openrouter.ai/docs/api-reference/limits) for their limits.

> [!NOTE]
> Negative credit balance: If your account has a negative credit balance, you may receive 402 errors, even when using free models. Add credits to bring your balance above zero to resolve this and regain access.

### Can I connect it with my local AI?

I'm uncertain if it will work, as I don't have a local AI setup on my machine to test it myself. However, it's highly likely to work if your local AI uses the same format as the `OpenAI SDK`. OpenRouter relies on the `OpenAI SDK` for request processing. I followed the [OpenRouter documentation](https://openrouter.ai/docs/quickstart) to configure the app to connect to their API.

To understand how the app sends and receives requests through the OpenRouter API, open the `Configs_and_Classes.ahk` script (`Menu` ➡ `Options` ➡ `Add API key`). If you successfully set up the app to connect to your local LLM, please let me know, and I will update this information.

### Inquiries regarding OpenRouter's service

Check out their [documentation](https://openrouter.ai/docs/quickstart) to learn more about their service.

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
- [htadashi/GPT3-AHK](https://github.com/htadashi/GPT3-AHK) - An AutoHotKey script that enables you to use GPT3 in any input field on your computer 
- [ecornell/ai-tools-ahk](https://github.com/ecornell/ai-tools-ahk) - AI Tools - AutoHotkey - Enable global hotkeys to run custom OpenAI prompts on text in any window.
- [kdalanon/ChatGPT-AutoHotkey-Utility](https://github.com/kdalanon/ChatGPT-AutoHotkey-Utility) - An AutoHotkey script that uses ChatGPT API to process text.
