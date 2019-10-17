pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

--main
--FLAG
--	0 block
--	1 oneway platform
--	2 spike
--	3 player
--	4 enemies
--	5 coins
gm={}
enemies={}

function _init()
	gm=make_game_manager()
	gm:set_level(0)

end

function _update60()
	gm:update()
end

function _draw()
	cls()
	map(0,0,0,0,128,128)
	gm:draw()
end


--Manage level
function make_game_manager()
	local gm={}
	local timer=make_timer(60)
	gm.player={}
	gm.coin={}
	gm.kills={}
	gm.c_level=0
	gm.cam_x=0
	gm.cam_y=0
	gm.cam_x=0
	gm.cam_y=0
	gm.d_cam_x=0
	gm.d_cam_y=0

	--0	playing
	--1 player death
	--2	transition_death
	--3	death_screen
	--4	game_over
	--5	restart
	--6	finished
	gm.state=0

	--change level
	--@param level level number
	gm.set_level=function(self,level)
		self.state=0
		self.c_level=level
		enemies={}
		self.kills={}
		del(self,self.player)

		if level!=0 then
			self.change_level=true
		end

		if level==0 then
			self.cam_x=0
			self.cam_y=0

			--bat
			add(enemies,make_bat(68,80,20))
			add(enemies,make_bat(68,20,0))

			--skeleton
			add(enemies,make_skeleton(60,116))

			--coin
			self.coin=make_coin(116,28)

			--player must created last
			self.player=make_player(12,120)

		elseif level==1 then
			self.d_cam_x=128
			self.d_cam_y=0

			--bat
			add(enemies,make_bat(228,80,10))

			--skeleton
			add(enemies,make_spider(238,116))

			--coin
			self.coin=make_coin(188,28)

			--player must created last
			self.player=make_player(140,120)
		end
	end


	--flash all screen for one frame
	gm.flash_screen=function(self)
		rectfill(0,0,128,128,7)
	end


	--show death screen
	gm.death_screen=function(self)
		print('sacre bleu! you are death', (self.cam_x+16), (self.cam_y+58))
		print('press btn 5 to restart', (self.cam_x+24), (self.cam_y+68))

		if btn(5) then
			self.state=5
		end
	end


	--update game state machine
	gm.state_update=function(self)
		if self.state==0 then
			if not self.player.is_alive then
				self.state=1
			end
		elseif self.state==1 then
			self.state=2
			timer:reset()
			timer:start()
		elseif self.state==2 and timer.finished then
			self.state=3
		elseif self.state==5 then
			self:set_level(self.c_level)
		end
	end


	--update game draw state machine
	gm.state_draw=function(self)
		if self.state==0 then
			return
		elseif self.state==1 then
			self:flash_screen()
		elseif self.state==2 then
			return
		elseif self.state==3 then
			self:death_screen()
		end
	end


	--update game loop
	gm.update=function(self)
		if self.cam_x!=self.d_cam_x or self.cam_y!=self.d_cam_y then
			return
		end

		--update game state
		self:state_update()

		--timer
		timer:update()

		--player
		self.player:update()

		--coin
		self.coin:update(self.player)

		--kills for previous frames
		if self.kills then
			for kill in all(self.kills) do
				del(enemies,kill)
			end
			self.kill={}
		end
		--update remaining enemies
		for enemy in all(enemies) do
			enemy:update()
		end
	end


	--update graphics
	gm.draw=function(self)
		if self.cam_x<self.d_cam_x then
			self.cam_x +=2
			camera(self.cam_x, self.cam_y)
			return
		elseif self.cam_y<self.d_cam_y then
			self.cam_y +=2
			camera(self.cam_x, self.cam_y)
			return
		end


		--gm state management
		self:state_draw()

		if (self.state==3) return

		--player update
		self.player:draw()

		--coin
		self.coin:draw()

		--update enemies sprites
		for enemy in all(enemies) do
			enemy:draw()
		end
	end

	return gm
end

-->8
--character

