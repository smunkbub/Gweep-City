local CLASS = player.RegClass("fatty")

local CHIPMUNK_PRESET = 4
local NO_EFFECT_PRESET = 0

local function EightbitReady()
	return istable(eightbit) and isfunction(eightbit.EnableEffect)
end

CLASS.CanUseDefaultPhrase = true
CLASS.CanEmitRNDSound = true
CLASS.CanUseGestures = true

local FAT_BONES = {
    "ValveBiped.Bip01_Pelvis",
    "ValveBiped.Bip01_Spine",
    "ValveBiped.Bip01_Spine1",
    "ValveBiped.Bip01_Spine2",
    "ValveBiped.Bip01_Spine4",
}

local function applyFatBelly(ply)
    for _, name in ipairs(FAT_BONES) do
        local id = ply:LookupBone(name)
        if id then
            ply:ManipulateBoneScale(id, Vector(1.3, 1.2, 1.4))
        end
    end
end

function CLASS.On(self)
	if CLIENT then return end
	ApplyAppearance(self,nil,nil,nil,true)
	if EightbitReady() then
		eightbit.EnableEffect(self:UserID(), CHIPMUNK_PRESET)
	end
end

function CLASS.Off(self)
	if CLIENT then return end
	self:SetGravity(1)
	if EightbitReady() then
		eightbit.EnableEffect(self:UserID(), NO_EFFECT_PRESET)
	end
end

local HELIUM_REASSERT_INTERVAL = 1

function CLASS.Think(self)
	if CLIENT then return end
	if self.PlayerClassName ~= "fatty" then return end
	if EightbitReady() then
		if not self._heliumNextAssert or CurTime() >= self._heliumNextAssert then
			eightbit.EnableEffect(self:UserID(), CHIPMUNK_PRESET)
			self._heliumNextAssert = CurTime() + HELIUM_REASSERT_INTERVAL
		end
	end

	self.StaminaExhaustMul = 2

	self:SetGravity(2)

	local ragdoll = self.FakeRagdoll
	if not IsValid(ragdoll) then return end

	local ARM_SLOTS = {2, 3, 4, 5, 6, 7} -- R_UpperArm, L_UpperArm, L_Forearm, L_Hand, R_Forearm, R_Hand

	local excludedPhys = {}
	for _, slot in ipairs(ARM_SLOTS) do
		local realIndex = hg.realPhysNum(ragdoll, slot)
		if realIndex then
			excludedPhys[realIndex] = true
		end
	end

	for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
		local phys = ragdoll:GetPhysicsObjectNum(i)
		if IsValid(phys) and not excludedPhys[i] then
			phys:SetMass(25)
		end
	end

	applyFatBelly(self)

end

hook.Add("Bones", "FatBelly", function(ply)
	if not IsValid(ply) then return end
	if ply.PlayerClassName ~= "fatty" then return end
	applyFatBelly(ply)
end)

hook.Add("HG_MovementCalc", "fatRunSpeed", function(vel, velLen, weightmul, ply, cmd, mv)
    if ply.PlayerClassName ~= "fatty" then return end

    ply.move = (ply.move or ply:GetRunSpeed()) / 1.5
end)

hook.Add("Org Think", "fatOrgs", function(owner, org)
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if owner.PlayerClassName ~= "fatty" then return end

    org.stamina.max = 50
end)

hook.Add("Org Think", "fatOrgRegen", function(owner, org, timeValue)
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if owner.PlayerClassName ~= "scp087brm" then return end
	
	local regen = math.max(timeValue * 5, 1)
	
	owner:SetHealth(math.min(owner:Health() + regen, 1000))
end)