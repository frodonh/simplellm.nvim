local sgem = require 'simplegemini.nvim'

local function ask_gemini(args)
	local prompt = ""
	if #args.fargs > 0 then
		prompt = args[1] .. "\n"
	end
	if not(args.bang) then
		local lines = vim.api.nvim_buf_get_lines(0, args.line1 - 1, args.line2, false)
		prompt = prompt .. table.concat(lines, "\n")
	end
	local res = sgem.send_prompt(prompt)
	local lines = {}
	for s in res:gmatch("[^\r\n]+") do
		table.insert(lines, s)
	end
	return lines
end

vim.api.nvim_create_user_command('GptToBuf', function(args)
	local lines = ask_gemini(args)
	local line = vim.api.nvim_win_get_cursor(0)
	vim.api.nvim_buf_set_lines(0, line, line, false, lines)
end, {
		desc = 'Ask Gemini and send result to current buffer',
		nargs = '?',
		range = '',
		bang = true,
	})

vim.api.nvim_create_user_command('GptToReg', function(args)
	local lines = ask_gemini(args)
	vim.fn.setreg(sgem.register, lines)
end, {
		desc = 'Ask Gemini and send result to register',
		nargs = '?',
		range = '',
		bang = true,
	})

vim.api.nvim_create_user_command('GptToScratch', function(args)
	local lines = ask_gemini(args)
	local bufnr = vim.api.nvim_create_buf(false, true)
	local winid = vim.api.nvim_open_win( bufnr, true, { title = 'Gemini', title_pos = 'center', relative = 'editor', row = math.floor(((vim.o.lines-20)/2)-1), col = math.floor(vim.o.columns/2-30), height = 20, width = 60, style = 'minimal', border = 'rounded'} )
	vim.api.nvim_win_set_option(winid, 'winblend', 0)
	vim.keymap.set({'n'}, '<Esc>', function()
		vim.api.nvim_buf_delete( bufnr, {force = true} )
	end, {
		buffer = bufnr,
		silent = true,
	})
	vim.api.nvim_buf_set_lines( bufnr, -1, 0, 0, false, lines )
end, {
		desc = 'Ask Gemini and send result to scratch buffer',
		nargs = '?',
		range = '',
		bang = true,
	})

