hook.Add("Org Think", "173Orgs", function(owner, org)
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if owner.PlayerClassName ~= "scp173" then return end
	
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
	
	org.pain = math.Approach(org.pain, 0, regen * 300)
	org.painadd = math.Approach(org.painadd, 0, regen * 300)
	org.avgpain = math.Approach(org.avgpain, 0, regen * 300)
	org.shock = math.Approach(org.shock, 0, regen * 300)
	org.immobilization = math.Approach(org.immobilization, 0, regen * 300)
	org.disorientation = math.Approach(org.disorientation, 0, regen * 300)
	
	owner:Health(10000)
	
	org.needotrub = false
    org.otrub = false
    org.consciousness = 1
	
	org.superfighter = true
	
	org.berserkActive = true

	org.hungry = 0

    org.needfake = false
    org.fake = false
end)

hook.Add("PlayerSay", "173NoChat", function(ply, text)
	if ply.PlayerClassName == "scp173" then
		return ""
	end
end)

hook.Add("HG_PlayerCanHearPlayersVoice", "173NoVoice", function(listener, speaker)
	if speaker.PlayerClassName == "scp173" then
		return false, false
	end
end)

local oldFake = hg.Fake

function hg.Fake(ply, ...)
	if IsValid(ply) and ply.PlayerClassName == "scp173" then
		return
	end

	return oldFake(ply, ...)
end

hook.Add("HG_MovementCalc", "173RunSpeed", function(vel, velLen, weightmul, ply, cmd, mv)
    if ply.PlayerClassName ~= "scp173" then return end

    ply.move = (ply.move or ply:GetRunSpeed()) * 2
end)

local function SCP173SnapNeck(scp, victim)

    if not IsValid(victim) then return end
    if not victim:IsPlayer() then return end
    if not victim:Alive() then return end

    victim:Kill()

    victim:ViewPunch(Angle(0,0,-10))

    victim:EmitSound("neck_snap_01.wav", 60, 100, 1, CHAN_AUTO)


    timer.Simple(0.5, function()

        if not IsValid(victim) then return end

        local rag = victim:GetNWEntity("Ragdoll")

        if not IsValid(rag) then return end


        local headBone = rag:LookupBone("ValveBiped.Bip01_Head1")
        local spineBone = rag:LookupBone("ValveBiped.Bip01_Spine2")

        if headBone == -1 or spineBone == -1 then return end


        local head = rag:TranslateBoneToPhysBone(headBone)
        local spine = rag:TranslateBoneToPhysBone(spineBone)


        rag:RemoveInternalConstraint(head)


        local headPhys = rag:GetPhysicsObjectNum(head)
        local spinePhys = rag:GetPhysicsObjectNum(spine)


        if IsValid(headPhys) and IsValid(spinePhys) then

            headPhys:SetPos(
                spinePhys:GetPos()
                + spinePhys:GetAngles():Forward() * 12
                + spinePhys:GetAngles():Right() * -1
            )


            local lpos, lang = WorldToLocal(
                headPhys:GetPos(),
                headPhys:GetAngles(),
                spinePhys:GetPos(),
                spinePhys:GetAngles()
            )


            constraint.AdvBallsocket(
                rag,
                rag,
                spine,
                head,
                lpos,
                nil,
                0,
                0,
                -55,
                -90,
                -50,
                55,
                35,
                50,
                0,
                0,
                0,
                0,
                0
            )
        end
    end)
end


hook.Add("Think", "SCP173_NeckSnap", function()

    for _, ply in ipairs(player.GetAll()) do

        if ply.PlayerClassName ~= "scp173" then continue end

        for _, victim in ipairs(player.GetAll()) do

            if victim == ply then continue end
            if not victim:Alive() then continue end

            if ply:GetPos():DistToSqr(victim:GetPos()) <= (100 * 100) then

                if ply.SCP173SnapCooldown then continue end

                ply.SCP173SnapCooldown = true

                SCP173SnapNeck(ply, victim)

                timer.Simple(2, function()
                    if IsValid(ply) then
                        ply.SCP173SnapCooldown = false
                    end
                end)

            end
        end
    end
end)

local SCP173Frozen = {}

hook.Add("Think", "SCP173_CheckLook", function()

    for _, scp in ipairs(player.GetAll()) do

        if scp.PlayerClassName ~= "scp173" then continue end
        if not scp:Alive() then continue end

        local lookedAt = false

        for _, ply in ipairs(player.GetAll()) do

            if ply == scp then continue end
            if not ply:Alive() then continue end

            local dir = (scp:GetPos() + Vector(0,0,50) - ply:EyePos()):GetNormalized()
            local dot = ply:GetAimVector():Dot(dir)

            if dot > 0.985 then

                local tr = util.TraceLine({
                    start = ply:EyePos(),
                    endpos = scp:GetPos() + Vector(0,0,50),
                    filter = {ply, scp}
                })

                if not tr.Hit then
                    lookedAt = true
                    break
                end
            end
        end

        SCP173Frozen[scp] = lookedAt
    end
end)


hook.Add("HG_MovementCalc", "SCP173_StopWhenSeen", function(vel, velLen, weightmul, ply, cmd, mv)

    if ply.PlayerClassName ~= "scp173" then return end

    if SCP173Frozen[ply] then
        mv:SetVelocity(Vector(0,0,0))
        mv:SetMaxSpeed(0)
        mv:SetMaxClientSpeed(0)
    end
end)