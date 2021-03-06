-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2015 
-- =============================================================
-- This content produced for Corona Geek Hangouts audience.
-- You may use any and all contents in this example to make a game or app.
-- =============================================================
local particleMgr = {}

local physics 			   = require "physics"
local common 			   = require "scripts.common"
local layersMaker		   = require "scripts.layersMaker"

local math2d 			   = require "plugin.math2d"

-- Localizations
local mRand             = math.random
local getTimer          = system.getTimer
local pairs             = pairs
local isValid           = display.isValid

local addVec			   = math2d.add
local subVec			   = math2d.sub
local diffVec			   = math2d.diff
local lenVec			   = math2d.length
local len2Vec			   = math2d.length2
local normVec			   = math2d.normalize
local vector2Angle		= math2d.vector2Angle
local angle2Vector		= math2d.angle2Vector
local scaleVec			   = math2d.scale
local mAbs              = math.abs

local freeParticles = { }
local usedParticles = { }

-- 
--	 reset()
-- 
function particleMgr.reset()
   while(#usedParticles > 0 ) do
      usedParticles[1]:release()
   end
end

-- 
--	 getCounts()
-- 
function particleMgr.getCounts()
   return #freeParticles, #usedParticles, #freeParticles + #usedParticles
end


-- 
--	 get()
-- 
function particleMgr.get()   
   local particle   
   
   -- Do we have a free particle ready to re-use?
   --
   
   --
   -- Yes - Grab it, and return it.
   if( #freeParticles > 0 ) then 
      particle = freeParticles[#freeParticles]
      table.remove( freeParticles, #freeParticles )
   
   --
   -- No - Create a new particle (line or circle as per setting in common.lua)
   else
      if( common.particleStyle == 1 ) then
         particle = display.newRect( 100000, 100000, 1, 1 )
      else
         particle = display.newCircle( 1, 1, 10 )
         particle.xScale = 0.05
         particle.yScale = 0.05
         particle.x = 100000
         particle.y = 100000
      end
      
      -- This method will 'clean up' the particle and put it into the 'unused' list
      -- when we are done with it.
      --
      -- This part is a bit costly, but should be cheaper than making new particles every time.
      --
      function particle.release(self)
         if( not isValid( self ) ) then return end
         if( not self.inUse ) then return end
         if( self.hasBody ) then
            self.hasBody = false
            physics.removeBody( self )               
         end
         self.x = 10000
         self.y = 10000
         self.inUse = false
         if( self.lastTimer ) then
            timer.cancel( self.lastTimer )
            self.lastTimer = nil
         end
         transition.cancel( self )
         self.onComplete = nil
         self.alpha = 1
         self.xScale = 1
         self.yScale = 1
         if( common.particleStyle == 1 ) then
         else
            self.strokeWidth = 0            
         end
         
         table.remove( usedParticles, table.indexOf( usedParticles, self ) )
         freeParticles[#freeParticles+1] = self
         display.currentStage:insert( self )
      end
   end
   particle.inUse = true
   usedParticles[#usedParticles+1] = particle
   return particle
end


return particleMgr