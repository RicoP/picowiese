pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--constants
g_state_spawn = 1
g_state_run = 2
g_state_dead = 3

--globals
g_frame = 0
g_frame_ref = 0
g_state = g_state_run

--enemies
enemy_skull = 64

--tiles
tile_exit = 51

--player
p1 = {}
p_state_stand = 1
p_state_jump = 2
p_state_run = 3
p_jumpstrength = 10
p_walkspeed = 1

--flags
flag_ground=0
flag_instadeath=1
flag_hurt=2

--melons == bullets
melon_speed = 3
tile_melon = 32

--items
items = {}
item_health1 = 16

--entities
entities = {}
entity_explosion1 = 35

--enemies
enemies = {}
enemy_health = 40

--level
levels = {}
level = 1
-->8
-- native functions
#include utils.lua

--https://www.lexaloffle.com/bbs/?tid=2951
clone=function (o)
 if type(o) == 'table' then
  local c = {}
  for k, v in pairs(o) do
   c[k] = clone(v)   
  end
  return c
 else
  return o
 end
end

function clamp(v, mi, ma)
 if v < mi then return mi end
 if v > ma then return ma end
 return v
end

function _init()
 level = 1
 for y = 0,63 do
  for x = 0,127 do
   local t = mget(x,y)
   if t == p_state_stand then
    mset(x,y,0)
    local l = {}
    
    l.x,l.y = x*8,y*8
    levels[level] = l
    level += 1
   end
   if t == item_health1 then
    mset(x,y,0)
    create_item(t,x*8,y*8)
   end
   if t == enemy_skull then
    mset(x,y,0)
				local e = {}
				e.x,e.y = x*8,y*8
				e.tile = t				
    e.direction = -1
    e.groundlevel = e.y
    e.iframes = 0
    e.health = enemy_health
				add(enemies,e)    
   end
   if t == tile_turret then
    mset(x,y,0)
    local e = {}
				e.x,e.y = x*8,y*8
				e.tile = t				
    e.health = enemy_health
    e.iframes = 0
    e.time = 0
    e.state = "searching"
				add(enemies,e)        
   end
  end
 end
 
 select_level(1)
end

function item_logic(p)
	for i,item in pairs(items) do
  if item.tile == item_health1 then
   if abs(item.x-p.x) <= 4 and abs(item.y-p.y) <= 8 then
    p1.health += 20
    del(items, item) 
    sfx(2)
   end
  end
 end
end

