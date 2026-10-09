local CLASS = player.RegClass("bennyfighter")

function CLASS.Off(self)
    if CLIENT then return end
	
	timer.Remove("BennyEffects_" .. self:EntIndex())
end

function CLASS.On(self)
    if CLIENT then return end
	local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
	ApplyAppearance(self,nil,nil,nil,true)
	
	local function ApplyBennyEffects()
		local org = self.organism
		if not org then return end

		org.pulse = 220
		org.temperature = math.min(2, 41)
        ent.sleeping = 0.6
		org.disorientation = 20
		apply_drgs_eff(ent,"effect2",6)
		apply_drgs_eff(ent,"effect8",6)
		apply_drgs_eff(ent,"effect12",6)
		apply_drgs_eff(ent,"effect37",6)
		apply_drgs_eff(ent,"effect35",6)
		apply_drgs_eff(ent,"effect48",6)
	end

	ApplyBennyEffects()

	timer.Create("BennyEffects_" .. self:EntIndex(), 30, 0, function()
		if not IsValid(self) then return end
		if self.PlayerClassName ~= "bennyfighter" then
			timer.Remove("BennyEffects_" .. self:EntIndex())
			return
		end

		ApplyBennyEffects()
	end)
end