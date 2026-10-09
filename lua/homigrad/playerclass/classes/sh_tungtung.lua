local CLASS = player.RegClass("tungtung")

function CLASS.Off(self)
    if CLIENT then return end

	self.StaminaExhaustMul = nil
end

function CLASS.On(self)
    if CLIENT then return end
	local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    ApplyAppearance(self, nil, nil, nil, true)

    Appearance.AColor = Color(140, 90, 15)

    hg.Appearance.ForceApplyAppearance(self, Appearance)    
	self:SetNWString("PlayerName", "Tung Tung Tung Sahur")
    self:SetModel("models/gacommissions/tungtungtungsahur.mdl")

	self.StaminaExhaustMul = 0

    self:SetSubMaterial()

    self:Give("weapon_tungtung")
end

if CLIENT then
    hook.Add("PreDrawHalos", "TungPlayerHighlight", function()
        local ply = LocalPlayer()

        if not IsValid(ply) then return end
        if ply.PlayerClassName ~= "tungtung" then return end

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
                Color(0, 0, 255),
                2,
                2,
                1,
                true,
                true
            )
        end
    end)
end

hook.Add("Org Think", "tungOrgRegen", function(owner, org, timeValue)
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if owner.PlayerClassName ~= "tungtung" then return end
	
	local regen = math.max(timeValue * 5, 1)
	
	owner:SetHealth(math.min(owner:Health() + regen, 200))

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

hook.Add("Org Think", "tungOrgs", function(owner, org)
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if owner.PlayerClassName ~= "tungtung" then return end
	
    org.superfighter = true
    org.adrenaline = 0
	org.avgpain = 0

	org.lleg = 0
	org.rleg = 0
	org.larm = 0
	org.rarm = 0
end)

hook.Add("HG_MovementCalc", "tungRunSpeed", function(vel, velLen, weightmul, ply, cmd, mv)
    if ply.PlayerClassName ~= "tungtung" then return end

    ply.move = (ply.move or ply:GetRunSpeed()) * 1.2
end)

if CLIENT then
    hook.Add("RenderScreenspaceEffects", "TungTungBrownVision", function()
        local ply = LocalPlayer()

        if not IsValid(ply) then return end
        if ply.PlayerClassName ~= "tungtung" then return end

        local colorModify = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,

            ["$pp_colour_brightness"] = 0,
            ["$pp_colour_contrast"] = 0.7,
            ["$pp_colour_colour"] = 0,

            ["$pp_colour_mulr"] = 1,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        }

        DrawColorModify(colorModify)
    end)
end

--if CLIENT then
    --hook.Add("PrePlayerDraw", "TungTestHide", function(ply)
        --if ply.PlayerClassName ~= "tungtung" then return end

        --return true
    --end)
--end