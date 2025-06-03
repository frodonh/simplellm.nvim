# SimpleGemini

SimpleGemini.nvim let you chat with Gemini AI from inside Neovim.

## Features
SimpleGemini plugin let you ask something to Google Gemini without leaving NeoVim. The plugin is written in Lua and takes its inspiration from askGemini.nvim. Contrary to other feature-rich plugins available on Github, this one strives to avoid imposing a specific workflow on the user.

It only adds one new command and several Lua functions to your environment (see also |SimpleGeminiCommands|). It does not create any new keymap. You have to configure them by yourself.

It is possible de setup predefined prompts for later use.

The plugin does not rely on third-party plugins.

The plugin implementation is lazily loaded. There is no need to use the package manager for a lazy loading of the plugin.

## Installation

The plugin needs a Gemini API key to connect to the Gemini API. You have to follow the instructions at <https://aistudio.google.com/app/apikey?hl=fr>.

### Installation with lazy.nvim
If you use lazy.nvim as your package manager, you can install SimpleGemini.nvim with the following specification.

```lua
return {
  -- Other plugins
  {
	'frodonh/simplegemini.nvim',
	opts = {
	    -- Put your configuration options here
	}
  }
  -- Other plugins
}
```

## Customization

### Keymaps
This plugin does not create any keymap. You can add you own keymaps by configuring them in your `init.lua` file:
```lua
-- init.lua:
vim.keymap.set({'i'}, '<F8>', '<cmd>SimpleGemini Buffer ',{silent=true, buffer=true, desc='Prompt Gemini and add answer to current buffer'})
vim.keymap.set({'n'}, '<F8>', '<cmd>SimpleGemini Scratch ',{silent=true, buffer=true, desc='Prompt Gemini and display answer in new scratch window'})
vim.keymap.set({'v'}, '<F8>', ':SimpleGemini! Buffer ',{silent=true, buffer=true, desc='Replace current visual selection by Gemini answer after prepending a prompt'})
```

Of course you should use your own keymaps in order to better integrate your workflow.

### Configuration options
The configuration options can be set when the plugin is loaded (see [Installation](#Installation)), or using:

```lua
require 'simplegemini'.setup({
	api_key = "gkeoc2dmclr", -- This is a fake key obviously
	model = "gemini-2.0-flash"
})
```

| Option  | Default value                         | Description        |
|---------|---------------------------------------|--------------------|
| api_key | `GEMINI_API_KEY` environment variable | The Gemini API key |
| model   | `'gemini-2.0-flash'`                  | Gemini model name  |
| prompts | Some predefines prompts are installed | Table where each item has two keys `action` and `prompt`. `action` should be a summary of what the prompt does with the selected text. `prompt` is the text of the prompt as it is sent to Gemini API |

The Gemini API key can also be set by the shell environment variable `GEMINI_API_KEY`.

## Commands
The following commands are available when the plugin is installed.

| Command                  |  Description                                                                     |
|--------------------------|----------------------------------------------------------------------------------|
| `:[range]SimpleGemini Buffer {prompt}` | Ask a question to Gemini and insert answer before cursor position in the current buffer. If specified, `prompt` is sent to Gemini. If `range` is given, the prompt is followed by a newline and all the lines in the range. |
| `:[range]SimpleGemini! Buffer {prompt}` | Ask a question to Gemini and insert answer before cursor position in the current buffer. If specified, `prompt` is sent to Gemini. If `range` is given, the prompt is followed by a newline and all the lines in the range. Unlike the previous plain version, the selection is deleted before the answer is inserted. In other words the selected text is used as the prompt for a Gemini request, which may be preceded by another prompt, and is replaced by its answer. |
| `:[range]SimpleGemini Reg {prompt}` | Ask a question to Gemini and fill the unnamed register with the answer. If specified, `prompt` is sent to Gemini. If `range` is given, the prompt is followed by a newline and all the lines in the range. |
| `:[range]SimpleGemini Reg={name} {prompt}` | Ask a question to Gemini and fill the `name` register with the answer. If specified, `prompt` is sent to Gemini. `name` should be a single character specifying the buffer which will be filled with the answer of the request to Gemini. If `range` is given, the prompt is followed by a newline and all the lines in the range. |
| `:[range]SimpleGemini Scratch {prompt}` | Ask a question to Gemini and display the answer in a new floating window. If specified, `prompt` is sent to Gemini. The floating window can be closed by pressing `<Esc>`. The content of the floating window is deleted when it is closed. If `range` is given, the prompt is followed by a newline and all the lines in the range. |


When no prompt is given, the user is asked to pick one from the predefined prompts.

## Related plugins
- [askGemini.nvim](https://github.com/agusnt/askGemini.nvim): This is the main source of inspiration for this plugin. It is a very good plugin, quite minimalistic in its design too. However I needed something that could be used without a popup window.
- [gemini.nvim](https://github.com/kiddos/gemini.nvim): This plugin has more features and configuration options but is very oriented towards code.
- [ai.nvim](https://github.com/gera2ld/ai.nvim): This plugin allows for other providers. Unlike simplegemini.nvim, it generates the answer in a new popup.
