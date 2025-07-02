local M = {}

function M.configure()
	return {
		env_name = "GEMINI_API_KEY", -- Name of the environment variable which can be used to set the API key
		default_model = "gemini-2.0-flash",	-- Name of the default LLM
		models = {"gemini-2.0-flash", "gemini-2.5-flash", "gemini-2.0-flash-lite", "gemma-3n-e4b-it"},	-- Available models
		make_curl = function(json_body, model, api_key)	-- Build the curl command parameters
			return {
				"curl", "-s", "-X", "POST",
				"-H", "Content-Type: application/json",
				"-d", json_body, -- Use the properly escaped JSON body
				string.format("https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s", model, api_key)
			}
		end,
		make_json_payload = function(context, model, api_key)	-- Create request based on the question text
			if type(context) == "string" then
				return { contents = { { parts = { { text = context } } } } }
			end
			local contents = {}
			for _, v in ipairs(context) do
				if v:sub(1,2) == "Q:" then
					table.insert(contents, { role = "user", parts = { { text = v:sub(4) } } })
				else
					table.insert(contents, { role = "model", parts = { { text = v:sub(4) } } })
				end
			end
			return { contents = contents }
		end,
		extract_answer = function(json_response)	-- Extract the answer from the JSON structure of the response
			return json_response.candidates[1].content.parts[1].text
		end
	}
end

return M
