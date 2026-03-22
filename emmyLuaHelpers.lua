---@class helpers
local helpers = {}

--- Unroll nil
---@generic T
---@param o T?
---@return T
function helpers.unroll(o)
    return o
end

return helpers