--generic actor properties
--w: width
--h: height
--x: x pos
--y: y pos
function make_actor(w,h,x,y)
	local a={}
	
	--size
	a.w=w
	a.h=h
	a.flipx=false
	
	--movement
	a.x=x --x position
	a.y=y --y position
	a.dx=0 --x direction speed
	a.dy=0 --y direction speed
	a.max_dx=1 --x direction speed
	a.max_dy=2 --y direction speed
	
	-- physic
	a.lx=1 --look direction
	a.grav=0.20 --gravity
	a.speed=85 --accelaration
	a.air_dcc=0.85 --air decceleration

	--actor state
	a.is_attacking=false
	a.is_alive=true
	
	
	--set motion props
	--@param d direction
	a.motion=function(self,d)
		self.lx=d
		self.moving=true
		self.flipx=d==-1
	end
	

	--check for collision 
	--at multiple points 
	--along the bottom
	--of the sprite: 
	--left, center, and right.
	--collide with flag 0, 1
	a.collide_floor=function(self)
		if (self.dy<0) return false
		
		local landed=false

		for i=-(self.w/3),(self.w/3),2 do
			local tile=mget((self.x+i)/8,(self.y+(self.h/2))/8)
			local ty = flr(self.y+(self.h/2))%8

			--if the sup sprite has flag 0
			if fget(tile,0) or (fget(tile,1) and self.dy>=0 and ty<=1) then
				self.dy=0
				self.y=(flr((self.y+(self.h/2))/8)*8)-(self.h/2)
				self.grounded=true
				self.airtime=0
				landed=true
			end
		end
		
		return landed
	end
	
	
	--check for collision 
	--at multiple points 
	--along the side
	--of the sprite: 
	--bottom, center, and top.
	--collide with flag 0
	a.collide_side=function(self)
		local offset=self.w/3
		for i=-(self.w/3),(self.w/3),2 do
			if fget(mget((self.x+(offset))/8,(self.y+i)/8),0) then
				self.dx=0
				self.x=(flr(((self.x+(offset))/8))*8)-(offset)
				return true
			end
			if fget(mget((self.x-(offset))/8,(self.y+i)/8),0) then
				self.dx=0
				self.x=(flr((self.x-(offset))/8)*8)+8+(offset)
				return true
			end
		end
		return false
	end

	--check for collision 
	--at multiple points 
	--along the top
	--of the sprite: 
	--left, center, and right.
	--collide with flag 0
	a.collide_roof=function(self)
		for i=-(self.w/3),(self.w/3),2 do
			if fget(mget((self.x+i)/8,(self.y-(self.h/2))/8),0) then
				self.dy=0
				self.y=flr((self.y-(self.h/2))/8)*8+8+(self.h/2)
				self.jump_hold_time=0
			end
		end
	end


	--get collision rect
	--@return object
	a.rect=function(self)
		return get_rect(self.x,self.y,self.w,self.h)
	end
	
	return a
end


