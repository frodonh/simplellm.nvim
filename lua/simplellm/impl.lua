local M = {}

-- List of supported endpoints
local endpointsl = {"gemini", "groq", "openrouter"}	-- Only used for completion
local endpoints = {}
local mt = {
	__index = function(table, key)
		local ok, res
		ok, res = pcall(function() return require('simplellm/' .. key).configure() end)
		if ok then
			table[key] = res
		end
		return res
	end
}
setmetatable(endpoints, mt)
local prompts = {}

-- Sent a question to a LLM
function M.send_prompt(config, question_text)
	-- Load endpoint configuration if needed
	local llm = config.endpoint

	-- Get model and API key
	local api_key = ( config[llm] and config[llm].api_key ) or os.getenv(endpoints[llm].env_name) or ''
    if api_key == '' then
        error('API key for endpoint ' .. llm .. ' is not set. Please set the environment variable ' .. endpoints[llm].env_name .. ' or pass it in setup.')
		return
    end
	local model = ( config[llm] and config[llm].model ) or endpoints[llm].default_model

    -- Construct JSON payload
    local json_payload = endpoints[llm].make_json_payload(question_text, model, api_key)

    -- Encode JSON safely
    local ok, json_body = pcall(vim.json.encode, json_payload)
	if not ok then
        return
    end

    -- Escape single quotes for the shell command (-d '...')
    -- WARNING: This is basic escaping and might not be fully secure if complex text is involved.
    -- Consider using libraries or more robust escaping if needed.
    local escaped_json_body = string.gsub(json_body, "'", "'\\''")

    -- Construct the curl command
    local cmd = endpoints[llm].make_curl(escaped_json_body, model, api_key)

    -- Run the job asynchronously
	local res = ""
    local ret = vim.system(cmd, { text = true }):wait()
	local data = ret.stdout
	if data and #data > 0 then -- Check if data is not nil and not empty table
		-- Attempt to decode JSON response
		local decode_ok, json_response = pcall(vim.json.decode, data)
		if decode_ok and json_response then
			-- Extract text safely using pcall or checks
			local extract_ok, result_text = pcall(function()
				-- Adjust path based on actual API response structure
				return endpoints[llm].extract_answer(json_response)
			end)

			if extract_ok and result_text then
				res = result_text
			else
				-- Handle cases where the expected structure isn't found
				error("Error: Could not extract text from " .. llm .. " response.\n\nRaw Response:\n" .. data)
			end
		elseif json_response and json_response.error then
			 -- Handle API error message if present in JSON
			local error_msg = json_response.error.message or "Unknown API error"
			error("API Error: " .. error_msg .. "\n\nRaw Response:\n" .. data)
		else
			-- Handle non-JSON or malformed JSON response
			error("Error: Received non-JSON or malformed response from API.\n\nRaw Response:\n" .. data)
		end
	end
	return res
end

local function create_scratch_with_lines(config, lines)
	local bufnr = vim.api.nvim_create_buf(false, true)
	local winid = vim.api.nvim_open_win( bufnr, true, { title = ' ' .. config.endpoint .. ' ', title_pos = 'center', relative = 'editor', row = math.floor(((vim.o.lines-20)/2)-1), col = math.floor(vim.o.columns/2-30), height = 20, width = 60, style = 'minimal', border = 'rounded'} )
	vim.api.nvim_win_set_option(winid, 'winblend', 0)
	vim.keymap.set({'n'}, '<Esc>', function()
		vim.api.nvim_buf_delete( bufnr, {force = true} )
	end, {
		buffer = bufnr,
		silent = true,
	})
	vim.api.nvim_buf_set_lines( bufnr, 0, 0, false, lines )
end

function M.complete(_, cmdline, _)
	local res = {}
	local m
	local n
	-- Test if the command has the forme :SimpleLLM set <endpoint> ...
	m, n = cmdline:match("^.*SimpleLLM%s*set%s*(%S+)%s*(%S*)$")
	if m and n then
		if endpoints[m] then
			for _, v in pairs(endpoints[m].models) do
				if v:match('^' .. n) then table.insert(res, v) end
			end
			return res
		end
	end
	-- Test if the command has the forme :SimpleLLM set ...
	m = cmdline:match("^.*SimpleLLM%s*set%s*(%S*)$")
	if m then
		for _, v in pairs(endpointsl) do
			if v:match('^' .. m) then table.insert(res, v) end
		end
		return res
	end
	-- Test if the command has the forme :SimpleLLM ...
	m = cmdline:match("^.*SimpleLLM!?%s*(%S*)$")
	if not m then return nil ; end
	for _, v in pairs({"Scratch ", "Reg=", "Buffer ", "set "}) do
		if v:match("^" .. m) then table.insert(res, v) ; end
	end
	return res
end

local function GetPrompts(config)
	if not prompts[config.language] then
		prompts[config.language] = require('simplellm/prompts').prompts[config.language]
		prompts[config.language] = vim.tbl_deep_extend("force", prompts[config.language], config.prompts[config.language] or {})
	end
	return prompts[config.language]
end

function M.process(config, args)
	if args.args == nil then
		return nil
	end
	-- Parse subcommand
	local cmd, rest = args.args:match('^(%S+)%s*(.*)$')
	-- Set subcommand
	if cmd == 'set' then
		local ep, mod = rest:match('^(%S+)%s*(%S*)')
		config.endpoint = ep
		if mod and mod ~= "" then
			if not config[ep] then
				config[ep] = {}
			end
			config[ep].model = mod
		else
			mod = endpoints[ep].default_model
		end
		print("SimpleLLM endpoint set to " .. ep .. ", using model " .. mod)
		return nil
	end
	-- Build prompt
	local prompt = rest
	if prompt == nil or prompt == "" then
		vim.ui.select(GetPrompts(config), {
			prompt = 'Select prompt:',
			format_item = function(item)
				return item.action
			end
		}, function(choice)
			if choice ~= nil then prompt = choice.prompt ; end
		end)
	end
	if args.range > 0 then
		local lines = vim.api.nvim_buf_get_lines(0, args.line1 - 1, args.line2, false)
		prompt = prompt .. "\n" .. table.concat(lines, "\n")
	end
	-- Get result
	local ok, res = pcall( function() return M.send_prompt(config, prompt) end )
	if not ok then
		vim.notify("Call to endpoint " .. config.endpoint .. " failed: " .. res)
		return {}
	end
	local lines = {}
	if res == nil then
		return {}
	end
	for s in res:gmatch("[^\r\n]+") do
		table.insert(lines, s)
	end
	-- Do something with the result
	if cmd == 'Scratch' then
		-- Send answer to new scratch window if the bang-form was used
		create_scratch_with_lines(config, lines)
	elseif cmd:sub(1, 3) == 'Reg' then
		-- Send answer to provided register
		local reg = (cmd:len() < 5) and '"' or cmd:sub(5, 5)
		vim.fn.setreg(reg, lines)
		print("Register filled with LLM answer")
	elseif cmd == 'Buffer' then
		-- Send answer to current buffer position otherwise
		local line = vim.api.nvim_win_get_cursor(0)
		if args.range > 0 and args.bang then
			-- If Bang version is used, delete selection
			vim.api.nvim_buf_set_lines(0, args.line1 - 1, args.line2, true, {})
		end
		vim.api.nvim_buf_set_lines(0, line[1]-1, line[1]-1, true, lines)
	else
		error("Bad verb after 'SimpleLLM' command: " .. cmd)
	end
end

return M
