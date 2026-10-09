local CLASS = player.RegClass("feared")

function CLASS.Off(self)
    if CLIENT then return end
	
	timer.Remove("FearEffects_" .. self:EntIndex())
end

function CLASS.On(self)
    if CLIENT then return end
	local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
	ApplyAppearance(self,nil,nil,nil,true)
	
	local function ApplyFearEffects()
		local org = self.organism
		if not org then return end

		org.fear = 1000
	end

	ApplyFearEffects()

	timer.Create("FearEffects_" .. self:EntIndex(), 30, 0, function()
		if not IsValid(self) then return end
		if self.PlayerClassName ~= "feared" then
			timer.Remove("FearEffects_" .. self:EntIndex())
			return
		end

		ApplyFearEffects()
	end)
end