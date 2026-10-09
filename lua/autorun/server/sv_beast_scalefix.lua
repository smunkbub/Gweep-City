--[[
	Beast scale fix - add-on, edits nothing in zcity itself.

	Vanilla zcity never copies a player's model scale onto the ragdoll/Fake
	body it spawns for them (fake/sv_tier_0.lua's hg.Ragdoll_Create always
	spawns at scale 1), which is what made a scaled-up player (Beast class)
	crumple when downed or killed. Instead of editing that vanilla file,
	this hooks the events zcity already fires around ragdoll creation and
	corrects the scale from the outside after the fact.

	Drop this anywhere under lua/autorun/server/ in your addon - GMod
	autoloads it, no #include or AddCSLuaFile needed, and it does not
	touch a single line of the base zcity files.
--]]

if CLIENT then return end

local function MatchScale(ply, ragdoll)
	if not IsValid(ply) or not IsValid(ragdoll) then return end

	local scale = ply:GetModelScale()
	if ragdoll:GetModelScale() ~= scale then
		ragdoll:SetModelScale(scale, 0)
	end
end

--// Real death ragdoll. zcity fires this from PostPlayerDeath once the
--// ragdoll already exists (organism/tier_0/sv_tier_0.lua).
hook.Add("RagdollDeath", "BeastScaleFix_Ragdoll", function(ply, ragdoll)
	MatchScale(ply, ragdoll)
end)

--// Fake/incapacitated stand-in body. zcity fires this at the end of
--// hg.Fake() for both freshly-created and reused Fake ragdolls
--// (fake/sv_tier_0.lua).
hook.Add("Fake", "BeastScaleFix_Fake", function(ply, ragdoll)
	MatchScale(ply, ragdoll)
end)

--// Belt-and-braces: in case some other path creates/reuses a
--// FakeRagdoll/RagdollDeath without going through the hooks above,
--// catch up once a second. Cheap - only players, only when mismatched.
timer.Create("BeastScaleFix_Poll", 1, 0, function()
	for _, ply in player.Iterator() do
		if not IsValid(ply) then continue end

		local scale = ply:GetModelScale()
		if scale == 1 then continue end -- nothing to fix for normal-sized players

		if IsValid(ply.FakeRagdoll) and ply.FakeRagdoll:GetModelScale() ~= scale then
			ply.FakeRagdoll:SetModelScale(scale, 0)
		end

		local deathRag = ply:GetNWEntity("RagdollDeath")
		if IsValid(deathRag) and deathRag:GetModelScale() ~= scale then
			deathRag:SetModelScale(scale, 0)
		end
	end
end)

--// Headshot-gib prop (headboom.mdl, spawned in headgib/init_sv.lua's
--// Gib_Input). Vanilla parents it to the ragdoll's head bone but never
--// scales it, so it looks tiny/floating on a scaled-up ragdoll. Catch
--// it by model + parent instead of editing that file.
local HEADBOOM_MODEL = "models/gleb/zcity/headboom.mdl"

hook.Add("OnEntityCreated", "BeastScaleFix_Headgib", function(ent)
	timer.Simple(0, function()
		if not IsValid(ent) then return end
		if ent:GetModel() ~= HEADBOOM_MODEL then return end

		local parent = ent:GetParent()
		if not IsValid(parent) then return end

		local scale = parent:GetModelScale()
		if scale ~= 1 and ent:GetModelScale() ~= scale then
			ent:SetModelScale(scale, 0)
		end
	end)
end)
