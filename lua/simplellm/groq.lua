local M = {}
local config = require('simplellm.config')
local name = 'groq'
local api_key = require('simplellm.utils').get_api_key(name, 'GROQ_API_KEY')

local function get_models()    -- Get a list of available models
	local cmd = {
		"curl", "-s", "-H", "Authorization: Bearer " .. api_key, "https://api.groq.com/openai/v1/models"
	}
	local ret = vim.system(cmd, { text = true }):wait()
	local data = ret.stdout
	if data == nil or #data == 0 then
		return {}
	end
	local decode_ok, json_response = pcall(vim.json.decode, data)
	if not decode_ok then
		return {}
	end
	return require('simplellm.utils').filter(json_response.data, function(e)
		if not e["input_modalities"] or not require('simplellm.utils').table_contains(e['input_modalities'], "text") or not e["output_modalites"] or not require('simplellm.utils').table_contains(e['output_modalities'], "text") or e["context_length"]<1000 then
			return {}
		end
		return e['id']
	end)
end

M.models = get_models()
M.model = ( config[name] and config[name].model ) or M.models[1]

function M.make_curl(json_body)	-- Build the curl command parameters
	return {
		"curl", "-s", "-X", "POST",
		"-H", "Content-Type: application/json",
		"-H", "Authorization: Bearer " .. api_key,
		"-d", json_body, -- Use the properly escaped JSON body
		string.format("https://api.groq.com/openai/v1/chat/completions", M.model, api_key)
	}
end

function M.make_json_payload(context)	-- Create request based on the question text
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
		model = M.model,
		max_completion_tokens = 1024,
		stream = false
	}
end

function M.extract_answer(json_response)	-- Extract the answer from the JSON structure of the response
	return json_response.choices[1].message.content
end

return M

