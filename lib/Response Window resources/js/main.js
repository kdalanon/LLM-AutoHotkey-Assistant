window.chrome.webview.addEventListener('message', handleWebMessage);

// Initialize markdown-it with options
var md = window.markdownit(
  {
    html: true,         // Enable HTML tags in source
    linkify: true,      // Autoconvert URL-like text to links
    typographer: true,  // Enable smartypants and other sweet transforms
    highlight: function (str, lang) 
    {
      if (lang && hljs.getLanguage(lang)) {
        try {
          return '<pre class="hljs"><code>' +
            hljs.highlight(str, { language: lang, ignoreIllegals: true }).value +
            '</code></pre>';
        } catch (__) { }
      }
      return '<pre class="hljs"><code>' + md.utils.escapeHtml(str) + '</code></pre>';
    }
  }
).use(window.texmath
     ,{  // Use texmath plugin for mathematical expressions
        engine: window.katex,
        delimiters: 'dollars',
        katexOptions: { macros: { "\\RR": "\\mathbb{R}" } }
      }
);

// Updates the Chat History / Latest Response button label and state
function updateChatHistoryButton(isChatHistoryDisplayed) {
  var button = document.getElementById("chatHistoryButton");
  if (!button) return;

  var historyIcon = '<svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>';
  if (isChatHistoryDisplayed) {
    // Chat History is displayed
    // Button to display is Latest Response
    button.innerHTML = historyIcon + '<span><u>L</u>atest Response</span>';
  } else {
    // Latest Response is displayed
    // Button to display is Chat History
    button.innerHTML = historyIcon + '<span>Chat <u>H</u>istory</span>';
  }

  // Store the button text in localStorage so it persists across refreshes 
  localStorage.setItem('chatHistoryButtonText', button.innerHTML);
  localStorage.setItem('isChatHistoryDisplayed', isChatHistoryDisplayed);
}

// Called by ShowResponseWindow() in AutoHotkey
// ----------------------------------------------------
// Theme Management
// ----------------------------------------------------

function applyTheme(themeName) {
  var isDark = (themeName !== 'Light');
  document.documentElement.setAttribute('data-bs-theme', isDark ? 'dark' : 'light');
  localStorage.setItem('theme', themeName);

  var hlDark = document.getElementById('highlight-dark-theme');
  var hlLight = document.getElementById('highlight-light-theme');
  if (hlDark && hlLight) {
    hlDark.disabled = !isDark;
    hlLight.disabled = isDark;
  }
}
window.applyTheme = applyTheme;

function formatReasoningTags(content) {
  if (!content) return "";
  return content.replace(/<think>([\s\S]*?)<\/think>/gi, (match, p1) => {
    return `<details class="reasoning-block">\n<summary class="reasoning-summary">💭 Réflexion</summary>\n\n${p1.trim()}\n\n</details>\n\n`;
  });
}

function renderStreamingOutput(reasoning, content, isDone, userHasToggled, userOpenState) {
  if (reasoning) {
    const isReasoningDone = content.length > 0 || isDone;
    let openAttr = "";
    if (userHasToggled) {
      openAttr = userOpenState ? " open" : "";
    } else {
      openAttr = isReasoningDone ? "" : " open";
    }
    const summaryTitle = isReasoningDone ? "💭 Réflexion" : "💭 Réflexion en cours...";
    let mdText = `<details class="reasoning-block"${openAttr}>\n<summary class="reasoning-summary">${summaryTitle}</summary>\n\n${reasoning.trim()}\n\n</details>`;
    if (content) {
      mdText += `\n\n${content}`;
    }
    return mdText;
  }

  if (/<think>/i.test(content)) {
    if (/<\/think>/i.test(content)) {
      return content.replace(/<think>([\s\S]*?)<\/think>/gi, (match, p1) => {
        let openAttr = (userHasToggled && userOpenState) ? " open" : "";
        return `<details class="reasoning-block"${openAttr}>\n<summary class="reasoning-summary">💭 Réflexion</summary>\n\n${p1.trim()}\n\n</details>\n\n`;
      });
    } else {
      const thinkContent = content.replace(/^[\s\S]*?<think>/i, '').trim();
      let openAttr = (userHasToggled && !userOpenState) ? "" : " open";
      const summaryTitle = isDone ? "💭 Réflexion" : "💭 Réflexion en cours...";
      return `<details class="reasoning-block"${openAttr}>\n<summary class="reasoning-summary">${summaryTitle}</summary>\n\n${thinkContent}\n\n</details>`;
    }
  }

  return content;
}

