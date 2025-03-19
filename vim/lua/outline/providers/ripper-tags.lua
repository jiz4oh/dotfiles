local kinds_index = require("outline.symbols").str_to_kind

local config = {
	scope_sep = "::",
	kinds = {
		prototype = "Function",
		member = "Field",
	},
	filetypes = {
		Ruby = {
			kinds = {
				class = "Class",
				method = "Method",
				module = "Module",
				constant = "Constant",
				alias = "method",
				["singleton method"] = "StaticMethod",
			},
		},
		Rails = {
			kinds = {
				has_many = "Macro",
				has_one = "Macro",
				has_and_belongs_to_many = "Macro",
				belongs_to = "Macro",
				scope = "Macro",
			},
		},
	},
}

local M = {
	name = "ripper-tags",
}

function M.supports_buffer(bufnr, conf) ---@diagnostic disable-line
	return vim.api.nvim_get_option_value("filetype", { buf = bufnr }) == "ruby", { ft = "ruby", buf = bufnr }
end

local function ctags_kind_to_outline_kind(kind, language)
	local fallback = "Class"
	if not kind then
		return kinds_index[fallback]
	end

	local filetypes = config.filetypes[language] or {}
	local kinds = filetypes.kinds or {}
	local outline_kind = kinds[kind]
	if not outline_kind then
		outline_kind = config.kinds[kind]
	end

	return kinds_index[outline_kind] or kinds_index[fallback]
end

local function format_tag(tag)
	local range = {
		-- line 和 character(column) 从 0 开始
		start = { line = tag.line - 1, character = 0 },
		["end"] = { line = tag.line - 1, character = 10000 },
	}
	if tag["end"] then
		range["end"].line = tag["end"] - 1
	end
	tag.range = range

	local symbol = {
		name = tag.name,
		kind = ctags_kind_to_outline_kind(tag.kind, tag.language),
		range = range,
		selectionRange = range,
		class = tag.class,
		inherits = tag.inherits,
		access = tag.access,
		children = {},
	}

	return symbol
end

-- ripper-tags --format=json {file}
local function convert_symbols(text)
	local tags = vim.json.decode(text)

	local tree = {}
	local node_map = {}

	for _, tag in ipairs(tags) do
		local node = format_tag(tag)
		node_map[tag.full_name] = node
	end

	for _, tag in ipairs(tags) do
		local current_node = node_map[tag.full_name]
		if tag["class"] then
			local parent_node = node_map[tag["class"]]
			if parent_node then
				table.insert(parent_node.children, current_node)
			else
				local kind = tag["class"]
				-- Create a parent node if it doesn't exist in the list
				local new_parent_node = {
					full_name = tag["class"],
					name = tag["class"],
					kind = ctags_kind_to_outline_kind(kind, tag.language),
					range = tag.range,
					selectionRange = tag.range,
					dummy = true, -- 标识作为 scope 添加
					children = { current_node },
				}
				node_map[tag["class"]] = new_parent_node
				table.insert(tree, new_parent_node)
			end
		else
			-- If no class or inherits, it's a root node
			table.insert(tree, current_node)
		end
	end

	local final_tree = {}
	for _, node in ipairs(tree) do
		if #node.children > 0 or not node.dummy then
			table.insert(final_tree, node)
		end
	end

	return final_tree
end

function M.request_symbols(on_symbols, opts)
	local on_exit = function(obj)
		vim.schedule(function()
			if obj.code ~= 0 then
				vim.notify(string.format("ripper-tags occur error %d: %s", obj.code, obj.stderr))
				return
			end
			on_symbols(convert_symbols(obj.stdout), opts)
		end)
	end
	vim.system({
		"ripper-tags",
		"-f",
		"-",
		"--format=json",
		vim.fn.expand("%:p"),
	}, { text = true }, on_exit)
end

return M
