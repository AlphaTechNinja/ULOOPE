local classes = require("classes")

--- Base game object
---@class GameObject : Instance<GameObject>, classes
---@field children [GameObject]
---@field components table<string, Component>
---@field _handles table<string, [fun(self : self, ... : any)]>
---@field parent GameObject?
---@field name string
---@field start fun(self : self, ... : any)?
---@field update fun(self : self, dt : number, ... : any)?
local GameObject = classes.create("GameObject")

--- Initalize game object
---@param o table
---@param name string
---@param parent GameObject?
function GameObject:init(o, name, parent)
    o.name = name
    o.children = {}
    o.components = {}
    o.parent = parent
    o._handles = {}
    classes.instance(self, o)
end

--- Base component
---@class Component : Instance<Component>, classes
---@field owner GameObject
---@field name string
---@field start fun(self : self, ... : any)?
---@field update fun(self : self, dt : number, ... : any)?
local Component = classes.create("Component")
function Component:init(o, name)
    name = name or self.__name
    o.name = name
    classes.instance(self, o)
end

--- Sets the parent of an object
---@param other GameObject
function GameObject:setParent(other)
    assert(classes.isA(other, GameObject),"Cannot be parented to something not a GameObject")
    if self.parent == other then return end
    if other == nil then self.parent:removeChild(self); return end
    other:addChild(self)
end

--- Adds a child to a GameObject
---@param obj GameObject
function GameObject:addChild(obj)
    assert(classes.isA(obj, GameObject),"Cannot have a child that is not a GameObject")
    if obj.parent then
        obj.parent:removeChild(obj)
    end
    obj.parent = self
    self.children[#self.children+1] = obj
end

--- Removes a child from a GameObject
---@param obj GameObject
function GameObject:removeChild(obj)
    assert(classes.isA(obj, GameObject),"Invalid object to attempt to remove as child")
    for i=1,#self.children do
        if self.children[i] == obj then
            obj.parent = nil
            table.remove(self.children,i)
        end
    end
end

--- Adds a component
---@param comp Component
function GameObject:addComponent(comp)
    assert(classes.isA(comp, Component),"Expected a component")
    assert(comp.owner == nil,"Component is already in use")
    assert(self.components[comp.name] == nil,"Component name already in use")

    comp.owner = self
    self.components[comp.name] = comp
end

--- Remove a component
---@param comp Component
function GameObject:removeComponent(comp)
    assert(classes.isA(comp, Component),"Expected a component")
    assert(comp.owner == self,"This GameObject doesn't own this Component")
    
    comp.owner = nil
    self.components[comp.name] = nil
end

--- List component names
---@return [string]
function GameObject:listComponentNames()
    local names = {}
    for name, _ in pairs(self.components) do
        names[#names+1] = name
    end
    return names
end

--- Lists components optionally using a filter
---@param filter Class<Component>?
---@return [Component]
function GameObject:listComponents(filter)
    local comps = {}
    for _, comp in pairs(self.components) do
        if filter then
            if classes.isA(comp, filter) then
                comps[#comps+1] = comp
            end
        else
        comps[#comps+1] = comp
        end
    end
    return comps
end

--- Invoke components with an optional filter
---@param filter Class<Component>?
---@param method string
---@param ... any
function GameObject:invokeComponents(filter, method, ...)
    if filter then
        for _, comp in pairs(self.components) do
            if classes.isA(comp, filter) then
                if comp[method] then
                    comp[method](comp, ...)
                end
            end
        end
    else
        for _, comp in pairs(self.components) do
            if comp[method] then
                comp[method](comp, ...)
            end
        end
    end
end

--- Subscribe to an event
---@param name string
---@param func fun(self : self, ... : any)
function GameObject:subscribe(name, func)
    local handles = self._handles[name] or {}
    handles[#handles+1] = func
    self._handles[name] = handles
end

--- Unscribe from an event
---@param name string
---@param func fun(self : self, ... : any)
function GameObject:unsubscribe(name, func)
    local handles = self._handles[name] or {}
    for i, handle in pairs(handles) do
        if handle == func then
            table.remove(handles,i)
        end
    end
end

--- Send an event
---@param name string
---@param ... any
function GameObject:message(name, ...)
    local handles = self._handles[name] or {}
    for _, handle in pairs(handles) do
        handle(self, ...)
    end
end


--- Async version of events
--- Check the `finished` key to see if it finished
---@param name string
---@param ... any
---@return {_co : [function], _t : table<function, boolean>, finished : boolean}
function GameObject:messageAsync(name, ...)
    local handles = self._handles[name] or {}
    if #handles > 0 then return {finished=true} end
    local finished = {_co={},_t={},finished=false}
    for _, handle in pairs(handles) do
        finished._t[handle] = false
        local co = coroutine.wrap(function (...)
            handle(self, ...)
            finished._t[handle] = true
            if finished.finished then return end
            local alldone = true
            for co, state in pairs(finished._t) do
                alldone = alldone and state
            end
            finished.finished = finished.finished or alldone
        end)
        finished._co[finished._co+1] = co
        co(...)
    end
    return finished
end

---@class Engine
---@field types table<string, Class>
local Engine = {}

Engine.GameObject = GameObject
Engine.Component = Component

Engine.types = {
    GameObject = GameObject,
    Component = Component
}

--- Register a new type
---@param cls Class<GameObject>
function Engine.registerType(cls)
    if Engine.types[cls.__name] then
        error("Type has already been registered!", 2)
    end
    Engine.types[cls.__name] = cls
end

return Engine