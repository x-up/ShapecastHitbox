# ShapecastHitbox
Hitbox Module for ROBLOX using `WorldRoot:Shapecast`

**Created for a game that I am currently developing; I would not recommend server-side use of this module, as it can be taxing.**

### How do I put this in my game?
1. Create a ModuleScript
2. Paste the code from ShapecastHitbox.luau inside of the newly created module
3. Insert another ModuleScript inside of the newly created module, name it `Hitbox`
4. Paste the code from HitboxObject.luau into the `Hitbox` module.

### Why wont the setting 'OnlyEntities' work?
- For this to work, you need to have a folder inside of `Workspace` named `Entities` that holds all entities.

## Example:
```lua
local combat = {}

local replicatedStorage = game:GetService("ReplicatedStorage")
local hitboxModule = require(replicatedStorage:WaitForChild("Modules"):WaitForChild("ShapecastHitbox"))
local hitbox = hitboxModule.CreateHitbox(
	{
		ReturnType = "Model";
		Time = 1;
		
		OnlyEntities = true;
		Exclude = {character, katana};
		HitOnce = true;
	},
	katanaHitbox
)

function combat:Invoke()
	hitboxObj:Start():Connect(function(model)
		combatEvent:FireServer({"Attack", model})
	end)
end

return combat
```
