local CLASS = player.RegClass("scp087brm")

function CLASS.Off(self)
    if CLIENT then return end
	
	self.StaminaExhaustMul = nil
end

local name = "SCP-087 (Red Mist Monster)"

function CLASS.On(self)
    if CLIENT then return end
    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    ApplyAppearance(self,nil,nil,nil,true)
	Appearance.AName = name
    self:SetNWString("PlayerName", name)
    self:SetNWString("Accessories", "")
    self:SetPlayerColor(Color(100,0,0):ToVector())
    self:SetModel("models/mental/087.mdl")
    self:SetSkin(3)
	
	self.StaminaExhaustMul = 0
	
	self:SetHealth(1000)
end

hook.Add("Org Think", "087OrgRegen", function(owner, org, timeValue)
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if owner.PlayerClassName ~= "scp087brm" then return end
	
	local regen = math.max(timeValue * 5, 1)
	
	owner:SetHealth(math.min(owner:Health() + regen, 1000))
end)

hook.Add("Org Think", "087Orgs", function(owner, org)
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if owner.PlayerClassName ~= "scp087brm" then return end
	
    org.superfighter = true
    org.adrenaline = 0
end)

hook.Add("HG_PlayerCanHearPlayersVoice", "087NoVoice", function(listener, speaker)
	if speaker.PlayerClassName == "scp087brm" then
		return false, false
	end
end)

hook.Add("HG_MovementCalc", "087RunSpeed", function(vel, velLen, weightmul, ply, cmd, mv)
    if ply.PlayerClassName ~= "scp087brm" then return end

    ply.move = (ply.move or ply:GetRunSpeed()) * 1.27
end)

hook.Add("PlayerSay", "No087Chat", function(ply, text)
    if not IsValid(ply) then return end
    if ply.PlayerClassName ~= "scp087brm" then return end

    ply:zChatPrint(Color(255,0,0), "You cannot speak.")

    return ""
end)