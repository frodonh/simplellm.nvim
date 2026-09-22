local M = {}

local config = require('simplellm.config')

function M.filter(tab, func)
	local res = {}
	local new_index = 1
	for old_index, v in ipairs(tab) do
		local nv = func(v, old_index)
		if nv ~=nil then
			res[new_index] = nv
			new_index = new_index + 1
		end
	end
	return res
end

function M.get_api_key(name, env_name)
	local api_key = ( config[name] and config[name].api_key ) or os.getenv(env_name) or ''
    if api_key == '' then
        error('API key for endpoint ' .. name .. ' is not set. Please set the environment variable ' .. env_name .. ' or pass it in setup.')
		return {}
    end
	return api_key
end

function M.table_contains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end

return M
