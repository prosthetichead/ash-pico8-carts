function init_game()
    ball = {
		x=64,
		y=64,
		a=0.33, -- angle in "turns": 1.0 = 360°, 0.25 = 90°
		spd=80,
		r=2,
        c=14, 
        hold=true
	}
    -- convert angle to velocity
    ball_a_to_v()

	pad = {
		x=64,
		y=120,
		w=20,
		h=5,
		spd=100,
		c=15
	}
	bricks = {}
	level = 1
	lives = 3
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
				hp=1
			})
			
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
        --release on button press
        if btnp(4) then
            ball.hold = false
            ball_a_to_v() -- convert angle to velocity
        end
    else
            --ball move
 	    ball.x+=ball.vx*dt
 	    ball.y+=ball.vy*dt
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
    end
    if ball.x+ball.r>128 then
        ball.x=128-ball.r
        ball.vx*=-1 
    end
    if ball.y-ball.r<9 then
        ball.y=9+ball.r 
        ball.vy*=-1 
    end
    
    --ball death
    if ball.y+ball.r>128 then
 	    --reset ball
 	    ball.hold = true
 	    lives-=1
 	    if lives<0 then
 		    init_over()
            state = ST.over
 	    end
    end	

	--paddle bounce
	if c_in_r(ball, pad) then
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
            score += 10
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

function draw_game()
    cls()
	--top info
	print("score:"..score, 2,2, 7)
	print("lives:", 85, 2, 7)
	for b=0,lives-1 do
		circfill((((2*2)+2)*b)+110, 4, 2, 7)
	end
	
	--bricks
	for brick in all(bricks) do
		if brick.hp > 0 then
			rectfill(brick.x, brick.y, brick.x+brick.w,brick.y+brick.h, brick.c)
			rect(brick.x, brick.y, brick.x+brick.w,brick.y+brick.h, 1)
		end
	end
	--paddle
	rectfill(pad.x, pad.y, pad.x+pad.w, pad.y+pad.h, pad.c)
	--ball
	circfill(ball.x, ball.y, ball.r, ball.c)
end