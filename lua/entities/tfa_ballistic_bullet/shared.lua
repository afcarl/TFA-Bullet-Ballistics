AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable = false
ENT.Type = "anim"
ENT.PrintName		= "TFA Bullet with Ballistics"
ENT.Author			= "Daxble"
ENT.RenderGroup     = RENDERGROUP_OPAQUE
ENT.Locked = false
ENT.CanEmitSound = true
ENT.TracerGlowMat = Material( "effects/softglow.vmt" )
ENT.TracerMat = Material( "trails/smoke.vmt" )
ENT.TracerAlpha = 0
ENT.TracerSize = 1

function ENT:Initialize()

      self:NextThink( CurTime() )
      
end

function ENT:Draw()
      
      self:DrawShadow( false )
      
      self.InitalPos = self:GetNWVector( "InitalPos" )
      
      render.SetMaterial( self.TracerGlowMat )
      
      if self:GetPos():Distance( self.InitalPos ) > 250 then
            self.TracerAlpha = math.Clamp( self.TracerAlpha + ( FrameTime() * 200 ), 0, 255)
            self.TracerSize = math.Clamp( self.TracerSize + ( FrameTime() * 5 ), 1, 100)
            render.DrawSprite( self:GetPos(), self.TracerSize, self.TracerSize, Color(244, 140, 66, self.TracerAlpha) )
      end
      
end

function ENT:Think()
      
      self:DrawShadow( false )
      
      if CLIENT then
            if self:GetPos():Distance( LocalPlayer():GetPos() ) < 500 and self.CanEmitSound and self:GetOwner() != LocalPlayer() then
                  sound.Play( "TFA_BALLISTICS.Crack", self:GetPos(), 97, 100, 1)
                  timer.Simple( 0, function()
                        self.CanEmitSound = false
                  end )
            end
      else
            if self:GetNWVector( "InitalPos" ):Distance( self:GetPos() ) > 100 and not self.Locked then
      		util.SpriteTrail( self, 1, Color( 255, 140, 66, 200 ), false, 1, 0.01, 0.1, 1, "trails/smoke.vmt")
                  self.Locked = true
      	end
      end
      
      self:NextThink( CurTime() )

end