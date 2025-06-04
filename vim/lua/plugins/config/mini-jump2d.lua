_G.jump2dfFtT_opts = _G.jump2dfFtT_opts or {}

local function make_fFtT_keymap(key, extra_opts)
  local opts =
    vim.tbl_deep_extend("force", { allowed_lines = { blank = false, fold = false } }, extra_opts)
  opts.hooks = opts.hooks or {}

  opts.hooks.before_start = function()
    local input = vim.fn.getcharstr()
    if input == nil then
      opts.spotter = function()
        return {}
      end
    else
      local pattern = vim.pesc(input)
      if MiniJump2d.gen_spotter then
        opts.spotter = MiniJump2d.gen_spotter.pattern(pattern)
      else
        opts.spotter = MiniJump2d.gen_pattern_spotter(pattern)
      end
    end
  end

  -- Using `<Cmd>...<CR>` enables dot-repeat in Operator-pending mode
  -- dot-repeat is not working for me
  _G.jump2dfFtT_opts[key] = opts
  local command = string.format(
    "<Cmd>lua require('lazy').load({ plugins = { 'mini.jump2d' } }); MiniJump2d.start(_G.jump2dfFtT_opts.%s)<CR>",
    key
  )

  vim.api.nvim_set_keymap("n", key, command, {})
  vim.api.nvim_set_keymap("v", key, command, {})
  vim.api.nvim_set_keymap("o", key, command, {})
end

---@type LazyPluginSpec
return {
  "echasnovski/mini.jump2d",
  config = function()
    require("mini.jump2d").setup()
  end,
  lazy = true,
  keys = {
    {
      "gl",
      function()
        MiniJump2d.start(MiniJump2d.builtin_opts.line_start)
      end,
      desc = "Jump to line start",
    },
    {
      "<leader><leader>w",
      function()
        MiniJump2d.start(
          vim.tbl_deep_extend(
            "force",
            { allowed_lines = { cursor_before = false } },
            MiniJump2d.builtin_opts.word_start
          )
        )
      end,
      desc = "Jump to word start forward",
    },
    {
      "<leader><leader>b",
      function()
        MiniJump2d.start(
          vim.tbl_deep_extend(
            "force",
            { allowed_lines = { cursor_after = false } },
            MiniJump2d.builtin_opts.word_start
          )
        )
      end,
      desc = "Jump to word start backward",
    },
  },
  init = function()
    make_fFtT_keymap("f", { allowed_lines = { cursor_before = false } })
    make_fFtT_keymap("F", { allowed_lines = { cursor_after = false } })
    make_fFtT_keymap("t", {
      allowed_lines = { cursor_before = false },
      hooks = {
        after_jump = function()
          vim.api.nvim_input("<Left>")
        end,
      },
    })
    make_fFtT_keymap("T", {
      allowed_lines = { cursor_after = false },
      hooks = {
        after_jump = function()
          vim.api.nvim_input("<Right>")
        end,
      },
    })
  end,
  optional = true,
  specs = {
    {
      "easymotion/vim-easymotion",
      enabled = false,
    },
  },
}
