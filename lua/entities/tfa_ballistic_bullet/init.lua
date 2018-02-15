AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.Locked = false

function ENT:Initialize()

	self:SetModel( "models/bullets/w_pbullet1.mdl" )
	self:PhysicsInit( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	
	self:NextThink( CurTime() )
	
end

function ENT:Think()
	
	if self:GetNWVector( "InitalPos" ):Distance( self:GetPos() ) > 100 and not self.Locked then
		util.SpriteTrail( self, 1, Color( 244, 140, 66, 200 ), false, 0.75, 0.25, 0.01, 1, "trails/smoke.vmt")
	end
	self:NextThink( CurTime() )
	
end
