local vars = {}
local stage = {}
local handle_node
local prohibited_vars = {"pass", "ass", "ss"}

stage.warnings = {
    ["215"] = {message_format = "prohibited name detected {name}", fields = {"name"}},
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

local function check_nodes(chstate, nodes)
   for _, node in ipairs(nodes) do
      if type(node) == "table" then
         handle_node(chstate, node)
      end
   end
end

function handle_node(chstate, node)
   if node.tag == "Id" then
      if #vars == 0 then
         table.insert(vars, node[1])
      else
         local bool = false
         for i in ipairs(vars) do
            if vars[i] == node[1] then
               bool = true
            end
         end
         if bool == false then
            table.insert(vars, node[1])
         end
      end
   else
      check_nodes(chstate, node)
   end
end

function stage.run(chstate)
   check_nodes(chstate, chstate.ast)
   detect_prohibited(chstate, chstate.ast, prohibited_vars)
end

return stage


