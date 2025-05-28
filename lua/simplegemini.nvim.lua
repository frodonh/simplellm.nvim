local M={}

function M.setup(options)
	options = options or {}

	-- Get API key from environment (can be overridden by opts.api_key)
    M.config.api_key = os.getenv('GEMINI_API_KEY')
    if options.api_key then
      M.config.api_key = options.api_key -- Allow overriding via setup options
    end

    -- Check if API key is finally set
    if not M.config.api_key or M.config.api_key == '' then
        vim.notify('GEMINI_API_KEY is not set. Set environment variable or pass api_key in setup.', vim.log.levels.WARN)
    end

    -- Set model, allowing override from options
    if options.model then
        M.config.model = options.model
    end

    -- Update default prompt if provided
    if options.default_prompt_for_selection then
        M.config.default_prompt_for_selection = options.default_prompt_for_selection
    end

	-- Custom register for saving results
	if options.register then
		M.register = options.register
	else
		M.register = 'g'
	end
end

-- Sent a question to Gemini
function M.send_prompt(question_text)
    -- Check API key existence early
    if not M.config.api_key or M.config.api_key == '' then
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
        M.config.model,  -- Use the configured model
        M.config.api_key
    )

    -- Construct the curl command
    local cmd = {
        "curl", "-s", "-X", "POST",
        "-H", "Content-Type: application/json",
        "-d", escaped_json_body, -- Use the properly escaped JSON body
        api_url
    }

    -- Variable to track if stdout callback was successful
    local response_received = false

    -- Run the job asynchronously
    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data, _)
            if data and #data > 0 then -- Check if data is not nil and not empty table
                local full_response = table.concat(data, "\n")
                -- Attempt to decode JSON response
                local decode_ok, json_response = pcall(vim.json.decode, full_response)
                if decode_ok and json_response then
                    -- Extract text safely using pcall or checks
                    local extract_ok, result_text = pcall(function()
                        -- Adjust path based on actual API response structure
                        return json_response.candidates[1].content.parts[1].text
                    end)

                    if extract_ok and result_text then
						return result_text
                    else
                        -- Handle cases where the expected structure isn't found
						error("Error: Could not extract text from Gemini response.\n\nRaw Response:\n" .. full_response)
                    end
                elseif json_response and json_response.error then
                     -- Handle API error message if present in JSON
                    local error_msg = json_response.error.message or "Unknown API error"
					error("API Error: " .. error_msg .. "\n\nRaw Response:\n" .. full_response)
                else
                    -- Handle non-JSON or malformed JSON response
					error("Error: Received non-JSON or malformed response from API.\n\nRaw Response:\n" .. full_response)
                end
            end
        end,
        on_stderr = function(_, data, _)
            -- Only show stderr if stdout didn't process successfully
            if not response_received and data and #data > 0 then
                local error_output = table.concat(data, "\n")
				error("Error during API call (stderr):\n" .. error_output)
            end
        end,
    })
end

return M
