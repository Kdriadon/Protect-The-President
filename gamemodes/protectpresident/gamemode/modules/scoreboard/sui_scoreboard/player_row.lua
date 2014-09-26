--[[

	Protect The President - Created by Blt950, Maintained by Sayshal
	Help Us Develop: https://github.com/Sayshal/Protect-The-President

]]--
// checking for utime for the hours
utimecheck = false
if file.Exists("autorun/cl_utime.lua", "LUA") then 
	utimecheck = true
	print(">>> PTP --> UTime Support added!")
end


// checking for ulib for the team names
ulibcheck = false
if file.Exists("ulib/cl_init.lua", "LUA") then 
	ulibcheck = true
	print(">>> PTP --> ULib Support added!")
end

local texGradient = surface.GetTextureID( "gui/center_gradient" )

local PANEL = {}

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint( w, h )
	if not IsValid( self.Player ) then
		self:Remove()
		SCOREBOARD:InvalidateLayout()
		return 
	end 
	
	local color = Color( 100, 100, 100, 255 )

	if self.Armed then
		color = Color( 125, 125, 125, 255 )
	end
	
	if self.Selected then
		color = Color( 125, 125, 125, 255 )
	end
	
	if self.Player:Team() == TEAM_CONNECTING then
		color = Color( 100, 100, 100, 155 )
	elseif IsValid( self.Player ) then
		if self.Player:Team() == TEAM_UNASSIGNED then
			color = Color( 100, 100, 100, 255 )
		else	
			color = team.GetColor( self.Player:Team() )
		end
	elseif self.Player:IsAdmin() then
		color = Color( 255, 155, 0, 255 )
	end
	
	if self.Player == LocalPlayer() then
		color = team.GetColor( self.Player:Team() )
	end

	if self.Open or self.Size ~= self.TargetSize then
		draw.RoundedBox( 4, 18, 16, self:GetWide() - 36, self:GetTall() - 16, color )
		draw.RoundedBox( 4, 20, 16, self:GetWide() - 40, self:GetTall() - 16 - 2, Color( 225, 225, 225, 150 ) )
		
		surface.SetTexture( texGradient )
		surface.SetDrawColor( 255, 255, 255, 100 )
		surface.DrawTexturedRect( 20, 16, self:GetWide() - 40, self:GetTall() - 18 )
	end
	
	draw.RoundedBox( 4, 18, 0, self:GetWide() - 36, 38, color )
	
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 255, 255, 255, 150 )
	surface.DrawTexturedRect( 0, 0, self:GetWide() - 36, 38 ) 
	
	/*surface.SetTexture( self.texRating )
	surface.SetDrawColor( 255, 255, 255, 255 )
	-- surface.DrawTexturedRect( 20, 4, 16, 16 )
	surface.DrawTexturedRect( 56, 3, 16, 16 )*/
	
	return true
end

/*---------------------------------------------------------
   Name: SetPlayer
---------------------------------------------------------*/
function PANEL:SetPlayer( ply )
	self.Player = ply
	self:UpdatePlayerData()
	self.imgAvatar:SetPlayer( ply )
end

