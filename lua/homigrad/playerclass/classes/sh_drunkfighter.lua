local CLASS = player.RegClass("drunkfighter")

function CLASS.Off(self)
    if CLIENT then return end
	
	timer.Remove("DrunkEffects_" .. self:EntIndex())
end

function CLASS.On(self)
    if CLIENT then return end
	local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
	ApplyAppearance(self,nil,nil,nil,true)
    self:SetNWString("PlayerName", "Drunk " .. Appearance.AName)
	
	local function ApplyDrunkEffects()
		local org = self.organism
		if not org then return end

		org.satiety = 2
		org.disorientation = 20
	end

	ApplyDrunkEffects()
	
	apply_drgs_eff(self, "effect17", 2)
	apply_drgs_eff(self, "effect37", 2)

	timer.Create("DrunkEffects_" .. self:EntIndex(), 5, 0, function()
		if not IsValid(self) then return end
		if self.PlayerClassName ~= "drunkfighter" then
			timer.Remove("DrunkEffects_" .. self:EntIndex())
			return
		end

		ApplyDrunkEffects()
	end)
end