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
		make_json_payload = function(question_text, model, api_key)	-- Create request based on the question text
			return { contents = { { parts = { { text = question_text } } } } }
		end,
		extract_answer = function(json_response)	-- Extract the answer from the JSON structure of the response
			return json_response.candidates[1].content.parts[1].text
		end
	}
end

return M
