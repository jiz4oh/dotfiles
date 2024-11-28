local client_notifs = {}

local function get_notif_data(client_id, token)
	if not client_notifs[client_id] then
		client_notifs[client_id] = {}
	end

	if not client_notifs[client_id][token] then
		client_notifs[client_id][token] = {}
	end

	return client_notifs[client_id][token]
end

local function format_message(number)
	return "Executing query - " .. tostring(number) .. "s"
end

local spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

local function update_spinner(client_id, token)
	local notif_data = get_notif_data(client_id, token)

	if notif_data.spinner then
		local new_spinner = (notif_data.spinner + 1) % #spinner_frames
		notif_data.spinner = new_spinner
		local start_time = notif_data.notification.start_time
		local current_time = vim.uv.clock_gettime("monotonic")
		local interval = (current_time.sec * 1e9 + current_time.nsec - start_time.sec * 1e9 - start_time.nsec) / 1e9
		local message = format_message(interval)

		notif_data.notification = vim.notify(message, "info", {
			hide_from_history = true,
			icon = spinner_frames[new_spinner],
			replace = notif_data.notification,
		})
		notif_data.notification.start_time = start_time

		vim.defer_fn(function()
			update_spinner(client_id, token)
		end, 100)
	end
end

return {
	{
		"stevearc/dressing.nvim",
		enabled = vim.fn.has("nvim-0.8") == 1,
		event = "VeryLazy",
		opts = {
			select = {
				-- Set to false to disable the vim.ui.select implementation
				enabled = true,

				-- Priority list of preferred vim.select implementations
				backend = { "fzf_lua", "fzf", "builtin" },
				fzf = {
					window = {
						width = 0.9,
						height = 0.8,
					},
				},
			},
		},
	},
	{
		"rcarriga/nvim-notify",
		enabled = vim.fn.has("nvim-0.5") == 1,
		init = function()
			vim.notify = require("notify")
			vim.g.db_ui_use_nvim_notify = 1
			vim.g.db_ui_disable_progress_bar = 1
		end,
		event = "VeryLazy",
		opts = {
			stages = "slide",
		},
		config = function(_, opts)
			require("notify").setup(opts)

			vim.api.nvim_create_autocmd("User", {
				pattern = { "DBQueryPre", "*DBExecutePre" },
				callback = function(event)
					local token = event.buf

					local notif_data = get_notif_data("dadbod-ui", token)

					local message = format_message(0.0)

					notif_data.notification = vim.notify(message, "info", {
						title = "[DBUI]",
						icon = spinner_frames[1],
						timeout = false,
						hide_from_history = false,
					})
					notif_data.notification.start_time = vim.uv.clock_gettime("monotonic")

					notif_data.spinner = 1
					update_spinner("dadbod-ui", token)
				end,
			})

			vim.api.nvim_create_autocmd("User", {
				pattern = { "DBQueryPost", "*DBExecutePost" },
				callback = function(event)
					local token = event.buf

					local notif_data = get_notif_data("dadbod-ui", token)

					notif_data.notification = vim.notify(nil, nil, {
						hide_from_history = true,
						icon = "",
						replace = notif_data.notification,
						timeout = 0,
					})

					notif_data.spinner = nil
				end,
			})
		end,
	},
}
