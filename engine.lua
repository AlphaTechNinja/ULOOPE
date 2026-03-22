local classes = require("classes")

--- Base game object
---@class GameObject : Instance<GameObject>, classes
---@field children [GameObject]
---@field components table<string, Component>
---@field parent GameObject?
---@field name string
---@field start fun(self : self, ... : any)?
---@field update fun(self : self, dt : number, ... : any)?
local GameObject = classes.create("GameObject")

--- Initalize game object
---@param o table
---@param name string
function GameObject:init(o, name)
    o.name = name
    o.children = {}
    o.components = {}
    classes.instance(self, o)
end

--- Base component
---@class Component : Instance<Component>, classes
---@field owner GameObject
---@field start fun(self : self, ... : any)?
---@field update fun(self : self, dt : number, ... : any)?
local Component = classes.create("Component")
function Component:init(o, name)
    name = name or self.__name
    o.name = name
    classes.instance(self, o)
end