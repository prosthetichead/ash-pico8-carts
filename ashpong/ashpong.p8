pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--ashpong
--by ash

function _init()
	ball = {
		x=64,
		y=64,
		r=2,
		dx=rnd(2) - 1, --direction
		dy=rnd(2) - 1,
		spd=1 
	}
	pad = {
		x=64,
		y=120,
		w=20,
		h=5,
		spd=2,
		c=15
	}
	bricks = {}
	level = 1
	score = 0
	
	setup(16,12)
end

function setup(cols,rows)
	--width and height
	local oh=4 local ow=8
	--pos of first brick
	local ox=0 local oy=8

	for r=0,rows-1 do
		for c=0,cols-1 do
		 
			add(bricks,{
				x=ox+c*ow,
				y=oy+r*oh,
				w=ow,
				h=oh,
				c=11,
				hp=flr(rnd(3))+1
			})
		end
	end
	
end

function _update()
	--paddle move
	if btn(1) then
		pad.x+=pad.spd
	end
	if btn(0) then
		pad.x-=pad.spd
	end
	pad.x=mid(0,pad.x,128-pad.w)
	
	--ball move
 ball.x+=ball.dx
 ball.y+=ball.dy
	
	 -- wall bounce
  if ball.x-ball.r<0 then 
  	ball.x=ball.r
  	ball.dx*=-1
  end
  if ball.x+ball.r>128 then
   ball.x=128-ball.r
   ball.dx*=-1 
  end
  if ball.y-ball.r<0 then
   ball.y=ball.r 
   ball.dy*=-1 
  end
  
  
end

function _draw()
	cls()
	print("score:"..score)
	
	--bricks
	for brick in all(bricks) do
		rectfill(brick.x, brick.y, brick.x+brick.w,brick.y+brick.h, brick.c)
		rect(brick.x, brick.y, brick.x+brick.w,brick.y+brick.h, 1)
		--print(brick.hp,(brick.x+brick.w/2)-2, (brick.y+brick.h/2)-2, 1)
	end
	--paddle
	rectfill(pad.x, pad.y, pad.x+pad.w, pad.y+pad.h, pad.c)
	--ball
	circfill(ball.x, ball.y, ball.r, 7)
end	
__gfx__
00000000004444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000004a444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000aaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000a1aa1a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000aa44aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000a4ee4a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
