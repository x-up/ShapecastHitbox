--// Environment
local hitboxObj = require(script.Hitbox)

local workspace = game:GetService("Workspace")
local runService = game:GetService("RunService")
local players = game:GetService("Players")

local function findEntity(instance)
	if typeof(instance) ~= "Instance" then return end
	if not instance:IsDescendantOf(workspace.Entities) then return end

	local model = instance:FindFirstAncestorWhichIsA("Model")
	local humanoid = model:FindFirstChild("Humanoid")

	local searches = 0
	while model and not humanoid or searches >= 3 do
		model = model:FindFirstAncestorWhichIsA("Model")
		humanoid = model:FindFirstChild("Humanoid")
		searches += 1
	end

	return model, humanoid
end


--// Module
local self = {} hitboxObj.ShapecastHitbox = self
self.Hitboxes = {}
self.Connections = {}

self.Connections["RenderStepped"] = runService.Stepped:Connect(function(dt)
	for i, hitbox in self.Hitboxes do
		local hitPart = hitbox.HitPart
		if hitbox.Casting then
			if os.clock() - hitbox.StartTime >= hitbox.Settings.Time then hitbox:Stop() end
			
			local _settings = hitbox.Settings

			local direction = hitPart.Position - hitbox.LastPosition
			local result = workspace:Shapecast(hitPart, direction, hitbox.RaycastParams)
			hitbox.CurrentResult = result
			
			if _settings.Visualize then
				local clone = hitPart:Clone()
				clone:ClearAllChildren()
				clone.Anchored = true
				clone.Parent = workspace.Ignore
				clone.Transparency = 0
				clone.Color = Color3.new(1,0,0)
				clone.CanCollide = false
				clone.CanQuery = false
				clone.CanTouch = false
				clone.Material = Enum.Material.Neon
				clone.CFrame += direction
				game.Debris:AddItem(clone, 1)
			end

			if result then
				if _settings.OnlyEntities then
					local model, humanoid = findEntity(result.Instance)
					if not model or not humanoid then return end
					hitbox.HitFunction(_settings.ReturnType == "Model" and model or _settings.ReturnType == "Humanoid" and humanoid or _settings.ReturnType == "Part" and result.Instance, result)
				else
					hitbox.HitFunction(result.Instance, result)
				end
				
				if _settings.HitOnce then hitbox:Stop() end
			end
		else
			hitbox.CurrentResult = nil
		end
		
		hitbox.LastPosition = hitPart.Position
	end
end)

self.CreateHitbox = function(hitboxSettings, hitboxPart)
	local hitbox = hitboxObj.new(hitboxSettings, hitboxPart)
	table.insert(self.Hitboxes, hitbox)
	
	return hitbox
end

self.DestroyHitbox = function(hitbox)
	local index = table.find(self.Hitboxes, hitbox)
	self.Hitboxes[index]:Destroy()
end

self.Destroy = function()
	for i,v in self.Hitboxes do
		v:Destroy()
	end
	
	for i,v in self do 
		if typeof(v) == "table" then table.clear(v) end
		v = nil
	end
	
	self = nil
end

return self
