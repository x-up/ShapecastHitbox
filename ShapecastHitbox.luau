--// Environment
local hitboxObj = require(script.Hitbox)

local emptyCFrame, emptyVector, xzVector, yVector = CFrame.new(), Vector3.new(0,0.1,0), Vector3.new(1,0,1), Vector3.new(0, 1, 0)

local function findHumanoid(instance)
	if typeof(instance) ~= "Instance" then return end
	if not instance:IsDescendantOf(workspace.Entities) then return end

	local model = instance:FindFirstAncestorWhichIsA("Model")
	local humanoid = model:FindFirstChild("Humanoid")

	local times = 0
	while model and not humanoid or times >= 3 do
		model = model:FindFirstAncestorWhichIsA("Model")
		humanoid = model:FindFirstChild("Humanoid")
		times += 1
	end

	return humanoid
end

local workspace = game:GetService("Workspace")
local runService = game:GetService("RunService")
local players = game:GetService("Players")



--// Module
local self = {} hitboxObj.ShapecastHitbox = self
self.Hitboxes = {}
self.Connections = {}

self.Connections["RenderStepped"] = runService.RenderStepped:Connect(function(dt)
	for i, hitbox in self.Hitboxes do
		if hitbox.Casting then
			if os.clock() - hitbox.StartTime >= hitbox.Settings.Time then hitbox:Stop() end
			
			local _settings = hitbox.Settings
			
			local hitPart = hitbox.HitPart
			
			local result = workspace:Shapecast(hitbox.HitPart, hitbox.HitPart.Position - hitbox.LastPosition, hitbox.RaycastParams)
			hitbox.CurrentResult = result

			if result then
				if _settings.OnlyEntities then
					local humanoid = findHumanoid(result.Instance)
					if not humanoid then return end
					hitbox.HitFunction(_settings.ReturnType == "Model" and humanoid.Parent or _settings.ReturnType == "Humanoid" and humanoid)
				else
					print('hi')
				end

				if _settings.HitOnce then hitbox:Stop() end
			end
			
			hitbox.LastPosition = hitPart.Position
		else
			hitbox.CurrentResult = nil
		end
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
