--[[
	Drug face effects - add-on, edits nothing in zcity or the drug addon.

	Uses the same facial flex controllers zcity's own lip-sync code
	already drives in homigrad/cl_utility.lua (jaw_drop, blink,
	wrinkler, half_closed) - just fed a different pattern instead of
	voice volume / a blink timer.

	Any drug weapon can trigger this by setting two timestamps on the
	entity - no dependency on this file, no need to touch the weapon's
	own Heal() logic beyond adding those two lines. See bottom of file
	for the exact lines to drop into weapon_codeine.lua or a new molly
	file.

	Drop this under lua/autorun/client/ in your addon.
--]]

if SERVER then return end

local function GetVisibleEnt(ply)
	return IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
end

local DEBUG = true -- flip to false (or delete this block) once it's confirmed working

local function ApplyDrugFace(ply)
	local ent = GetVisibleEnt(ply)
	if not IsValid(ent) then return end

	local jawUntil = ent:GetNWFloat("drgVisJawUntil", 0)
	local eyesUntil = ent:GetNWFloat("drgVisWideEyesUntil", 0)

	if DEBUG and ply == LocalPlayer() and (jawUntil > CurTime() or eyesUntil > CurTime()) then
		local jawFlex = ent:GetFlexIDByName("jaw_drop")
		local blinkFlex = ent:GetFlexIDByName("blink")
		print(string.format(
			"[DrugFace] model=%s jawUntil=%.1f eyesUntil=%.1f now=%.1f jawFlexID=%s blinkFlexID=%s",
			ent:GetModel() or "?", jawUntil, eyesUntil, CurTime(), tostring(jawFlex), tostring(blinkFlex)
		))
	end

	-- Jaw spasm: oscillate jaw_drop (and lower_lip, if the model has
	-- it, for a bit more visible movement) instead of holding it at
	-- a fixed weight. Frequency/amplitude are tunable below.
	-- Read via GetNWFloat - weapon_molly.lua sets this server-side
	-- with SetNWFloat, so this has to read the networked var, not a
	-- plain field (a plain field set on SERVER never reaches CLIENT).
	if jawUntil > CurTime() then
		local jaw = ent:GetFlexIDByName("jaw_drop")
		if jaw then
			local weight = math.abs(math.sin(CurTime() * 14)) -- ~14 = fast twitchy spasm, lower = slower/looser
			ent:SetFlexWeight(jaw, weight)
		end

		local lowerLip = ent:GetFlexIDByName("lower_lip")
		if lowerLip then
			ent:SetFlexWeight(lowerLip, math.abs(math.sin(CurTime() * 14)) * 0.5)
		end
	end

	-- Wide eyes: override the model's own blink cycle so the eyes
	-- stay open instead of periodically closing.
	if eyesUntil > CurTime() then
		ent.Blink = 0
		ent.Blinking = 0 -- blink/wrinkler/half_closed all read from this, see cl_utility.lua

		-- Optional: only applies on models that happen to have a
		-- dedicated "wide eye"/surprise flex - harmless no-op otherwise.
		local upL = ent:GetFlexIDByName("UpperLidUp_L")
		if upL then ent:SetFlexWeight(upL, 0.6) end

		local upR = ent:GetFlexIDByName("UpperLidUp_R")
		if upR then ent:SetFlexWeight(upR, 0.6) end
	end
end

hook.Add("Player Think", "DrugFaceEffects", function(ply)
	if IsValid(ply) then
		ApplyDrugFace(ply)
	end
end)

--[[
	To trigger from any other drug weapon's Heal() (server-side):

		ent:SetNWFloat("drgVisJawUntil", CurTime() + 25)
		ent:SetNWFloat("drgVisWideEyesUntil", CurTime() + 40)

	weapon_molly.lua already does this (refreshed every Org Think
	tick through come-up/peak, see that file).
--]]
