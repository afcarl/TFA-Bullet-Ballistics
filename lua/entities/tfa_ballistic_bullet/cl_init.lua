include('shared.lua')

ENT.CanEmitSound = true

function ENT:Initialize()
      self.CanEmitSound = true
      self.TracerGlowMat = Material( "effects/softglow.vmt" )
      self.TracerAlpha = 0
      self.TracerSize = 1
      
      self:NextThink( CurTime() )
end

function ENT:Draw()
      
      self:DrawShadow( false )
      
      self.InitalPos = self:GetNWVector( "InitalPos" )
      
      render.SetMaterial( self.TracerGlowMat )
      
      if self:GetPos():Distance( self.InitalPos ) > 100 then
            self.TracerAlpha = math.Clamp( self.TracerAlpha + ( FrameTime() * 200 ), 0, 255)
            self.TracerSize = math.Clamp( self.TracerSize + ( FrameTime() * 5 ), 1, 8)
      end
      
      render.DrawSprite( self:GetPos(), self.TracerSize, self.TracerSize, Color(244, 140, 66, self.TracerAlpha) )
      
end

function ENT:Think()

      if self:GetPos():Distance( LocalPlayer():GetPos() ) < 500 and self.CanEmitSound and self:GetOwner() != LocalPlayer() then
            sound.Play( "TFA_BALLISTICS.Crack", self:GetPos(), 97, 100, 1)
            timer.Simple( 0, function()
                  self.CanEmitSound = false
            end )
      end
      
      self:NextThink( CurTime() )

end
