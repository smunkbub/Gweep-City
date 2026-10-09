if CLIENT then return end

util.AddNetworkString("headcrab_vomit_squirt")

local VOMIT_COOLDOWN = 15

hook.Add("Org Clear", "ResetVomitCooldown", function(org)
	if IsValid(org.owner) then org.owner.NextVomitAllowed = nil end
end)

function hg.organism.VomitNoBloodLoss(owner, snd)
	if not hg.IsValidPlayer(owner) then return end

	if owner.NextVomitAllowed and owner.NextVomitAllowed > CurTime() then
		owner:Notify("I can't vomit right now.")
		return false
	end
	owner.NextVomitAllowed = CurTime() + VOMIT_COOLDOWN

	local org = owner.organism

	org.poison1 = nil
	org.poison1notificate = nil
	org.poison2 = nil
	org.poison2notificate = nil
	org.poison3 = nil
	org.poison3notificate = nil
	org.poison4 = nil
	org.poison4notificate = nil
	org.Poison_KCN = nil

	org.disorientation = math.min(org.disorientation + 1.5, 10)

	if org.stamina then
		org.stamina.subadd = (org.stamina.subadd or 0) + 15
	end

	local ent = hg.GetCurrentCharacter(owner)

	local bon = "ValveBiped.Bip01_Head1"
	local bone = ent:LookupBone(bon)
	local mat = ent:GetBoneMatrix(bone)

	if not mat then return end

	local on_spine = mat:GetAngles():Right()[3] > 0.25
	if on_spine then
		org.vomitInThroat = true
	end

	owner:SetNetVar("vomiting", CurTime() + 1.5)

	ent:EmitSound(snd or "zcitysnd/real_sonar/" .. (ThatPlyIsFemale(ent) and "female" or "male") .. "_cough" .. math.random(4) .. ".mp3")
	if not on_spine then ent:EmitSound("vomit/vomit5.mp3") end

	if owner.armors and owner.armors.face and hg.armor.face[owner.armors.face].voice_change then
		owner:SetNetVar("zableval_masku", true)
	else
		if not on_spine then
			net.Start("headcrab_vomit_squirt")
			net.WriteEntity(ent)
			net.WriteString(bon)
			net.WriteMatrix(mat)
			net.WriteVector(mat:GetTranslation() + mat:GetAngles():Right() * 6 + mat:GetAngles():Forward() * 1)
			net.WriteVector(mat:GetAngles():Right() * 2 * math.Clamp(org.pulse / 70, 0.4, 1))
			net.Broadcast()
		end
	end
end

concommand.Add("hg_puke", function(ply, cmd, args)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	hg.organism.VomitNoBloodLoss(ply)
end)