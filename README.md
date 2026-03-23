
# ULOOPE

(Untitled Lua Object Oriented Programming Engine) this is a small engine that aims to be pure Lua but exposes a lot of object oriented features and a simple game engine model

## Class System

If you are looking for documentation on the class system please look at the [classes](./classes.lua) file as it has the most documentation on it.

## Engine

My engine is inspired by Unity and Godot with how it works where each [GameObject](./engine.lua#L4) has a table of [children](./engine.lua#L18) and it also has a table of [components](./engine.lua#L19)

I added a simple messaging system recently I would check out [subscribe](./engine.lua#L145), [unsunscribe](./engine.lua#L154), and [message](./engine.lua#L166) (async version [at here](./engine.lua#L179))

### GameObject

This is the base class of all things related to the actual dynamic members of the engine. The GameObject posses the 4 main fields name, parent, children, and components thses each accept the respective classes of string, [GameObject](.\engine.lua#L4), \[[GameObject](./engine.lua#L4)\], and \[[Component](./engine.lua#L33)\] when using [GameObject](./engine.lua#L4)s make sure obey the warnings of your syntax highlighter if it uses EmmyLua as all of this is completely typed for EmmyLua so generally if it warns abour invalids types it is likely right.
