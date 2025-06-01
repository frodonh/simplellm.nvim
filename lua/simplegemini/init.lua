local M={}

M.config = {}
M.config.api_key = os.getenv('GEMINI_API_KEY')
M.config.model = 'gemini-2.0-flash'

function M.setup(options)
	M.config = vim.tbl_deep_extend("force", M.config, options or {})

    -- Check if API key is finally set
    if not M.config.api_key or M.config.api_key == '' then
        vim.notify('GEMINI_API_KEY is not set. Set environment variable or pass api_key in setup.', vim.log.levels.WARN)
    end
end

function M.ask_gemini(args)
	return require('simplegemini/impl').ask_gemini(M.config, args)
end

function M.create_scratch_with_lines(lines)
	return require('simplegemini/impl').create_scratch_with_lines(lines)
end

return M
