hook.Add("Org Think", "buttheadOrgRegen", function(owner, org, timeValue)
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if owner.PlayerClassName ~= "butthead" then return end
	
	local regen = math.max(timeValue * 5, 1)

	org.pain = math.max(org.pain - regen, 0)
	
	owner:SetHealth(math.min(owner:Health() + regen, 250))
end)

hook.Add("Org Think", "buttheadOrgs", function(owner, org)
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if owner.PlayerClassName ~= "butthead" then return end
	
	org.recoilmul = 0
	org.meleespeed = 20
	org.bleedingmul = 0.1
	org.consciousness = 1
	org.adrenaline = 0
	org.shock = 0
	org.heartbeat = 100
	
	org.otrub = false
	org.llegdislocation = false
	org.rlegdislocation = false
	org.larmdislocation = false
	org.rarmdislocation = false
	org.jawdislocation = false

	org.hungry = 0
end)

local buttheadsounds = {
    "beavis&buttpoop/butthead01.wav",
    "beavis&buttpoop/butthead02.wav",
    "beavis&buttpoop/butthead03.wav",
    "beavis&buttpoop/butthead04.wav",
    "beavis&buttpoop/butthead05.wav",
}

-- why tf is is so hard to find sound effects of butthead being in pain
-- beavis just cops all the beating lmao

local buttheadhurt = {
    "beavis&buttpoop/buttheadhurt01.wav",
}

hook.Add("HG_ReplacePhrase", "ButtheadPhrases", function(ply, phrase, muffed, pitch)
	if IsValid(ply) and ply.PlayerClassName == "butthead" then
		local inpain = ply.organism.pain > 60
		local phr = (inpain and buttheadhurt[math.random(#buttheadhurt)] or buttheadsounds[math.random(#buttheadsounds)])

		return ply, phr, muffed, pitch
	end
end)

hook.Add("HG_ReplaceBurnPhrase", "ButtheadBurnPhrases", function(ply, phrase)
	if ply.PlayerClassName == "butthead" then
		return ply, buttheadhurt[math.random(#buttheadhurt)]
	end
end)

hook.Add("HG_MovementCalc", "ButtheadRunSpeed", function(vel, velLen, weightmul, ply, cmd, mv)
    if ply.PlayerClassName ~= "butthead" then return end

    ply.move = (ply.move or ply:GetRunSpeed()) * 1.15
end)