pico-8 cartridge // http://www.pico-8.com
version 43
__lua__

function _init()
	t = 0
	directions = {
		{0, -8}, -- up
		{0, 8},  -- down
		{-8, 0}, -- left
		{8, 0}   -- right
	}
	plr = {
		gx = 0,
		gy = 0,
		gold = 20,
		menu=false,
	}
 
 	--setup grid
	rows = 14
	cols = 15
	grid = {}
	
	for i = -1, cols+1 do
		grid[i] = {}
		for j = -1, rows+1 do
			grid[i][j]=copy_tbl(nothing)
		end
	end
end

function update_flow()    
	for x = -1, cols + 1 do
		for y = -1, rows + 1 do
 			grid[x][y].flow = 999 
  		end
 	end
 
	local q = {}
	local kx = flr(king.gx)
	local ky = flr(king.gy)
        
	grid[kx][ky].flow = 0
	add(q, {x=kx, y=ky})
	
	
	local head = 1
	while head <= #q do
		local curr = q[head]
		head += 1 
		for dir in all(directions) do
			local nx = curr.x + dir[1]/8 
			local ny = curr.y + dir[2]/8             
			if nx >= -1 and nx <= cols + 1 and ny >= -1 and ny <= rows + 1 then                
				local is_walkable = true
				if nx >= 0 and nx <= cols and ny >= 0 and ny <= rows then
					is_walkable = grid[nx][ny].walk
				else
					is_walkable = true
				end
			
				if is_walkable then
					local distflow = grid[curr.x][curr.y].flow + 1
					if distflow < grid[nx][ny].flow then
						grid[nx][ny].flow = distflow
						add(q, {x=nx, y=ny})
					end
				end
			end
		end
	end
end

function get_best_move(e)
	if not flow_grid[e.gx] then return {0,0} end
	
	local current_score = flow_grid[e.gx][e.gy]
	local best_dir = {0,0}
    
	for dir in all(directions) do
		local nx = e.gx + dir[1]/8
		local ny = e.gy + dir[2]/8
        
		if nx >= -1 and nx <= cols+1 and ny >= -1 and ny <= rows+1 then
			local score = flow_grid[nx][ny]
			if score < current_score then
				current_score = score
				best_dir = dir
			end
		end
	end

	return best_dir
end

function copy_tbl(obj)
 if type(obj) ~= "table" then
 	return obj
 end
 local new_tbl = {}
 for k, v in pairs(obj) do
  new_tbl[k] = copy_tbl(v)
 end
 return new_tbl
end

function _update()

	t += 1
 if (t > 30000) t = 0
 
 if(not plr.menu) then
  if(btnp(1)) then
  	plr.gx += 1
  elseif(btnp(0)) then
  	plr.gx -= 1
  elseif(btnp(2)) then
   plr.gy -= 1
  elseif(btnp(3)) then
   plr.gy += 1
  elseif(btnp(4)) then
  	reset_menu()
  	plr.menu=true
  end
  plr.gy = mid(0,plr.gy,rows)
  plr.gx = mid(0,plr.gx,cols)
 else
 	u_menu() 	
 end
 
 u_king()
 u_enemy()
end



