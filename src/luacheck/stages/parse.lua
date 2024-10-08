local decoder = require "luacheck.decoder"
local parser = require "luacheck.parser"

local stage = {}

function stage.run(chstate)
   chstate.source = decoder.decode(chstate.source_bytes)
   chstate.line_offsets = {}
   chstate.line_lengths = {}
   local ast, comments, code_lines, line_endings, useless_semicolons = parser.parse(
      chstate.source, chstate.line_offsets, chstate.line_lengths)
   chstate.ast = ast
   chstate.comments = comments
   chstate.code_lines = code_lines
   chstate.line_endings = line_endings
   chstate.useless_semicolons = useless_semicolons

   local function format_any_value(obj, buffer)
      local _type = type(obj)
      if _type == "table" then
         buffer[#buffer + 1] = '{"'
         for key, value in next, obj, nil do
            buffer[#buffer + 1] = tostring(key) .. '":'
            format_any_value(value, buffer)
            buffer[#buffer + 1] = ',"'
         end
         buffer[#buffer] = '}' -- note the overwrite
      elseif _type == "string" then
         buffer[#buffer + 1] = '"' .. obj .. '"'
      elseif _type == "boolean" or _type == "number" then
         buffer[#buffer + 1] = tostring(obj)
      else
         buffer[#buffer + 1] = '"???' .. _type .. '???"'
      end
   end

   local function format_as_json(obj)
      if obj == nil then return "null" else
         local buffer = {}
         format_any_value(obj, buffer)
         return table.concat(buffer)
      end
   end

   local function print_as_json(obj)
      print(format_as_json(obj))
   end

   print_as_json(ast)
end

return stage
