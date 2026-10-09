local CLASS = player.RegClass("balla")

function CLASS.Off(self)
    if CLIENT then return end
end

local models = {
    "models/gta_peds/ballas1.mdl",
    "models/gta_peds/ballas2.mdl",
    "models/gta_peds/ballas3.mdl"
}

local subnames = {
	"Big ",
	"Lil ",
	"OG "
}

function CLASS.On(self)
    if CLIENT then return end
    ApplyAppearance(self,nil,nil,nil,true)
    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    Appearance.AAttachments = ""
    Appearance.AColthes = ""
	self:SetNWString("PlayerName",subnames[math.random(#subnames)] .. Appearance.AName)
    self:SetPlayerColor(Color(130,0,255):ToVector())
    self:SetModel(models[math.random(#models)])
	for _, bg in ipairs(self:GetBodyGroups()) do
		self:SetBodygroup(bg.id, math.random(0, bg.num))
	end

    self:SetNetVar("Accessories", "")
    
    local inv = self:GetNetVar("Inventory", {})
    inv["Weapons"] = inv["Weapons"] or {}
    inv["Weapons"]["hg_sling"] = true
    self:SetNetVar("Inventory", inv)

    self:SetSubMaterial()
    self.CurAppearance = Appearance
end

local sounds = {
    "gangsta/ballas/sound_004.ogg",
    "gangsta/ballas/sound_151.ogg",
    "gangsta/ballas/sound_153.ogg",
    "gangsta/ballas/sound_169.ogg",
    "gangsta/ballas/sound_179.ogg",
    "gangsta/ballas/sound_278.ogg",
    "gangsta/ballas/sound_310.ogg",
    "gangsta/ballas/sound_336.ogg",
    "gangsta/ballas/sound_340.ogg"
}

if SERVER then
    hook.Add("HG_ReplacePhrase", "BallasPhrases", function(ply, phrase, muffed, pitch)
        if IsValid(ply) and ply.PlayerClassName == "balla" then
            print("BallasPhrases firing for", ply, "class:", ply.PlayerClassName)
            return ply, sounds[math.random(#sounds)], muffed, pitch
        end
    end)
end