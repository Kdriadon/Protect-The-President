--[[

	Protect The President - Created by Blt950, Maintained by Sayshal
	Help Us Develop: https://github.com/Sayshal/Protect-The-President

]]--
AddCSLuaFile()

if SERVER then
	util.AddNetworkString("KeypadCracker_Hold")
	util.AddNetworkString("KeypadCracker_Sparks")
end

if CLIENT then
	SWEP.PrintName = "Keypad Cracker"
	SWEP.Slot = 4
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
end

SWEP.Author = "Willox"
SWEP.Instructions = "Left click to crack keypad or fingerpad"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/v_c4.mdl")
SWEP.WorldModel = Model("models/weapons/w_c4.mdl")

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.AnimPrefix = "python"

SWEP.Sound = Sound("weapons/deagle/deagle-1.wav")

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.KeyCrackTime = 30

SWEP.KeyCrackSound = Sound("buttons/blip2.wav")

SWEP.IdleStance = "slam"

function SWEP:Initialize()
	self:SetWeaponHoldType(self.IdleStance)

	if SERVER then
		net.Start("KeypadCracker_Hold")
			net.WriteEntity(self)
			net.WriteBit(true)
		net.Broadcast()
	end

end	

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.4)

	if self.Owner:HasItem("hackspeed") > 0 then
		self.KeyCrackTime = 30 / (GMShop["hackspeed"].upgrades[self.Owner:HasItem("hackspeed")].value / 2)
	else
		self.KeyCrackTime = 30
	end
	
	if self.IsCracking or not IsValid(self.Owner) then return end

	local tr = self.Owner:GetEyeTrace()
	local ent = tr.Entity

	if IsValid(ent) and tr.HitPos:Distance(self.Owner:GetShootPos()) <= 50 and (ent:GetClass() == "keypad" or ent:GetClass() == "keypad_wire" or ent:GetClass() == "fingerpad") then
		self.IsCracking = true
		self.StartCrack = CurTime()
		self.EndCrack = CurTime() + self.KeyCrackTime

		self:SetWeaponHoldType("pistol") -- TODO: Send as networked message for other clients to receive

		
		if SERVER then
			net.Start("KeypadCracker_Hold")
				net.WriteEntity(self)
				net.WriteBit(true)
			net.Broadcast()

			timer.Create("KeyCrackSounds: "..self:EntIndex(), 1, self.KeyCrackTime, function()
				if IsValid(self) and self.IsCracking then
					if self.Owner:HasItem("hacksound") > 0 then
						self:EmitSound("buttons/button1.wav", 100, 100)
					else
						self:EmitSound(self.KeyCrackSound, 100, 100)
					end
					
				end
			end)
		else
			self.Dots = self.Dots or ""
			
			local entindex = self:EntIndex()
			timer.Create("KeyCrackDots: "..entindex, 0.5, 0, function()
				if not IsValid(self) then
					timer.Destroy("KeyCrackDots: "..entindex)
				else
					local len = string.len(self.Dots)
					local dots = {[0] = ".", [1] = "..", [2]= "...", [3] = ""}

					self.Dots = dots[len]
				end
			end)
		end
	end
end

function SWEP:Holster()
	self.IsCracking = false

	if SERVER then
		timer.Destroy("KeyCrackSounds: "..self:EntIndex())
	else
		timer.Destroy("KeyCrackDots: "..self:EntIndex())
	end

	return true
end

function SWEP:Reload()
	return true
end

function SWEP:Succeed()
	self.IsCracking = false

	local tr = self.Owner:GetEyeTrace()
	local ent = tr.Entity
	self:SetWeaponHoldType(self.IdleStance)

	if SERVER and IsValid(ent) and tr.HitPos:Distance(self.Owner:GetShootPos()) <= 50 and (ent:GetClass() == "keypad" or ent:GetClass() == "keypad_wire" or ent:GetClass() == "fingerpad") then
		ent:Process(true)

		net.Start("KeypadCracker_Hold")
			net.WriteEntity(self)
			net.WriteBit(true)
		net.Broadcast()

		net.Start("KeypadCracker_Sparks")
			net.WriteEntity(ent)
		net.Broadcast()
	end

	if SERVER then
		timer.Destroy("KeyCrackSounds: "..self:EntIndex())
	else
		timer.Destroy("KeyCrackDots: "..self:EntIndex())
	end
end

function SWEP:Fail()
	self.IsCracking = false

	self:SetWeaponHoldType(self.IdleStance)

	if SERVER then
		net.Start("KeypadCracker_Hold")
			net.WriteEntity(self)
			net.WriteBit(true)
		net.Broadcast()

		timer.Destroy("KeyCrackSounds: "..self:EntIndex())
	else
		timer.Destroy("KeyCrackDots: "..self:EntIndex())
	end
end