/*function PANEL:CheckRating( name, count )
	if self.Player:GetNetworkedInt( "Rating." .. name, 0 ) > count then
		count = self.Player:GetNetworkedInt( "Rating." .. name, 0 )
		self.texRating = texRatings[ name ]
	end
	return count
end*/

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:UpdatePlayerData()
	local ply = self.Player
	if not IsValid( ply ) then return end
	
	self.lblName:SetText( ply:Nick() )
	if ply:IsPremium() and not ply:IsAdmin() then
		self.lblStatus:SetText( "Premium Member" )
	else
		self.lblStatus:SetText( "" )
	end
	if ulibcheck then 
		local jobname = ply:GetTeamName()
		if ply:GetSharedVar("class") then
			jobname = jobname .. " "..ply:GetClassName()
		end
		self.lblTeam:SetText( jobname or "" )
	end
	if utimecheck then self.lblHours:SetText( math.floor( ply:GetUTimeTotalTime() / 3600 ) ) end
	self.lblFrags:SetText( ply:Frags() )
	self.lblDeaths:SetText( ply:Deaths() )
	self.lblPing:SetText( ply:Ping() )

	local k = ply:Frags()
	local d = ply:Deaths()
	local kdr = "--   "
	if d ~= 0 then
	   kdr = k / d
	   local y, z = math.modf( kdr )
	   z = string.sub( z, 1, 5 )
	   if y ~= 0 then kdr = string.sub( y + z, 1, 5 ) else kdr = z end
	   kdr = kdr .. ":1"
	   if k == 0 then kdr = k .. ":" .. d end
	end

	self.lblRatio:SetText( kdr ) 
	
	// Work out what icon to draw
	/*self.texRating = surface.GetTextureID( "gui/silkicons/emoticon_smile" )

	self.texRating = texRatings[ 'none' ]
	local count = 0
	
	count = self:CheckRating( 'smile', count )
	count = self:CheckRating( 'love', count )
	count = self:CheckRating( 'artistic', count )
	count = self:CheckRating( 'gold_star', count )
	count = self:CheckRating( 'builder', count )
	count = self:CheckRating( 'lol', count )
	--count = self:CheckRating( 'gay', count ) -- No thanks.
	count = self:CheckRating( 'curvey', count )
	count = self:CheckRating( 'god', count )
	count = self:CheckRating( 'stunter', count )
	count = self:CheckRating( 'best_landvehicle', count )
	count = self:CheckRating( 'best_airvehicle', count )
	count = self:CheckRating( 'friendly', count )
	count = self:CheckRating( 'informative', count )
	count = self:CheckRating( 'naughty', count )*/
end

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()
	self.Size = 38
	self:OpenInfo( false )
	
	self.lblName 	= vgui.Create( "DLabel", self )
	self.lblStatus 	= vgui.Create( "DLabel", self )
	if ulibcheck then self.lblTeam 	= vgui.Create( "DLabel", self ) end
	if utimecheck then  self.lblHours 	= vgui.Create( "DLabel", self ) end
	self.lblFrags 	= vgui.Create( "DLabel", self )
	self.lblDeaths 	= vgui.Create( "DLabel", self )
	self.lblRatio 	= vgui.Create( "DLabel", self )
	self.lblPing 	= vgui.Create( "DLabel", self )
	self.lblPing:SetText( "9999" )
	
	self.btnAvatar = vgui.Create( "DButton", self )
	self.btnAvatar.DoClick = function() self.Player:ShowProfile() end
	
	self.imgAvatar = vgui.Create( "AvatarImage", self.btnAvatar )
	
	// If you don't do this it'll block your clicks
	self.lblName:SetMouseInputEnabled( false )
	self.lblStatus:SetMouseInputEnabled( false )
	if ulibcheck then self.lblTeam:SetMouseInputEnabled( false ) end
	if utimecheck then self.lblHours:SetMouseInputEnabled( false ) end
	self.lblFrags:SetMouseInputEnabled( false )
	self.lblDeaths:SetMouseInputEnabled( false )
	self.lblRatio:SetMouseInputEnabled( false )
	self.lblPing:SetMouseInputEnabled( false )
	self.imgAvatar:SetMouseInputEnabled( false )
end

