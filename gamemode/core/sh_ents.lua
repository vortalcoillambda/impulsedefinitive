local entityMeta = FindMetaTable("Entity")

function entityMeta:IsDoor()
	return self:GetClass():find("door")
end

local chairs = {}

for k, v in pairs(list.Get("Vehicles")) do
	if v.Category == "Chairs" then
		chairs[v.Model] = true
	end
end

function entityMeta:IsChair()
	return chairs[self.GetModel(self)]
end