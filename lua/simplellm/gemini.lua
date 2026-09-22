local M = {}
local config = require('simplellm.config')
local name = 'gemini'
local api_key = require('simplellm.utils').get_api_key(name, 'GEMINI_API_KEY')

local function get_models()    -- Get a list of available models
	local cmd = {"curl", "-s", string.format("https://generativelanguage.googleapis.com/v1beta/models?key=%s", api_key)}
	local ret = vim.system(cmd, { text = true }):wait()
	local data = ret.stdout
	if data == nil or #data == 0 then
		return {}
	end
	local decode_ok, json_response = pcall(vim.json.decode, data)
	if not decode_ok then
		return {}
	end
	return require('simplellm.utils').filter(json_response['models'], function(e)
		if not e['supportedGenerationMethods'] or not require('simplellm.utils').table_contains(e['supportedGenerationMethods'], 'generateContent') then
			return nil
		end
		return e['name']
	end)
end

M.models = get_models()
M.model = ( config[name] and config[name].model ) or 'models/gemini-flash-latest'

function M.make_curl(json_body)	-- Build the curl command parameters
	return {
		"curl", "-s", "-X", "POST",
		"-H", "Content-Type: application/json",
		"-d", json_body, -- Use the properly escaped JSON body
		string.format("https://generativelanguage.googleapis.com/v1beta/%s:generateContent?key=%s", M.model, api_key)
	}
end

function M.make_json_payload(context)	-- Create request based on the question text
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
end

function M.extract_answer(json_response)	-- Extract the answer from the JSON structure of the response
	return json_response.candidates[1].content.parts[1].text
end

return M