function renderMarkdown(mapName2Data) {

  // Change button label according to isChatHistoryDisplayed
  updateChatHistoryButton(mapName2Data.isChatHistoryDisplayed);

  // Define the content to render. Use the provided content or a default message
  var contentToRender = mapName2Data.content || '⚠️ There is no content available.';

  // Save the pre-markdown text in localStorage for reloading later
  localStorage.setItem('preMarkdownText', contentToRender);

  var result = ""
  try {
    // Format any <think> tags into collapsible reasoning blocks
    var formattedContent = formatReasoningTags(contentToRender);
    // Render the markdown content
    result = md.render(formattedContent);

  } catch (error) {
    result = "*** ERROR ***<br><br>" + error + "<br><br>" + contentToRender
    
    console.error(error);
  }

  // Inject the rendered HTML into the target element
  var contentElement = document.getElementById('content');
  contentElement.innerHTML = result;
  enhanceCodeBlocks(contentElement);

  // Scroll to the top and give focus so keyboard scrolling works immediately
  contentElement.scrollTo(0, 0);
  contentElement.focus();
}

// Enhances code blocks with a header and a copy button
function enhanceCodeBlocks(container) {
  if (!container) container = document.getElementById('content');
  if (!container) return;

  var preElements = container.querySelectorAll('pre');
  preElements.forEach(function (pre) {
    if (pre.parentElement && pre.parentElement.classList.contains('code-block-wrapper')) {
      return; // Already enhanced
    }

    var codeEl = pre.querySelector('code');
    var lang = '';
    if (codeEl) {
      codeEl.classList.forEach(function (cls) {
        if (cls.startsWith('language-')) {
          lang = cls.replace('language-', '');
        }
      });
    }

    var wrapper = document.createElement('div');
    wrapper.className = 'code-block-wrapper';

    var header = document.createElement('div');
    header.className = 'code-block-header';

    var langSpan = document.createElement('span');
    langSpan.className = 'code-block-lang';
    langSpan.textContent = lang || 'code';

    var copyBtn = document.createElement('button');
    copyBtn.type = 'button';
    copyBtn.className = 'code-copy-btn';
    copyBtn.title = 'Copier ce bloc de code';
    copyBtn.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg><span>Copier</span>';

    copyBtn.addEventListener('click', function () {
      var codeToCopy = codeEl ? codeEl.innerText : pre.innerText;
      navigator.clipboard.writeText(codeToCopy).then(function () {
        copyBtn.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg><span>Copié !</span>';
        setTimeout(function () {
          copyBtn.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg><span>Copier</span>';
        }, 2000);
      });
    });

    header.appendChild(langSpan);
    header.appendChild(copyBtn);

    pre.parentNode.insertBefore(wrapper, pre);
    wrapper.appendChild(header);
    wrapper.appendChild(pre);
  });
}

function responseWindowCopyButtonAction(copyAsMarkdown) {

  // Get the button element by its id
  var button = document.getElementById('copyButton');

  // Store the original button text
  var btnOriginalText = button.innerHTML;

  if (copyAsMarkdown) {
    // Shall Copy As Markdown

    //
    // Just update the button without copying, 
    // because Markdown text has already been copied (by Response Window.ahk)
    //

    var checkIcon = '<svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>';
    button.innerHTML = checkIcon + '<span>Copied!</span>';
    button.disabled = true;

    // After 2 seconds, restore the original text and enable the button
    setTimeout(function () {
      button.innerHTML = btnOriginalText;
      button.disabled = false;
    }, 2000);
    
  } else {
    // Shall Copy As HTML and Plain Text

    //
    // Put the content into Navigator Clipboard as HTML and Plain Text
    //
    // then Update the button 
    //

    // Get the 'content' element
    var contentElement = document.getElementById('content');

    // Create a temporary element to hold the formatted content
    const tempElement = document.createElement('div');
    tempElement.innerHTML = contentElement.innerHTML;

    // Use the Clipboard API to write the HTML content to the clipboard
    navigator.clipboard.write([
      new ClipboardItem({
        'text/html': new Blob([tempElement.innerHTML], { type: 'text/html' }),
        'text/plain': new Blob([contentElement.innerText], { type: 'text/plain' })
      })
    ]).then(() => {
        // Change button text to "Copied!" and disable the button
        var checkIcon = '<svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>';
        button.innerHTML = checkIcon + '<span>Copied!</span>';
        button.disabled = true;

        // After 2 seconds, restore the original text and enable the button
        setTimeout(function () {
          button.innerHTML = btnOriginalText;
          button.disabled = false;
        }, 2000);

        // Set Focus
        

    }).catch(failureCallback);
  }
}

