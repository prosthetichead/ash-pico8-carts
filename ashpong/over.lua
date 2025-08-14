function init_over()
    timer = 0
    nhs = false
    if last_score > high_score then
        high_score = last_score
        nhs = true
    end
end

function update_over()
    timer += 1/60 
    if timer > 20 then
        state = ST.title
        init_game()        
    end
    if btnp(4) then
        state = ST.title
        init_title()
    end
end

function draw_over()
    cls(1)
    if(nhs) then
        print("new high score!", 30, 5, 11)
    end
    
    print("high score: " .. high_score, 30, 15, 7)
    
    print("game over", 40, 40, 7)
    print("press ❎ to restart", 30, 50, 7)
end