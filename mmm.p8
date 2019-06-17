pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
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
 print(p.x .. " " .. p.y)
 print(p.y < p.groundlevel)
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

-->8
-- movement functions

function apply_hero_falling()
 if p.y < p.groundlevel then
  p.y += p.jumpvel
 else
  p.y = p.groundlevel
 end
end

function apply_hero_jumping()
 --jumping
 local y = p.y
 local jumpvel = p.jumpvel
 
 if btnd(🅾️) and y == p.groundlevel then
  jumpvel = p_jumpstrength
 end

 y -= jumpvel
 jumpvel -= 0.5

 if y >= p.groundlevel then
  y = p.groundlevel
  jumpvel = 0
 end
 
 if calc_groundlevel(p.x,y) != p.groundlevel then
  -- hitting the ceiling but 
  -- being off by just a little 
  -- bit. round player position
  p.y = flr(p.y/8)*8
  p.jumpvel = 0
  return
 end
 
 p.y = y
 p.jumpvel = jumpvel
end

function apply_hero_movement()
 if p.state == p_state_stand then return end
 local x1 = p.x
 x1 += p.direction  

 local tl = mget(x1/8,p.y/8)
 if tl != 0 then return end

 local tr = mget((x1+7)/8,p.y/8)
 if tr != 0 then return end

 p.x = x1
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

 local oldx = p.x
 apply_hero_jumping() 
 apply_hero_movement()
 if oldx == p.x then
  p.state = p_state_stand
 end
end

function physics_update()
 local g1 = calc_groundlevel(p.x,p.y)
 local g2 = calc_groundlevel(p.x+7,p.y)
 p.groundlevel = min(g1,g2) 
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


__gfx__
00000000e44444eee44444eee44444eee44444ee0330033003330330033333300330033000000000000000000000000000000000000000000000000000000000
00000000e47171ee4471714ee47171eee47171ee3333333333553333353355533355333300000000000000000000000000000000000000000000000000000000
00700700eeffffee4effff4eeeffffeeeeffff4e3355552352225253522552253525553300000000000000000000000000000000000000000000000000000000
00077000e99ff9eee99f09ee449ffeeee49ff94e3552522522232222532222225222255300000000000000000000000000000000000000000000000000000000
000770004e999e4eee999eee4ee99eeee4e99eee3522522222252222222222222222525000000000000000000000000000000000000000000000000000000000
007007004e444e4eee444eeeeee494eeeee94eee0522222223222222222222222222225000000000000000000000000000000000000000000000000000000000
00000000ee949eeeee94944ee4994eeeee4994ee0522222222222252222223222225225000000000000000000000000000000000000000000000000000000000
00000000e44e44eeee4eeeeee44e44eeee44e44e5522252222222222222222222222222500000000000000000000000000000000000000000000000000000000
55555555e44444eee44444eee44444eee44444ee5222225222522222522252222222222500000000000000000000000000000000000000000000000000000000
00000500e47171ee447171eee47171eee47171ee5222222222222322222222222522225500000000000000000000000000000000000000000000000000000000
00000000eeffffee4effffeeeeffffeeeeffffee5222222222222222222225222222225000000000000000000000000000000000000000000000000000000000
00000000e99ff944e99f0944449ff944e49ff9445522222252222222222222222222225500000000000000000000000000000000000000000000000000000000
000000004e999eeeee999eee4ee99eeee4e99eee5525222222222222522222222223222500000000000000000000000000000000000000000000000000000000
000000004e444eeeee444eeeeee49eeeeee94eee5522232222222252222225222222252500000000000000000000000000000000000000000000000000000000
00000000ee949eeeee94944ee4994eeeee4994ee5222222222252222222222222222222500000000000000000000000000000000000000000000000000000000
00000000e44e44eeee4eeeeee44e44eeee44e44e0522222222222222232522222252225000000000000000000000000000000000000000000000000000000000
00000000333333330000000000000000000000000522222225222252222222222222225000000000000000000000000000000000000000000000000000000000
00000000333333330000000000000000000000005522252222222222222222522225255500000000000000000000000000000000000000000000000000000000
00000000333333330000000000000000000000005522222222222222222222222222225500000000000000000000000000000000000000000000000000000000
0099aa00333333330000000000000000000000005222222232225222222522222222222500000000000000000000000000000000000000000000000000000000
00000000333333330000000000000000000000005222252222222225222222225232222500000000000000000000000000000000000000000000000000000000
00000000333333330000000000000000000000005522222222222222222222222222222500000000000000000000000000000000000000000000000000000000
00000000333333330000000000000000000000005225222225222252222322222222522500000000000000000000000000000000000000000000000000000000
00000000333333330000000000000000000000000522252222222222222222225222225000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000522222222222252222225222222225000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005522222552252252222222222222255000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005222322222222222252222252252225500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005252222222222222222222222222232500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000522222222222232222222222222225500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000525525252225222522222525222222500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005255255552522525555252555525255500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000555555005555550055555500055555000000000000000000000000000000000000000000000000000000000
__gff__
0000000000010101010000000000000000000000000101010100000000000000000000000001010101000000000000000000000000010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1626171617262627261626000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2626271726261726272617000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3637373737363637373637000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0507060800000508000005080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2516161800002528000025180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1516161800001518000015180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2516161800002528000025180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2516262607072728000025160700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2516161616161618000015272800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3536373636373736060737363800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000f150131501415015150171501b1501e15015150101500f1500e1500e1500f1500f150101501415017150191501015000550005500055000550005500055000550005500055000550005500055000550
000100000f150111501315016150181501a1501c1501f1501c1501615016150171501715016150151501615000000000000000000000000000000000000000000000000000000000000000000000000000000000
