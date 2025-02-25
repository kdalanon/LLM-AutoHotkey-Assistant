window.chrome.webview.addEventListener('message', handleWebMessage);

// Initialize markdown-it with options
var md = window.markdownit({
  html: true,         // Enable HTML tags in source
  linkify: true,      // Autoconvert URL-like text to links
  typographer: true   // Enable smartypants and other sweet transforms
})
  .use(window.texmath, {  // Use texmath plugin for mathematical expressions
    engine: window.katex,
    delimiters: 'dollars', // Use $...$ for inline math, $$...$$ for display math
    katexOptions: { macros: { "\\RR": "\\mathbb{R}" } }
  });

function renderMarkdown(content, ChatHistoryText) {
  // Define the content to render. Use the provided content or a default message
  var contentToRender = content || 'There is no content available.';

  // Save the pre-markdown text in localStorage for reloading later
  localStorage.setItem('preMarkdownText', contentToRender);

  // Render the markdown content
  var result = md.render(contentToRender);

  // Inject the rendered HTML into the target element
  var contentElement = document.getElementById('content');
  contentElement.innerHTML = result;

  // Scroll to the top
  contentElement.scrollTo(0, 0);

  // If ChatHistoryText, change button text to Chat History. Used by ShowResponseWindow in AutoHotkey
  var button = document.getElementById("chatHistoryButton");
  if (ChatHistoryText) {
    button.textContent = "Chat History";
  }
}

function responseWindowCopyButtonAction() {
  // Get the button element by its id
  var button = document.getElementById('copyButton');

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
    // Store the original button text
    var originalText = button.innerHTML;

    // Change button text to "Copied!" and disable the button
    button.innerHTML = 'Copied!';
    button.disabled = true;

    // After 2 seconds, restore the original text and enable the button
    setTimeout(function () {
      button.innerHTML = originalText;
      button.disabled = false;
    }, 2000);
  }).catch(err => {
    console.error('Failed to copy text: ', err);
  });
}

// Enables or disables the buttons and resets the cursor
function responseWindowButtonsEnabled(enable) {
  // Array of button IDs
  var buttonIds = ["chatButton", "copyButton", "retryButton", "chatHistoryButton"];

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

function handleWebMessage(event) {
  try {
    // Name incoming data
    const message = event.data;

    // Check if data is an array for multiple parameters
    if (Array.isArray(message.data)) {
      if (typeof window[message.target] === 'function') {
        window[message.target](...message.data);
      } else {
        console.error(`Function "${message.target}" does not exist.`);
      }
    } else {
      // Existing single parameter handling
      if (typeof window[message.target] === 'function') {
        window[message.target](message.data);
      } else {
        console.error(`Function "${message.target}" does not exist.`);
      }
    }
  } catch (error) {
    console.error("Error handling incoming message:", error);
  }
}

// Toggle text button between Chat History and Latest Response
function toggleButtonText(ChatHistoryText) {
  var button = document.getElementById('chatHistoryButton');
  if (button.textContent === "Chat History") {
    button.textContent = "Latest Response";
  } else if (button.textContent === "Latest Response") {
    button.textContent = "Chat History";
    // Scroll to the top when displaying chat history
    document.getElementById('content').scrollTo(0, 0);
  } else if (ChatHistoryText) {
    button.textContent = "Chat History";
  }

  // Store the button text in localStorage so it persists across refreshes 
  localStorage.setItem('chatHistoryButtonText', button.textContent);
}

// Store button text before page refresh
window.addEventListener("beforeunload", function () {
  var button = document.getElementById("chatHistoryButton");
  if (button) {
    localStorage.setItem("chatHistoryButtonText", button.textContent);
  }
});

// Call renderMarkdown when the DOM is ready
document.addEventListener("DOMContentLoaded", function () {
  // Retrieve pre-markdown text from localStorage and re-render
  var storedContent = localStorage.getItem('preMarkdownText');
  renderMarkdown(storedContent);

  // Retrieve the button text from localStorage
  var storedButtonText = localStorage.getItem("chatHistoryButtonText");
  var button = document.getElementById("chatHistoryButton");
  button.textContent = storedButtonText;
});