--create a player
--FLAG=3
--px -- x position
--py -- y position
--@return p new player
function make_player(px,py)
	local p=make_actor(8,8,px,py)
	local slash_ap=make_animation_player({
		["slash"]={
			ticks=4,
			frames={32,32,34},
			loop=false
		}
	},"slash")
	local ap=make_animation_player({
		["idle"]={
			ticks=1,
			frames={1},
			loop=true
		},
		["block"]={
			ticks=1,
			frames={2},
			loop=true
		},
		["attack"]={ --btn(4)
			ticks=4,
			frames={9,10,11,12},
			loop=false
		},
		["move"]={ --btn(0) and btn(1)
			ticks=4,
			frames={3,4,5,6},
			loop=true
		},
		["jump"]={ --btn(5)
			ticks=1,
			frames={7},
			loop=true
		},
		["fall"]={
			ticks=1,
			frames={8},
			loop=true
		},
		["death"]={
			ticks=1,
			frames={13},
			loop=true
		}
	},"idle")
	local hitbox=make_hitbox(10,10,enemies)
	local hurtbox=make_hurtbox(4,4,enemies)
	
	--player states
	p.is_blocking=false
	p.is_jumping=false
	p.slash_active=false
	
	
	--jump properties
	p.jump_speed=-1.8 --velocity
	p.jump_hold_time=0 --how long jump is held
	p.min_jump_pressed=5 --min time jump can be held
	p.max_jump_pressed=15 --max time jump can be held
	p.jump_btn_released=true
	p.grouned=false
	p.moving=false
	p.airtime=0


	--btn(5), should manage jump input
	p.jump_button={
		update=function(self)
			self.is_pressed=false
			
			if btn(5) then
				if not self.is_down then
					self.is_pressed=true
				end
				
				self.is_down=true
				self.ticks_down+=1
			else
				self.is_down=false
				self.is_pressed=false
				self.ticks_down=0
			end 
		end,
			
		--state
		is_pressed=false,	-- pressed this frame
		is_down=false,				-- currently down
		ticks_down=0					-- how long down
	}	

	
	--should make the player jump
	p.jump=function(self)
		if not self:collide_floor() then
			if self.dy<0 then
				ap:set_anim("jump")
			elseif self.dy>0 then
				ap:set_anim("fall")
			end
			self.grounded=false
			self.airtime+=1
		end
		
		if self.jump_button.is_down then
			
			local on_ground=(self.grounded or self.airtime<5)
			local new_jump_btn=self.jump_button.ticks_down<10
			
			if self.jump_hold_time>0 or (on_ground and new_jump_btn) then
				self.jump_hold_time+=1
				
				if self.jump_hold_time<self.max_jump_pressed then
					self.dy=self.jump_speed
				end
			end
		else
			self.jump_hold_time=0
		end
	end
	
	
	--btn(4) will make the player
	--attack
	p.attack_button={
		update=function(self)
			self.is_pressed=false
	
			if btn(4) then
				if not self.is_down then
					self.is_pressed=true
				end
				
				self.is_down=true
			else
				self.is_pressed=false
				self.is_down=false
			end
		end,
			
		--state
		is_pressed=false,
		is_down=false
	}	
	

	--play the player attack animation
	p.attack=function(self)
		if self.attack_button.is_pressed then
			ap:set_anim("attack")
			slash_ap:set_anim("slash")
			self.is_attacking=true
			self.slash_active=true
		elseif self.is_attacking and ap.finished then
			self.is_attacking=false
		end
		
	end
	
	
	--make player move left/right
	p.move=function(self)
		--left
		if btn(0) then
			self:motion(-1)
			self.dx=self.speed*self.lx
			ap:set_anim("move")
		--right
		elseif btn(1) then
			self:motion(1)
			self.dx=self.speed*self.lx
			ap:set_anim("move")
		else
			self.moving=false
			self.dx=0
			if self.grounded and not self.is_attacking then
				ap:set_anim("idle")
			end
		end
		
		--limit move speed
		self.dx=mid(-self.max_dx,self.dx,self.max_dx)
		self.x+=self.dx
		p:collide_side()
	end


	--gravity
	p.compute_gravity=function(self)
		if(self:collide_floor()==true) return
		self.dy+=self.grav
		self.dy=mid(-self.max_dy,self.dy,self.max_dy)
		self.y+=self.dy
	end	
	

	--encounter a deadly traps
	p.collide_traps=function(self)
		self.is_alive=not fget(mget((self.x/8),(self.y/8)),2)
	end
	
	--update game loop
	p.update=function(self)
		if not self.is_alive then
			ap:set_anim("death")
			self:compute_gravity()
			return
		end

		self:collide_traps()
		self:compute_gravity()
		self.jump_button:update()
		self:jump()
		self:collide_roof()
		self:move()
		self.attack_button:update()
		self:attack()

		--update animation player
		ap:play()

		hurtbox:update(self.x,self.y)
		if self.slash_active and self.is_alive then
			slash_ap:play()
			hitbox:update(self.x,self.y)
			if slash_ap.finished then
				self.slash_active=false
			end
		end
	end
	
	
	--game loop functions
	p.draw=function(self)
		local x=self.x
		local y=self.y
		local fx=self.flipx

		--player
		ap:draw(x,y,self.w,self.h,fx)
		-- hurtbox:draw(x,y)

		--slash
		if self.slash_active and self.is_alive then
			-- hitbox:draw(self.x,self.y)
			slash_ap:draw(x,y,16,16,fx)
		end
	end
	
	return p
