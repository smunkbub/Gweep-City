hook.Add("Org Think", "beavisOrgRegen", function(owner, org, timeValue)
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if owner.PlayerClassName ~= "beavis" then return end
	
	local regen = math.max(timeValue * 5, 1)

	org.pain = math.max(org.pain - regen, 0)
	
	owner:SetHealth(math.min(owner:Health() + regen, 250))
end)

hook.Add("Org Think", "beavisOrgs", function(owner, org)
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if owner.PlayerClassName ~= "beavis" then return end
	
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

local beavissounds = {
    "beavis&buttpoop/beavis01.wav",
    "beavis&buttpoop/beavis02.wav",
    "beavis&buttpoop/beavis03.wav",
    "beavis&buttpoop/beavis04.wav",
}

local beavishurt = {
    "beavis&buttpoop/beavishurt01.wav",
    "beavis&buttpoop/beavishurt02.wav",
    "beavis&buttpoop/beavishurt03.wav",
    "beavis&buttpoop/beavishurt04.wav",
    "beavis&buttpoop/beavishurt05.wav",
    "beavis&buttpoop/beavishurt06.wav",
}

hook.Add("HG_ReplacePhrase", "BeavisPhrases", function(ply, phrase, muffed, pitch)
	if IsValid(ply) and ply.PlayerClassName == "beavis" then
		local inpain = ply.organism.pain > 60
		local phr = (inpain and beavishurt[math.random(#beavishurt)] or beavissounds[math.random(#beavissounds)])

		return ply, phr, muffed, pitch
	end
end)

hook.Add("HG_ReplaceBurnPhrase", "BeavisBurnPhrases", function(ply, phrase)
	if ply.PlayerClassName == "beavis" then
		return ply, beavishurt[math.random(#beavishurt)]
	end
end)

hook.Add("HG_MovementCalc", "BeavisRunSpeed", function(vel, velLen, weightmul, ply, cmd, mv)
    if ply.PlayerClassName ~= "beavis" then return end

    ply.move = (ply.move or ply:GetRunSpeed()) * 1.15
end)