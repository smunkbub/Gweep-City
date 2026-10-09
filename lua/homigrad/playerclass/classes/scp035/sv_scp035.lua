hook.Add("Org Think", "035OrgRegen", function(owner, org, timeValue)
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if owner.PlayerClassName ~= "scp035" then return end
	
	local regen = math.max(timeValue * 5, 1)

	org.blood = math.Approach(org.blood, 0, timeValue * 10)
	
	owner:SetHealth(math.min(owner:Health() + regen, 450))
end)

hook.Add("Org Think", "035Orgs", function(owner, org)
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if owner.PlayerClassName ~= "scp035" then return end
	
	org.disorientation = 1.3
	org.avgpain = 25
	org.health = 100
	org.recoilmul = 0
	org.meleespeed = 20
	org.bleedingmul = 0.008
	org.consciousness = 1
	org.adrenaline = 0
	org.shock = 0
	org.heartbeat = 250
	org.brain = 0
	org.skull = 0

	org.lleg = 0
	org.rleg = 0
	org.larm = 0
	org.rarm = 0
	
	org.otrub = false
	org.llegdislocation = false
	org.rlegdislocation = false
	org.larmdislocation = false
	org.rarmdislocation = false
	org.jawdislocation = false
	org.lungsfunction = true

	org.hungry = 0
end)

hook.Add("HG_PlayerCanHearPlayersVoice", "035NoVoice", function(listener, speaker)
	if speaker.PlayerClassName == "scp035" then
		return false, false
	end
end)

hook.Add("HG_MovementCalc", "035RunSpeed", function(vel, velLen, weightmul, ply, cmd, mv)
    if ply.PlayerClassName ~= "scp035" then return end

    ply.move = (ply.move or ply:GetRunSpeed()) * 1.2
end)

hook.Add("PlayerSay", "No035Chat", function(ply, text)
    if not IsValid(ply) then return end
    if ply.PlayerClassName ~= "scp035" then return end

    ply:zChatPrint(Color(255,0,0), "You cannot speak.")

    return ""
end)