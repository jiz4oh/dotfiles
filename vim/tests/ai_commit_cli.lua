local cli = require("ai_commit.cli")

local api, resolve_err = cli.resolve_openai()
assert(api, resolve_err)
assert(api.endpoint == "http://127.0.0.1:28770/v1/chat/completions")
assert(cli.get_model() == "test-model")

local command, opts = cli.build_openai_invocation(api, "test prompt", cli.get_model())
assert(command[1] == "/bin/sh")
assert(not table.concat(command, " "):find("test%-key"))

local request = vim.json.decode(opts.stdin)
assert(request.model == "test-model")
assert(request.messages[1].content == "test prompt")

local output, output_err = cli.read_openai_response({
  stdout = '{"choices":[{"message":{"content":"feat: fast commit"}}]}',
})
assert(output == "feat: fast commit", output_err)

local invalid_output, invalid_err = cli.read_openai_response({ stdout = "not json" })
assert(not invalid_output and invalid_err:find("invalid JSON"))

local api_err = cli.read_openai_error({
  stdout = '{"error":{"message":"bad request"}}',
  stderr = "",
  code = 22,
})
assert(api_err == "bad request")

print("ai_commit_openai: ok")
