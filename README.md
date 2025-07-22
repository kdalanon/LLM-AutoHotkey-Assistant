<!-- 
  To générate README.pdf with VSCode + Markdown PDF extension, 
  remove comments Around <style> ... </style> tags.

  <style> ... </style> tags must be commented before push on GITHUB,
  because GITHUB refuse to handle them for security reasons.
  See https://github.com/github/markup#github-markup
-->

<!--
<style>

body {
  counter-reset: level1;
}

h1 {
  counter-reset: level2;
}

h2 {
  counter-reset: level3;
}

h3 {
  counter-reset: level4;
}

h4 {
  counter-reset: level5;
}

h5 {
  counter-reset: level6;
}

h1::before {
  counter-increment: level1;
  }

h2::before {
  counter-increment: level2;
  content: counter(level2) "." " ";
}

h3::before {
  counter-increment: level3;
  content: counter(level2) "." counter(level3) " ";
}

h4::before {
  counter-increment: level4;
  content: counter(level2) "." counter(level3) "." counter(level4) " ";
}

h5::before {
  counter-increment: level5;
  content: counter(level2) "." counter(level3) "." counter(level4) "." counter(level5) " ";
}

.center, h1, p.title, p.author {
    text-align: center; // Centre le text du paragraphe
}

h1, h2, h3, h4, p.title {
    color: #004F91;
    font-weight: bold;
}

h4 {
    color:rgb(0, 145, 73);
}

p.title {
    font-size: 18px;
}

p.author {
}

p.highlighted {
    color:rgb(221, 29, 15);
}

</style>
-->

<div align="center">