end


--enemy
--create an enemy
--FLAG=4
--w -- width
--h -- height
--px -- x position
--py -- y position
--hu -- hurtbox object params {w,h}
--anims --anims object {lists, current}
--@return e new enemy
function make_enemy(name,w,h,px,py,hu,anims)
	local e=make_actor(w,h,px,py)
	
	--state
	e.ap=make_animation_player(anims.a,anims.c)
	e.name=name

	--make the enemies move
	e.fly=function(self)
		if (self.dist==0) return

		if self.dmax<=self.x and self.lx==1 then
			self.lx=-1
		elseif self.dmin>=self.x and self.lx==-1 then
			self.lx=1
		end
		
		self:motion(self.lx)
		self.dx=self.speed*self.lx
		--limit move speed
		self.dx=mid(-self.max_dx,self.dx,self.max_dx)
		self.x+=self.dx
	end


	--should detect pike nearby
	e.patrol=function(self)
		if self:collide_side() or self:detect_edge() then
			self.lx*=-1
		end
		
		self:motion(self.lx)
		self.dx=self.speed*self.lx
		--limit move speed
		self.dx=mid(-self.max_dx,self.dx,self.max_dx)
		self.x+=self.dx
	end

	--detect edge
	--@return bool check x+(look_direction*8), y-8
	e.detect_edge=function(self)
		local celx=(self.x+(self.lx*(self.w/2)))/8
		local cely=(self.y+(self.h/2))/8
		return fget(mget(celx,cely),2)
	end

	--update
	e.update=function(self)
		self.ap:play()
	end

	--draw
	e.draw=function(self)
		self.ap:draw(self.x,self.y,self.w,self.h,self.flipx)
	end
	
	return e
end


--Should fly from let to right
--with a specific distance
--px -- x position
--py -- y position
--@return b
function make_bat(px,py,dist)
	local b=make_enemy(
		"bat",
		8,
		8,
		px,
		py,
		{w=8,h=8},
		{
			a={
				["fly"]={
					ticks=5,
					frames={64,65,66,67,68},
					loop=true
				}
			},
			c="fly"
		}
	)

	b.dmin=px-dist
	b.dmax=px+dist
	b.speed=60
	b.max_dx=0.45
	b.dist=dist

	b.update=function(self)
		self:fly()
		self.ap:play()
	end

	return b
end


--Stay at the same positoin
--but fade away to hide in the dark
--px -- x position
--py -- y position
--@return g
function make_ghost(px,py)
	local g=make_enemy(
		"ghost",
		8,
		8,
		px,
		py,
		{w=8,h=8},
		{
			a={
				["idle"]={
					ticks=10,
					frames={80,80,81,81,82,82,83,83,84,84},
					loop=true
				}
			},
			c="idle"
		}
	)
	
	return g
end


--Move from left to right
--and change direction only
--when colliding a corner
--px -- x position
--py -- y position
--@return s
function make_spider(px,py)
	local s=make_enemy(
		"spider",
		8,
		8,
		px,
		py,
		{w=8,h=8},
		{
			a={
				["move"]={
					ticks=4,
					frames={96,97,98,99},
					loop=true
				}
			},
			c="move"
		}
	)

	s.max_dx=0.35

	s.update=function(self)
		self:patrol()
		self.ap:play()
	end

	return s
end


