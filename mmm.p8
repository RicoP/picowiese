pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- globals
p_state_stand = 1
p_state_jump = 2
p_state_run = 3

p_jumpstrength = 10
p_walkspeed = 1
--player
p = {x = 10, y = 10}
p.health = 100
p.state = p_state_stand
p.slide_frames = 0
p.direction = 1
p.jumpvel = 0
p.groundlevel = 0
p.iframes = 0
p.stuned = 0

--flags
flag_ground=0
flag_instadeath=1
flag_hurt=2

--melons == bullets
melons = {}

g_frame = 0

tile_melon = 32
melon_speed = 6

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
 --if (g_frame % 4) != 0 then return end
 
 camera()
 cls(1)
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
  melon.x += melon.direction * melon_speed
 end
 
 print(p.groundlevel)
 print(p.x .. " " .. p.y)
 print(p.health)
 print(p.jumpvel)
end

function _draw()
 local camx=p.x - 32
 if camx < 0 then camx=0 end
 camera(camx, 0)

 map(0)

 hero_draw(4,9)

 for i,melon in pairs(melons) do
  spr(tile_melon, melon.x, melon.y, 1, 1, melon.direction == -1)
 end

 --debug
 line(0, p.groundlevel, 128, p.groundlevel, 7)
 pset(p.x, p.y, 8)
 pset(p.x+7, p.y, 8)
 pset(p.x, p.y+7, 8)
 pset(p.x+7, p.y+7, 8)

 g_frame = g_frame + 1
end

-->8
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

function calc_char_groundlevel(x,y,w)
 local g0 = calc_groundlevel(x,y)
 local g1 = calc_groundlevel(x-1+w,y)
 return min(g0,g1)
end
-->8
-- movement functions

function apply_hero_falling()
 if p.y < p.groundlevel then
  p.jumpvel += 0.5
 end

 if p.jumpvel <= 0 then return end

 print("falling")

 p.y += p.jumpvel
 
 if p.y >= p.groundlevel then
  p.jumpvel = 0
  p.y = p.groundlevel
 end
end

function apply_hero_jumping()
 if p.jumpvel >= 0 then return end

 print("jumping")
 
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

function apply_hero_movement()
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

function check_hero_touch(x,y)
 local t = mget(x/8,y/8)
 if p.iframes == 0 and fget(t, flag_instadeath) then
  p.health = 0
 end
 if p.iframes == 0 and fget(t, flag_hurt) then
  p.stuned = 30
  p.iframes = 60
  p.health -= 20
  sfx(1)
 end
end

function hero_movement()
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
 apply_hero_falling()
 apply_hero_jumping()
 apply_hero_movement()

 if oldx == p.x then
  p.state = p_state_stand
 end
 
 if p.iframes > 0 then p.iframes -= 1 end
 if p.stuned > 0 then p.stuned -= 1 end
 
 if p.state != p_state_jump then 
  check_hero_touch(p.x,p.y+8)
  check_hero_touch(p.x+8,p.y+8)
  check_hero_touch(p.x,p.y)
  check_hero_touch(p.x+7,p.y)
 end
end

function physics_update()
 p.groundlevel = calc_char_groundlevel(p.x,p.y,8)
end
-->8
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

 if p.stuned > 0 then
  p_frame = 34
 end

 if p.iframes > 0 and (g_frame % 2) == 0 then
  return
 end

 --draw player 
 pal(4,col_main)
 pal(9,col_second) 
 palt(0, false)
 palt(14, true)
 
 spr(p_frame, p.x, p.y, 1, 1, p.direction == -1)
 
 palt(0, true)
 pal() 
end


