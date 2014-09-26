--[[

	Protect The President - Created by Blt950, Maintained by Sayshal
	Help Us Develop: https://github.com/Sayshal/Protect-The-President

]]--
local view = {
	origin = Vector(0, 0, 0),
	angles = Angle(0, 0, 0),
	fov = 90,
	znear = 1
}

hook.Add("CalcView", "rp_deathPOV", function(ply, origin, angles, fov)
	if ply:Alive() then return end

	local Ragdoll = ply:GetRagdollEntity()
	if not IsValid(Ragdoll) then return end

	local head = Ragdoll:LookupAttachment("eyes")
	head = Ragdoll:GetAttachment(head)
	if not head or not head.Pos then return end

	if not Ragdoll.BonesRattled then
		Ragdoll.BonesRattled = true

		Ragdoll:InvalidateBoneCache()
		Ragdoll:SetupBones()

		local matrix

		for bone = 0, (Ragdoll:GetBoneCount() or 1) do
			if Ragdoll:GetBoneName(bone):lower():find("head") then
				matrix = Ragdoll:GetBoneMatrix(bone)
				break
			end
		end

		if IsValid(matrix) then
			matrix:SetScale(Vector(0, 0, 0))
		end
	end

	view.origin = head.Pos + head.Ang:Up() * 8
	view.angles = head.Ang

	return view
end)
