local Hitbox = {} Hitbox.__index = Hitbox 
Hitbox.ShapecastHitbox = nil

local workspace = game:GetService("Workspace")
local runService = game:GetService("RunService")
local players = game:GetService("Players")

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

function Hitbox.new(hitboxSettings, hitboxPart)
	local self = setmetatable({}, Hitbox)
	
	self.Settings = {
		Distance = hitboxSettings.Distance or 0;
		Exclude = hitboxSettings.Exclude or {};
		
		ReturnType = hitboxSettings.ReturnType or "Model";
		
		OnlyEntities = hitboxSettings.OnlyEntities or true;
		Visualize = hitboxSettings.Visualize or false;
		HitOnce = hitboxSettings.HitOnce or true;
		Effects = hitboxSettings.Effects or true;
		Time = hitboxSettings.Time or 3;
	}
	
	if typeof(self.Settings.Exclude) == "Instance" then
		self.Settings.Exclude = {self.Settings.Exclude}
	end
	
	table.insert(self.Settings.Exclude, workspace.Ignore)
	
	self.HitPart = hitboxPart
	self.HitFunction = nil
	self.Hits = {}
	self.LastPosition = hitboxPart.Position
	
	self.StartTime = 0
	self.Casting = false
	self.CurrentResult = nil
	
	self.Skip = true --// this gets flipped on the first cast, so keep it initialized to true
	
	self.RaycastParams = RaycastParams.new()
	self.RaycastParams.IgnoreWater = true
	self.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
	self.RaycastParams.FilterDescendantsInstances = hitboxSettings.Exclude
	
	self.HitEvent = Instance.new("BindableEvent")
	self.EndedEvent = Instance.new("BindableEvent")
	
	self.Hit = self.HitEvent.Event
	self.Ended = self.EndedEvent.Event
	
	return self
end

function Hitbox:ResetBindables()
	self.HitEvent:Destroy()
	self.EndedEvent:Destroy()
	
	self.HitEvent = Instance.new("BindableEvent")
	self.EndedEvent = Instance.new("BindableEvent")

	self.Hit = self.HitEvent.Event
	self.Ended = self.EndedEvent.Event
end

function Hitbox:Modify(hitboxSettings, hitboxPart)
	self.Settings = hitboxSettings
	self.HitPart = hitboxPart
end

function Hitbox:Start(func)
	if func ~= nil then
		assert(typeof(func) == "function", "argument #1 of Hitbox:Start() must be a function")
	end
	if self.Casting then
		self:Stop()
	end
	
	table.clear(self.Hits)
	self.LastPosition = self.HitPart.Position
	self.HitFunction = func
	self.StartTime = os.clock()
	self.Casting = true
	return self.Hit
end

function Hitbox:Stop()
	table.clear(self.Hits)
	self.EndedEvent:Fire()
	self:ResetBindables()
	self.Casting = false
	self.HitFunction = nil
	self.StartTime = 0
	return Hitbox
end

function Hitbox:Destroy()
	self.Casting = false
	
	local index = table.find(Hitbox.ShapecastHitbox.Hitboxes, self)
	Hitbox.ShapecastHitbox.Hitboxes[index]:Destroy()
	table.remove(Hitbox.ShapecastHitbox.Hitboxes, index)
	
	self.HitEvent:Destroy()
	self.EndedEvent:Destroy()
	
	for i,v in self do
		if typeof(v) == "table" then
			table.clear(v)
		end
	end
end

return Hitbox