![bot](https://github.com/user-attachments/assets/fd5e1d8c-d19f-44f1-b590-2cc950ede6b9)

# LLM AutoHotkey Assistant

<p class="center">
If you already now what <b>LLM AutoHotkey Assistant</b> is and just want to <b>get started</b> right now?
</p>

<p class="title highlighted">Jump to "Getting Starded" section below !</p>

***

<p class="center">
Otherwise
</p>

<p class="center">
LLM AutoHotkey Assistant is an AutoHotkey v2 application that usually utilizes <a href="https://openrouter.ai/" target="_blank">OpenRouter.ai</a> to seamlessly integrate LLM (Large Language Models) into your daily workflow. Process texts with customizable prompts by pressing a hotkey and interact with multiple AI models simultaneously.
</p>

[![Download](https://img.shields.io/github/v/release/kdalanon/LLM-AutoHotkey-Assistant?style=for-the-badge&color=blue&label=Download)](https://github.com/kdalanon/LLM-AutoHotkey-Assistant/releases/latest)

![Total downloads](https://img.shields.io/github/downloads/kdalanon/LLM-AutoHotkey-Assistant/total?style=for-the-badge&color=blue&label=Total%20Downloads)

</div>

> [!TIP] 
> Want to ask questions on how to use this app? [Download this documentation](https://github.com/kdalanon/LLM-AutoHotkey-Assistant/raw/refs/heads/main/README.md) and include it in your prompt when using your preferred AI chat app!
>
> Navigate through this page by clicking on the menu button at the upper-right corner.
> ![image](https://github.com/user-attachments/assets/eddb0216-f0db-4ecf-9231-81592d4aa454)

<div style="page-break-after: always;"></div>

## 🔑 Key Features

The following paragraphs describe the **key features** of the application and some **use cases**.

However, due to the ability to **customize** your own **prompt menu** items, you can create lot more use cases, according to the ability of your **connected AI**.


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

<div style="page-break-after: always;"></div>

## 🚀 Getting Started

### Prerequisites

- [AutoHotkey v2](https://autohotkey.com/download/) (requires version `2.0.18` or later)
- Windows OS
- [API key](https://openrouter.ai/settings/keys) from [OpenRouter.ai](https://openrouter.ai)

### Install the Assistant

1. Download `LLM AutoHotkey Assistant.zip`  
[![Download](https://img.shields.io/github/v/release/kdalanon/LLM-AutoHotkey-Assistant?style=for-the-badge&color=blue&label=Download)](https://github.com/kdalanon/LLM-AutoHotkey-Assistant/releases/latest)
2. Unzip `LLM AutoHotkey Assistant.zip`

3. OPTIONAL : Configure the `config/Preferences.ahk` file as needed if you want to use a **local LLM**.

4. Run the `LLM AutoHotkey Assistant.ahk` script and press the `backtick` (or `Alt+Shift+o`) hotkey.

5. Select `Options` ➡ `Edit prompts`
![image](https://github.com/user-attachments/assets/93b4b345-6651-4693-82b4-0edd728ff076)

6. Enter your [OpenRouter.ai API key](https://openrouter.ai/settings/keys) within the quotation marks. Then, press `CTRL + S` to save the file automatically and reload the application.

> [!NOTE]
> To ensure the API key is automatically applied and the application reloads, use the keyboard shortcut `CTRL + S` to save.  Saving via `File` ➡ `Save` will not trigger the **automatic reload**.

![image](https://github.com/user-attachments/assets/6622d386-d73b-40bd-9fb5-7a5a429133a3)

7. You can now use the app!  
If you want to further enhance your experience and customize your prompts, press the `backtick` (or `Alt+Shift+o`) hotkey and select `Options` ➡ `Edit prompts` again. See [Editing prompts](#editing-prompts) for more info.


> [!NOTE]
> The `robot icon` will appear in your system tray and will indicate that the Assistant is running in the background, ready to be called.  
> ![image](https://github.com/user-attachments/assets/93fa2fed-3222-494a-974c-5a037cf7e60d)

### Shutdown the Assistant

To shutdown the assistant, **right-click** the yellow `robot icon` in the `tray bar` and select `Exit`.

### Uninstall permanently the Assistant

Delete the folder containing `LLM AutoHotkey Assistant.exe`.

<div style="page-break-after: always;"></div>

## 🖱️ Usage

### How to use

1. **Highlight** any **text** (this is optional if your prompt does not require you to input text)
2. **Press** `backtick` (or the `Alt+Shift+o`) hotkey to bring up the prompt menu :
3. Select a menu item :
    - to display a **Custom prompt** window or 
    - to process the **selected text**
      
      > [!NOTE]  
      > Use `Ctrl + Click` on menu item to **switch** between :
      >  - **Custom prompt** mode and 
      >  - **Process text** mode.

4. OPTIONAL : According to your Prompt configuration, write your question or custom prompt :
![image](https://github.com/user-attachments/assets/951a3133-bf21-44e6-8959-b98ab26bbbb1)

5. View the AI response in the `Response Window` and continue to **Chat** or **Paste and Close** the window as needed
> [!NOTE]
> `Alt + underlined character` of a Response Window button, is the **shortcut** key to activate a button.

7. OPTIONAL : Select `Options` ➡ `View available models` to get available **model ids** on server, to customize your Prompt `APIModels` field.

8. OPTIONAL : Select `Options` ➡ `Edit prompts` to add/customize your **Prompt Menu** items (in the `config/Prompts.ahk` file).

> [!NOTE]
> You may **call** the Assistant **multiple times**, even if the previous response window is not yet opened or still open.  
> A **new** `response window` will be created when the LLM response is received.

### Suspend the Assistant

If you want to use the `backtick` character, you can press `CapsLock + Backtick` (or `CapsLock + o`) to suspend and unsuspend the script.

It can also be done through the `tray menu > Suspend Assistant`

> A message will be displayed at the bottom indicating that the app is suspended.
> ![image](https://github.com/user-attachments/assets/e8611390-5fb3-4916-ac8f-774210b5a14d)


### Hotkeys Summary

- `Backtick` or `Alt+Shift+o` : Show prompt menu
- `Ctrl + S`: Will automatically save and reload the script when editing in Notepad (or any other editing tool that matches `LLM AutoHotkey Assistant.ahk` title window)
- `CapsLock + backtick`: Suspend/resume hotkeys
- `ESC`: Cancel ongoing requests
- `CTRL + W`: Close the following windows:
  - Custom prompt
  - Chat
  - Chat with specific prompt
  - Response Window

### Get Help

- **Right-click** the yellow `robot icon` in the `tray bar` and  
- Select `Help > Open README.pdf`.

<div style="page-break-after: always;"></div>

## 🖱️ Configuration

### Running the script at startup

You can automatically run the script at startup by following the steps below:

1. Copy `LLM AutoHotkey Assistant.ahk`

![image](https://github.com/user-attachments/assets/dec84b9c-b945-4902-92f6-4e042fcd6649)

2. Enter `shell:startup` at the File Explorer address bar and press `enter`.

![image](https://github.com/user-attachments/assets/970b44c5-c365-406a-814c-1c5ed6be0611)

3. Right-click ➡ `Paste shortcut`

![image](https://github.com/user-attachments/assets/eecefcac-629d-4527-95c0-0f4b77533fee)

### Editing prompts

Edit the `prompts` array in the script to add your own prompts.

```autohotkey
prompts := [{
    promptName: "Your Prompt Name",
    menuText: "&1 - Menu Text",
    tags: ["", "&tag1", "&tag2"],
    isCustomPrompt: true,
    customPromptInitialMessage: "Initial message that will show on Custom Prompt window",
    isCustomPromptCursorAtEnd: false,
    systemPrompt: "Your system prompt",
    APIModels: "
    (
    perplexity/r1-1776:online,
    openai/o3-mini-high:online,
    anthropic/claude-3.7-sonnet:thinking:online,
    google/gemini-2.0-flash-thinking-exp:free:online
    )",
    copyAsMarkdown: true,
    isAutoPaste: true,
    skipConfirmation: true
}]
```

#### promptName

The name of the prompt. This will also be shown in the tooltip, `Send message to`, `Activate`, `Minimize`, and `Close` menus. In addition, this will also show in the Response Window title together with the chosen API model.

![image](https://github.com/user-attachments/assets/4d4385b4-4abd-4c0d-8922-ab046cc38f38)

![image](https://github.com/user-attachments/assets/a06b87b6-2468-4166-a17f-a0bad27d9bb7)

![image](https://github.com/user-attachments/assets/f521d9b0-24cd-46da-9b73-2fe6fb8ec4f6)

![image](https://github.com/user-attachments/assets/cea6810f-1408-4d49-8a53-18d8bd334c46)


<div style="page-break-after: always;"></div>

#### menuText

The name of the prompt that will appear when your press the hotkey to bring up the menu. The ampersand (`&`) is a shortcut key and indicates that by pressing the character next to it after bringing up the menu, the prompt will be selected.

![image](https://github.com/user-attachments/assets/caa7a07a-b62f-48b2-8741-0a143f53ac99)

> [!NOTE]
> You can have duplicate shortcut keys for the prompts. Pressing the shortcut key will highlight the first prompt, and pressing the shortcut key again will highlight the second prompt. Pressing `Enter` afterwards will select the prompt and initiate the request.

#### tags

Enabling this feature will sort and group the prompts by their tags.

For instance, the following configuration 

```autohotkey
prompts := [
   {
    tags: [
           "&Custom prompts"
         , "Multi-models"
         , "---"
         , "Text manipulation"
         , "&Articles"
         , "---"
         , "Language"
         , "Learning"
         , "&Auto paste"
        ]
}, {
    promptName: "Multi-model custom prompt",
    menuText: "&1 - Gemini, GPT-4o, Claude",
    systemPrompt: "System prompt",
    APIModels: "google/gemini-2.0-flash-thinking-exp:free, openai/gpt-4o, anthropic/claude-3.7-sonnet",
    isCustomPrompt: true,
    customPromptInitialMessage: "How can I leverage the power of AI in my everyday tasks?",
    tags: ["&Custom prompts", "&Multi-models"]
}, {
    promptName: "Auto-paste custom prompt",
    menuText: "&5 - Auto-paste custom prompt",
    systemPrompt: "You are a helpful assistant. Follow the instructions that I will provide or answer any questions that I will ask.",
    APIModels: "google/gemini-2.0-flash-thinking-exp:free",
    isCustomPrompt: true,
    isAutoPaste: true,
    tags: ["", "&Custom prompts", "&Auto paste"]
}]
```
will show :
  - Tag menus `&Custom prompts`, `Multi-models`, `Text manipulation`... 
    - in **this order**, due to the first **special prompt** containing **only one** `tags` field.
    - "---" will add **menu separators** between menu items  
    (not yet shown on the picture below)
  - Menu `&1 - Gemini, GPT-4o, Claude` in both sub menus :
    - `&Custom prompts` and 
    - `&Multi-models` 
  - Menu `Auto-paste custom prompt` in both sub-menus :
    - `&Custom prompts` and 
    - `&Auto paste` and
    -  as a **top direct menu** due to tag `""`  
    (not yet shown on the picture below)

![image](https://github.com/user-attachments/assets/f6629513-35c4-4469-886d-480363c89214)

![image](https://github.com/user-attachments/assets/8c931782-0937-4a10-a26a-2fe7f22272aa)

#### isCustomPrompt

Setting `isCustomPrompt: true` will allow the prompt to show an input box to write custom prompts. Remove this if you don't need Custom Prompt functionality.

By maintaining **Ctrl** key and **clicking** on a menu item, this inverts the behavior of the `isCustomPrompt` flag for that specific call.


![image](https://github.com/user-attachments/assets/951a3133-bf21-44e6-8959-b98ab26bbbb1)

**Ctrl+Enter** key will send the prompt to the LLM.

#### customPromptInitialMessage

An optional message that you can set to be displayed when the Custom Prompt window is shown. Remove this if you don't want to show a message whenever you open the Custom Prompt.

![image](https://github.com/user-attachments/assets/7aeb1a40-8bbd-4aae-bf44-fb417c5f366c)

https://github.com/user-attachments/assets/d8f70927-2544-4c8e-a856-b4569d89263e

> [!TIP]
> You can also split a long message into a series of multiple lines.
> See [Splitting a long prompt into a series of multiple lines](#Splitting-a-long-prompt-into-a-series-of-multiple-lines) for more info.

> [!IMPORTANT]  
> Make sure to add a comma at the end of the line before the Auto Paste, Custom Prompt, `copyAsMarkdown`, etc. functionality:

![image](https://github.com/user-attachments/assets/04ad392f-0f6d-45c0-b00b-00d0e4414109)

#### isCustomPromptCursorAtEnd

When **isCustomPromptCursorAtEnd** is :
- **true** : the cursor will be placed at the **end** (Not defined assumes **true**)
- **false** : the **whole text** will be **selected** allowing to esealy **overwrite** the text


#### systemPrompt

This will be the initial prompt and will set the tone and context of the conversation.

##### Splitting a long prompt into a series of multiple lines

Long prompts can be divided into new lines to improve readability.

```autohotkey
prompts := [{
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
```

![image](https://github.com/user-attachments/assets/ebd22b64-0c49-4ce2-a5b7-c10dd0b9f2e0)

#### APIModels

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

To enable multi-model functionality, you can specify different API models, separating them with a comma and a space:

```autohotkey
prompts := [{
    promptName: "Deep thinking multi-model custom prompt",
    menuText: "&1 - Deep thinking multi-model custom prompt",
    systemPrompt: "You are a helpful assistant. Follow the instructions that I will provide or answer any questions that I will ask. My first query is the following:",
    APIModels: "perplexity/r1-1776, openai/o3-mini-high, anthropic/claude-3.7-sonnet:thinking, google/gemini-2.0-flash-thinking-exp:free",
    isCustomPrompt: true,
    customPromptInitialMessage: "This is a message template."
}]
```

You can also enter them into new lines for better readability:

```autohotkey
prompts := [{
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
}]
```

![image](https://github.com/user-attachments/assets/f0a7158a-b1ee-4cf5-959a-696c561b6d25)

After selecting the prompt with multiple API models, it will enable the `Send message to`, `Activate`, `Minimize`, and `Close` menu options after pressing the backtick hotkey.

Since this app uses [OpenRouter.ai](https://openrouter.ai/) service, you get access to the [latest models](https://openrouter.ai/models) as soon as they're available.

> [!TIP]
> Feeling overwhelmed by the number of models to choose from? Take a look at [OpenRouter.ai's ranking page](https://openrouter.ai/rankings) to discover the best models for each task. You can also find benchmarks across various models at [LiveBench.ai](https://livebench.ai/#/).


<div style="page-break-after: always;"></div>

##### Auto Router

Your prompt will be processed by a meta-model and [routed to one of dozens of models](https://openrouter.ai/openrouter/auto), optimizing for the best possible output. To use it, just enter `openrouter/auto` in the `APIModel` field.

#### copyAsMarkdown

Setting `copyAsMarkdown: true` will enable the `Copy` button in the Response Window to copy content in Markdown format. This is especially useful for responses that need markdown content such as codes for programming.

If you’d rather copy the response as plain text or HTML-formatted text (default behavior), simply remove this setting.

#### isAutoPaste

Setting `isAutoPaste: true` will automatically paste the model's response in Markdown format. Remove this if you don't need auto-paste functionality.

> [!NOTE]  
> The app will automatically disable the Auto Paste functionality if more than one model is set, and will show the Response Window instead.

Default behavior of copied content between `isAutoPaste: true` and `Copy`:

| Setting             | Format        |
|----------------------|---------------|
| `Copy` button from the Response Window | HTML          |
| `isAutoPaste: true`  | Markdown      |

#### skipConfirmation

Setting `skipConfirmation: true` will skip confirmation messages when closing the following windows:

- Custom prompt
- Chat
- Chat with specific prompt
- Response Window

<div style="page-break-after: always;"></div>

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

<div style="page-break-after: always;"></div>

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

Yes !

You just have to uncomment and configure the `gLLM_BASE_URL` variable in the `config/Preferences.ahk` file to point to your local AI server'

You can also customize the icon of your local AI server by adding the following lines to the `config/Preferences.ahk` file :

```autohotkey
ICON_XXX    := 18

gMapIconNb2IconPath.Set(ICON_XXX, "icons\xxx.ico")
```

where `xxx` is the name of :
- your icon
- the prefix of your model in the APIModels section of your prompts :

```autohotkey
 APIModels: "
    (
    xxx/mymodel
    )"
```

You can add other icons by adding more lines like the one above.
Don't forget to increment the icon number (`ICON_XXX`) for each new icon you add.


### Can I run the app using a portable installation of AutoHotkey?

Yes, you can modify the `LLM AutoHotkey Assistant.ahk` script to point to your portable `AutoHotkey64.exe` file. Just change this line:

```autohotkey
Run("lib\Response Window.ahk " "`"" dataObjToJSONStrFile)
```

to

```autohotkey
Run('"C:\path\to\AutoHotkey64.exe" "' A_ScriptDir '\lib\Response Window.ahk" "' dataObjToJSONStrFile '"')
```

Thanks to [@WhazZzZzup25](https://github.com/kdalanon/LLM-AutoHotkey-Assistant/issues/1#issuecomment-2693062034) for testing this out.

### Inquiries regarding OpenRouter's service

Check out their [documentation](https://openrouter.ai/docs/quickstart) to learn more about their service.

<div style="page-break-after: always;"></div>

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

## ⚖️ Third-Party Licenses

### highlight.js
This project uses CSS files from [highlight.js](https://github.com/highlightjs/highlight.js).

Copyright (c) 2006, Ivan Sagalaev.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
