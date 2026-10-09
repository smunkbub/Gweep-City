--[[
	Fent-fold posture - add-on, edits nothing in zcity. Callable from
	any weapon, at any time, via one line server-side:

		ply:SetNWFloat("fentFoldUntil", CurTime() + duration)

	This is genuinely reusable, not tied to one weapon - see
	weapon_perc30.lua for an example trigger.

	Note: this uses hg.bone.Set (sh_bonemethods.lua) directly - the
	SAME function weapon_codeine.lua's :BoneSet() ultimately calls for
	arm bones like r_upperarm, since those aren't actually in
	hg.bone.client_only (only finger bones are - I mis-traced that
	distinction on the headlock/drug-face scripts earlier, which used
	the client_only-only code path for r_upperarm/l_upperarm etc. and
	so likely never actually applied anything. Worth fixing those too
	if you've noticed the headlock arms not visibly posing - happy to
	patch that once you confirm.) hg.bone.Set is layered, so this
	coexists cleanly with anything else manipulating these bones.
--]]

if SERVER then return end

-- Starting guesses - like every bone-pose value in this addon so far,
-- these need to be seen on your actual playermodel to get right.
local FOLD_POSE = {
	spine  = Angle(0, 60, 0),
	spine1 = Angle(0, 50, 0),
	spine2 = Angle(0, 30, 0),
	head   = Angle(0, 40, 0),
	r_upperarm = Angle(10, -10, 60),
	r_forearm  = Angle(-20, 0, 0),
	l_upperarm = Angle(10, 10, -60),
	l_forearm  = Angle(-20, 0, 0),
}

hook.Add("Player Think", "FentFoldPose", function(ply, time, dtime)
	if not IsValid(ply) then return end
	if ply:GetNWFloat("fentFoldUntil", 0) <= CurTime() then return end

	for boneName, ang in pairs(FOLD_POSE) do
		hg.bone.Set(ply, boneName, vector_origin, ang, "fentfold", 0.15, dtime)
	end
end)