__gfx__
00000000e44444eee44444eee44444eee44444ee0330033003330330033333300330033003300330033303300333333003300330000000000000000000000000
00000000e47171ee4471714ee47171eee47171ee3333333333553333353355533355333333333333335533333533555333553333000000000000000000000000
00700700eeffffee4effff4eeeffffeeeeffff4e3355552352225253522552253525553333555523522252535225522535255533000000000000000000000000
00077000e99ff9eee99f09ee449ffeeee49ff94e3552522522232222532222225222255335525225222322225322222252222553000000000000000000000000
000770004e999e4eee999eee4ee99eeee4e99eee3522522222252222222222222222525005222222222222322222222222222255000000000000000000000000
007007004e444e4eee444eeeeee494eeeee94eee0522222223222222222222222222225005255252522252225222225252222225000000000000000000000000
00000000ee949eeeee94944ee4994eeeee4994ee0522222222222252222223222225225052552555525225255552525555252555000000000000000000000000
00000000e44e44eeee4eeeeee44e44eeee44e44e5522252222222222222222222222222505555550055555500555550000555550000000000000000000000000
55555555e44444eee44444eee44444eee44444ee5222225222522222522252222222222500000000000000000000000000000000000000000000000000000000
00000500e47171ee447171eee47171eee47171ee5222222222222322222222222522225500000000000000000000000000000000000000000000000000000000
00000000eeffffee4effffeeeeffffeeeeffffee5222222222222222222225222222225000000000000000000000000000000000000000000000000000000000
00000000e99ff944e99f0944449ff944e49ff9445522222252222222222222222222225500000000000000000000000000000000000000000000000000000000
000000004e999eeeee999eee4ee99eeee4e99eee5525222222222222522222222223222500000000000000000000000000000000000000000000000000000000
000000004e444eeeee444eeeeee49eeeeee94eee5522232222222252222225222222252500000000000000000000000000000000000000000000000000000000
00000000ee949eeeee94944ee4994eeeee4994ee5222222222252222222222222222222500000000000000000000000000000000000000000000000000000000
00000000e44e44eeee4eeeeee44e44eeee44e44e5522222222222222232522222252225000000000000000000000000000000000000000000000000000000000
0000000000007000e44444ee00000000000000000522222225222252222222222222225000000000000000000000000000000000000000000000000000000000
0000000007077070e47878ee00000000000000005522252222222222222222522225255500000000000000000000000000000000000000000000000000000000
0000000006066060eeff0fee00000000000000005522222222222222222222222222225500000000000000000000000000000000000000000000000000000000
0099aa0006066060e99f09ee00000000000000005222222232225222222522222222222500000000000000000000000000000000000000000000000000000000
00000000006666004e999e4e00000000000000005222252222222225222222225232222500000000000000000000000000000000000000000000000000000000
00000000066666604e444e4e00000000000000005522222222222222222222222222222500000000000000000000000000000000000000000000000000000000
0000000023222232ee949eee00000000000000005225222225222252222322222222522500000000000000000000000000000000000000000000000000000000
0000000022223222e44e44ee00000000000000000522252222222222222222225222225000000000000000000000000000000000000000000000000000000000
00000000ffffffff0000000000000000000000000522222222222252222225222222225000000000000000000000000000000000000000000000000000000000
00000000ffffffff0000000000000000000000005522222552252252222222222222255000000000000000000000000000000000000000000000000000000000
00000000ffffffff0000000000000000000000005222322222222222252222252252225500000000000000000000000000000000000000000000000000000000
00000000ffffffff0000000000000000000000005252222222222222222222222222232500000000000000000000000000000000000000000000000000000000
00000000ffffffff0000000000000000000000000522222222222232222222222222225500000000000000000000000000000000000000000000000000000000
00000000ffffffff0000000000000000000000000525525252225222522222525222222500000000000000000000000000000000000000000000000000000000
00000000ffffffff0000000000000000000000005255255552522525555252555525255500000000000000000000000000000000000000000000000000000000
00000000ffffffff0000000000000000000000000555555005555550055555000055555000000000000000000000000000000000000000000000000000000000
__gff__
0000000000010101010101010100000000000000000101010100000000000000000300000001010101000000000000000004000000010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000506070706070800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000211516262627262800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000508000005062616161626261727070c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000035370c003537373637373737373638000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000050800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000000000000310009373800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0507060800000508000005080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2516161800002528000025180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1516161800001518000015180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2516161821212528212125180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2516261616161616161617160a0a0a0a0a0a0a0a0a0a0a0b0a0b070c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000a0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000f150131501415015150171501b1501e15015150101500f1500e1500e1500f1500f150101501415017150191501015000550005500055000550005500055000550005500055000550005500055000550
00020000336502f6502c6502965026650236501c650136500c6501165010650126500d6500c6500b6500a6500b6500a6500000000000000000000000000000000000000000000000000000000000000000000000
