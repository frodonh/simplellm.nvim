local M = {}

-- Sent a question to Gemini
local function send_prompt(config, question_text)
    -- Check API key existence early
    if not config.api_key or config.api_key == '' then
        vim.notify('GEMINI_API_KEY is not set. Please set the environment variable or pass it in setup.', vim.log.levels.ERROR)
        return
    end

    -- Construct JSON payload
    local json_payload = {
        contents = {
            {
                parts = {
                    { text = question_text }
                }
            }
        }
        -- Add generationConfig here if needed (temperature, max tokens etc.)
        -- generationConfig = { ... }
    }

    -- Encode JSON safely
    local ok, json_body = pcall(vim.json.encode, json_payload)
	if not ok then
        return
    end

    -- Escape single quotes for the shell command (-d '...')
    -- WARNING: This is basic escaping and might not be fully secure if complex text is involved.
    -- Consider using libraries or more robust escaping if needed.
    local escaped_json_body = string.gsub(json_body, "'", "'\\''")

    -- Construct the API URL using the configured model
    local api_url = string.format(
        "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s",
        config.model,  -- Use the configured model
        config.api_key
    )

    -- Construct the curl command
    local cmd = {
        "curl", "-s", "-X", "POST",
        "-H", "Content-Type: application/json",
        "-d", escaped_json_body, -- Use the properly escaped JSON body
        api_url
    }

    -- Run the job asynchronously
	local res = ""
    local ret = vim.system(cmd, { text = true }):wait()
	data = ret.stdout
	if data and #data > 0 then -- Check if data is not nil and not empty table
		-- Attempt to decode JSON response
		local decode_ok, json_response = pcall(vim.json.decode, data)
		if decode_ok and json_response then
			-- Extract text safely using pcall or checks
			local extract_ok, result_text = pcall(function()
				-- Adjust path based on actual API response structure
				return json_response.candidates[1].content.parts[1].text
			end)

			if extract_ok and result_text then
				res = result_text
			else
				-- Handle cases where the expected structure isn't found
				error("Error: Could not extract text from Gemini response.\n\nRaw Response:\n" .. data)
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

function M.ask_gemini(config, args)
	local prompt = ""
	if args.args then
		prompt = args.args .. "\n"
	end
	if args.range > 0 then
		local lines = vim.api.nvim_buf_get_lines(0, args.line1 - 1, args.line2, false)
		prompt = prompt .. table.concat(lines, "\n")
	end
	local res = send_prompt(config, prompt)
	local lines = {}
	if res == nil then
		return {}
	end
	for s in res:gmatch("[^\r\n]+") do
		table.insert(lines, s)
	end
	return lines
end

function M.create_scratch_with_lines(lines)
	local bufnr = vim.api.nvim_create_buf(false, true)
	local winid = vim.api.nvim_open_win( bufnr, true, { title = ' Gemini ', title_pos = 'center', relative = 'editor', row = math.floor(((vim.o.lines-20)/2)-1), col = math.floor(vim.o.columns/2-30), height = 20, width = 60, style = 'minimal', border = 'rounded'} )
	vim.api.nvim_win_set_option(winid, 'winblend', 0)
	vim.keymap.set({'n'}, '<Esc>', function()
		vim.api.nvim_buf_delete( bufnr, {force = true} )
	end, {
		buffer = bufnr,
		silent = true,
	})
	vim.api.nvim_buf_set_lines( bufnr, 0, 0, false, lines )
end

return M