function failureCallback(erreur) {

  // Get the button element by its id
  var button = document.getElementById('copyButton');

  // Store the original button text
  var btnOriginalText = button.innerHTML;

  button.innerHTML = "** ERROR **";

  // After 2 seconds, restore the original text and enable the button
  setTimeout(function () {
    button.innerHTML = btnOriginalText;
    button.disabled = false;
  }, 2000);
}


// Enables or disables the buttons and resets the cursor
function responseWindowButtonsEnabled(enable) {
  // Array of button IDs
  var buttonIds = ["chatButton", "copyButton", "pasteButton", "retryButton", "chatHistoryButton"];

  // Iterate over each ID in the array
  buttonIds.forEach(function (id) {
    // Get the button element by ID
    var button = document.getElementById(id);

    // Check if the button exists to avoid errors
    if (button) {
      // Toggle the 'disabled' property using the ternary operator
      button.disabled = !enable;
    }
  });
  // Resets cursor
  document.body.style.cursor = 'auto';
}

function logToAhk(msg) {
  try {
    if (window.ahk && window.ahk.StreamEvent && typeof window.ahk.StreamEvent.Func === 'function') {
      window.ahk.StreamEvent.Func("debugLog", String(msg), "");
    }
  } catch (_) {}
}

function handleWebMessage(event) {
  try {
    // Name incoming data
    const message = event.data;
    logToAhk("handleWebMessage received: " + (message ? message.target : "null"));

    // Check if data is an array for multiple parameters
    if (Array.isArray(message.data)) {
      if (typeof window[message.target] === 'function') {
        window[message.target](...message.data);
      } else {
        logToAhk(`Function "${message.target}" does not exist.`);
        console.error(`Function "${message.target}" does not exist.`);
      }
    } else {
      // Existing single parameter handling
      if (typeof window[message.target] === 'function') {
        window[message.target](message.data);
      } else {
        logToAhk(`Function "${message.target}" does not exist.`);
        console.error(`Function "${message.target}" does not exist.`);
      }
    }
  } catch (error) {
    logToAhk("Error handling incoming message: " + error);
    console.error("Error handling incoming message:", error);
  }
}

// Store button label before page refresh
window.addEventListener("beforeunload", function () {

  // alert("beforeunload");
  
  var button = document.getElementById("chatHistoryButton");
  if (button) {
    localStorage.setItem("chatHistoryButtonText", button.innerHTML);
  }
});

// Call renderMarkdown when the DOM is ready
document.addEventListener("DOMContentLoaded", function () {
  logToAhk("DOMContentLoaded fired, sending pageReady");
  // Clear any old stored markdown text so fresh requests don't show ghost content
  localStorage.removeItem('preMarkdownText');

  // Synchronize highlight theme on DOM ready
  var currentTheme = (document.documentElement.getAttribute('data-bs-theme') === 'light') ? 'Light' : 'Dark';
  var storedTheme = localStorage.getItem('theme');
  if (storedTheme) {
    currentTheme = storedTheme;
  }
  applyTheme(currentTheme);

  // Retrieve the button text from localStorage
  var storedButtonText = localStorage.getItem("chatHistoryButtonText");
  var button = document.getElementById("chatHistoryButton");
  if (button && storedButtonText) {
    button.innerHTML = storedButtonText;
  }

  notifyAhkStreamEvent("pageReady", "", "");
});

