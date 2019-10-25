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
explosions={}
--sounds
snd={
	jump=0,
	slash=1,
	death=2,
	coin=3,
	explosion=4
}

function _init()
	music(0)
	gm=make_game_manager()
	gm:main_menu()
	-- gm:set_level(11)
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
	local death_screen_timer=make_timer(60)
	local win_timer=make_timer(60)
	local spawn_timer=make_timer(20)
	gm.txt_blink_i=0
	gm.txt_blink=false
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
	gm.cam_speed=2

	--0	playing
	--1 player death
	--2	transition_death
	--3	death_screen
	--4	game_over
	--5	restart
	--6	main menu
	--7	end screen
	--8	transition to main menu
	gm.state=6

	--change level
	--@param level level number
	gm.set_level=function(self,level)
		spawn_timer:reset()
		spawn_timer:start()
		enemies={}
		self.state=0
		self.c_level=level
		del(self, kills)
		del(self,self.player)
		self.kills={}
		sfx(snd.coin)

		for enemy in all(enemies) do
			del(enemies,enemy)
		end

		if level!=0 then
			self.change_level=true
		end

		if level==0 then--x[0,128] y[0,128]
			self.cam_x=0
			self.cam_y=0

			add(enemies,make_bat(68,80,{x=20,y=0}))
			add(enemies,make_bat(68,20,{x=0,y=0}))
			add(enemies,make_skeleton(60,116))
			self.coin=make_coin(116,28)
			self.player=make_player(12,120)

		elseif level==1 then--x[128,256] y[0,128]
			self.d_cam_x=128
			self.d_cam_y=0

			add(enemies,make_bat(228,80,{x=10,y=0}))
			add(enemies,make_spider(238,116))
			add(enemies,make_ghost(212,20))
			self.coin=make_coin(244,28)
			self.player=make_player(140,120)
		elseif level==2 then--x[256,384] y[0,128]
			self.d_cam_x=256
			self.d_cam_y=0

			add(enemies,make_ghost(273,92))
			add(enemies,make_ghost(273,44))
			add(enemies,make_ghost(337,92))
			add(enemies,make_ghost(337,44))
			self.coin=make_coin(372,116)
			self.player=make_player(268,120)
		elseif level==3 then--x[384,512] y[0,128]
			self.d_cam_x=384
			self.d_cam_y=0

			add(enemies,make_spider(473,44))
			add(enemies,make_spider(450,92))
			add(enemies,make_spider(490,116))
			self.coin=make_coin(396,20)
			self.player=make_player(408,120)
		elseif level==4 then--x[512,640] y[0,128]
			self.d_cam_x=512
			self.d_cam_y=0

			add(enemies,make_ghost(544,70))
			add(enemies,make_bat(568,70,{x=0,y=10}))
			add(enemies,make_ghost(593,70))
			self.coin=make_coin(628,75)
			self.player=make_player(524,75)
		elseif level==5 then--x[640,768] y[0,128]
			self.d_cam_x=640
			self.d_cam_y=0

			add(enemies,make_spider(700,108))
			add(enemies,make_skeleton(674,100))
			add(enemies,make_bat(664,34,{x=0,y=10}))
			add(enemies,make_bat(688,34,{x=0,y=14}))
			add(enemies,make_bat(733,90,{x=0,y=18}))
			self.coin=make_coin(652,28)
			self.player=make_player(652,100)
		elseif level==6 then--x[768,896] y[0,128]
			self.d_cam_x=768
			self.d_cam_y=0

			add(enemies,make_skeleton(788,44))
			add(enemies,make_skeleton(796,52))
			add(enemies,make_skeleton(804,60))
			add(enemies,make_skeleton(812,68))
			add(enemies,make_skeleton(820,76))
			add(enemies,make_skeleton(828,84))
			add(enemies,make_skeleton(836,92))
			add(enemies,make_skeleton(844,100))
			add(enemies,make_skeleton(852,108))
			add(enemies,make_skeleton(860,116))
			add(enemies,make_skeleton(868,116))
			add(enemies,make_skeleton(876,116))
			self.coin=make_coin(884,116)
			self.player=make_player(780,36)
		elseif level==7 then--x[896,1024] y[0,128]
			self.d_cam_x=896
			self.d_cam_y=0

			add(enemies,make_bat(924,32,{x=16,y=0}))
			add(enemies,make_bat(968,64,{x=0,y=44}))
			add(enemies,make_bat(996,64,{x=0,y=36}))

			self.coin=make_coin(1012,76)
			self.player=make_player(906,8)
		elseif level==8 then--x[896,1024] y[128,256]
			self.d_cam_x=896
			self.d_cam_y=128

			add(enemies,make_spider(916,188))
			add(enemies,make_spider(961,188))
			add(enemies,make_bat(948,220,{x=0,y=12}))
			self.coin=make_coin(908,228)
			self.player=make_player(908,132)
		elseif level==9 then--x[768,896] y[128,256]
			self.d_cam_x=768
			self.d_cam_y=128

			self.coin=make_coin(780,236)
			self.player=make_player(884,132)
		elseif level==10 then--x[640,768] y[128,256]
			self.d_cam_x=640
			self.d_cam_y=128

			add(enemies,make_bat(705,168,{x=28,y=0}))
			add(enemies,make_spider(715,244))
			add(enemies,make_spider(695,244))
			add(enemies,make_ghost(656,212))
			add(enemies,make_ghost(752,212))
			add(enemies,make_ghost(656,164))
			add(enemies,make_ghost(752,164))

			self.coin=make_coin(705,147)
			self.player=make_player(705,197)
		elseif level==11 then--x[640,768] y[128,256]
			self.cam_x=0
			self.cam_y=0

			self.state=7
			gm:ending()

		end
	end


	--main menu
	gm.main_menu=function(self)
		if self.txt_blink_i>30 then
			self.txt_blink=not self.txt_blink
			self.txt_blink_i=0
		end
		self.txt_blink_i+=1

		local author="by levrault"
		local new_game="press \x97 to start a new game"
		print("a devtober game",10,10,9)
		spr(32,22,21,3,1)
		spr(96,23,29,10,4)
		spr(35,74,44,4,1)
		if self.txt_blink then
			print(new_game,hcenter(new_game),68,7)
		end
		print(author,hcenter(author),112,9)

		if btn(5) then
			if not win_timer.started or win_timer.finished then
				gm:set_level(0)
				self.state=0
			end
		end
	end


	--ending screen
	gm.ending=function(self)
		if self.txt_blink_i>30 then
			self.txt_blink=not self.txt_blink
			self.txt_blink_i=0
		end
		self.txt_blink_i+=1
		local title="you win!"
		local screen="press \x97 to go to main menu"
		local thanks="thanks for playing!"
		local devtober="a devtober game"
		local author="by levrault"

		print(title,hcenter(title),12,9)
		print(thanks,hcenter(thanks),18,9)
		if self.txt_blink then
			print(screen,hcenter(screen),68,7)
		end
		print(devtober,12,104,9)
		print(author,52,112,9)

		if btn(5) then
			win_timer:reset()
			win_timer:start()
			self.state=6
		end
	end


	--flash all screen for one frame
	gm.flash_screen=function(self)
		rectfill(0,0,128,128,7)
	end


	--show death screen
	gm.death_screen=function(self)
		print('sacre bleu! you are death', (self.cam_x+16), (self.cam_y+58), 7)
		print('press \x97 to restart', (self.cam_x+24), (self.cam_y+68), 7)

		if btn(5) then
			self.state=5
		end
	end


	--update game state machine
	gm.state_update=function(self)
		if self.state==0 then
			if not self.player.is_alive then
				sfx(snd.death)
				self.state=1
			end

			if self.player.is_spawning and spawn_timer.finished then
				self.player.is_spawning=false
			end
		elseif self.state==1 then
			self.state=2
			death_screen_timer:reset()
			death_screen_timer:start()
		elseif self.state==2 and death_screen_timer.finished then
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
		elseif self.state==6 then
			self:main_menu()
		elseif self.state==7 then
			self:ending()
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
		death_screen_timer:update()
		win_timer:update()
		spawn_timer:update()

		if self.state==6 or self.state==7 then 
			return
		end

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

		for explosion in all(explosions) do
			explosion:update()
		end
	end


	--update graphics
	gm.draw=function(self)
		if self.cam_x<self.d_cam_x then
			self.cam_x+=self.cam_speed
			camera(self.cam_x, self.cam_y)
			return
		elseif self.cam_y<self.d_cam_y then
			self.cam_y+=self.cam_speed
			camera(self.cam_x, self.cam_y)
			return
		elseif self.cam_x>self.d_cam_x then
			self.cam_x-=self.cam_speed
			camera(self.cam_x, self.cam_y)
			return
		elseif self.cam_y>self.d_cam_y then
			self.cam_y-=self.cam_speed
			camera(self.cam_x, self.cam_y)
			return
		else
			self.cam_x=self.d_cam_x
			self.cam_y=self.d_cam_y
			camera(self.cam_x, self.cam_y)
		end


		--gm state management
		self:state_draw()

		if (self.state==3 or self.state==6 or self.state==7) return

		print(stat(0),self.cam_x+10,self.cam_y+8)
		print(stat(1),self.cam_x+10,self.cam_y+16)
		print(stat(7),self.cam_x+10,self.cam_y+24)
		--player update
		self.player:draw()

		--coin
		self.coin:draw()

		--update enemies sprites
		for enemy in all(enemies) do
			enemy:draw()
		end

		for explosion in all(explosions) do
			explosion:draw()
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
	a.ly=1 --look direction
	a.grav=0.20 --gravity
	a.speed=65 --accelaration
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
			ticks=3,
			frames={76,76,78},
			loop=false
		}
	},"slash")
	local ap=make_animation_player({
		["idle"]={
			ticks=1,
			frames={1},
			loop=true
		},
		["attack"]={ --btn(4)
			ticks=4,
			frames={8,9,10,11},
			loop=false
		},
		["move"]={ --btn(0) and btn(1)
			ticks=4,
			frames={2,3,4,5},
			loop=true
		},
		["jump"]={ --btn(5)
			ticks=1,
			frames={6},
			loop=true
		},
		["fall"]={
			ticks=1,
			frames={7},
			loop=true
		},
		["death"]={
			ticks=1,
			frames={12},
			loop=true
		}
	},"idle")
	local hitbox=make_hitbox(11,11)
	local hurtbox=make_hurtbox(4,4)
	local cooldown=make_timer(30)
	
	--player states
	p.can_attack=true
	p.is_blocking=false
	p.is_jumping=false
	p.slash_active=false
	p.is_spawning=true
	p.max_dx=0.85 --x direction speed
	
	
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
			if (self.is_spawning) return

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

		if (self.is_spawning) return
		
		if self.jump_button.is_down then
			
			local on_ground=(self.grounded or self.airtime<5)
			local new_jump_btn=self.jump_button.ticks_down<10
			
			if self.jump_hold_time>0 or (on_ground and new_jump_btn) then
				if(self.jump_hold_time==0)sfx(snd.jump)--new jump snd
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
		if self.attack_button.is_pressed and self.can_attack then
			sfx(snd.slash)
			ap:set_anim("attack")
			slash_ap:set_anim("slash")
			cooldown:reset()
			cooldown:start()
			self.can_attack=false
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

		if not self.can_attack then
			cooldown:update()
			self.can_attack=cooldown.finished
		end

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
					frames={52,53,54,55,56},
					loop=true
				}
			},
			c="fly"
		}
	)

	b.x_dmin=px-dist.x
	b.x_dmax=px+dist.x
	b.y_dmin=py-dist.y
	b.y_dmax=py+dist.y
	b.dist=dist
	b.speed=60
	b.max_dx=0.45
	b.max_dy=0.45

	--make the enemies move
	b.fly=function(self)
		if self.dist.x !=0 then
			if self.x_dmax<=self.x and self.lx==1 then
				self.lx=-1
			elseif self.x_dmin>=self.x and self.lx==-1 then
				self.lx=1
			end

			self:motion(self.lx)
			self.dx=self.speed*self.lx
			self.dx=mid(-self.max_dx,self.dx,self.max_dx)
			self.x+=self.dx
			return
		end

		if self.dist.y !=0 then
			if self.y_dmax<=self.y and self.ly==1 then
				self.ly=-1
			elseif self.y_dmin>=self.y and self.ly==-1 then
				self.ly=1
			end
			
			self.moving=true
			self.dy=self.speed*self.ly
			self.dy=mid(-self.max_dy,self.dy,self.max_dy)
			self.y+=self.dy
		end
	end

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
					ticks=16,
					frames={57,57,58,59,60,61,61,61,61,61,61,60,59,58,57,57},
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
					frames={48,49,50,51},
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
					frames={13,13,14,14,15,15},
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
			frames={44,45,45,46,46,47},
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


