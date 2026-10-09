local CLASS = player.RegClass("butthead")

function CLASS.Off(self)
    if CLIENT then return end
end

local name = "Butthead"

local model = "models/ut2004/cursed/ut2004cursedbutthead.mdl"

function CLASS.On(self)
    if CLIENT then return end
    ApplyAppearance(self,nil,nil,nil,true)
    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    Appearance.AAttachments = ""
    Appearance.AColthes = ""
	Appearance.AName = name
    self:SetNWString("PlayerName", name)
	self:SetNetVar("Accessories", "")
    self:SetPlayerColor(Color(165,0,0):ToVector())
    self:SetModel(model)

    local inv = self:GetNetVar("Inventory", {})
    inv["Weapons"] = inv["Weapons"] or {}
    inv["Weapons"]["hg_sling"] = true
    self:SetNetVar("Inventory", inv)

    self:SetSubMaterial()
    
    self.CurAppearance = Appearance
end