-- utilities for pico-8
local btn_update_state = {0,0,0,0,0,0}
btn_update=function ()
 for b=0,6 do
  if btn_update_state[b] == 0 and btn(b) then
   btn_update_state[b] = 1
  elseif btn_update_state[b] == 1 then
   btn_update_state[b] = 2
  elseif btn_update_state[b] == 2 and not btn(b) then
   btn_update_state[b] = 3
  elseif btn_update_state[b] == 3 then
   btn_update_state[b] = 0
  end
 end
end

btnd=function (b)
 return btn_update_state[b] == 1
end

btnu=function (b)
 return btn_update_state[b] == 3
end

--https://www.lexaloffle.com/bbs/?pid=18374#p18374
qsort=function (t, cmp, i, j)
 i = i or 1
 j = j or #t
 if i < j then
  local p = i
  for k = i, j - 1 do
   if cmp(t[k], t[j]) <= 0 then
    t[p], t[k] = t[k], t[p]
    p = p + 1
   end
  end
  t[p], t[j] = t[j], t[p]
  qsort(t, cmp, i, p - 1)
  qsort(t, cmp, p + 1, j)  
 end
end

frnd=function (n)
 return flr(rnd(n))
end

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

-- globals
p_state_stand = 1
p_state_jump = 2
p_state_run = 3

p_jumpstrength = 7

--player
p = {x = 10, y = 10}
p.state = p_state_stand
p.slide_frames = 0
p.direction = 1
p.jumpvel = 0
p.groundlevel = 0

--flags
flag_ground=0

--melons == bullets
melons = {}

g_frame = 0

tile_melon = 32
melon_speed = 6


-- native functions
function _init()
 print("init")
 
 for x = 0,127 do
  for y = 0,31 do
   local t = mget(x,y)
   if t == p_state_stand then
    p.x,p.y = x*8,y*8
    mset(x,y,0)
    p.groundlevel = p.y
    break
   end
  end
 end
end

function _update()
 btn_update()
 p.state = p_state_stand 
 
 physics_update()

 hero_movement()

 --shootng
 if btnd(❎) then
  local melon = {x=p.x, y=p.y}
  melon.direction = p.direction
  add(melons, melon)
  sfx(0)
 end
 
 --melon logic
 for i,melon in pairs(melons) do
  --print(i)
  melon.x += melon.direction * melon_speed
 end
end

function _draw()
 cls(1)
 map(0)

 hero_draw(4,9)

 for i,melon in pairs(melons) do
  spr(tile_melon, melon.x, melon.y, 1, 1, melon.direction == -1)
 end

 line(0, p.groundlevel, 128, p.groundlevel, 7)

 print(p.groundlevel)
 g_frame = g_frame + 1
end


-- logic
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


-- movement functions

function apply_hero_jumping()
 --jumping
 local p1 = clone(p)
 if btnd(🅾️) and p1.y == p1.groundlevel then
  p1.jumpvel = p_jumpstrength
 end

 p1.y -= p1.jumpvel
 p1.jumpvel -= 0.5

 if p1.y >= p1.groundlevel then
  p1.y = p1.groundlevel
  p1.jumpvel = 0
 end
 
 if calc_groundlevel(p1.x,p1.y) != p.groundlevel then
  p.jumpvel = 0
  return
 end
 
 p = p1
end

function apply_hero_movement()
 if p.state == p_state_stand then return end
 local p1 = clone(p)
 p1.x += p.direction  
 local t1 = mget(p1.x/8,p1.y/8)
 if t1 != 0 then return end
 t1 = mget((p1.x+7)/8,p1.y/8)
 if t1 != 0 then return end
 p = p1
end

function hero_movement()
 --walking 
 if btn(⬅️) then 
  p.state = p_state_run
  p.direction = -1
 end 
 if btn(➡️) then 
  p.state = p_state_run
  p.direction = 1
 end  

 apply_hero_jumping() 
 apply_hero_movement()
end

function physics_update()
 p.groundlevel = calc_groundlevel(p.x,p.y)
end

-- draw functions
function hero_draw(col_main, col_second)
 local p_frame = p.state
 if p_frame == p_state_run and g_frame % 20 < 10 then
  p_frame = p_frame + 1
 end
 
 if p.y != p.groundlevel then
  p_frame = p_state_jump
 end
 
 if btn(❎) then
  p_frame += 16
 end

 --draw player 
 pal(4,col_main)
 pal(9,col_second) 
 palt(0, false)
 palt(14, true)
 
 spr(p_frame, p.x, p.y, 1, 1, p.direction == -1)
 
 palt(0, true)
 pal()
 
 --debug
 pset(p.x, p.y, 8)
 pset(p.x+7, p.y, 8)
 pset(p.x, p.y+7, 8)
 pset(p.x+7, p.y+7, 8)
end