// ----------------------------------------------------
// LLM Streaming Implementation
// ----------------------------------------------------

let currentAbortController = null;
let isStreaming = false;

// Starts SSE streaming LLM response directly in WebView2
async function startStream(config) {
  logToAhk("startStream called, url=" + (config ? config.url : "undefined"));
  if (document.readyState === 'loading') {
    await new Promise(resolve => document.addEventListener('DOMContentLoaded', resolve, { once: true }));
  }

  if (config && config.theme) {
    applyTheme(config.theme);
  }

  const contentElement = document.getElementById('content');
  responseWindowButtonsEnabled(false);
  updateChatHistoryButton(false);
  isStreaming = true;
  currentAbortController = new AbortController();

  // Reset display with loading placeholder and ensure scroll is at the top
  contentElement.innerHTML = '<div class="streaming-placeholder"><span class="spinner-border spinner-border-sm me-2" role="status"></span><i>Waiting for response...</i></div>';
  contentElement.scrollTo(0, 0);

  let accumulatedResponse = "";
  let accumulatedReasoning = "";
  let accumulatedContent = "";
  let renderScheduled = false;
  let userHasToggledReasoning = false;
  let userReasoningOpenState = false;

  const onToggleListener = (e) => {
    if (e.target && e.target.classList.contains('reasoning-block')) {
      userHasToggledReasoning = true;
      userReasoningOpenState = e.target.open;
    }
  };
  contentElement.addEventListener('toggle', onToggleListener, true);

  let renderRafId = null;

  function scheduleRender() {
    if (renderScheduled) return;
    renderScheduled = true;
    renderRafId = requestAnimationFrame(() => {
      renderScheduled = false;
      renderRafId = null;
      if (!isStreaming) return;
      try {
        const renderedMd = renderStreamingOutput(
          accumulatedReasoning,
          accumulatedContent,
          false,
          userHasToggledReasoning,
          userReasoningOpenState
        );
        contentElement.innerHTML = md.render(renderedMd);
      } catch (e) {
        contentElement.innerText = (accumulatedReasoning ? accumulatedReasoning + "\n\n" : "") + accumulatedContent;
      }
    });
  }

  try {
    const headers = {
      'Content-Type': 'application/json',
      'X-Title': 'LLM AutoHotkey Assistant'
    };
    if (config.apiKey && config.apiKey !== "none" && config.apiKey !== "Your API Key here") {
      headers['Authorization'] = `Bearer ${config.apiKey}`;
    }

    if (config.payload) {
      config.payload.stream = true;
    }

    logToAhk("Fetching stream from: " + config.url + " (payload.stream=" + config.payload.stream + ")");
    const response = await fetch(config.url, {
      method: 'POST',
      headers: headers,
      body: JSON.stringify(config.payload),
      signal: currentAbortController.signal
    });
    logToAhk("Fetch response status: " + response.status);

    if (!response.ok) {
      let errorBody = "";
      try {
        const errorJson = await response.json();
        errorBody = errorJson.error?.message || JSON.stringify(errorJson);
      } catch (_) {
        try {
          errorBody = await response.text();
        } catch (_) {}
      }
      logToAhk("HTTP error response: " + errorBody);
      throw new Error(`HTTP ${response.status} (${response.statusText}):\n\n${errorBody}`);
    }

    const reader = response.body.getReader();
    const decoder = new TextDecoder('utf-8');
    let buffer = "";
    let rawResponseText = "";
    let chunkCount = 0;

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      chunkCount++;
      const decodedChunk = decoder.decode(value, { stream: true });
      rawResponseText += decodedChunk;
      buffer += decodedChunk;
      const lines = buffer.split('\n');
      buffer = lines.pop(); // Keep uncompleted line in buffer

      for (const line of lines) {
        const trimmed = line.trim();
        if (!trimmed || trimmed.startsWith(':')) continue;

        if (trimmed === 'data: [DONE]') {
          break;
        }

        if (trimmed.startsWith('data: ')) {
          const jsonStr = trimmed.slice(6);
          try {
            const parsed = JSON.parse(jsonStr);
            const delta = parsed.choices?.[0]?.delta;
            if (delta) {
              const reasoningChunk = delta.reasoning_content || delta.reasoning || delta.thought || "";
              const contentChunk = delta.content || "";

              if (reasoningChunk) {
                accumulatedReasoning += reasoningChunk;
              }
              if (contentChunk) {
                accumulatedContent += contentChunk;
              }

              if (reasoningChunk || contentChunk) {
                scheduleRender();
              }
            }
          } catch (e) {
            console.warn("Error parsing SSE chunk:", jsonStr, e);
          }
        }
      }
    }

    logToAhk(`Stream loop finished. Chunks: ${chunkCount}, reasoning length: ${accumulatedReasoning.length}, content length: ${accumulatedContent.length}`);

    // Flush any remaining buffer line
    if (buffer.trim().startsWith('data: ') && buffer.trim() !== 'data: [DONE]') {
      try {
        const parsed = JSON.parse(buffer.trim().slice(6));
        const delta = parsed.choices?.[0]?.delta;
        if (delta) {
          const reasoningChunk = delta.reasoning_content || delta.reasoning || delta.thought || "";
          const contentChunk = delta.content || "";
          if (reasoningChunk) {
            accumulatedReasoning += reasoningChunk;
          }
          if (contentChunk) {
            accumulatedContent += contentChunk;
          }
        }
      } catch (_) {}
    }

    // Fallback: If non-streaming JSON was returned
    if (!accumulatedContent && !accumulatedReasoning && rawResponseText.trim()) {
      try {
        const parsed = JSON.parse(rawResponseText.trim());
        const message = parsed.choices?.[0]?.message;
        if (message) {
          const reasoning = message.reasoning_content || message.reasoning || message.thought || "";
          const content = message.content || "";
          if (reasoning) {
            accumulatedReasoning = reasoning;
          }
          if (content) {
            accumulatedContent = content;
            logToAhk("Parsed non-streaming fallback content length: " + content.length);
          }
        }
      } catch (_) {}
    }

    contentElement.removeEventListener('toggle', onToggleListener, true);

    if (renderRafId) {
      cancelAnimationFrame(renderRafId);
      renderRafId = null;
    }
    renderScheduled = false;
    isStreaming = false;

    // Final render without cursor
    const finalFormatted = renderStreamingOutput(
      accumulatedReasoning,
      accumulatedContent,
      true,
      userHasToggledReasoning,
      userReasoningOpenState
    );
    accumulatedResponse = finalFormatted || '*(Empty response received)*';
    contentElement.innerHTML = md.render(accumulatedResponse);
    enhanceCodeBlocks(contentElement);

    currentAbortController = null;
    responseWindowButtonsEnabled(true);

    notifyAhkStreamEvent("complete", accumulatedResponse, config.shortModelName);

  } catch (err) {
    contentElement.removeEventListener('toggle', onToggleListener, true);

    if (renderRafId) {
      cancelAnimationFrame(renderRafId);
      renderRafId = null;
    }
    renderScheduled = false;
    isStreaming = false;

    if (err.name === 'AbortError') {
      console.log("Stream aborted by user");
      const currentFormatted = renderStreamingOutput(
        accumulatedReasoning,
        accumulatedContent,
        true,
        userHasToggledReasoning,
        userReasoningOpenState
      );
      accumulatedResponse = currentFormatted;
      contentElement.innerHTML = md.render(accumulatedResponse) + '<br><br><span class="badge text-bg-warning">⏹ Generation stopped</span>';
      enhanceCodeBlocks(contentElement);
      currentAbortController = null;
      responseWindowButtonsEnabled(true);

      notifyAhkStreamEvent("aborted", accumulatedResponse, config.shortModelName);
    } else {
      console.error("Stream error:", err);
      const errorMsg = `**⛔ ERROR**\n\n${err.message || err}`;
      contentElement.innerHTML = md.render(errorMsg);
      currentAbortController = null;
      responseWindowButtonsEnabled(true);

      notifyAhkStreamEvent("error", err.message || String(err), config.shortModelName);
    }
  }
}

