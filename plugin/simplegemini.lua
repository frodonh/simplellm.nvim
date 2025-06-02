vim.api.nvim_create_user_command('SimpleGemini', require('simplegemini').process, {
		desc = 'Interact with simpleGemini',
		nargs = '?',
		range = true,
		bang = true,
		complete = require('simplegemini').complete,
	})
