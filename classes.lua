--[[
This is my most complicated class system yet so I should explain it

Everything is mostly method based so don't use direct access to any of
the fields starting with "__" unless they are a metamethod you plan to add

The simplest way to define a class is 
---@class cls : Class<parent>
local cls = classes.create(name, parent)

Or if you perfer more traditionally (just needs more casting to get rid of warnings)
---@class cls : parent
local cls = classes.create(name, parent)

This system allows the use of mixins currently they are simple and allow just
defining new values in a class or instance. Later on they might get more advanced
and I may add getters and setters via a new "__proxies" table

I have documented every function and exactly what it does if you need further
documentation please open a issue
]]

---@generic T
---@class Class<T>
---@field __index self|fun(self : self, key : any) : any
---@field __call (fun(self : self, ... : any) : any)?
---@field __class Class
---@field __mixins [Mixin]?
---@field __name string
---@field init fun(self : self,o : table, ... : any)?

---@generic T : Class
---@class Instance<T>

---@alias Object Class|Instance

---@class classes : Class
local classes = {}
classes.__class = classes
classes.__index = classes
classes.__name = "classes"
classes.__mixins = {}

--- Makes a class
---@generic T : Class
---@param name string
---@param parent T?
---@return Class<T>
function classes.create(name, parent)
    parent = parent or classes
    local o = {}
    o.__class = parent
    o.__index = o
    o.__name = name
    ---@cast o Class
    ---@cast parent Class
    return setmetatable(o, parent)
end

--- Gets the class of the provided object
---@param obj Object
---@return Class?
function classes.getClass(obj)
    assert(type(obj) == "table","Expected a table to check class of")
    return rawget(obj,"__class")
end

--- Gets the mixins of the provided object
---@param obj Object
---@return [Mixin]
function classes.getMixins(obj)
    assert(type(obj) == "table","Expected to fetch the mixins of a table")
    return rawget(obj,"__mixins") or {}
end

--- Resolves a value for an object
---@param obj Object
---@param key any
---@return any
function classes.resolve(obj, key)
    local class = classes.getClass(obj)
    if class and class[key] then
        return class[key]
    end
    local mixins = classes.getMixins(obj)
    for i=1, #mixins do
        if mixins[i][key] then
            return mixins[i][key]
        end
    end
end
classes.__index = classes.resolve

--- Helper for instancing
---@generic T : Class
---@param cls T
---@param o table
---@return Instance<T>
function classes.instance(cls, o)
    o.__class = cls
    return setmetatable(o, cls)
end

--- Calls the constructor of a class
---@param cls Class
---@param ... any
---@return Instance
function classes.new(cls, ...)
    if cls.init then
        local o = {}
        cls:init(o, ...)
        return o
    end
    error("No initalizer for class", 2)
end

--- Simply returns the super (aka __class)
---@param obj Object
---@return Class?
function classes.super(obj)
    return classes.getClass(obj)
end

classes.__call = classes.new

-- mixins
---@class Mixin : classes
local Mixin = classes.create("Mixin")

--- Initalize a mixin
---@param o table
---@param name string
function Mixin:init(o, name)
    o.__name = name
    classes.instance(self, o)
end

--- Adds a mixin
---@param obj Object
---@param mixin Mixin
function classes.addMixin(obj, mixin)
    local mixins = classes.getMixins(obj)
    mixins[#mixins+1] = mixin
    rawset(obj,"__mixins",mixins)
end

--- Checks for a mixin
---@param obj Object
---@param mixin Mixin
---@return boolean
function classes.hasMixin(obj, mixin)
    local mixins = classes.getMixins(obj)
    for i=1, #mixins do
        if mixins[i] == mixin then
            return true
        end
    end
    return false
end

return classes