function _draw()
	cls()
	
	for xi = 0, cols do
		for yi = 0, rows do
			cell = grid[xi][yi]
			spr(cell.current_anim[cell.frame], (xi)*8, (yi)*8,1,1,cell.filp_h)
			print(cell.flow,(xi)*8, (yi)*8,1)   
		end
 end    
	
	--draw player
	spr(1, plr.gx*8, plr.gy*8)
	
	print("♥"..king.hp, 1, 122, 10)
	print("$"..plr.gold, 25, 122, 10)	
	
	print("😐"..#enemies, 100, 122,10)
	
	d_king()

	if plr.menu then
		d_menu()
	end
end


-->8
--enemy

enemies = {}
enemy = {
	x=3,
	y=3,
	gx=-1,
	gy=-1,
	hp=10,
	speed=.2,
	anispeed=4,	
	state="walk_h",
	frame=0,
	idle={17},
	walk_h={20,21,20,22},
	walk_v={17,19,17,18},
	current_anim = {17},
	flip_h=false
}

function u_enemy()
	if t%100 == 0 then
		spawn_enemy()
	end
	for e in all(enemies) do
		
	end
end

function spawn_enemy()
	local dir = flr(rnd(4))+1
	local new_e = enemy
	
	if(dir==1) then --top
		new_e.gx=flr(rnd(cols))
		new_e.gy=-1
	elseif(dir==2) then --right
		new_e.gx=cols+1
		new_e.gy=flr(rnd(rows))
	elseif(dir==3) then --left
		new_e.gx=-1
		new_e.gy=flr(rnd(rows))
	else --bottom
		new_e.gx=flr(rnd(cols))
		new_e.gy=rows+1
	end
	new_e.x = new_e.gx * 8
	new_e.y = new_e.gy * 8
	add(enemies, new_e)
	
end	
	
-->8
--menu
options = {}
opto = {"build","sell","upgrade","info"}
optb = {"arrow","cannon","wall"}
opts = {"yes","no"}
optu = {"power","range","speed"}
opti = {"done"}

option = 1
choice = ""

function reset_menu()
	choice = ""
	option = 1
	options = opto
end

function u_menu()
	if(btnp(4)) then
		choice = choice..options[option]	
 	option = 1
 elseif(btn(5))then
 	plr.menu = false
 end
 if(btnp(3)) then
 	option+=1
 elseif(btnp(2)) then
  option-=1
 end
 option = mid(1,option,#options)
 
	if(choice == "build")then
		options = optb
	elseif(choice == "sell")then
		options = opts
	elseif(choice == "upgrade")then
		options = optu
	elseif(choice == "info")then
		options = opti
	elseif(choice == "infodone")then
		plr.menu = false
	elseif(choice == "buildwall")then
		grid[plr.gx][plr.gy] = copy_tbl(wall)
		plr.menu = false
	elseif(choice == "buildarrow")then
		grid[plr.gx][plr.gy] = copy_tbl(arrow_tower)
		plr.menu = false
	elseif(choice == "buildcannon")then
		grid[plr.gx][plr.gy] = copy_tbl(cannon_tower)
		plr.menu = false
	end
	
 
end

function d_menu()
	local x1, y1, x2, y2
	local pad = 3
	local lh = 7
	local g = 2
	local mw = 32
	local mh = (#options * lh) + (pad+1)	
	
	if plr.gx > (cols / 2) then
		x2 = (plr.gx*8) - g
		x1 = x2 - mw
	else
		x1 = (plr.gx*8)+7+g
		x2 = x1 + mw
	end
	if plr.gy > (rows / 2) then
		y2 = (plr.gy*8)+7 
  y1 = y2 - mh
 else
 	y1 = plr.gy*8
  y2 = y1 + mh
	end
	rectfill(x1, y1, x2, y2, 12)
	rect(x1, y1, x2, y2, 0)

	for i=1, #options do
		local ty = y1 + pad + ((i-1) * lh)
		print(options[i], x1 + pad, ty, 7)
		if option == i then
			spr(2, x1-5, ty-1)
		end
	end
end		
-->8
--towers
nothing = {
 name="nothing",
	idle_up = {3},
	state = "idle_up",
	current_anim = {3},
	flip_h = false,
	frame = 1,
	walk = true,
	flow = 999
}

wall = {
	wall="wall",
	idle_up = {4},
	state = "idle_up",
	current_anim = {4},
	flip_h = false,
	frame = 1,
	walk=false,
	flow = 999
}

cannon_tower = { 
	name="cannon tower",
	idle_up = {5},
	idle_right = {8},
	fire_up = {5,6,7},
	fire_right = {8,9,10},
	current_anim = {5},
	state = "idle_up",	
	frame = 1,
	flip_h = false,
	walk = false,
	lvl=1,
	kills=0,
	speed=1,
	splash=1,
	range=2,
	dmg=1,
	gold=10,
	flow = 999
}

arrow_tower = { 
	name="arrow tower",
	idle_up = {5},
	idle_right = {8},
	fire_up = {5,6,7},
	fire_right = {8,9,10},
	state = "idle_up",
	current_anim = {5},
	flip_h = false,
	frame = 1,
	walk = false,
	lvl=1,
	kills=0,
	speed=1,
	splash=0,
	range=5,
	dmg=1,
	gold=10,
	flow = 999
}
-->8
--king
king = {
	x=7*8,
	y=-1*8,
	gx=7,
	gy=7,
	tx=7*8,
	ty=7*8,
	hp=100,
	speed=.6,
	anispeed=4,	
	state="walk_h",
	frame=0,
	idle={17},
	walk_h={20,21,20,22},
	walk_v={17,19,17,18},
	current_anim = {17},
	flip_h=false,
	path=false;
}



function u_king()
	if t%100 == 0 and king.state=="idle" then
  
  		local dir = directions[flr(rnd(4)) + 1]
	
		local next_gx = flr((king.x + dir[1]) / 8)
		local next_gy = flr((king.y + dir[2]) / 8)
	
  		if next_gx >= 0 and next_gx <= cols and next_gy >= 0 and next_gy <= rows then  
			local cell = grid[next_gx][next_gy]
			if(cell.walk) then
				king.tx = flr(king.x + dir[1])
  				king.ty = flr(king.y + dir[2])  
  			end
  		end		
 	end
 
	if (flr(king.x) < king.tx) then
	 	king.x += king.speed
	 	king.state = "walk_h"
	 	king.flip_h = false
	elseif (flr(king.x) > king.tx) then 
		king.x -= king.speed
		king.state = "walk_h"
		king.flip_h = true
 	elseif (flr(king.y) < king.ty) then
 		king.y += king.speed
 		king.state = "walk_v"
	elseif (flr(king.y) > king.ty) then
	 	king.y -= king.speed
	 	king.state = "walk_v"
	else
		king.state = "idle"	
		king.path = true
	end

	if (king.path) then
		king.gx = king.x/8
		king.gy = king.y/8
		update_flow()
		king.path = false
	end

	king.current_anim=king[king.state]
	king.frame=flr(t / king.anispeed) % #king.current_anim + 1

end

function d_king()
	spr(king.current_anim[king.frame], king.x, king.y,1,1,king.flip_h)
end
__gfx__
000000007707707700110000bbbbbbbbb000000bb004400bb004400bb005500bb009700bb000970bb009700bb000000bb008800bb000000bb000000bb000000b
000000007000000701771000bbbbbbbb0545454006644660066446600661566006697660066696700669766006555d60068aa860066666600666666006666660
007007000000000017711110bbbbbbbb045454500664466006644660066516600669764006696670066976400665d66006555d6006555d600696965009696580
000770007000000787777771bbbbbbbb054545409994499906955960999449994444744044455517515474400695d9600665d6600665d66006555550055555a8
000770007000000787776110bbbbbbbb045454507777777799655699777777774444744044455157551474400665d6600695d9600695d96006555550055555a8
007007000000000087777100bbbbbbbb054545400664466076615667066446600669764006696670066976400695d9600665d6600665d6600696965009696580
000000007000000787776100bbbbbbbb04545450064444600775177006444460066976600666967006697660066666600695d9600695d9600666666006666660
000000007707707711111000bbbbbbbbb000000bb000000bb007700bb000000bb009700bb000970bb009700bb000000bb000000bb000000bb000000bb000000b
b000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666660000aa000000aa000000aa000000aa000000aa000000aa000006666000066660000666600006666000066660000666600000000000000000000000000
09696560000770000007700000077000000770000007700000077000067777600677776006777760067777600677776006777760000000000000000000000000
05555560005665000056650000566500000560000005600000056000678778766787787667877876677778766777787667777876000000000000000000000000
05555560005665000076650000566700000560000005700000566000677777766777777667777776677777766777777667777776000000000000000000000000
09696560007dd700000dd700007dd0000007d000000dd000007dd000676666766766667667666676677666666776666667766666000000000000000000000000
06666660000dd000000d50000005d000000dd0000005d000000d5000067777600677776006777760067777600677776006777760000000000000000000000000
b000000b000550000005000000005000000550000000500000050000067667600676000000006760067667600000676006760000000000000000000000000000
__map__
0403030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
