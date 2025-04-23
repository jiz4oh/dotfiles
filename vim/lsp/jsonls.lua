local opts = {}
local ok1, schemasstore = pcall(require, "schemastore")
if ok1 then
  opts = {
    settings = {
      json = {
        schemas = schemasstore.json.schemas(),
        validate = { enable = true },
      },
    },
  }
end
return opts
