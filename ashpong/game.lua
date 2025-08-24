function init_game()
    ball = {
		x=64,
		y=64,
		a=0.33, -- angle in "turns": 1.0 = 360°, 0.25 = 90°
		spin=0,
		spin_rate=0.01, 
		spd=80,
		r=2,
        c=14, 
        hold=true,
		multi=1, -- multiplier for score
	}
    -- convert angle to velocity
    ball_a_to_v()

	pad = {
		x=64,
		y=115,
		w=24,
		h=8,
		spd=100,
		c=15
	}
	bricks = {}
	level = 1
	lives = 3
	score = 0
	
	load_level(level)

end

function load_level(idx)
	local lvl=lvls[idx]
	local oh=5 local ow=8
  	local ox=0 local oy=8

	for row=1,#lvl.layout do
		local line=lvl.layout[row]
		for col=1,#line do
			local ch=sub(line,col,col)
			local def=lveldefs[ch]
			if def != "." and def != nil then
				add(bricks,{
					x=ox+(col-1)*ow,
					y=oy+(row-1)*oh,
					w=ow,
					h=oh,
					c=def.c,
					hp=def.hp
				})
			end
		end
	end		 
end

function update_game()
    local dt = 1/60

    --hold ball
    if ball.hold then
        --move ball with paddle
        ball.x = pad.x + (pad.w / 2)
        ball.y = pad.y - ball.r-1
		ball.spin = 0
		ball.spin_rate = 0.01
        --release on button press
        if btnp(4) then
            ball.hold = false
            ball_a_to_v() -- convert angle to velocity
        end
    else
        --ball move
 	    ball.x+=ball.vx*dt
 	    ball.y+=ball.vy*dt
		ball.spin=(ball.spin+ball.spin_rate)%1
		ball.spin_rate*=0.995 -- gradual decay
    end


    --paddle move
	if btn(1) then
		pad.x+=pad.spd*dt
	end
	if btn(0) then
		pad.x-=pad.spd*dt
	end
	pad.x=mid(0,pad.x,128-pad.w)

	--wall bounce
    if ball.x-ball.r<0 then 
        ball.x=ball.r
        ball.vx*=-1
		ball.spin_rate += 0.01
    end
    if ball.x+ball.r>128 then
        ball.x=128-ball.r
        ball.vx*=-1 
		ball.spin_rate -= 0.01 
    end
    if ball.y-ball.r<9 then
        ball.y=9+ball.r 
        ball.vy*=-1 
		ball.spin_rate += 0.01
    end
    
    --ball death
    if ball.y+ball.r>128 then
 	    --reset ball
		ball.multi = 1
 	    ball.hold = true
 	    lives-=1
 	    if lives<0 then
            last_score = score
 		    init_over()
            state = ST.over
 	    end
    end	

	--paddle bounce
	if c_in_r(ball, pad) then
		ball.multi = 1
        --calculate where the ball hit the paddle
        local hit_pos = mid(-1, (ball.x - (pad.x+(pad.w/2))) / (pad.w/2), 1) 
        ball.a = 0.25 + -hit_pos * (0.1667+(rnd() - 0.5) * 0.02)
        ball_a_to_v()
	end
	
	--brick break
	for brick in all(bricks) do
		if c_in_r(ball, brick) 
				and brick.hp>0 then
			brick.hp -= 1			
            score += 10 * ball.multi
			ball.multi += 1
			--bounce ball
			if abs(ball.vy) > abs(ball.vx) then
				--hit top or bottom
				if ball.y < brick.y or ball.y > brick.y + brick.h then
					ball.vy *= -1
				else
					ball.vx *= -1
				end
			else
				--hit left or right
				if ball.x < brick.x or ball.x > brick.x + brick.w then
					ball.vx *= -1
				else
					ball.vy *= -1
				end
			end
		end
	end
end

function c_in_r(c,r)
	--get distance using c pos & clamp
	local dx = c.x - mid(r.x, c.x, r.x+r.w) 
	local dy = c.y - mid(r.y, c.y, r.y+r.h)
	--pythagoras magic
	return dx*dx + dy*dy <= c.r*c.r
end

function ball_a_to_v()
    --convert angle to velocity
    ball.vx = cos(ball.a)*ball.spd
    ball.vy = sin(ball.a)*ball.spd
end

function draw_ball(b)
	local r=b.r

	--circfill(b.x+1, b.y+1, b.r, 5)
	circfill(b.x, b.y, b.r, 6)
	circ(b.x,b.y,b.r,5)

  	-- rotating seam (thin line across the face)
  	local a=b.spin         -- 0..1 turn
  	local nx=cos(a)  local ny=sin(a)
  	line(b.x-nx*(r-1), b.y-ny*(r-1), b.x+nx*(r-1), b.y+ny*(r-1), 8)

  -- specular glint orbiting the edge (offset +90°)
  --local gx=b.x+cos(a+0.25)*(r-1)
  --local gy=b.y+sin(a+0.25)*(r-1)
  --pset(gx,gy,7)                   -- white (7)
  -- thicken the glint a touch
  --pset(gx-1,gy,7)

end

function draw_game()
    cls(1)
	--top info
	print("score:"..score, 2,2, 7)
	print("lives:", 85, 2, 7)
	for b=0,lives-1 do
		circfill((((2*2)+2)*b)+110, 4, 2, 7)
	end
	
	--bricks
	for brick in all(bricks) do
		if brick.hp > 0 then
			spr(1,brick.x,brick.y)
			--rectfill(brick.x, brick.y, brick.x+brick.w,brick.y+brick.h, brick.c)
			--rect(brick.x, brick.y, brick.x+brick.w,brick.y+brick.h, 1)
		end
	end
	
	
	--ball
	draw_ball(ball)

	--paddle
	spr(17,pad.x, pad.y)
	spr(18,pad.x+8, pad.y)
	spr(17,pad.x+16, pad.y,1,1,true)
	--rectfill(pad.x, pad.y, pad.x+pad.w, pad.y+pad.h, pad.c)
end