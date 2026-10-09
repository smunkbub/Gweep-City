if SERVER then return end

local VOMIT_SPRITE = "decals/yblood1"

local VOMIT_DECAL = "YellowBlood"

local DIM = 140

local function TryPlaceVomitDecal(spawnPos, vel)
	local endPos = spawnPos + vel:GetNormalized() * 40 - Vector(0, 0, 150)

	local tr = util.TraceLine({
		start = spawnPos,
		endpos = endPos,
		mask = MASK_SOLID_BRUSHONLY,
	})

	if tr.Hit then
		util.Decal(VOMIT_DECAL, tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
	end
end

net.Receive("headcrab_vomit_squirt", function()
	local ent = net.ReadEntity()
	if not IsValid(ent) then return end

	local bone = net.ReadString()
	local boneIndex = ent:LookupBone(bone)
	local mat = net.ReadMatrix()
	local pos = net.ReadVector()
	local dir = net.ReadVector()
	local len = dir:Length()

	local ply = hg.RagdollOwner(ent) or ent
	local lply = LocalPlayer()

	local localPos, localDir = WorldToLocal(pos, dir:Angle(), mat:GetTranslation(), mat:GetAngles())

	if ply == lply then
		localPos:Add(-Vector(2, -2, 0))
	end

	local emitter = ParticleEmitter(pos)
	if not emitter then return end

	local name = "headcrabvomit" .. ent:EntIndex()
	local i = 50
	local maxI = i

	timer.Create(name, 0.01 * game.GetTimeScale(), i + 10, function()
		if not IsValid(ent) or not IsValid(emitter) then
			timer.Remove(name)
			if IsValid(emitter) then emitter:Finish() end
			return
		end

		local rEnt = IsValid(ent.FakeRagdoll) and ent.FakeRagdoll or ent
		local amt = math.max(i / maxI, 0.2)

		if math.random(5) == 1 then
			i = i - 1
			return
		end

		local boneMat = rEnt:GetBoneMatrix(boneIndex)
		if not boneMat then
			timer.Remove(name)
			emitter:Finish()
			return
		end

		if ply == lply and (i == 50 or i == 25) then
			ViewPunch(Angle(15, 0, 0))
		end

		local ppos, pdir = LocalToWorld(localPos, localDir, boneMat:GetTranslation(), boneMat:GetAngles())

		if lply == ply then
			pdir = lply:EyeAngles()
		end

		pdir = pdir:Forward() * len

		local spawnPos = ppos + VectorRand(-0.2, 0.2)
		local vel = pdir * amt * 90 + VectorRand(-amt * 25, amt * 25)

		local p = emitter:Add(VOMIT_SPRITE, spawnPos)
		if p then
			p:SetVelocity(vel)
			p:SetDieTime(math.Rand(0.4, 0.8))
			p:SetStartAlpha(180)
			p:SetEndAlpha(0)
			p:SetStartSize(math.Rand(2, 4))
			p:SetEndSize(math.Rand(1, 2))
			p:SetGravity(Vector(0, 0, -800))
			p:SetAirResistance(100)
			p:SetColor(DIM, DIM, DIM)
		end

		TryPlaceVomitDecal(spawnPos, vel)

		i = i - 1
		if i <= 0 then
			timer.Remove(name)
			emitter:Finish()
		end
	end)
	timer.Adjust(name, 0)
end)