// Aborts the current stream if active
function abortStream() {
  if (isStreaming && currentAbortController) {
    currentAbortController.abort();
  }
}

// Helper to notify AutoHotkey of stream events
function notifyAhkStreamEvent(eventType, text, modelName) {
  try {
    if (window.ahk && window.ahk.StreamEvent && typeof window.ahk.StreamEvent.Func === 'function') {
      window.ahk.StreamEvent.Func(eventType, text, modelName);
    } else {
      setTimeout(function () {
        if (window.ahk && window.ahk.StreamEvent && typeof window.ahk.StreamEvent.Func === 'function') {
          window.ahk.StreamEvent.Func(eventType, text, modelName);
        }
      }, 50);
    }
  } catch (e) {
    console.error("Failed to notify AHK of stream event:", e);
  }
}

// Keyboard shortcuts listener when WebView2 has focus
window.addEventListener('keydown', function (e) {
  // Escape key: cancel stream if streaming, otherwise close window
  if (e.key === 'Escape') {
    e.preventDefault();
    if (isStreaming) {
      abortStream();
    } else {
      if (window.ahk && window.ahk.ButtonClick && typeof window.ahk.ButtonClick.Func === 'function') {
        window.ahk.ButtonClick.Func('Close');
      }
    }
    return;
  }

  // Ctrl+W to close window
  if (e.ctrlKey && !e.altKey && !e.metaKey && e.key.toLowerCase() === 'w') {
    e.preventDefault();
    if (window.ahk && window.ahk.ButtonClick && typeof window.ahk.ButtonClick.Func === 'function') {
      window.ahk.ButtonClick.Func('Close');
    }
    return;
  }

  // F5 or Ctrl+R: Refresh content instead of reloading and blanking the page
  if (e.key === 'F5' || (e.ctrlKey && !e.altKey && !e.metaKey && e.key.toLowerCase() === 'r')) {
    e.preventDefault();
    if (!isStreaming) {
      notifyAhkStreamEvent("refreshRequest", "", "");
    }
    return;
  }

  // PageUp / PageDown / Home / End scrolling navigation for #content
  if (e.key === 'PageDown' || e.key === 'PageUp' || e.key === 'Home' || e.key === 'End') {
    var activeTag = document.activeElement ? document.activeElement.tagName.toLowerCase() : '';
    if (activeTag !== 'input' && activeTag !== 'textarea') {
      var contentEl = document.getElementById('content');
      if (contentEl) {
        if (e.key === 'PageDown') {
          e.preventDefault();
          contentEl.scrollBy({ top: contentEl.clientHeight * 0.85, behavior: 'smooth' });
        } else if (e.key === 'PageUp') {
          e.preventDefault();
          contentEl.scrollBy({ top: -contentEl.clientHeight * 0.85, behavior: 'smooth' });
        } else if (e.key === 'Home') {
          e.preventDefault();
          contentEl.scrollTo({ top: 0, behavior: 'smooth' });
        } else if (e.key === 'End') {
          e.preventDefault();
          contentEl.scrollTo({ top: contentEl.scrollHeight, behavior: 'smooth' });
        }
      }
    }
    return;
  }

  // Alt+<key> shortcuts for colored buttons
  if (e.altKey && !e.ctrlKey && !e.metaKey) {
    const key = e.key.toLowerCase();
    let buttonId = null;

    switch (key) {
      case 't':
        buttonId = 'chatButton';
        break;
      case 'r':
        buttonId = 'retryButton';
        break;
      case 'h':
      case 'l':
        buttonId = 'chatHistoryButton';
        break;
      case 'c':
        buttonId = 'copyButton';
        break;
      case 'p':
        buttonId = 'pasteButton';
        break;
    }

    if (buttonId) {
      const button = document.getElementById(buttonId);
      if (button && !button.disabled) {
        e.preventDefault();
        button.click();
      }
    }
  }
});

// Explicitly export to window
window.startStream = startStream;
window.abortStream = abortStream;
window.handleWebMessage = handleWebMessage;
window.renderMarkdown = renderMarkdown;
window.responseWindowButtonsEnabled = responseWindowButtonsEnabled;
window.updateChatHistoryButton = updateChatHistoryButton;
