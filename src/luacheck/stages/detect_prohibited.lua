local vars = {}
local stage = {}
-- local reserved_keywords = { "and", "break", "do", "else", "elseif", "end", "false", "for", "function", "goto", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while", "assert", "collectgarbage", "dofile", "error", "getmetatable", "ipairs", "load", "loadfile", "next", "pairs", "pcall", "print", "rawequal", "rawget", "rawlen", "rawset", "require", "select", "setmetatable", "tonumber", "tostring", "type" }
local prohibited_vars = { "pass" }

stage.warnings = {
    ["215"] = {message_format = "prohibited variable name detected {name}", fields = {"name"}},
}

local function detect_prohibited(chstate, nodes, word)
   local items = {}
   for i in ipairs(vars) do
      for j in ipairs(word) do
         if vars[i] == word[j] then
            table.insert(items, vars[i])
            local num_nodes = #nodes

            for index = 1, num_nodes do
               local node = nodes[index]

               if type(node) == "table" then
                  chstate:warn_range("215", node, { name = word[j] })
                  break
               end
            end
         end
      end
   end
   return items
end

local function check_nodes(nodes)
   for _, node in ipairs(nodes) do
      if type(node) == "table" then
         if node.tag == "Id" then
            if next(vars) == nil then
               table.insert(vars, node[1])
            else
               local var_name_is_new = true
               for i in ipairs(vars) do
                  if vars[i] == node[1] then
                     var_name_is_new = false
                  end
               end
               if var_name_is_new == true then
                  table.insert(vars, node[1])
               end
            end
         else
            check_nodes(node)
         end
      end
   end
end

function stage.run(chstate)
   check_nodes(chstate.ast)
   detect_prohibited(chstate, chstate.ast, prohibited_vars)
end

return stage
