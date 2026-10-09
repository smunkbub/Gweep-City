MODE.name = "rvb"
MODE.PrintName = "Team Deathmatch (Red vs Blue)"

MODE.ForBigMaps = false
MODE.ROUND_TIME = 300

MODE.Chance = 0.02

MODE.OverideSpawnPos = true
MODE.LootSpawn = false

function MODE:CanLaunch()
	return true
	--[[local points = zb.GetMapPoints( "HMCD_TDM_T" )
	local points2 = zb.GetMapPoints( "HMCD_TDM_CT" )
    return (#points > 0) and (#points2 > 0)--]]
end

function MODE.GuiltCheck(Attacker, Victim, add, harm, amt)
	return 1, true--returning true so guilt bans
end

util.AddNetworkString("rvb_start")
function MODE:Intermission()
	game.CleanUpMap()

	self.CTPoints = {}
	table.CopyFromTo(zb.GetMapPoints( "HMCD_TDM_CT" ),self.CTPoints)
	self.TPoints = {}
	table.CopyFromTo(zb.GetMapPoints( "HMCD_TDM_T" ),self.TPoints)
	
	for i, ply in player.Iterator() do
		ply:SetupTeam(ply:Team())
	end

	net.Start("rvb_start")
	net.Broadcast()
end

function MODE:CheckAlivePlayers()
	return zb:CheckAliveTeams(true)
end

function MODE:ShouldRoundEnd()
	local endround, winner = zb:CheckWinner(self:CheckAlivePlayers())

	return endround or boringround
end

function MODE:BoringRoundFunction()		
	timer.Simple(2, function()
		//PrintMessage(HUD_PRINTTALK, "IT IS A GANG SHOOTOUT FFS...")
	end)
end

local swatSpawned = false

function MODE:RoundStart()
    swatSpawned = false 
end

local tblweps = {
	[0] = {
		"weapon_m4a1",
		"weapon_asval",
		"weapon_tmp",
		"weapon_mp7",
		"weapon_vector",
		"weapon_uzi",
		"weapon_m16a2",
		"weapon_ak74u",
		"weapon_xm1014",
		"weapon_m590a1",
		"weapon_saiga12",
		"weapon_svd",
		"weapon_m98b",
		"weapon_rpk",
		"weapon_hg_rpg",
		"weapon_vpo209",
		"weapon_ar_pistol",
		"weapon_flamezsisi",
	},
	[1] = {
		"weapon_m4a1",
		"weapon_asval",
		"weapon_tmp",
		"weapon_mp7",
		"weapon_vector",
		"weapon_uzi",
		"weapon_m16a2",
		"weapon_ak74u",
		"weapon_xm1014",
		"weapon_m590a1",
		"weapon_saiga12",
		"weapon_svd",
		"weapon_m98b",
		"weapon_rpk",
		"weapon_hg_rpg",
		"weapon_vpo209",
		"weapon_ar_pistol,",
		"weapon_flamezsisi"
	}
}

local tblweps2 = {
	[0] = {
		"weapon_cz75",
		"weapon_deagle",
		"weapon_glock17",
		"weapon_revolver2",
		"weapon_hk_usp",
		"weapon_p22",
		"weapon_revolverequiem",
		"weapon_microuzi",
	},
	[1] = {
		"weapon_cz75",
		"weapon_deagle",
		"weapon_glock17",
		"weapon_revolver2",
		"weapon_hk_usp",
		"weapon_p22",
		"weapon_revolverequiem",
		"weapon_microuzi",
	}
}


local tblatts = {
    ["weapon_m4a1"] = {
        "optic4",
        "holo14",
        "laser2",
        "grip3"
    },

    ["weapon_asval"] = {
        "optic4",
        "holo14",
        "laser2"
    },
	["weapon_rpk"] = {
		"holo9"
	},
	["weapon_tmp"] = {
		"supressor4",
		"holo11"
	},
	["weapon_vector"] = {
		"holo9"
	},
	["weapon_svd"] = {
		"optic4"
	},
	["weapon_m16a2"] = {
		"holo3"
	},
	["weapon_m590a1"] = {
		"supressor5"
	},
	["weapon_ar_pistol"] = {
		"holo8"
	}
}

--[[local tblarmors = {
	[0] = {
		{"ent_armor_vest3","ent_armor_helmet2"}
	},
	[1] = {
		{"ent_armor_vest3","ent_armor_helmet2"}
	}
}
]]

local function GiveWeaponAttachments(wep)
    if not IsValid(wep) then return end

    local sourceList = tblatts[wep:GetClass()]
    if not sourceList then return end

    local attachments = table.Copy(sourceList)

    local amount = math.random(1, math.min(3, #attachments))
    local chosen = {}

    for i = 1, amount do
        local index = math.random(#attachments)
        table.insert(chosen, attachments[index])
        table.remove(attachments, index)
    end

    if not wep.attachments then
        if wep.ClearAttachments then
            wep:ClearAttachments()
        else
            return
        end
    end

    for _, att in ipairs(chosen) do
        hg.SetAttachment(wep.attachments, att, wep:GetClass())
    end

    wep:SetNetVar("attachments", wep.attachments)
end
function MODE:GetPlySpawn(ply)
end

function MODE:GiveEquipment()
	self.CTPoints = {}
	table.CopyFromTo(zb.GetMapPoints( "HMCD_TDM_CT" ),self.CTPoints)
	self.TPoints = {}
	table.CopyFromTo(zb.GetMapPoints( "HMCD_TDM_T" ),self.TPoints)
	timer.Simple(0.1,function()
		local teamArmorCount = { [0] = 0, [1] = 0 } 

		for _, ply in player.Iterator() do
			if not ply:Alive() then continue end
			ply:SetSuppressPickupNotices(true)
			ply.noSound = true

			if ply:Team() == 0 then
				zb.GiveRole(ply, "Red", Color(190,0,0))
				ply:SetNetVar("CurPluv", "pluvred")
				local tbl = ply.CurAppearance
				tbl.AClothes["main"] = "normal"
				tbl.AClothes["pants"] = "normal"
				tbl.AClothes["boots"] = "normal"
				tbl.AColor = Color(255, 0, 0)
				hg.Appearance.ForceApplyAppearance(ply, tbl)
			else
				zb.GiveRole(ply, "Blue", Color(0,0,190))
				ply:SetNetVar("CurPluv", "pluvgreen")
				local tbl = ply.CurAppearance
				tbl.AClothes["main"] = "normal"
				tbl.AClothes["pants"] = "normal"
				tbl.AClothes["boots"] = "normal"
				tbl.AColor = Color(0, 0, 255)
				hg.Appearance.ForceApplyAppearance(ply, tbl)
			end

			local tbl = tblweps[ply:Team()]
			local wepClass = tbl[math.random(#tbl)]
			local wep = ply:Give(wepClass)

			GiveWeaponAttachments(wep)

			local ammoType = wep:GetPrimaryAmmoType()
			if ammoType and ammoType > -1 then
				ply:GiveAmmo(wep:GetMaxClip1() * 3, ammoType)
			end

			local tbl2 = tblweps2[ply:Team()]
			local wep2 = ply:Give(tbl2[math.random(#tbl2)])
			ply:GiveAmmo(wep2:GetMaxClip1() * 3, wep2:GetPrimaryAmmoType())

			if wep2.SetDeagleSkin then
				//wep2:SetDeagleSkin(4)
				//wep2:SetDeagleBodygroup(1)
			end

			ply:Give("weapon_medkit_sh")
			ply:Give("weapon_morphine")
			ply:Give("weapon_melee")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_hg_pipebomb_tpik")
			ply:Give("weapon_hg_rgd_tpik")

			local Radio = ply:Give("weapon_walkie_talkie")
			Radio.Frequency = (ply:Team() == 1 and math.Round(math.Rand(88,95),1)) or math.Round(math.Rand(100,108),1)

			local hands = ply:Give("weapon_hands_sh")
			ply:SelectWeapon("weapon_hands_sh")

			timer.Simple(0.1,function()
				ply.noSound = false
			end)

			ply:SetSuppressPickupNotices(false)
		end
	end)
end

function MODE:GetTeamSpawn()
	return zb.TranslatePointsToVectors(zb.GetMapPoints( "HMCD_TDM_T" )), zb.TranslatePointsToVectors(zb.GetMapPoints( "HMCD_TDM_CT" ))
end

function MODE:CanSpawn()
end

util.AddNetworkString("rvb_roundend")

function MODE:EndRound()
    local endround, winner = zb:CheckWinner(self:CheckAlivePlayers())

    local winnerName = "No team"

    if winner == 0 then
        winnerName = "Red Team"
    elseif winner == 1 then
        winnerName = "Blue Team"
    end

    net.Start("rvb_roundend")
    net.Broadcast()
    PrintMessage(HUD_PRINTTALK, winnerName .. " wins the round!")

    for _, ply in player.Iterator() do
        if ply:Team() == winner then
            ply:GiveExp(math.random(15,30))
            ply:GiveSkill(math.Rand(0.1,0.15))
        else
            ply:GiveSkill(-math.Rand(0.05,0.1))
        end
    end
end