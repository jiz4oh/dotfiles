local cli = require("ai_commit.cli")

local resolved, resolve_err = cli.resolve_cli()
assert(resolved and resolved.backend == "openai", resolve_err)
assert(resolved.endpoint == "http://127.0.0.1:28770/v1/chat/completions")
assert(cli.resolve_models("openai")[1] == "test-model")

local command, opts = cli.build_cli_invocation(resolved, "test prompt", "test-model")
assert(command[1] == "/bin/sh")
assert(not table.concat(command, " "):find("test%-key"))

local request = vim.json.decode(opts.stdin)
assert(request.model == "test-model")
assert(request.messages[1].content == "test prompt")

local output, output_err = cli.read_cli_output(resolved, {
  stdout = '{"choices":[{"message":{"content":"feat: fast commit"}}]}',
})
assert(output == "feat: fast commit", output_err)

local invalid_output, invalid_err = cli.read_cli_output(resolved, { stdout = "not json" })
assert(not invalid_output and invalid_err:find("invalid JSON"))

local api_err = cli.read_error(resolved, {
  stdout = '{"error":{"message":"bad request"}}',
  stderr = "",
  code = 22,
})
assert(api_err == "bad request")

print("ai_commit_cli: ok")
