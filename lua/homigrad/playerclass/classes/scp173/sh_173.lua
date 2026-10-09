local CLASS = player.RegClass("scp173")

function CLASS.Off(self)
    if CLIENT then return end
	
	ApplyAppearance(self,false,false,false,true)

	-- if self.oldspeed then
	-- 	self:SetRunSpeed(self.oldspeed)
	-- 	self.oldspeed = nil
	-- end

	if SERVER then
		self.organism.bloodtype = self.oldbloodtype or "o-"
		
		hg.ClearArmorRestrictions(self)
	end

	if eightbit and eightbit.EnableEffect and self.UserID then
		eightbit.EnableEffect(self:UserID(), 0)
	end

	self.JumpPowerMul = nil
	self.SpeedGainClassMul = nil
	self:SetNWInt("SpeedGainClassMul", nil)
	self.MeleeDamageMul = nil
	self.StaminaExhaustMul = nil
    self.Is173 = false
end

local name = "SCP-173"

function CLASS.On(self, data)
    if CLIENT then return end

    data = data or {}

    self.Is173 = true

    ApplyAppearance(self,nil,nil,nil,true)

    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    Appearance.AAttachments = ""
    Appearance.AColthes = ""
    Appearance.AName = name

    self:SetNWString("PlayerName", name)
    self:SetPlayerColor(Color(255,255,255):ToVector())
    self:SetModel("models/scp/173.mdl")

    self:SetSubMaterial()

    self.CurAppearance = Appearance
	
	self.JumpPowerMul = 0
	self.SpeedGainClassMul = 9999
	self:SetNWInt("SpeedGainClassMul", self.SpeedGainClassMul)
	self.StaminaExhaustMul = 0
end