--Doesn't nothing beside
--beign spooky
--px -- x position
--py -- y position
--@return s
function make_skeleton(px,py)
	local s=make_enemy(
		"skeleton",
		8,
		8,
		px,
		py,
		{w=8,h=8},
		{
			a={
				["idle"]={
					ticks=6,
					frames={112,112,113,113,114,114},
					loop=true
				}
			},
			c="idle"
		}
	)
	
	return s
end


--Collecting coin let the player
--complete the level
--Flag 5
--@param px -- x position
--@param py -- y position
--@return s
function make_coin(px,py)
	local c=make_actor(8,8,px,py)
	local ap=make_animation_player({
		["idle"]={
			ticks=6,
			frames={128,129,129,130,130,131},
			loop=true
		}
	},"idle")


	--check if player is in the coin's rect collision
	c.update=function(self,player)
		ap:play()
		local box=get_rect(px,py,8,8)
		local pbox=player:rect()
		local x0=pbox.x0
		local y0=pbox.y0
		local x1=pbox.x1
		local y1=pbox.y1

		--player is top left corner is in the hitbox (x0,y0)
		--player is lower left corner is in the hitbox (x0,y1)
		--player is top right corner is in the hitbox (x1,y0)
		--player is lower right corner is in the hitbox (x1.y1)
		if collide_rect(box,x0,y0) or collide_rect(box,x0,y1) or collide_rect(box,x1,y0) or collide_rect(box,x1,y1) then
			printh("coin collected")
			gm.c_level+=1
			gm:set_level(gm.c_level)
			cls()
		end
	end

	--update graphics
	c.draw=function(self)
		ap:draw(px,py,8,8)
	end

	return c
end
-->8
--libs

--animation_player
--@param a anims table
--@param c current_anim
function make_animation_player(a,c)
	local ap={}

	--props
	ap.anims=a
	ap.current_anim=c
	ap.current_frame=1
	ap.anim_tick=0
	ap.finished=false

	--draw sprite
	--@param x position
	--@param y position
	--@param w width
	--@param h height
	--@param fx flipx
	ap.draw=function(self,x,y,w,h,fx)
		-- local a=self.anims[self.current_anim]
		local frame=self.anims[self.current_anim].frames[self.current_frame]
		spr(
			frame,
			x-(w/2),
			y-(h/2),
			w/8,h/8,
			fx,
			false
		)
	end
	

	--select new animation
	--@param anim string
	ap.set_anim=function(self,anim)
		if(anim==self.current_anim) return
		
		local a=self.anims[anim]
		self.anim_tick=a.ticks			
		self.current_anim=anim		
		self.current_frame=1
	end


	--should manage what kind of animation this is
	ap.play=function(self)
		if self.anims[self.current_anim].loop then
			self:loop()
		else
			self:once()
		end
	end


	--should play all the animation frame one
	ap.once=function(self)
		self.finished=false
		self.anim_tick-=1
		if self.anim_tick<=0 then
			local a=self.anims[self.current_anim]
			self.current_frame+=1
			
			self.anim_tick=a.ticks
			
			if self.current_frame>#a.frames then
				self.current_frame=1
				self.finished=true
			end
		end	
	end


	--loop throught all animation frame until a new animation
	ap.loop=function(self)
		self.finished=true
		self.anim_tick-=1
		if self.anim_tick<=0 then
			local a=self.anims[self.current_anim]
			self.current_frame+=1
			
			self.anim_tick=a.ticks--reset timer
			
			if self.current_frame>#a.frames then
				self.current_frame=1--loop
			end
		end	
	end
	return ap
end


