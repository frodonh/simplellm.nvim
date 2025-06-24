# SimpleLLM

SimpleLLM.nvim let you chat with LLM AI from inside Neovim.

## Features
SimpleLLM plugin let you ask something to an online LLM without leaving NeoVim. The plugin is written in Lua and takes its inspiration from askGemini.nvim. Contrary to other feature-rich plugins available on Github, this one strives to avoid imposing a specific workflow on the user.

At the moment two endpoints are supported:

- [Google Gemini](https://aistudio.google.com/prompts/new_chat)
- [Groq](https://console.groq.com/playground)

All the free LLM available on those endpoints can be used.

It only adds one new command and several Lua functions to your environment (see also |SimpleLLMCommands|). It does not create any new keymap. You have to configure them by yourself.

It is possible to setup predefined prompts for later use. Some commonly-used prompts are provided.

The plugin does not rely on third-party plugins.

The plugin implementation is lazily loaded. There is no need to use the package manager for a lazy loading of the plugin.

## Installation

The plugin may need an API key to connect to the API. 

- For Google Gemini, you have to follow the instructions at <https://aistudio.google.com/app/apikey?hl=fr>.
- For Groq, you have to follow the instructions at <https://console.groq.com/keys>

### Installation with lazy.nvim
If you use lazy.nvim as your package manager, you can install SimpleLLM.nvim with the following specification.

```lua
return {
  -- Other plugins
  {
	'frodonh/simplellm.nvim',
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
vim.keymap.set({'i'}, '<F8>', '<cmd>SimpleLLM Buffer ',{silent=true, buffer=true, desc='Prompt LLM and add answer to current buffer'})
vim.keymap.set({'n'}, '<F8>', '<cmd>SimpleLLM Scratch ',{silent=true, buffer=true, desc='Prompt LLM and display answer in new scratch window'})
vim.keymap.set({'v'}, '<F8>', ':SimpleLLM! Buffer ',{silent=true, buffer=true, desc='Replace current visual selection by LLM answer after prepending a prompt'})
```

Of course you should use your own keymaps in order to better integrate your workflow.

### Configuration options
The configuration options can be set when the plugin is loaded (see [Installation](#Installation)), or using:

```lua
require 'simplellm'.setup({
	endpoint = 'gemini', -- Default endpoint
	gemini = {  -- Parameters for the Gemini endpoint
		model = "gemini-2.5-flash",
		api_key = "gkeoc2dmclr", -- This is a fake key obviously
	},
	groq = { -- Parameters for the Groq endpoint
		model = "compound-beta",
		api_key = "taioçvlbkgislc4dkd" -- This is also a fake key
	}
	language = 'fr', -- Default language
	prompts = { -- The following prompts will be added to the predefined one
		fr = {
			{action = "Résumer", prompt = "Résume le texte suivant. N'y ajoute ni introduction ni conclusion et ne renvoie que le texte résumé."}
		}
	}
})
```

The LLM API key can also be set by the shell environment variable `GEMINI_API_KEY` for the Gemini endpoint, and by the variable `GROQ_API_KEY` for the Groq endpoint.

## Commands
The following commands are available when the plugin is installed.

| Command                  |  Description                                                                     |
|--------------------------|----------------------------------------------------------------------------------|
| `:[range]SimpleLLM Buffer {prompt}` | Ask a question to LLM and insert answer before cursor position in the current buffer. If specified, `prompt` is sent to LLM. If `range` is given, the prompt is followed by a newline and all the lines in the range. |
| `:[range]SimpleLLM! Buffer {prompt}` | Ask a question to LLM and insert answer before cursor position in the current buffer. If specified, `prompt` is sent to LLM. If `range` is given, the prompt is followed by a newline and all the lines in the range. Unlike the previous plain version, the selection is deleted before the answer is inserted. In other words the selected text is used as the prompt for a LLM request, which may be preceded by another prompt, and is replaced by its answer. |
| `:[range]SimpleLLM Reg {prompt}` | Ask a question to LLM and fill the unnamed register with the answer. If specified, `prompt` is sent to LLM. If `range` is given, the prompt is followed by a newline and all the lines in the range. |
| `:[range]SimpleLLM Reg={name} {prompt}` | Ask a question to LLM and fill the `name` register with the answer. If specified, `prompt` is sent to LLM. `name` should be a single character specifying the buffer which will be filled with the answer of the request to LLM. If `range` is given, the prompt is followed by a newline and all the lines in the range. |
| `:[range]SimpleLLM Scratch {prompt}` | Ask a question to LLM and display the answer in a new floating window. If specified, `prompt` is sent to LLM. The floating window can be closed by pressing `<Esc>`. The content of the floating window is deleted when it is closed. If `range` is given, the prompt is followed by a newline and all the lines in the range. |
| `:SimpleLLM set {endpoint} {model}` | Set the endpoint and model for the following calls to the API. It is up to the user to ensure the model is available at the chosen endpoint and that the he is allowed to use the given model according to his plan. You can also use the auto-completion to find the available endpoints and models. |


When no prompt is given for a command that expects a prompt, the user is asked to pick one from the predefined prompts.

## Related plugins
- [askGemini.nvim](https://github.com/agusnt/askGemini.nvim): This is the main source of inspiration for this plugin. It is a very good plugin, quite minimalistic in its design too. However I needed something that could be used without a popup window.
- [gemini.nvim](https://github.com/kiddos/gemini.nvim): This plugin has more features and configuration options but is very oriented towards code.
- [ai.nvim](https://github.com/gera2ld/ai.nvim): This plugin allows for other providers. Unlike simpleLLM.nvim, it generates the answer in a new popup.
