call personal#op#map('<leader>ac', 'CopilotChatToggle')
call personal#op#map('<leader>af', 'CopilotChatFix')
call personal#op#map('<leader>aD', 'CopilotChatDocs')
call personal#op#map('<leader>at', 'CopilotChatTests')
call personal#op#map('<leader>ao', 'CopilotChatOptimize')
call personal#op#map('<leader>ae', 'CopilotChatExplain')

nnoremap <leader>ac :CopilotChatToggle<cr>
nnoremap <leader>ag :CopilotChatCommitStaged<cr>
nnoremap <leader>ad :CopilotChatFixDiagnostic<cr>
xnoremap <leader>ar :CopilotChatReview<cr>

lua<<EOF
require("CopilotChat.integrations.cmp").setup()
require("CopilotChat").setup {
  mappings = {
    complete = {
      insert = '',
    },
  },
}
vim.keymap.set('n', '<leader>aa',
  function()
    local input = vim.fn.input("Quick Chat: ")
    if input ~= "" then
      require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
    end
  end, { desc = 'CopilotChat - Quick chat' })
EOF