/*---------------------------------------------------------
   Name: ApplySchemeSettings
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()
	self.lblName:SetFont( "suiscoreboardplayername" )
	self.lblStatus:SetFont( "suiscoreboardplayerstatus" )
	if ulibcheck then self.lblTeam:SetFont( "suiscoreboardplayername" ) end
	if utimecheck then self.lblHours:SetFont( "suiscoreboardplayername" ) end
	self.lblFrags:SetFont( "suiscoreboardplayername" )
	self.lblDeaths:SetFont( "suiscoreboardplayername" )
	self.lblRatio:SetFont( "suiscoreboardplayername" )
	self.lblPing:SetFont( "suiscoreboardplayername" )
	
	self.lblName:SetTextColor( color_black )
	self.lblStatus:SetTextColor( Color(0,127,127,255) )
	if ulibcheck then self.lblTeam:SetTextColor( color_black ) end
	if utimecheck then self.lblHours:SetTextColor( color_black ) end
	self.lblFrags:SetTextColor( color_black )
	self.lblDeaths:SetTextColor( color_black )
	self.lblRatio:SetTextColor( color_black )
	self.lblPing:SetTextColor( color_black )
end

/*---------------------------------------------------------
   Name: DoClick
---------------------------------------------------------*/
function PANEL:DoClick()
	if self.Open then
		surface.PlaySound( "ui/buttonclickrelease.wav" )
	else
		surface.PlaySound( "ui/buttonclick.wav" )
	end
	self:OpenInfo( not self.Open )*/
	self.Player:ShowProfile()
end

/*---------------------------------------------------------
   Name: OpenInfo
   ---------------------------------------------------------*/
function PANEL:OpenInfo( open )
	if open then
		self.TargetSize = 154
	else
		self.TargetSize = 38
	end
	self.Open = open
end

/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function PANEL:Think()
	if self.Size ~= self.TargetSize then
		self.Size = math.Approach( self.Size, self.TargetSize, (math.abs( self.Size - self.TargetSize ) + 1) * 10 * FrameTime() )
		self:PerformLayout()
		SCOREBOARD:InvalidateLayout()
	end
	
	if not self.PlayerUpdate or self.PlayerUpdate < CurTime() then
		self.PlayerUpdate = CurTime() + 0.5
		self:UpdatePlayerData()
	end
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()
	self:SetSize( self:GetWide(), self.Size )
	
	self.btnAvatar:SetPos( 21, 4 )
	self.btnAvatar:SetSize( 32, 32 )
	
 	self.imgAvatar:SetSize( 32, 32 )
	
	self.lblName:SizeToContents()
	self.lblStatus:SizeToContents()
	if ulibcheck then self.lblTeam:SizeToContents() end
	if utimecheck then self.lblHours:SizeToContents() end
	self.lblFrags:SizeToContents()
	self.lblDeaths:SizeToContents()
	self.lblRatio:SizeToContents()
	self.lblPing:SizeToContents()
	self.lblPing:SetWide( 100 )
	
	self.lblName:SetPos( 60, 3 )
	self.lblStatus:SetPos( self:GetParent():GetWide() - 45 * 15 - 6, 3 )
	if ulibcheck then self.lblTeam:SetPos( self:GetParent():GetWide() - 45 * 10.2 - 6, 3 ) end
	if utimecheck then self.lblHours:SetPos( self:GetParent():GetWide() - 45 * 7.5 - 6, 3 ) end
	self.lblFrags:SetPos( self:GetParent():GetWide() - 45 * 4.4 - 6, 3 )
	self.lblDeaths:SetPos( self:GetParent():GetWide() - 45 * 3.4 - 6, 3 )
	self.lblRatio:SetPos( self:GetParent():GetWide() - 45 * 2.4 - 6, 3 )
	self.lblPing:SetPos( self:GetParent():GetWide() - 45 - 6, 3 )
end

/*---------------------------------------------------------
   Name: HigherOrLower
---------------------------------------------------------*/
function PANEL:HigherOrLower( row )
	if self.Player:Team() == TEAM_CONNECTING then return false end
	if row.Player:Team() == TEAM_CONNECTING then return true end
	
	if self.Player:Team() ~= row.Player:Team() then
		return self.Player:Team() < row.Player:Team()
	end
	
	if ( self.Player:Frags() == row.Player:Frags() ) then
	
		return self.Player:Deaths() < row.Player:Deaths()
	
	end

	return self.Player:Frags() > row.Player:Frags()
end

vgui.Register( "suiscoreplayerrow", PANEL, "DButton" )