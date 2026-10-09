--[[
	Beast player class
	--------------------------------------------------------------
	- Uses the organism system's built-in "superfighter" flag.
	  This is the same flag the codebase already uses to bypass the
	  organ system (organism/tier_1/sv_input.lua, sv_organs.lua,
	  sv_bone.lua): with it on, headshots no longer route through
	  hg.organism.input_list.skull/brain or hg.BreakNeck(), so a
	  headshot can never insta-kill the Beast via broken neck /
	  brain damage / bleedout. Damage instead comes straight off
	  Health(), so raising MaxHealth is what makes the class tanky.
	- Player model is scaled to 2x (BEAST_SCALE below).
	- Both effects are undone in CLASS.Off, which fires whenever the
	  class is switched away from OR the player dies
	  (see playerclass/sv_tier_0.lua -> PostPostPlayerDeath).

	Tune the numbers below to taste.
--]]

local CLASS = player.RegClass("beast")

local BEAST_SCALE = 1.3          -- player model scale while in this class
local BEAST_MAX_HEALTH = 1000  -- "really strong" health pool (default is 100)
local DEFAULT_MAX_HEALTH = 100 -- what to restore MaxHealth to when leaving the class

CLASS.CanUseDefaultPhrase = true
CLASS.CanEmitRNDSound = true
CLASS.CanUseGestures = true

function CLASS.On(self)
	if CLIENT then return end
	local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
	ApplyAppearance(self,nil,nil,nil,true)

	self:SetModelScale(BEAST_SCALE, 0)

	self:SetMaxHealth(BEAST_MAX_HEALTH)
	self:SetHealth(BEAST_MAX_HEALTH)

	if IsValid(self.organism) then
		-- This is what stops headshots (and bleedout/organ death in
		-- general) from being able to kill the Beast outright - see
		-- organism/tier_1/sv_input.lua and modules_input/sv_organs.lua
		-- and sv_bone.lua for every place this flag is checked.
		self.organism.superfighter = true
	end

	self:SetHealth(600)
end

function CLASS.Off(self)
	if CLIENT then return end

	self:SetModelScale(1, 0)

	self:SetMaxHealth(DEFAULT_MAX_HEALTH)
	if self:Health() > DEFAULT_MAX_HEALTH then
		self:SetHealth(DEFAULT_MAX_HEALTH)
	end

	if IsValid(self.organism) then
		self.organism.superfighter = false
	end

	self:SetHealth(100)
end

-- Defensive re-assert every think, same pattern used by the other
-- classes (see sh_headcrabzombie.lua re-forcing org.pulse etc each
-- tick) in case something else in the organism pipeline resets the
-- flag (e.g. Org Clear runs on respawn/reset and always sets
-- superfighter back to false).
function CLASS.Think(self)
	if CLIENT then return end

	if self:GetModelScale() ~= BEAST_SCALE then
		self:SetModelScale(BEAST_SCALE, 0)
	end
end

function CLASS.Guilt(self, Victim)
	if CLIENT then return end
end

hook.Add("Org Think", "beastOrgRegen", function(owner, org, timeValue)
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if owner.PlayerClassName ~= "beast" then return end
	
	local regen = math.max(timeValue * 5, 1)
	
	owner:SetHealth(math.min(owner:Health() + regen, 600))

	if org.llegamputated or org.rlegamputated or org.larmamputated or org.rarmamputated then
        if not org.amputationTime then
            org.amputationTime = CurTime()
        end

        if CurTime() >= org.amputationTime + 5 then
            org.llegamputated = false
            org.rlegamputated = false
            org.larmamputated = false
            org.rarmamputated = false

            org.amputationTime = nil
        end
    else
        org.amputationTime = nil
    end

	for i, wound in pairs(org.wounds) do
        wound[1] = math.max(wound[1] - timeValue * 2, 0)
    end

    for i, wound in pairs(org.arterialwounds) do
        wound[1] = math.max(wound[1] - timeValue * 1, 0)
    end
end)

hook.Add("Org Think", "beastOrgs", function(owner, org)
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if owner.PlayerClassName ~= "beast" then return end
	
    org.superfighter = true
    org.adrenaline = 0
end)

hook.Add("HG_MovementCalc", "beastRunSpeed", function(vel, velLen, weightmul, ply, cmd, mv)
    if ply.PlayerClassName ~= "beast" then return end

    ply.move = (ply.move or ply:GetRunSpeed()) * 1.27
end)
