pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--main
function _init()	
	player=make_player(64,64,5)
end

function _update60()
	player:update()
end

function _draw()
	cls()
	player:draw()
	print(player.current_anim)
	print(player.moving)
end

-->8
--player

-- create a player
-- x -- x position
-- y -- y position
-- l -- lifes
-- @return p new player
function make_player(x,y,l)
	local p=make_actor(8,8,x,y)
	
	-- player properties
	p.score=0
	p.lives=l
	
	
	-- player states
	p.is_alive=true
	p.is_blocking=false
	p.is_jumping=false
	
	
	-- jump properties
	p.jump_speed=-1.75 	-- velocity
	p.jump_hold_time=0		--	how long jump is held
	p.min_jump_press=5		--	min time jump can be held
	p.max_jump_press=15	-- max time jump can be held
	p.jump_btn_released=true
	p.grouned=false
	p.moving=false
	p.airtime=0


	-- animations
	p.current_anim="idle"
	p.current_frame=1
	p.anim_tick=0
	p.flipx=false
	p.anims={
		["idle"]={
			ticks=1,
			frames={1}
		},
		["block"]={
			ticks=1,
			frames={2}
		},
		["move"]={
			ticks=2,
			frames={3,4}
		}
	}

	-- set new anims
	p.set_anim=function(self,anim)
		if(anim==self.current_anim) return
		
		local a=self.anims[anim]
		self.anim_tick=a.ticks			
		self.current_anim=anim		
		self.current_frame=1
	end


	-- update tick (anim frames)
	p.compute_tick=function(self)
		self.anim_tick-=1
		
		if self.anim_tick<=0 then
			self.current_frame+=1
			local a=self.anims[self.current_anim]
			
			self.anim_tick=a.ticks--reset timer
			
			if self.current_frame>#a.frames then
					self.current_frame=1--loop
			end
		
		end	
	end
	
	
	-- actions
	p.jump_button={}	
	
	-- make player move left/right
	p.move=function(self)
		local btn_left=btn(0)
		local btn_right=btn(1)
		
		if btn_left==true then
			self.dx-=self.acc
			self.moving=true
			self.flipx=true
			self:set_anim("move")
			btn_right=false
		elseif btn_right==true then
			self.dx+=self.acc
			self.moving=true
			self.flipx=false
			self:set_anim("move")
			btn_left=false
		else
			self.moving=false
			self.dx*=self.dcc
			self:set_anim("idle")
		end
		
		--limit walk speed
		self.dx=mid(-self.max_dx,self.dx,self.max_dx)
		self.x+=self.dx
		
	end
	
	
	-- update game loop
	p.update=function(self)
		self:move()
		self:compute_tick()
	end
	
	
	-- game loop functions
	p.draw=function(self)
		local a=self.anims[self.current_anim]
		local frame=a.frames[self.current_frame]
		spr(
			frame,
			self.x-(self.w/2),
			self.y-(self.h/2),
			self.w/8,self.h/8,
			self.flipx,
			false
		)
	end
	
	return p
end
-->8
--actor

-- generic actor properties
-- w: width
-- h: height
-- x: x pos
-- y: y pos
function make_actor(w,h,x,y)
	local a={}
	
	-- size
	a.w=w
	a.h=h
	
	-- movement
	a.x=x 					-- x position
	a.y=y 					-- y position
	a.dx=0					-- x direction speed
	a.dy=0					-- y direction speed
	a.max_dx=1	-- x direction speed
	a.max_dy=1	-- y direction speed
	
	-- physic
	a.grav=0.15 	-- gravity
	a.acc=0.05			-- accelaration
	a.dcc=0.8				-- deceleration
	a.air_dcc=1		-- air decceleration

	a.frame=0
	return a
end
__gfx__
00000000070000000700000000700000000700000700000007000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000070ff000070ff000007ff0000007f000070ff00007000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000060ff000060f4440006ff0000006f000060f4440060ff000000000000000000000000000000000000000000000000000000000000000000000000000
000000000622444006224940006244000006240006224940062f4440000000000000000000000000000000000000000000000000000000000000000000000000
0000000001d2494001d24440001d49000021d40001d2444001224940000000000000000000000000000000000000000000000000000000000000000000000000
0000000000dd444000ddd00000ddd40000ddd40000ddd00000dd44400ff444000000000000000000000000000000000000000000000000000000000000000000
000000000020200000202000000220000002200000202000002d2000022666700000000000000000000000000000000000000000000000000000000000000000
0000000000101000001010000001000000001000010100000010100022ddd2210000000000000000000000000000000000000000000000000000000000000000
