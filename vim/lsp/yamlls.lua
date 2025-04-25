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
        schemas = schemasstore.yaml.schemas({
          extra = {
            {
              description = "Configuration schema for clash meta",
              fileMatch = { "clash.meta/*.yaml" },
              name = "clash.meta",
              url = "https://fastly.jsdelivr.net/gh/dongchengjie/meta-json-schema@main/schemas/meta-json-schema.json",
            },
          },
        }),
      },
    },
  }
end
return opts
