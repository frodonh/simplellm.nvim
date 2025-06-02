local M={}

-- Default parameters values
M.config = {}
M.config.api_key = os.getenv('GEMINI_API_KEY')
M.config.model = 'gemini-2.0-flash'
M.config.prompts = {}

-- Setup configuration
function M.setup(options)
	M.config = vim.tbl_deep_extend("force", M.config, options or {})

    -- Check if API key is finally set
    if not M.config.api_key or M.config.api_key == '' then
        vim.notify('GEMINI_API_KEY is not set. Set environment variable or pass api_key in setup.', vim.log.levels.WARN)
    end

	-- Add a few predefined prompts
	for _, v in pairs({
		{action = "Traduction en anglais", prompt = "Traduis-moi le texte suivant en anglais ; ne retourne que le texte traduit sans aucun message d'introduction ou de conclusion."},
		{action = "Amélioration du texte", prompt = "Améliore le texte suivant en corrigeant les erreurs d'orthographe et de grammaire et en améliorant le vocabulaire et les tournures de phrase, sans dénaturer le sens. Répond sans rajouter de message d'introduction ou de conclusion, en formatant le texte en Markdown."},
		{action = "Pas de prompt", prompt = ""}
	}) do
		table.insert(M.config.prompts, 1, v)
	end

M.config.prompts = {
}
end

-- Custom complete function for subcommands
function M.complete(arglead, cmdline, cursorpos)
	return require('simplegemini/impl').complete(arglead, cmdline, cursorpos)
end

-- Send a raw prompt to the LLM and return the answer
function M.send_prompt(prompt)
	return require('simplegemini/impl').send_prompt(M.config, prompt)
end

-- Process command arguments, wraps a call to the LLM and the processing of the answer
function M.process(args)
	return require('simplegemini/impl').process(M.config, args)
end

return M
