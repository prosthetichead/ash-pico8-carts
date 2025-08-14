ST={title=1, game=2, over=3}

function _init()
	state=ST.title
	init_title()

	high_score=0
	last_score=0
end

function _update60()
	if state==ST.title then 
		update_title() 
	elseif state==ST.game then 
		update_game()
	elseif state==ST.over then
		update_over()
	end
end

function _draw()
	if state==ST.title then 
		draw_title()
	elseif state==ST.game then 
		draw_game()
	elseif state==ST.over then
		draw_over()
	else
		cls(8) 	
		print("err state="..state)
	end
end


