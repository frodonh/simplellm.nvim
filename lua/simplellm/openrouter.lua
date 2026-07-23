local M = {}

function M.configure()
	return {
		env_name = "OPENROUTER_API_KEY", -- Name of the environment variable which can be used to set the API key
		default_model = "openai/gpt-oss-20b:free",	-- Name of the default LLM
		models = { "openai/gpt-oss-20b:free", "google/gemma-4-26b-a4b-it:free", "nvidia/nemotron-3-ultra-550b-a55b:free" },
		make_curl = function(json_body, model, api_key)	-- Build the curl command parameters
			return {
				"curl", "-s", "-X", "POST",
				"-H", "Content-Type: application/json",
				"-H", "Authorization: Bearer " .. api_key,
				"-d", json_body, -- Use the properly escaped JSON body
				string.format("https://openrouter.ai/api/v1/chat/completions", model, api_key)
			}
		end,
		make_json_payload = function(context, model, api_key)	-- Create request based on the question text
			local messages = {}
			if type(context) == "string" then
				messages = { { role = "user", content = context } }
			else
				for _, v in ipairs(context) do
					if v:sub(1,2) == "Q:" then
						table.insert(messages, { role = "user", content = v:sub(4) })
					else
						table.insert(messages, { role = "system", content = v:sub(4) })
					end
				end
			end
			return {
				messages = messages,
				model = model,
				stream = false
			}
		end,
		extract_answer = function(json_response)	-- Extract the answer from the JSON structure of the response
			return json_response.choices[1].message.content
		end
	}
end

return M


