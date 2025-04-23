local opts = {}
local ok1, schemasstore = pcall(require, "schemastore")
if ok1 then
  opts = {
    settings = {
      yaml = {
        schemaStore = {
          -- You must disable built-in schemaStore support if you want to use
          -- this plugin and its advanced options like `ignore`.
          enable = false,
          -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
          url = "",
        },
        schemas = schemasstore.yaml.schemas(),
      },
    },
  }
end
return opts
