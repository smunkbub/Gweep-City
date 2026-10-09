local CLASS = player.RegClass("scp035")

function CLASS.Off(self)
    if CLIENT then return end
	
	self.StaminaExhaustMul = nil
end

local name = "SCP-035"

function CLASS.On(self)
    if CLIENT then return end
    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    ApplyAppearance(self,nil,nil,nil,true)
	Appearance.AName = name
    self:SetNWString("PlayerName", name)
	self:SetNetVar("Accessories", "035_mask")
	
	self.StaminaExhaustMul = 0
	
	self:SetHealth(450)

    hg.AddArmor(self, "cmb_helmet")
    hg.AddArmor(self, "cmb_armor")
end

if CLIENT then
    local ambience

    hook.Add("Think", "SCP035Ambience", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        if ply.PlayerClassName == "scp035" then
            if not ambience then
                ambience = CreateSound(ply, "scp035/ambience.wav")
                ambience:SetSoundLevel(0)
                ambience:Play()
            elseif not ambience:IsPlaying() then
                ambience:Play()
            end
        else
            if ambience then
                ambience:Stop()
                ambience = nil
            end
        end
    end)
	
	local heartbeatMat = Material("scp035/bloodvignette.png")
	
	hook.Add("HUDPaint", "SCP035Heartbeat", function()
		local ply = LocalPlayer()
		if not IsValid(ply) then return end
		if ply.PlayerClassName ~= "scp035" then return end

		local pulse = (math.sin(CurTime() * 2) + 1) / 2

		local scale = Lerp(pulse, 1.08, 1.15)

		local w = ScrW() * scale
		local h = ScrH() * scale

		surface.SetDrawColor(255, 255, 255, 90)
		surface.SetMaterial(heartbeatMat)
		surface.DrawTexturedRect(
			(ScrW() - w) / 2,
			(ScrH() - h) / 2,
			w,
			h
		)
	end)
end