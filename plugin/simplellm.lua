vim.api.nvim_create_user_command('SimpleLLM', require('simplellm').process, {
		desc = 'Interact with LLM',
		nargs = '?',
		range = true,
		bang = true,
		complete = require('simplellm').complete,
	})
