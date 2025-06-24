local M={}

-- Default parameters values
M.config = {}
M.config.endpoint = 'gemini'
M.config.prompts = {}
M.config.language = 'fr'

-- Setup configuration
function M.setup(options)
	M.config = vim.tbl_deep_extend("force", M.config, options or {})
end

-- Custom complete function for subcommands
function M.complete(arglead, cmdline, cursorpos)
	return require('simplellm/impl').complete(arglead, cmdline, cursorpos)
end

-- Sent a question to a LLM
function M.send_prompt(question_text)
	return require('simplellm/impl').send_prompt(M.config, question_text)
end

-- Process command arguments, wraps a call to the LLM and the processing of the answer
function M.process(args)
	return require('simplellm/impl').process(M.config, args)
end

return M
