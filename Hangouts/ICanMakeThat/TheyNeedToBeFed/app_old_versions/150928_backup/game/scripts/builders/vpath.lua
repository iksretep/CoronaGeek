-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2015 
-- =============================================================
-- 
-- =============================================================
local common 	= require "scripts.common"

local builder = {}

-- =============================================
-- The Builder (Create) Function
-- =============================================
function builder.create( layers, data )
	local aPiece

	-- Create an object (basic or pretty) to represent this world object
	--
	if( common.niceGraphics ) then
		aPiece = display.newImageRect( layers.content, "images/kenney/elementMetal001.png", common.blockSize, common.blockSize )
		aPiece.x = data.x
		aPiece.y = data.y
	else
		aPiece = display.newCircle( layers.content, data.x, data.y, common.blockSize/2 )
		aPiece.strokeWidth = 4
		aPiece:setStrokeColor(0,0,0)
	end

	-- If debug mode is enabled, add a label for showing 'distance to'
	--
	if( common.debugEn ) then	
		-- debug label to show distance to player
		aPiece.debugLabel = display.newText( layers.content, "TBD", data.x, data.y + common.blockSize/3, native.systemFontBold, 18 )
		aPiece.debugLabel:setFillColor(1,0,0)
	end

	-- Add a physics body to our world object and use the appropriate filter from the 'collision calculator'
	--
	local physics = require "physics"
	physics.addBody( aPiece, "static", 
		             { density = 1, bounce = 0, friction = 1, radius = common.blockSize/2,
		               filter = common.myCC:getCollisionFilter( "platform" ) } )

	-- This is a platform object, so add it to the 'common.pieces' list.  The player scans this list for nearby 'gravity' objects.
	--
	common.pieces[#common.pieces+1] = aPiece


	-- Draw A Path (based on subtype)
	--
	local points = {}
	if( data.subtype == 1 ) then
		points[1] = { y = aPiece.y, x = aPiece.x }
		points[2] = { y = aPiece.y + common.gapSize, x = aPiece.x }

	elseif( data.subtype == 2 ) then
		points[1] = { y = aPiece.y - common.gapSize, x = aPiece.x }
		points[2] = { y = aPiece.y, x = aPiece.x }

	elseif( data.subtype == 3 ) then
		points[1] = { y = aPiece.y - common.gapSize, x = aPiece.x }
		points[2] = { y = aPiece.y + common.gapSize, x = aPiece.x }

	elseif( data.subtype == 4 ) then
		points[1] = { y = aPiece.y + common.gapSize, x = aPiece.x }
		points[2] = { y = aPiece.y, x = aPiece.x }

	elseif( data.subtype == 5 ) then
		points[1] = { y = aPiece.y, x = aPiece.x }
		points[2] = { y = aPiece.y - common.gapSize, x = aPiece.x }

	elseif( data.subtype == 6 ) then
		points[1] = { y = aPiece.y + common.gapSize, x = aPiece.x }
		points[2] = { y = aPiece.y - common.gapSize, x = aPiece.x }
	end

	for i = 2, #points do
		local tmp
		if( data.subtype < 4 ) then
			tmp = display.newLine( layers.content,points[i-1].x, points[i-1].y-2, points[i].x, points[i].y+2 )
		else
			tmp = display.newLine( layers.content,points[i-1].x, points[i-1].y+2, points[i].x, points[i].y-2 )
		end

		tmp.strokeWidth = 7
		tmp:setStrokeColor(0.9,0.9,0.9)
		local tmp = display.newLine( layers.content,points[i-1].x, points[i-1].y, points[i].x, points[i].y )
		tmp.strokeWidth = 3
		tmp:setStrokeColor(0.5,0.5,0.5)
	end

	-- Follow the path
	--
	local function followPath( obj, path, speed )
		obj.x = path[1].x
		obj.y = path[1].y
		local dir = 1
		local nextNode = 2
		local onNextNode
		local function calculateTime( curNode, nextNode )
			local node1 = path[curNode]
			local node2 = path[nextNode]
			local vx = node1.x - node2.x
			local vy = node1.y - node2.y
			local len = math.sqrt( vx * vx + vy * vy )
			local time = 1000 * len / speed
			return time
		end
		onNextNode = function( self )		
			local curNode
			if( dir == 1 ) then
				curNode = nextNode
				nextNode = nextNode + 1
				if( nextNode > #path ) then
					nextNode = curNode - 1
					dir = -1 * dir
				end
			else
				curNode = nextNode
				nextNode = nextNode - 1
				if( nextNode < 1) then
					nextNode = curNode + 1
					dir = -1 * dir
				end
			end
			transition.to( obj, { x = path[nextNode].x, y = path[nextNode].y, time = calculateTime( curNode, nextNode ), onComplete = onNextNode } )
		end
		transition.to( obj, { x = path[nextNode].x, y = path[nextNode].y, time = calculateTime( 1, nextNode ), onComplete = onNextNode } )
	end

	followPath( aPiece, points, common.pathSpeed )


	-- Put the platform in front of the path
	--
	aPiece:toFront()

	-- Return a reference to this object 
	--
	return aPiece
end

return builder