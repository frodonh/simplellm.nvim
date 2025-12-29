local M = {}

function M.configure()
	return {
		env_name = "GROQ_API_KEY", -- Name of the environment variable which can be used to set the API key
		default_model = "compound-beta",	-- Name of the default LLM
		models = { "groq/compound-beta", "groq/compound-mini", "qwen/qwen3-32b", "meta-llama/llama-4-maverick-17b-128e-instruct", "meta-llama/llama-4-scout-17b-16e-instruct" },
		make_curl = function(json_body, model, api_key)	-- Build the curl command parameters
			return {
				"curl", "-s", "-X", "POST",
				"-H", "Content-Type: application/json",
				"-H", "Authorization: Bearer " .. api_key,
				"-d", json_body, -- Use the properly escaped JSON body
				string.format("https://api.groq.com/openai/v1/chat/completions", model, api_key)
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
						table.insert(messages, { role = "assistant", content = v:sub(4) })
					end
				end
			end
			return {
				messages = messages,
				model = model,
				max_completion_tokens = 1024,
				stream = false
			}
		end,
		extract_answer = function(json_response)	-- Extract the answer from the JSON structure of the response
			return json_response.choices[1].message.content
		end
	}
end

return M