--juicy effect when killing a enemy
function make_explosion(px,py)
	local e={}
	local ap=make_animation_player({
		["explosion"]={
			ticks=5,
			frames={64,66,68,70,72,74},
			loop=false
		}
	},"explosion")
	e.x=px
	e.y=py

	e.update=function(self)
		ap:play()
		if ap.finished then
			sfx(snd.explosion)
			del(explosions, self)
		end
	end

	e.draw=function(self)
		ap:draw(self.x,self.y,16,16,false)
	end

	return e
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

	
	--return current frames from anims array
	ap.get_current_frame=function(self)
		return self.anims[self.current_anim].frames[self.current_frame]
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
function make_hitbox(w,h)
	local hb={}
	local ap=make_animation_player({
		["explosion"]={
			ticks=5,
			frames={160,162,164,166,168,170},
			loop=false
		}
	},"explosion")
	hb.w=w
	hb.h=h


	--get collision recenemyt
	--@return object
	hb.update=function(self,x,y)
		local box=get_rect(x,y,self.w,self.h)
		for enemy in all(enemies) do
			if (enemy.name=="ghost") return
			local ebox=enemy:rect()
			local x0=ebox.x0
			local y0=ebox.y0
			local x1=ebox.x1
			local y1=ebox.y1

			--enemy is top left corner is in the hitbox (x0,y0)
			--enemy is lower left corner is in the hitbox (x0,y1)
			--enemy is top right corner is in the hitbox (x1,y0)
			--enemy is lower right corner is in the hitbox (x1.y1)
			if collide_rect(box,x0,y0) or collide_rect(box,x0,y1) or collide_rect(box,x1,y0) or collide_rect(box,x1,y1) then
				add(explosions,make_explosion(enemy.x,enemy.y))
				add(gm.kills,enemy)
				printh("player kill a " ..enemy.name)
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
				--only ghost has frame that can't hurt the player
				if enemy.name!="ghost" or enemy.ap:get_current_frame()!=61 then
					printh("player was killed by " ..enemy.name)
					gm.player.is_alive=false
				end

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


  -- screen center minus the
  -- string length times the 
  -- pixels in a char's width,
  -- cut in half
