local CLASS = player.RegClass("furyfighter")

function CLASS.Off(self)
    if CLIENT then return end
	
	timer.Remove("fury13Effects_" .. self:EntIndex())
end

function CLASS.On(self)
    if CLIENT then return end
	local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
	ApplyAppearance(self,nil,nil,nil,true)
	
	local function ApplyFuryEffects()
		local org = self.organism
		if not org then return end

		org.berserkActive2 = true
		org.berserk = 20
	end

	ApplyFuryEffects()

	timer.Create("fury13Effects_" .. self:EntIndex(), 30, 0, function()
		if not IsValid(self) then return end
		if self.PlayerClassName ~= "furyfighter" then
			timer.Remove("fury13Effects_" .. self:EntIndex())
			return
		end

		ApplyFuryEffects()
	end)
end