--should damage an actor when colliding with a hurtbox
--@param w width
--@param h height
--@param t target
function make_hitbox(w,h,t)
	local hb={}
	hb.w=w
	hb.h=h


	--get collision rect
	--@return object
	hb.update=function(self,x,y)
		local box=get_rect(x,y,self.w,self.h)
		for target in all(t) do
			local ebox=target:rect()
			local x0=ebox.x0
			local y0=ebox.y0
			local x1=ebox.x1
			local y1=ebox.y1

			--enemy is top left corner is in the hitbox (x0,y0)
			--enemy is lower left corner is in the hitbox (x0,y1)
			--enemy is top right corner is in the hitbox (x1,y0)
			--enemy is lower right corner is in the hitbox (x1.y1)
			if collide_rect(box,x0,y0) or collide_rect(box,x0,y1) or collide_rect(box,x1,y0) or collide_rect(box,x1,y1) then
				add(gm.kills,target)
				printh("player kill a " ..target.name)
			end
		end
	end

	hb.draw=function(self,x,y)
		local r=get_rect(x,y,self.w,self.h)
		rect(r.x0,r.y0,r.x1,r.y1)
	end
	
	return hb
end


--represente the zone where an actor can 
--receive damage
--@param w width
--@param h height
function make_hurtbox(w,h)
	local hub={}
	hub.flag=f
	hub.w=w
	hub.h=h

	hub.update=function(self,x,y)
		local box=get_rect(x,y,self.w,self.h)
		local x0=box.x0
		local y0=box.y0
		local x1=box.x1
		local y1=box.y1
		for enemy in all(enemies) do
			local ebox=enemy:rect()

			if collide_rect(ebox,x0,y0) or collide_rect(ebox,x0,y1) or collide_rect(ebox,x1,y0) or collide_rect(ebox,x1,y1) then
				printh("player was killed by " ..enemy.name)
				gm.player.is_alive=false
			end
		end
	end

	hub.draw=function(self,x,y)
		local r=get_rect(x,y,self.w,self.h)
		rect(r.x0,r.y0,r.x1,r.y1)
	end
	
	return hub
end


--timer
--@param t nb of frame the timer should wait
function make_timer(wt,callback)
	local t={}
	t.wait_time=wt
	t.c_time=wt
	t.started=false
	t.finished=false


	--reset timer
	t.reset=function(self)
		self.c_time=self.wait_time
		self.finished=false
		self.started=false
	end

	
	--decrease timer
	t.start=function(self)
		if not self.started then
			self.started=true
		end
	end


	--decrease timer
	t.update=function(self)
		if (not self.started) return
		self.c_time-=1
		if self.c_time<=0 then
			self.finished=true
			self.started=false
		end
	end

	return t
end
-->8
--utils

--@return 
--	x0 The x coordinate of the upper left corner.
--	y0 The y coordinate of the upper left corner.
--	x1 The x coordinate of the lower right corner.
--	y1 The y coordinate of the lower right corner.
function get_rect(x,y,w,h)
	w=w/2
	h=h/2
	return {
		x0=x-w,
		y0=y+h,
		x1=x+w,
		y1=y-h
	}
end


-- Does the point is in the rect ?
-- @return bool
function collide_rect(box,x,y)
	return box.x0<=x and box.y0>=y and box.x1>=x and box.y1<=y
