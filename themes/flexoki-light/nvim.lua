return {
	{
		"kepano/flexoki-neovim",
		name = "flexoki",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd("colorscheme flexoki-light")
		end,
	},
}
