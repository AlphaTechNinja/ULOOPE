-- A small concept

local custom = {}
--- This is a helper to allow the @class<name, parent>
---@param code any
---@return string
function custom.apply(code)
    local lines = {}
    for line in code:gmatch("[^\n]+") do
        local _, e, name, parent = line:find("$@class<([%a%d_]+)%s*,%s*([%a%d_]*)")
        if e then
            if name and name ~= "" then
                if parent and parent ~= "" then
                    lines[#lines+1] = ("---@class %s : Instance<%s>, classes"):format(name,name)
                    lines[#lines+1] = line:sub(e+1,-1).."classes.create(\""..name.."\","..parent..")"
                else
                    lines[#lines+1] = ("---@class %s : Instance<%s>, %s"):format(name,name,parent)
                    lines[#lines+1] = line:sub(e+1,-1).."classes.create(\""..name.."\")"
                end
            else
                error("Invalid syntax "..line:sub(1,e),2)
            end
        else
            lines[#lines+1] = line
        end
    end
    return table.concat(lines,"\n")
end
--[[
An example is doing
@class<test>
function test:init(...)
    ...
end

...

or

@class<test2, test>

...

It isnt too helpful and maybe more confusing but it is a way to compact it.
I wouid suggest using this as a static compiled sort of thing
]]
return custom