" Configuration for CopilotChat.nvim plugin
" This sets up keymappings and window behavior for GitHub Copilot chat interface
"
" Keymappings:
" <leader>af - Fix code issues
" <leader>aD - Generate documentation
" <leader>at - Generate tests
" <leader>ao - Optimize code
" <leader>ae - Explain code
" <leader>ac - Toggle chat window
" <leader>ag - Generate commit message for staged changes
" <leader>ad - Fix diagnostic issues
" <leader>ar - Review selected code (visual mode)
" <leader>aa - Quick chat with buffer context

call personal#op#map('<leader>af', 'CopilotChatFix')
call personal#op#map('<leader>ad', 'CopilotChatDocs')
call personal#op#map('<leader>at', 'CopilotChatTests')
call personal#op#map('<leader>ao', 'CopilotChatOptimize')
call personal#op#map('<leader>ae', 'CopilotChatExplain')
call personal#op#map('<leader>ar', 'CopilotChatReview')

nnoremap <leader>ac :CopilotChatToggle<cr>
nnoremap <leader>aF :CopilotChatFixDiagnostic<cr>

augroup copilotchat-nvim_augroup
  autocmd!
  autocmd FileType gitcommit nnoremap <buffer> cc :CopilotChatCommit<cr>
augroup END

lua<<EOF
require("CopilotChat.integrations.cmp").setup()
require("CopilotChat").setup {
  model = vim.g.copilot_model, -- call CopilotChatModels to check
  mappings = {
    complete = {
      insert = '',
    },
  },
  window = {
    layout = 'float',
    relative = 'cursor',
    width = 0.4,    -- Changed from 1 to 0.4 (40% of screen width)
    height = 0.4,
    row = 1
  }
}
EOF