function _update()
 --if (g_frame % 4) != 0 then return end
 
 camera()
 cls(1)
 cursor(11,5)
 btn_update()

 --item logic
 item_logic(p1)
 
 --enemy logic
 for e in all(enemies) do
  enemy_update(e,p1)
  if e.tile == tile_turret then
   turret_logic(e,p1)
  end
 end
 
 --entity logic
 for e in all(entities) do
  entity_update(e)
 end

 if g_state == g_state_run then
	 p1.state = p_state_stand 
	 hero_movement(p1)
 end
 
 if g_state == g_state_dead then
  if frame() == 60 then
   select_level(level)
  end
 end
 
 color(13)
 --print(#entities)
 --print(p.groundlevel)
 --print(p.x .. " " .. p.y)
 --print(p.health)
 --print(p.jumpvel)
 
 for e in all(enemies) do
  if e.tile == tile_turret then
   print(e.state)
  end
 end
  
end

function _draw()
 local camx=p1.x - 32
 local camy=flr(p1.y/128)*128
 if camx < 0 then camx=0 end
 camera(camx, camy)

 map()

 palt(0, false)
 palt(14, true)

 for i in all(items) do
  spr(i.tile, i.x, i.y)
 end

 for e in all(enemies) do
  if e.tile == tile_turret then
   turret_draw(e,p1)
  else
   enemy_draw(e)
  end
 end
 
 for e in all(entities) do
  entity_draw(e)
 end

 hero_draw(p1)
 
 palt(0, true)
 palt(14, false)
 
 --debug
 --pset(p.x, p.y, 8)
 --pset(p.x+7, p.y, 8)
 --pset(p.x, p.y+7, 8)
 --pset(p.x+7, p.y+7, 8)

 camera()

 --ui
 draw_healthbar(p1)

 for i = 1,15 do
  local g = calc_char_groundlevel(p1.x,8*i,8)
  --line(0, g, 128, g, i)
 end

 g_frame = g_frame + 1
end

-->8
-- logic
function next_row(tile, row)
 return tile + (16*row)
end

function select_level(l)
 level = l
 p1 = cstr_player(levels[l].x,levels[l].y)
 g_state = g_state_run
 g_frame = 0
end

function timer_reset()
 g_frame_ref = g_frame
end

function frame()
 return g_frame - g_frame_ref
end

function calc_groundlevel(x,y)
 local tx = flr(x/8)
 local ty = flr(y/8)
 local hero_tile=0
 repeat
  hero_tile = mget(tx,ty)
  if fget(hero_tile, flag_ground) or ty > 128 then
   break
  end  
  ty += 1
 until false
 return (ty-1)*8
end

function calc_char_groundlevel(x,y,w)
 local g0 = calc_groundlevel(x,y)
 local g1 = calc_groundlevel(x-1+w,y)
 return min(g0,g1)
end

function hurt_hero(damage, p)
 if p.iframes > 0 then return end
 p.stuned = 30
 p.iframes = 60
 p.health -= damage
 p.health = clamp(p.health,0,100)
 if p.health == 0 then
  kill_hero(p)
 else
  sfx(1)
 end
end

function kill_hero(p)
 g_state = g_state_dead
 timer_reset()
 
 p.health = 0
 
 for i=1,6 do
		local e = {}
		e.x,e.y = p.x,p.y
		if i==1 then e.velx,e.vely=2,1 end
		if i==2 then e.velx,e.vely=2,-1 end
		if i==3 then e.velx,e.vely=0,2 end
		if i==4 then e.velx,e.vely=0,-2 end
		if i==5 then e.velx,e.vely=-2,1 end
		if i==6 then e.velx,e.vely=-2,-1 end

		e.tile = entity_explosion1
		e.lifetime = 60
		add(entities,e)  
 end
end

function heal_hero(healing, p)
 p.health += healing
end
-->8
-- movement functions
function apply_hero_falling(p)
 if p.y < p.groundlevel then
  p.jumpvel += 0.5
 end

 if p.jumpvel <= 0 then return end

 --print("falling")

 p.y += p.jumpvel
 
 if p.y >= p.groundlevel then
  p.jumpvel = 0
  p.y = p.groundlevel
 end
end

function apply_hero_jumping(p)
 if p.jumpvel >= 0 then return end

 --print("jumping")
 
 local y = p.y
 
 y += p.jumpvel
 
 if y < p.groundlevel then
  p.jumpvel += 0.5
 else
  p.jumpvel = 0
  y = p.groundlevel
 end 

 local g = calc_char_groundlevel(p.x,y,8)

 if g == p.groundlevel then
  p.y = y
 else
  print("newg " .. g)
  --bonged our head
  --on the ceiling
  --p.jumpvel = 0
  p.y = flr(p.y/8)*8
  --repeat
  -- g0 = calc_groundlevel(p.x,y)
  -- g1 = calc_groundlevel(p.x+7,y)
  -- y += 8
  --until g0 >= p.groundlevel and g1 >= p.groundlevel
  --p.y = y-8
  --p.jumpvel = 0
 end
end

function apply_hero_movement(p)
 local direction = p.direction
 if p.stuned != 0 then
  direction = -direction / 2
 else
  direction *= p_walkspeed
 end
 if p.state == p_state_stand and p.stuned == 0 then return end
 local x1 = p.x
 x1 += direction  

 if x1 < 0 then return end

 local tl = mget(x1/8,p.y/8)
 if fget(tl, flag_ground) then return end

 local tr = mget((x1+7)/8,p.y/8)
 if fget(tr, flag_ground) then return end

 p.x = x1
end

function check_hero_touch(x,y,p)
 local t = mget(x/8,y/8)
 
 if p.iframes == 0 and fget(t, flag_instadeath) then
  --kill_hero(p)
 end
 if p.iframes == 0 and fget(t, flag_hurt) then
  hurt_hero(20,p)
 end
end

function hero_movement(p)
 p.groundlevel = calc_char_groundlevel(p.x,p.y,8)

 if p.health == 0 then return end
 --walking 
 if btn(⬅️) and p.stuned == 0 then 
  p.state = p_state_run
  p.direction = -1
 end 
 if btn(➡️) and p.stuned == 0 then 
  p.state = p_state_run
  p.direction = 1
 end  
 if btnd(🅾️) and p.y == p.groundlevel and p.stuned == 0 then
  p.jumpvel = -p_jumpstrength
 end 

 local oldx = p.x
 apply_hero_falling(p)
 apply_hero_jumping(p)
 apply_hero_movement(p)

 if oldx == p.x then
  p.state = p_state_stand
 end
 
 if p.iframes > 0 then p.iframes -= 1 end
 if p.stuned > 0 then p.stuned -= 1 end
 
 if p.state != p_state_jump then 
  check_hero_touch(p.x,p.y+8,p)
  check_hero_touch(p.x+8,p.y+8,p)
  check_hero_touch(p.x,p.y,p)
  check_hero_touch(p.x+7,p.y,p)
 end
 
 check_spikes(p)
 
 --shootng
 if btnd(❎) then
  local melon = {x=p.x, y=p.y}
  melon.direction = p.direction
  melon.velx = p.direction * melon_speed
  melon.vely = 0
  melon.player = true
  melon.tile = tile_melon
  melon.lifetime = 20
  add(entities, melon)
  sfx(0)
 end
end

function check_spikes(p)
	local check_hero_touch=function(x,y,p)
	 local t = mget(x/8,y/8)
	 
	 if fget(t, flag_instadeath) then
	  kill_hero(p)
	 end
	end

 if p.state != p_state_jump then 
  check_hero_touch(p.x,p.y,p)
  check_hero_touch(p.x+8,p.y,p)
 end 
end

function enemy_update(e,p)
  if abs(e.x-p.x) <= 8 and abs(e.y-p.y) <= 8 then
   hurt_hero(9,p)
  end

	 if e.velx and e.vely then
	  e.x += e.velx
	  e.y += e.vely
	 end

  if e.direction then
	  if e.direction == -1 and calc_groundlevel(e.x-1,e.y) != e.groundlevel then
	   e.direction = -e.direction
	  end
	  if e.direction == 1 and calc_groundlevel(e.x+8,e.y) != e.groundlevel then
	   e.direction = -e.direction
	  end
	  e.x += e.direction
  end
  
  if e.iframes == 0 then
	  for m in all(entities) do
	   if m.tile == tile_melon and abs(e.x-m.x) < 6 and abs(e.y-m.y) < 8 then
	    e.health -= 20
	    e.iframes = 10
	    del(entities,m)
	   end
	  end
	 else
	  e.iframes -= 1
  end
  
  if e.health <= 0 then
   --spawn healh
   create_item(item_health1,e.x,e.y)
   del(enemies, e)
  end
end

function entity_update(e)
 if e.velx and e.vely then
  e.x += e.velx
  e.y += e.vely
 end
 if e.lifetime then
  e.lifetime -= 1
  if e.lifetime == 0 then
   del(entities,e)
  end
 end
end

function create_item(t, x, y)
 local i = {}
 i.x,i.y = x,y
 i.tile = t
 add(items,i)
end

-->8
-- draw functions
function hero_draw(p)
 if p.health == 0 then return end
 if p.iframes > 0 and (g_frame % 2) == 0 then
  return
 end

 local p_frame = p.state
 if p_frame == p_state_run and g_frame % 20 < 10 then
  p_frame = p_frame + 1
 end
 
 if p.y != p.groundlevel then
  p_frame = p_state_jump
 end
 
 if btn(❎) then
  p_frame = next_row(p_frame,1)
 end

 if p.stuned > 0 then
  p_frame = 34
 end

 --draw player 
 pal(4,p.color1)
 pal(9,p.color2) 
 spr(p_frame, p.x, p.y, 1, 1, p.direction == -1) 
 pal(4,4)
 pal(9,9)
end

function draw_healthbar(p)
 local h = 20
 for y=0,h do
  local c
  if (h * (p.health / 100.0))<y then c=0 else c=6 end
  if c == 6 and y % 2 == 0 then c = 7 end
  line(1,h-y+3,6,h-y+3, c)
 end
end

function enemy_draw(e)
 if e.iframes > 0 and (g_frame % 2) == 0 then return end

 spr(e.tile, e.x, e.y, 1, 1, e.direction == -1)
end

function entity_draw(e)
 if not e.tile then return end

 local tile = e.tile
 local flipt = false
 
 if tile == entity_explosion1 then
  flipt = g_frame % 20 < 10
  if g_frame % 40 < 20 then tile+=1 end
 end
 
 if e.direction == -1 then
  flipt = not flipt
 end
 
 spr(tile, e.x, e.y, 1, 1, flipt)
end
-->8
--constructors
function cstr_player(x,y)
 local p = {x=x,y=y}
 p.health = 100
	p.state = p_state_stand
	p.slide_frames = 0
	p.direction = 1
	p.jumpvel = 0
	p.groundlevel = 0
	p.iframes = 0
	p.stuned = 0
	p.color1 = 4
	p.color2 = 9
	p.groundlevel = y
	return p
end
-->8
--turret
tile_turret = 13

function turret_shoot(t,p)
	local e = {}
	e.x,e.y = t.x,t.y
 e.velx = (p.x-t.x)/20
 e.vely = (p.y-t.y)/20
 e.iframes=0
 e.health=100
 
	e.tile = entity_explosion1
	e.lifetime = 60
	add(enemies,e)  
end

function turret_logic(e,p)
 local range = 45
 local s = e.state
 
 print(abs(p.x-e.x))
 if abs(p.x-e.x) < range and p.y>=e.y then
  s = turret_in(s)
 else 
  s = turret_out(s)
 end

 if e.time > 0 then
  e.time -= 1
  if e.time == 0 then
   s = turret_time(s)
  end
 end

 if s == "attacking" then  
  if g_frame % 50 == 0 then
   turret_shoot(e,p)
  end
 end
 
 e.state = s
end

function turret_draw(e,p)
 local t = e.tile
 local s = e.state
 local hz = 20 
 local turret_cooldown = 50
 
 if p.x-e.x < -10 then t=t end
 if p.x-e.x > 10 then t=t+2 end
 if abs(p.x-e.x) <= 10 then t=t+1 end
 
 if s == "searching" then  
  e.time = turret_cooldown
  t = tile_turret
  t += (g_frame/hz) % 3
 end
 if s == "spotted" then  
  hz *= 2
  t = next_row(t, 1)
  --if g_frame / 
 end
 if s == "attacking" then  
  hz *= 2
  t = next_row(t, 2)
  e.time = turret_cooldown
 end
 if s == "waiting" then  
  t = next_row(t, 3)
 end


 spr(t, e.x, e.y)
end
-->8
-- turret statemachine
function turret_in(s)
 if s == "searching" then return "spotted" end 

 return s
end

function turret_out(s)
 if s == "spotted" then return "searching" end 

 return s
end

function turret_time(s)
 if s == "spotted" then return "attacking" end 

 return s
end
__gfx__
00000000e44444eee44444eee44444eee44444ee0bb00bb00bbb0bb00bb3bbb00bb00bb00bb00bb00bbb0bb00bbb3bb00bb00bb0333333333333333333333333
00000000e47171ee4471714ee47171eee47171eeb333b333b355b333b5335553b355b333b333b333b355b333b5335553b355b333e333333ee333333ee333333e
00700700eeffffee4effff4eeeffffeeeeffff4e3355552352225253522552253525553333555523522252535225522535255533ee3333eeee3333eeee3333ee
00077000e99ff9eee99f09ee449ffeeee49ff94e3552522522232222532222225222255335525225222322225322222252222553eee66eeeeee66eeeeee66eee
000770004e999e4eee999eee4ee99eeee4e99eee3522522222252222222222222222525005222222222222322222222222222255ee67eeeeeee67eeeeeee67ee
007007004e444e4eee444eeeeee494eeeee94eee0522222223222222222222222222225005255252522252225222225252222225e667eeeeeee67eeeeeee667e
00000000ee949eeeee94944ee4994eeeee4994ee0522222222222252222223222225225052552555525225255552525555252555666eeeeeeee66eeeeeeee666
00000000e44e44eeee4eeeeee44e44eeee44e44e552225222222222222222222222222250555555005555550055555000055555066eeeeeeeee66eeeeeeeee66
eeeeeeeee44444eee44444eee44444eee44444ee5222225222522222522252222222222500000000000000000000000000000000999999999999999999999999
eeeeeeeee47171ee447171eee47171eee47171ee5222222222222322222222222522225500000000000000000000000000000000e999999ee999999ee999999e
eeeeeeeeeeffffee4effffeeeeffffeeeeffffee5222222222222222222225222222225000000000000000000000000000000000ee9999eeee9999eeee9999ee
eeeeeeeee99ff944e99f0944449ff944e49ff9445522222252222222222222222222225500000000000000000000000000000000eee66eeeeee66eeeeee66eee
eee44eee4e999eeeee999eee4ee99eeee4e99eee5525222222222222522222222223222500000000000000000000000000000000ee67eeeeeee67eeeeeee67ee
ee9999ee4e444eeeee444eeeeee49eeeeee94eee5522232222222252222225222222252500000000000000000000000000000000e667eeeeeee67eeeeeee667e
ee4444eeee949eeeee94944ee4994eeeee4994ee5222222222252222222222222222222500000000000000000000000000000000666eeeeeeee66eeeeeeee666
eee99eeee44e44eeee4eeeeee44e44eeee44e44e552222222222222223252222225222500000000000000000000000000000000066eeeeeeeee66eeeeeeeee66
eeeeeeee06667767e44444eeeeeeaaeeeeeeeeee0522222225222252222222222222225000000000000000000000000000000000888888888888888888888888
eeeeeeee76666660e47878eeeeaa9aeeeeeeaaee5522252222222222222222522225255500000000000000000000000000000000e888888ee888888ee888888e
eeea9eee06667767eeff0feeaa9999aeeaaa9aee5522222222222222222222222222225500000000000000000000000000000000ee8888eeee8888eeee8888ee
eeaa99ee76666660e99f09ee999999aee9999aee5222222232225222222522222222222500000000000000000000000000000000eee66eeeeee66eeeeee66eee
eeeaaeee066677674e999e4ee9999999ee99999e5222252222222225222222225232222500000000000000000000000000000000ee67eeeeeee67eeeeeee67ee
eeeeeeee766666604e444e4ee9999999ee99999e5522222222222222222222222222222500000000000000000000000000000000e667eeeeeee67eeeeeee667e
eeeeeeee06667767ee949eeeee9999eeee99eeee5225222225222252222322222222522500000000000000000000000000000000666eeeeeeee66eeeeeeee666
eeeeeeee76666660e44e44eeee99eeeeeeeeeeee052225222222222222222222522222500000000000000000000000000000000066eeeeeeeee66eeeeeeeee66
0000000008800080eeee4eeeaa990aa0000000000522222222222252222225222222225000000000000000000000000000000000222222222222222222222222
0000000088888888eee94eeea0909a0a000000005522222552252252222222222222255000000000000000000000000000000000e222222ee222222ee222222e
0000000089888888ee4944eeaa909a0a000000005222322222222222252222252252225500000000000000000000000000000000ee2222eeee2222eeee2222ee
0000000088889889ee4944eea0909a0a000000005252222222222222222222222222232500000000000000000000000000000000eee66eeeeee66eeeeee66eee
0000000088988888ee4444eeaa909aaa000000000522222222222232222222222222225500000000000000000000000000000000ee67eeeeeee67eeeeeee67ee
0000000088988988ee4494ee77777777000000000525525252225222522222525222222500000000000000000000000000000000e667eeeeeee67eeeeeee667e
0000000089888989eee49eee00000770000000005255255552522525555252555525255500000000000000000000000000000000666eeeeeeee66eeeeeeee666
0000000089889898eee4eeee0000070000000000055555500555555005555500005555500000000000000000000000000000000066eeeeeeeee66eeeeeeeee66
eeeeeeeeeeeeeeeecccccccccccccccc2000000025522552000000000000000000500000cccccccccccccccc2000000025522552000005000000000000000000
e44444eeeeeeeeeeccccccccccccccc55200000052255225000000000000000005555500ccccccccccccccc55200000052255225005555500000000000000000
e477774ee6eaea6ecccccccccccccc552520000025522552000000000000000055555000cccccccccccccc552520000025522552000555550000000000000000
e779797eee6666eeccccccccccccc5555252000052255225000000000000000005550000ccccccccccccc5555252000052255225000055500000000000000000
e777777eee6666eecccccccccccccc5c2525200025522552000000000000000000500000cccccccccccccc5c2525200025522552000005007777777777770000
e777777ee6eaea6eccccccccccc555555252520052255225000000000000000055000000ccccccccccc555555252520052255225000000557777777777777700
ee7000eeeeeeeeeecccccccccc55c5552525252025522552000000000000000050000000cccccccccc55c5552525252025522552000000057777777777777770
eee777eeeeeeeeeeccccccccc55555555252525252255225000000000000000000000000ccccccccc55555555252525252255225000000007777777777777777
0000000000000000000000000000000ddddd2525dddddddd00000000000000002525252d000000000000000ddddd2525ddddddddd2525252dddddddd00000000
000000000000000000000077000000dd5ddd5252dddddddd00000000000000005252525d00000077000000dd5ddd5252ddddddddd5252525dddddddd00000000
00000000000000000000077700000dd525d5dd252ddddd250000000000000000252525dd0000077700000dd525d5dd252ddddd25dd525252dddddddd00000000
0000000000000000000077770000ddd252ddddd252dddd52000000000000000052525ddd000077770000ddd252ddddd252dddd52ddd52525dddddddd00000000
000000000000000000777777000dddd5252ddd252525d525000000000000000025252ddd00777777000dddd5252ddd252525d525ddd25252dddddddd77770000
00000000000000000777777700dddd52525d5252525252520000000000000000525252dd0777777700dddd52525d525252525252dd252525dddddddd77777700
0000000000000000077777770dd5d52525252525252525250000000000000000252525dd077777770dd5d5252525252525252525dd525252dddddddd77777770
000000000000000077777777dd5dd252525252525252525200000000000000005252525d77777777dd5dd2525252525252525252d5252525dddddddd77777777
0000000000000000000000000000000ddddd2525dddddddd000000000000000025522552000000000000000ddddd2525dddddddd200000000000000000000000
000000000000000077000000000000dddddd5252dddddddd00000000000000005225522577000000000000dddddd5252dddddddd500000000000000000000000
000000000000000077770000000000ddddd52525dddddddd00000000000000002552255277770000000000ddddd52525dddddddd200000000000000000000000
0000000000000000777770000000ddddddd25252dddddddd000000000000000052255225777770000000ddddddd25252dddddddd520200000000000000000000
000000000000000077777700000dddddddd52525dddddddd00000000000000002552255277777700000dddddddd52525dddddddd252520007777777777770000
00000000000000007777770000ddd5dddd525252dddddddd0000000000000000522552257777770000ddd5dddd525252dddddddd525250007777777777777700
0000000000000000777777700ddd5dddd5252525dddddddd000000000000000025522552777777700ddd5dddd5252525dddddddd252525007777777777777770
000000000000000077777777d5ddddddd2525252dddddddd00000000000000005225522577777777d5ddddddd2525252dddddddd525252507777777777777777
0000000000000000777777770000777700000000000000000000000000000000dddddddd77777777000077770000000000000000dddd2525dddddddd00000000
0000000000000000777777770000777700000000000000000000000000000000dddddddd77777777000077770000000000000000dddd5252dddddddd00000000
00000000000000007777777700007777000000000000000000000000000000002ddddd2577777777000077770000000000000000ddd52525dddddddd00000000
000000000000000077777777000077770000000000000000000000000000000052dddd5277777777000077770000000000000000ddd25252dddddddd00000000
00000000000000007777777777777777777777777777000000000000000000002525d52577777777777777777777777777770000ddd52525dddddddd77770000
00000000000000007777777777777777777777777777770000000000000000005252525277777777777777777777777777777700dd525252dddddddd77777700
00000000000000007777777777777777777777777777777000000000000000002525252577777777777777777777777777777770d5252525dddddddd77777770
00000000000000007777777777777777777777777777777700000000000000005252525277777777777777777777777777777777d2525252dddddddd77777777
__gff__
0000000000010101010101010100000000000000000101010100000000000000000300000001010101000000000000000004000000010101010000000000000000000101000000000101010000000000000000000000000000000000000000000000010000000000000100000000000000000100000000000001000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000506070706070800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000001000211516262627262800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000508000005062616161626261727070c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000035370c003537373637373737373638000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000002121212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000050708000000000021212121212100212121212100002121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000000000000000009373738000000212121212121212100212121212100002121212121210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
060706080000050800000508000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2616161800002528000025180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1716161800001518000015180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2716161821212528313125180000000000000000000040000000050800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1616261616161616070617160607060606070607060607070606161706070707060706070607000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1616161616161616161617172626262617172626171717261717261727261727171717171717000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000f150131501415015150171501b1501e15015150101500f1500e1500e1500f1500f150101501415017150191501015000550005500055000550005500055000550005500055000550005500055000550
00020000336502f6502c6502965026650236501c650136500c6501165010650126500d6500c6500b6500a6500b6500a6500000000000000000000000000000000000000000000000000000000000000000000000
000100000c15011150141501615018150181501815014150101500615002150001502c00028000260000000003000040000200001000000000000000000000000000000000000000000000000000000000000000