function SWEP:Think()
	if not self.StartCrack then
		self.StartCrack = 0
		self.EndCrack = 0
	end

	if self.IsCracking and IsValid(self.Owner) then
		local tr = self.Owner:GetEyeTrace()

		if not IsValid(tr.Entity) or tr.HitPos:Distance(self.Owner:GetShootPos()) > 50 or (tr.Entity:GetClass() ~= "keypad" and tr.Entity:GetClass() ~= "keypad_wire" and tr.Entity:GetClass() ~= "fingerpad") then
			self:Fail()
		elseif self.EndCrack <= CurTime() then
			self:Succeed()
		end
	else
		self.StartCrack = 0
		self.EndCrack = 0
	end
	
	self:NextThink(CurTime())
	return true
end

if(CLIENT) then
	SWEP.BoxColor = Color(10, 10, 10, 100)

	surface.CreateFont("KeypadCrack", {
		font = "Trebuchet",
		size = 18,
		weight = 600,
	})

	function SWEP:DrawHUD()
		if self.IsCracking then
			--[[self.Dots = self.Dots or ""

			local w, h = ScrW(), ScrH()

			local x, y, width, height = (w/2-w/10), (h/ 2), (w/5), (h/15)

			draw.RoundedBox(8, x, y, width, height, self.BoxColor)

			local time = self.EndCrack - self.StartCrack
			local curtime = CurTime() - self.StartCrack
			local status = curtime/time
			local BarWidth = status * (width - 16) + 8

			draw.RoundedBox(8, x+8, y+8, BarWidth, height-16, Color(255 - (status * 255), 0 + (status*255), 0, 255))

			draw.SimpleText("Cracking"..self.Dots, "KeypadCrack", w/2, h/2 + height/2, color_white, 1, 1) shit]]
			if not self.StartCrack then
				self.StartCrack = CurTime()
				self.EndCrack = CurTime() + self.KeyCrackTime
			end

			local frac = math.Clamp((CurTime() - self.StartCrack) / (self.EndCrack - self.StartCrack), 0, 1) -- Between 0 and 1 (a fraction omg)
			
			local dots = self.Dots or ""
			
			local w, h = ScrW(), ScrH()
			
			local x, y = (w / 2) - 150, (h / 2) - 25
			local w, h = 300, 50
			
			draw.RoundedBox(4, x, y, w, h, self.BoxColor)
			
			surface.SetDrawColor(Color(255 + (frac * -255), frac * 255, 40))			
			surface.DrawRect(x + 5, y + 5, frac * (w - 10), h - 10)
			
			surface.SetFont("KeypadCrack")
			local fontw, fonth = surface.GetTextSize("Cracking")
			local fontx, fonty = (x + (w / 2)) - (fontw / 2), (y + (h / 2)) - (fonth / 2)
			
			surface.SetTextPos(fontx + 1, fonty+1)
			surface.SetTextColor(color_black)
			surface.DrawText("Cracking"..dots)
			
			surface.SetTextPos(fontx, fonty)
			surface.SetTextColor(color_white)
			surface.DrawText("Cracking"..dots)
		end
	end
	
	SWEP.DownAngle = Angle(-10, 0, 0)
	
	SWEP.LowerPercent = 1
	SWEP.SwayScale = 0
	
	function SWEP:GetViewModelPosition(pos, ang)
		
		
		if self.IsCracking then
			local delta = FrameTime() * 3.5
			self.LowerPercent = math.Clamp(self.LowerPercent - delta, 0, 1)
		else
			local delta = FrameTime() * 5
			self.LowerPercent = math.Clamp(self.LowerPercent + delta, 0, 1)
		end
		
		ang:RotateAroundAxis(ang:Forward(), self.DownAngle.p * self.LowerPercent)
		ang:RotateAroundAxis(ang:Right(), self.DownAngle.p * self.LowerPercent)

		return self.BaseClass.GetViewModelPosition(self, pos, ang)
	end

	net.Receive("KeypadCracker_Hold", function()
		local ent = net.ReadEntity()
		local state = (net.ReadBit() == 1)

		if IsValid(ent) and ent:IsWeapon() and ent:GetClass() == "keypad_cracker" and not game.SinglePlayer() and ent.SetWeaponHoldType then
			if not state then
				ent:SetWeaponHoldType(ent.IdleStance)
				ent.IsCracking = false
			else
				ent:SetWeaponHoldType("pistol")
				ent.IsCracking = true
			end
		end
	end)
	
	net.Receive("KeypadCracker_Sparks", function()
		local ent = net.ReadEntity()
		
		if IsValid(ent) then
			local vPoint = ent:GetPos()
			local effect = EffectData()
			effect:SetStart(vPoint)
			effect:SetOrigin(vPoint)
			effect:SetEntity(ent)
			effect:SetScale(2)
			util.Effect("cball_bounce", effect)
			
			ent:EmitSound("buttons/combine_button7.wav", 100, 100)
		end
	end)
end