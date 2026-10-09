hook.Add("Org Think", "regenerationmonkey", function(owner, org, timeValue)
	if not owner:IsPlayer() or not owner:Alive() then return end
	if owner.PlayerClassName != "chimp" then return end
	//if org.heartstop then return end

	org.blood = math.Approach(org.blood, 5000, timeValue * 60)

	for i, wound in pairs(org.wounds) do
		wound[1] = math.max(wound[1] - timeValue * 0.6,0)
	end
	
	for i, wound in pairs(org.arterialwounds) do
		wound[1] = math.max(wound[1] - timeValue * 0.6,0)
	end
	
	org.internalBleed = math.max(org.internalBleed - timeValue * 0.6, 0)
	
	local regen = timeValue / 60

	org.lleg = math.max(org.lleg - regen, 0)
	org.rleg = math.max(org.rleg - regen, 0)
	org.rarm = math.max(org.rarm - regen, 0)
	org.larm = math.max(org.larm - regen, 0)
	org.chest = math.max(org.chest - regen, 0)
	org.pelvis = math.max(org.pelvis - regen, 0)
	org.spine1 = math.max(org.spine1 - regen, 0)
	org.spine2 = math.max(org.spine2 - regen, 0)
	org.spine3 = math.max(org.spine3 - regen, 0)
	org.skull = math.max(org.skull - regen, 0)

	org.llegdislocation = false
	org.rlegdislocation = false
	org.rarmdislocation = false
	org.larmdislocation = false
	org.jawdislocation = false

	org.liver = math.max(org.liver - regen, 0)
	org.intestines = math.max(org.intestines - regen, 0)
	org.heart = math.max(org.heart - regen, 0)
	org.stomach = math.max(org.stomach - regen, 0)
	org.lungsR[1] = math.max(org.lungsR[1] - regen, 0)
	org.lungsL[1] = math.max(org.lungsL[1] - regen, 0)
	org.lungsR[2] = math.max(org.lungsR[2] - regen, 0)
	org.lungsL[2] = math.max(org.lungsL[2] - regen, 0)
	org.brain = math.max(org.brain - regen * 0.1, 0)
	
	org.pain = math.Approach(org.pain, 0, regen * 70)
	org.painadd = math.Approach(org.painadd, 0, regen * 70)
	org.avgpain = math.Approach(org.avgpain, 0, regen * 70)
	org.shock = math.Approach(org.shock, 0, regen * 70)
	org.immobilization = math.Approach(org.immobilization, 0, regen * 70)
	org.disorientation = math.Approach(org.disorientation, 0, regen * 70)
	
	org.berserkActive = true

	org.hungry = 0
	
	if not owner.NextMonkeySound then
		owner.NextMonkeySound = CurTime() + math.Rand(15, 30)
	end

	if CurTime() >= owner.NextMonkeySound then
		owner:EmitSound(
			table.Random(monkeysounds),
			75,
			math.random(95, 105),
			1
		)

		owner.NextMonkeySound = CurTime() + math.Rand(15, 30)
	end
end)

hook.Add("PlayerCanHearPlayersVoice", "MonkeyMuteVoice", function(listener, talker)
    if talker.IsMonkey then
        return false, false
    end
end)

local monkeysounds = {
    "monkey/monkey1.mp3",
    "monkey/monkey2.mp3",
    "monkey/monkey3.mp3",
    "monkey/monkey4.mp3"
}

local monkeyhurt = {
	"monkey/monkeyhurt1.mp3",
	"monkey/monkeyhurt2.mp3",
	"monkey/monkeyhurt3.mp3",
	"monkey/monkeyhurt4.mp3",
	"monkey/monkeyhurt5.mp3"
}

hook.Add("PlayerStartVoice", "MonkeyVoice", function(ply)
    if not ply.IsMonkey then return end

    ply:EmitSound(
        table.Random(monkeysounds),
        75,                    -- Volume
        math.random(95, 105),  -- Slightly random pitch
        1                      -- Sound level
    )
end)

hook.Add("HG_ReplacePhrase", "MonkeyPhrases", function(ply, phrase, muffed, pitch)
	if IsValid(ply) and ply.PlayerClassName == "chimp" then
		local inpain = ply.organism.pain > 60
		local phr = (inpain and monkeyhurt[math.random(#monkeyhurt)] or monkeysounds[math.random(#monkeysounds)])

		return ply, phr, muffed, pitch
	end
end)

hook.Add("HG_ReplaceBurnPhrase", "MonkeyBurnPhrases", function(ply, phrase)
	if ply.PlayerClassName == "chimp" then
		return ply, monkeyhurt[math.random(#monkeyhurt)]
	end
end)

hook.Add("HG_MovementCalc", "ChimpRunSpeed", function(vel, velLen, weightmul, ply, cmd, mv)
    if ply.PlayerClassName ~= "chimp" then return end

    ply.move = (ply.move or ply:GetRunSpeed()) * 1.2
end)