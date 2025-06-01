vim.api.nvim_create_user_command('SimpleGemini', function(args)
	if args.args == nil then
		return nil
	end
	local cmd, rest = args.args:match('^(%S+)%s+(.*)$')
	args.args = rest
	local lines = require('simplegemini').ask_gemini(args)
	if cmd == 'Scratch' then
		-- Send answer to new scratch window if the bang-form was used
		require('simplegemini').create_scratch_with_lines(lines)
	elseif cmd:sub(1, 3) == 'Reg' then
		-- Send answer to provided register
		local reg = (cmd:len() < 5) and '"' or cmd:sub(5, 5)
		vim.fn.setreg(reg, lines)
		print("Register filled with Gemini answer")
	elseif cmd == 'Buffer' then
		-- Send answer to current buffer position otherwise
		local line = vim.api.nvim_win_get_cursor(0)
		if args.range > 0 and args.bang then
			-- If Bang version is used, delete selection
			vim.api.nvim_buf_set_lines(0, args.line1 - 1, args.line2, true, {})
		end
		vim.api.nvim_buf_set_lines(0, line[1]-1, line[1]-1, true, lines)
	else
		error("Bad verb after 'SimpleGemini' command: " .. cmd)
	end
end, {
		desc = 'Interact with simpleGemini',
		nargs = '?',
		range = true,
		bang = true,
		complete = function(_, cmdline, _)
			local m = cmdline:match("^.*SimpleGemini%s*(%S*)$")
			if not m then return nil ; end
			local res = {}
			for _, v in pairs({"Scratch ", "Reg=", "Buffer "}) do
				if v:match("^" .. m) then
					table.insert(res, v)
				end
			end
			return res
		end
	})