end
__gfx__
00000000070000000700000007000000007000000007000000700000070000000700000000070000000070000000000000000000000000000000000000000000
00000000070550000705500007055000007550000007500000755000070550000705500000755000000750000005500000055000000000000000000000000000
000000000602f000060244400602f0000062f0000006f0000062f000060244400602f0000602f0000062f0000002f0000002f000000000000000000000000000
00000000062244400622494006224440006244000026240000624400062249400622444001224440001244000022240000224440000000000000000000000000
0000000001d2494001d2444001dd4940001d49000021d400001d490001d2444001d2494000d2494000d249000021667700124940000000000000000000000000
0000000000dd444000ddd000000d4440000dd400000dd400000dd40000ddd00000dd444000dd444000ddd40000ddd40006dd444005f444000000000000000000
00000000002020000020200000022000000220000002200000022000002020000020200000202000002020000020200060202000022666700000000000000000
0000000000101000001010000001000000001000000100000000100000100000000010000010100000101000001010000010100022ddd2210000000000000000
d6666667d666bbbbbbbbbbbbbbbbbbbbbbb66667d66666670006700066ddd5555500000000000055000000000000000000000000000000000000000000000000
1d6666761d666b3bb3b3b3b333b3b3b333b666761d666676000670007666dd555555000000005555011000000000001000000000000000000000000000000000
11dddd6611dddd633133dd333333dd333133dd6611dddd660056600007666d505ddd55000055ddd5010000000000000000000000000000000000000000000000
11dddd6611dddd66113ddd63313ddd66113ddd6611dddd660056670007666d50dd666666666666dd000000000001100000001000000000000000000000000000
11dddd6611dddd6611dddd6611dddd6611dddd66016666d005d6667000766500d66666777766666d000000000001100000010000000000000000000000000000
11dddd6611dddd6611dddd6611dddd6611dddd660000000005d6667000066500d66670000007666d000000100000000000000000000000000000000000000000
100000d6100000d6100000d6100000d6100000d60000000055dd6667000760006677000000007766000001100100000000000000000000000000000000000000
0000000d0000000d0000000d0000000d0000000d00000000555ddd66000760006700000000000076000000000000000000000000000000000000000000000000
00000000777000000000000000000000dd666666666666770a2222a09442444994442449944444490a444444444444a000000000000000000000000000000000
00000066666600000000000000660000dd6666666666667712244441444244422444244424444442124444444444442100000000000000000000000000000000
0000000066666700000000000000000011dd66666666776612444441444222222222244422222222122222222222222100000000000000000000000000000000
0000000066666700000000000000070011dd66666666776601111110222111111111122211111111011111111111111000000000000000000000000000000000
000000000666677000000000000000701111dddddddd666600000000111000000000011100000000000000000000000000000000000000000000000000000000
007000000000077000000000000000701111dddddddd666600000000000000000000000000000000000000000000000000000000000000000000000000000000
007700000000077000000000000000701111dddddddd666600000000000000000000000000000000000000000000000000000000000000000000000000000000
007000000000077700000000000000071111dddddddd666600000000000000000000000000000000000000000000000000000000000000000000000000000000
007000000000077700000000000000071111dddddddd666600000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000777000000000000000001111dddddddd666600000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000777000000000000000001111dddddddd666600000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000777777000000000070000701111dddddddd666600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777000000000000007700110000000000dd6600000000000000000000000000000000000000000000000000000000000000000000000000000000
00007000007777000000000000777700110000000000dd6600000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000007777000000070077777000000000000000000dd00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000007777770000000000777700000000000000000000dd00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000110000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000011100111121001210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11000011001001000011110012111121011001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12100121111111110112811001128110001111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111110011281101218812100188100001281000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00128100000110001101101100011000001881000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00188100000000000000000000000000001881000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000660000005500000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700006666000055550000111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07787870066868600558585001181810000808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770066666600555555001111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700006666000055550000111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777000006660000055500000111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07770000066600000555000001110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00110000011110000001100000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111000011110000011110000111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111190008181900011111900111119000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00818110008281100008181100081811000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08282000028080000008282000008282000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007770000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777000000700000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000007770000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777000000000000707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07070700070707000277720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02777200027772000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00202000002020000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00707000007070000070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900009999000099990000aaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
099aaa90099a999009a999900aaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0999aa90099aa99009aa99900aaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0999aa90099aa99009aa99900aaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09999a900999aa9009aaa9900aaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900009999000099990000aaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0008080808080808080808080808000001010101010104040404000202020202000000000101020202020202000000000000000001010000000000000000000010101010100000000000000000000000101010101000000000000000000000001010101000000000000000000000000010101000000000000000000000000000
2020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000000000000000001010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000001a00000000000000001010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10001b0000000000000000000000001010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000260012121214242510000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000000026000000000000343510000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000002600000000000000001010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1027292929292b0000001a000000001010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10001a0000000000000000000000001010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000000000000000000010100000000000000000000000002a2810000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010242500000000000000000000001010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010343500001500150015000000001010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000000000000000000010100000000000000000000000002a2810000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000000000000000001010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000000000001112131010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101616161010121410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
