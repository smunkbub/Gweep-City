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
	tbl.AClothes["main"] = "normal"
	tbl.AClothes["pants"] = "normal"
	tbl.AClothes["boots"] = "normal"
	tbl.AColor = Color(0, 0, 255)
	hg.Appearance.ForceApplyAppearance(self,tbl)
end