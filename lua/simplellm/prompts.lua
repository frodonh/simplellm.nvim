local M={}

M.prompts = {
	fr = {
		{action = "Traduction en anglais", prompt = "Traduis-moi le texte suivant en anglais ; ne retourne que le texte traduit sans aucun message d'introduction ou de conclusion."},
		{action = "Amélioration du texte", prompt = "Améliore le texte suivant en corrigeant les erreurs d'orthographe et de grammaire et en améliorant le vocabulaire et les tournures de phrase, sans dénaturer le sens. Répond sans rajouter de message d'introduction ou de conclusion, en formatant le texte en Markdown."},
		{action = "Ajout d'exemples", prompt = "Améliore le texte suivant rédigé en Markdown, en y rajoutant des exemples pour illustrer les propos, en veillant à les sourcer autant que possible. Répond sans rajouter de message d'introduction ou de conclusion."},
		{action = "Ajout d'illustrations", prompt = "Améliore le texte suivant rédigé en Markdown, en y rajoutant des illustrations liées depuis le web, en indiquant la référence si nécessaire. Les illustrations devront être ajoutées par la méthode usuelle de lien vers des images externes en Markdown. Répond sans rajouter de message d'introduction ou de conclusion."},
		{action = "Pas de prompt", prompt = ""}
	},
	en = {
		{action = "French translation", prompt = "Please translate the following text in French ; display only the translated text without any introduction or conclusion."},
		{action = "Improve text", prompt = "Improve the following text by correcting spelling and grammar errors, and enhancing vocabulary and sentence structures, without altering the original meaning. Respond in Markdown format, without adding introductory or concluding messages."},
		{action = "Add examples", prompt = "Improve the following Markdown text by adding examples to illustrate the points made, sourcing them whenever possible. Respond without adding introductory or concluding messages."},
		{action = "Add illustrations", prompt = "Improve the following Markdown text by adding relevant illustrations from the web, indicating the reference if necessary. Illustrations should be added using the standard Markdown method of linking to external images. Respond without adding introductory or concluding messages."},
		{action = "No prompt", prompt = ""}
	},
}

return M