function hcenter(s)
  return 64-#s*2
end
__gfx__
00000000070000000700000000700000000700000070000007000000070000000007000000007000000000000000000000000000000000000077700000777000
00000000070550000705500000755000000750000075500007055000070550000075500000075000000550000005500000000000007770000007000000070000
000000000602f0000602f0000062f0000006f0000062f000060244400602f0000602f0000062f0000002f0000002f00000000000000700000077700000777000
00000000062244400622444000624400002624000062440006224940062244400122444000124400002224000022444000000000007770000000000007070700
0000000001d2494001dd4940001d49000021d400001d490001d2444001d2494000d2494000d24900002166770012494000000000070707000707070002777200
0000000000dd4440000d4440000dd400000dd400000dd40000ddd00000dd444000dd444000ddd40000ddd40006dd444005f44400027772000277720000202000
00000000002020000002200000022000000220000002200000202000002020000020200000202000002020006020200002266670002020000020200000202000
00000000001010000001000000001000000100000000100000100000000010000010100000101000001010000010100022ddd221007070000070700000707000
d6666667d666bbbbbbbbbbbbbbbbbbbbbbb66667d66666670006700066ddd55555000000000000550a2222a09442444994442449944444490a444444444444a0
1d6666761d666b3bb3b3b3b333b3b3b333b666761d666676000670007666dd555555000000005555122444414442444224442444244444421244444444444421
11dddd6611dddd633133dd333333dd333133dd6611dddd660056600007666d505ddd55000055ddd5124444414442222222222444222222221222222222222221
11dddd6611dddd66113ddd63313ddd66113ddd6611dddd660056670007666d50dd666666666666dd011111102221111111111222111111110111111111111110
11dddd6611dddd6611dddd6611dddd6611dddd66016666d005d6667000766500d66666777766666d000000001110000000000111000000000000000000000000
11dddd6611dddd6611dddd6611dddd6611dddd660000000005d6667000066500d66670000007666d000000000000000000000000000000000000000000000000
100000d6100000d6100000d6100000d6100000d60000000055dd6667000760006677000000007766000000000000000000000000000000000000000000000000
0000000d0000000d0000000d0000000d0000000d00000000555ddd66000760006700000000000076000000000000000000000000000000000000000000000000
00000000000000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000007070000000000000000000000000000000000000000000000000000000000000000000000999900009999000099990000aaaa00
007707000000000000000000070707070770007700700070077000000000000000000000000000000000000000000000099aaa90099a999009a999900aaaaaa0
0700000000000000000000000707070707070707070707070707000000000000000000000000000000000000000000000999aa90099aa99009aa99900aaaaaa0
0070070070070700700000000707070707070707077007070707000000000000000000000000000000000000000000000999aa90099aa99009aa99900aaaaaa0
00070707070707070700000007700077070700770077007007070000000000000000000000000000000000000000000009999a900999aa9009aaa9900aaaaaa0
00070707700707070000000000000000000000070000000000000000000000000000000000000000000000000000000000999900009999000099990000aaaa00
07700700770077070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001100001100077000000660000005500000011000000000000000000000000000
00000000000000000000000000000000000000000000000000000000111001111210012100777700006666000055550000111100000000000000000000000000
00000000001100000000000000000000110000110010010000111100121111210110011007787870066868600558585001181810000808000000000000000000
00110000011110000001100000011000121001211111111101128110011281100011110007777770066666600555555001111110000000000000000000000000
01111000011110000011110000111100011111100112811012188121001881000012810000777700006666000055550000111100000000000000000000000000
01111190008181900011111900111119001281000001100011011011000110000018810000777000006660000055500000111000000000000000000000000000
00818110008281100008181100081811001881000000000000000000000000000018810007770000066600000555000001110000000000000000000000000000
08282000028080000008282000008282000110000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000666600000000000006666000000000777000000000000000000000
00000000000000000000000000000000000000000000000066660077770000000066000d06666660006d0000000dddd600000066666600000000000000660000
000000000000000000700077700000000000aaaa770000006aaa7766dd7aaa000666600066666666060000000000000600000000666667000000000000000000
00000000000000000070777777700000000aaaaaad777000aaaaa6d6d6aaaaa00099900066669966000000000060000d00000000666667000000000000000700
0000000000000000000777777777700000aaaaaaaa667700aaaaaddd66aaaaa009aaa900d669aa9d00dd00000060000000000000066667700000000000000070
0000000110000000000777aaa777000000aaaaaaaa6677000aaa666dddaaaaa009aaa9000d69aa90000000000000099000700000000007700000000000000070
000000111100000000777aaaaa77700000aaaaaaaadd770007766666666aaa7009aaa66000dd9900000006000000000000770000000007700000000000000070
00000111111000000077aaaaaaa77000007aaaaaa666d700076666666666dd700099666600000000000060600000000000700000000007770000000000000007
00000111111000000077aaaaaaa770000076aaaad666d70007666aa66666dd700d00d66d0d000000000000000000000000700000000007770000000000000007
000000111100000000777aaaaa777000007dd6d66d6dd70007ddaaaa666ddd7000000dd060066600000000060000000000000000000077700000000000000000
0000000110000000000777aaa77700000007dd666aaa7000007ddaa666ddd7000000000000666660000000000000006000000000000077700000000000000000
000000000000000000077777777700000007d666aaaaa000007d66666ddd77000666000006666666000600000000006600070000077777700000000007000070
00000000000000000070777777700000000d67ddaaaaa00000677dddddd7760066666009066666666d0060000000066600000000077777000000000000007700
00000000000000000000007770007000000dd077aaaaa00000d677dddd776d006666609a9d66666d6d0d60000000066d00007000007777000000000000777700
00000000000000000000000000000000000000000aaa000000dd0077770dd000d666d00900d666d06dd00000000006d000000000077770000000700777770000
00000000000000000000000000000000000000000000000000000000000000000ddd0000000ddd000660000000000d0000000077777700000000007777000000
7770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dd66666666666677
7170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dd66666666666677
717000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011dd666666667766
717000007777770007777770777777000777770077777000777777007777777077777700077777700000000000000000000000000000000011dd666666667766
71700000711117707711117071111770771117077111700071111777711111707111177077111177000000000000000000000000000000001111dddddddd6666
71700000777771707177777077777170717777071777700077777177177711707177711771777717000000000000000000000000000000001111dddddddd6666
71700007711111707170000771111170771117777111770771111177171711707170711771711717000000000000000000000000000000001111dddddddd6666
71700007177771707170000717777170007771700777170717777177171711707170711771777717000000000000000000000000000000001111dddddddd6666
71700007170071707170000717117170000071700007170717117177171711707170711771777777000000000000000000000000000000001111dddddddd6666
71777777177771707177777717777170777771777777170717777177177711707170711771111170000000000000000000000000000000001111dddddddd6666
71111170711111707711117071111170711117771111770071111177711111707170711777111170000000000000000000000000000000001111dddddddd6666
77777770077777700777777007777770777777077777700007777770777711707770777700777770000000000000000000000000000000001111dddddddd6666
0000000000000000000000000000000000000000000000000000000000071170000000000000000000000000000000000000000000000000110000000000dd66
0000000000000000000000000000000000000000000000000000000077771170000000000000000000000000000000000000000000000000110000000000dd66
000000000000000000000000000000000000000000000000000000007111177000000000000000000000000000000000000000000000000000000000000000dd
000000000000000000000000000000000000000000000000000000007777700000000000000000000000000000000000000000000000000000000000000000dd
__gff__
0008080808080808080808080808080801010101010104040404020202020202000000000000020202020202101010100808080808080808080808080800000000000000000000000000000000000000000000000000000000000000000000001010101000000000000000000000010110101000000000000000000000000101
2020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1000000000000000000000000000001010000000000000000000000000000010100000000000006e6f00000000000010100000000000000000000000000000101010101010101010101010101010101010000000000000000000000000000010100000000000000000000000000000101000000000006e6f0010101010100010
1000000000000000000000000000001010000000000000000000000000000010100000000000007e7f00000000000010100000000000000000000000000000101010101010101010101010101010101010000000000000000000000000000010100000000000000000000000000000101000000000007e7f0000101010000010
1000000000000000000000000000001010000000000000000000000000000010101b1c6e6f00006e6f1b1c6e6f00001010111212141011121212131400000010100000001710001010101010000000101000000000000000000000000000001010000000000000000000000000000010101b1f000000101000006e6f00000010
10000000000000001a00121212146e6f100000001500001500001500006e6f6e6f00007e7f00007e7f00007e7f000010100000000000000000000000001a0010100000000000000000101700000000101011000015000015000000000000001010000000000000000000000000000010100000000000101000007e7f00000010
1000000000001a000000000000007e7f100000000000000000000000007e7f7e7f00006e6f00006e6f00006e6f0000101000000000000000000000000000001010000000000000000000000000000010101500000000000000000000000000101010000000000000000000000000001010000000000000000000000000000010
10000000000000000000000000000010101b1f00000000000000000000000010101b1c7e7f00007e7f1b1c7e7f0000101000001a14161116101011121314101010000000000000000000000000000010100000000000000000150000000000101010100000000000000000000000001010000000000000000000000000000010
101b1d1d1d1d1f000000000000000010100000000000000000000000000000101000006e6f00006e6f00006e6f00001010000000101010101010101010101010100000000000000000000000000000101000000000000000000000000000001010101010000000000000000000000010100000001e1c6e6f00006e6f00000010
10000000000000000000000000000010101000000000000000000000000000101000007e7f00007e7f00007e7f00001010001a000000000000000000000000101000000000000000000000000000001010000000000000000000001e1d1d1c10101010101000000000000000000000101000000000007e7f00007e7f00000010
10000000000000000000000000000010106e6f00000000000000000000000010101b1c6e6f00006e6f1b1c6e6f000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010101010101010000000000000000000101000000000006e6f0000101000000010
10106e6f000000000000000000000010107e7f000000000000000000000000101000007e7f00007e7f00007e7f000010100000001010000000000000000000101010100000100000100000100000101010000000000000000000000000000010101010101010100000000000000000101000000000007e7f0000101000001a10
10107e7f000015001500150000000010101010101010101000001a00000000101000006e6f00006e6f00006e6f000010106e6f101010100000001010101a00101010100000100000100000100000101010000000000000000000000000150010101010101010101000000000000000101016000000006e6f0000101000000010
10000000000000000000000000000010100000000000000000000000001a0010101b1c7e7f00007e7f1b1c7e7f000010107e7f101010101112141010100000101010100000100000100000100000101010000000000000000000000000000010101010101010101010000000000000101010160000007e7f0000101000000010
100000000000000000000000000000101000000000000000000000000000006e6f00006e6f0000000000006e6f00001010000000000000000000000000001a101010100000100000100000100000101010101113131410000010110000000010101010101010101010100000000000101010100000006e6f0000101000000010
100000000000000000000000111213101000000000000000000000000000007e7f00007e7f0000000000007e7f000010100000000000000000000000000000101010100000100000100000100000101010101010101010111410101016161610101010101010101010101000000000101010101616167e7f1616101016161610
10101010101010101010101010101010101112121410111416161410101214101010106e6f1010161610106e6f1010101010101010101016101610101010101010101016161016161016161016161010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010107e7f1010101010107e7f1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000010100000000010100000000010
1000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000101010100010100000000010100000000010
1000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000111212131212121313140000101000000000000000000000000000001010100010100010100010100010100010
1000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000100000000000000000100000101000000000000000000000000000001010100010101a10100010101a10100010
1000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010101b1c100000000000000000101b1c101000001600000000000000000000001010100010100010100010100010100010
100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000010000010101a100000100000101000191018000000001515150000001010100010101a10100010101a10100010
1000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000100000100000100000100000101000001700000000000000000000001010100000000010100000000010100010
1000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010101b1c100000100000100000101b1c101000000000000016000000001600001010101010101010101112121410100010
1000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000100000111213140000100000101000000000001910180000191018001010101010000000000000000000000010
1000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000100000000000000000100000101000000000000017000000001700001010000000000000000000000000000010
1000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010101b1c101010100000101010101b1c101000000000000000000000000000001010000000000000000000000010161010
1000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000001700000000000017000000101000000000000000000000000000001010000000000000000010111610101010
10000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010101010101600001114101010106e6f10
10000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101011000000000011140000000000141010101116161616161616161616161610101010101016161010101010107e7f10
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
__sfx__
00060000190611c0511f0412203100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000016100d6111b61131611146110c6110861105611026100810000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001d1431d1331d1231d1131c0001a000180000a0001500012000100000e0000d0000b0000700005000030000000001000010000400003000020000100000000000002c0000000000000000000000000000
0004000021525265352060024600286002d6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002763022631206211b6211661115611116110d6110b6100761005610036100261002610026100261001610016100161500000000000000000000000000000000000000000000000000000000000000000
01180000021100211002110021120e1140e1100e1100e1120d1140d1100d1100d1120d1120940509110091120c1100c1100c1100c1120b1110b1100b1100b1120a1100a1100a1100a11209111091100911009112
01180000117201172011722117221d7201d7201d7221d7221c7211c7201c7201c7201c7221c72218720187221b7211b7201b7201b7201b7221b7221d7221d7221a7201a7201a7201a7201a7221a7221672016722
011800001972019720197221972218720187201872018720147201472015720157201f7211f7201d7201d7201c7201c7201c7221c7221a7201a7201a7221a7251a7201a7201a7221a72219721197201972219722
011800001a7201a7201a7221a7221c7201c7201c7221c7221e7201e7202172021720247212472023720237202272022720227202272022722227221f7201f7202272122720227202272221721217202172221722
0118000002114021100211002112091140911009110091120e1140e1100c1100c1120911209110081100811207110071100711007112061110611006110061120111101110011100111202111021100211002112
0118000020720207202072220722217202172021722217222b7212b72029720297202872128720267202672526720267202672026720267222672228721287202672026720267202672225721257202572225722
__music__
01 05064344
00 05074344
00 05064344
00 05074344
02 0a094344
02 5d624344

