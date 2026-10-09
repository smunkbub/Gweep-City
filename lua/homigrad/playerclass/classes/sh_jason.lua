local CLASS = player.RegClass("jason")

function CLASS.Off(self)
    if CLIENT then return end

	self.StaminaExhaustMul = nil
end

function CLASS.On(self)
    if CLIENT then return end
	local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
	ApplyAppearance(self,nil,nil,nil,true)
	local sex = ThatPlyIsFemale(self) and 2 or 1
	local tbl = self.CurAppearance
	tbl.AClothes["main"] = "worker"
	tbl.AClothes["pants"] = "normal"
	tbl.AClothes["boots"] = "normal"
	tbl.AColor = Color(0, 0, 255)
	hg.Appearance.ForceApplyAppearance(self,tbl)
	self:SetNWString("PlayerName", "jason")

	self.StaminaExhaustMul = 0

	self:SetNetVar("Accessories", {
    	["red scarf"] = true,
		["helicopter cap"] = true
	})
end

if CLIENT then
    hook.Add("PreDrawHalos", "JasonPlayerHighlight", function()
        local ply = LocalPlayer()

        if not IsValid(ply) then return end
        if ply.PlayerClassName ~= "jason" then return end

        local entities = {}

        for _, target in ipairs(player.GetAll()) do
            if not IsValid(target) then continue end
            if target == ply then continue end

            -- Only highlight the actual player if they're alive
            if target:Alive() then
                table.insert(entities, target)
            end

            -- Highlight their ZCity fake/ragdoll if it exists
            if IsValid(target.FakeRagdoll) then
                table.insert(entities, target.FakeRagdoll)
            end
        end

        if #entities > 0 then
            halo.Add(
                entities,
                Color(255, 0, 0),
                2,
                2,
                1,
                true,
                true
            )
        end
    end)
end

hook.Add("Org Think", "jasonOrgRegen", function(owner, org, timeValue)
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if owner.PlayerClassName ~= "jason" then return end
	
	local regen = math.max(timeValue * 5, 1)
	
	owner:SetHealth(math.min(owner:Health() + regen, 500))

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

hook.Add("Org Think", "jasonOrgs", function(owner, org)
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if owner.PlayerClassName ~= "jason" then return end
	
    org.superfighter = true
    org.adrenaline = 0
	org.avgpain = 0
    org.disorientation = 0

	org.lleg = 0
	org.rleg = 0
	org.larm = 0
	org.rarm = 0
end)

hook.Add("ScalePlayerDamage", "JasonMeleeStrength", function(ply, hitgroup, dmginfo)
    local attacker = dmginfo:GetAttacker()

    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if attacker.PlayerClassName ~= "jason" then return end

    local damageType = dmginfo:GetDamageType()

    -- Only increase physical/melee attacks
    if bit.band(damageType, DMG_CLUB) ~= 0 or bit.band(damageType, DMG_SLASH) ~= 0 then
        dmginfo:ScaleDamage(30)
    end
end)

hook.Add("HG_MovementCalc", "jasonRunSpeed", function(vel, velLen, weightmul, ply, cmd, mv)
    if ply.PlayerClassName ~= "jason" then return end

    ply.move = (ply.move or ply:GetRunSpeed()) * 1.2
end)