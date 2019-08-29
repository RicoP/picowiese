pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function array()
 return {}
end
--tile dictionary
tls = {
 hero=1
}

--hero/player
h = {x=0,y=0}
h.vely=0
h.velx=0

--level
lvl = {stage=0}
lvl.stages = array()
-->8
--native functions 

function _init()
 for y=0,63 do
  for x=0,127 do
   local t = mget(x,y)
   if tls.hero == t then
    mset(x,y,0)
    local stg={}
    stg.cx=0
    stg.cy=flr(y/128)
    stg.hx=x
    stg.hy=y
    
    add(lvl.stages,stg) 
   end
  end
 end
 set_level(1)
end

function next_level()
 set_level(lvl.stage+1)
end

function set_level(n)
end

function _update()
end

function _draw()
end
__gfx__
00000000eeeaa9ee0000000000000000000000000000000000000000000000ee0500000555555555555555555555555555555555555555555555555555555555
00000000eeafaa9e0000000000000000000000000000000000000000000000ee5555055555555555555555555555555555555555555555555555555555555555
00700700eea1f1ee0000000000000000000000000000000000000000000000ee0500050055555555555555555555555555555555555555555555555555555555
00077000eeefffee0000000000000000000000000000000000000000000000ee5500550555555555555555555555555555555555555555555555555555555555
00077000ee56655e0000000000000000000000000000000000000000000000ee0505005555555555555555555555555555555555555555555555555555555555
00700700eee66eee0000000000000000000000000000000000000000000000ee0055000055555555555555555555555555555555555555555555555555555555
00000000ee44e4ee0000000e000000000000000000000000000000000000000e0500050055555555555555555555555555555555555555555555555555555555
00000000ee07770e0000000e0000e0000000000000000000000000000000000e5500550055555555555555555555555555555555555555555555555555555555
00000000eeeaa9ee000000ee0000e0000e0000000e000000000000000000000e0000000055555555555505555555555555555555555555555555555555555555
00000000eeafaa9e0000ee000000e0000e000ee00eeeee00000000000000000e0000000055555555555550000000555550555555000005555555555555555555
00000000eea1f1ee000e00000000e0000e000ee000e000e000000000e000000e0000000055555555555555505555555550555555055555555555555555555555
00000000eeefffee000e00000000e0000e00e0e000e000e0000000ee0000000e0000000055555555555555505555550550555555055555555555555555555555
00000000ee55665e000e00000000e0000e00e0e000e000e00000eee00000000e0000000055555555555555550555555550555555055555555555555555555555
00000000eeee66ee000e0000000e00000e00e0e000e00ee000eee0000000000e0000000055555555555555550555555550555555000055555555555555555555
00000000eee4e44e000e0000000e00000e0e00e00e0eee0000eeeeee0000000e0000000055555555555555550555505550555555055555555555555555555555
00000000ee07770e000e0000000e00000e0e00e00e0ee0000000000e0000000e3333333355555555555555550555505550555555055555555555555555555555
0000000000000000000e0000000eeeeeee0e00e0ee00e0000000000e0000000e0000000055555555555555550555505550555550555555555555555555555555
0000000000000000000e0000000e0000e0eeeee0e0000e000000000e0000000e0000000055555555555555500555505550555550000055555555555555555555
0000000000000000000e0000000e0000e0e000e0e0000ee00000000e0000000e0000000055555555555555505555005550000050555555555555555555555555
0000000000000000000ee000000e000ee0e000e0e00000e00000000e0000000e0000000055555555555555505555055500555555555555555555555555555555
00000000000000000000e000000e000e00e000e0e00000e0000000ee0000000e0000000055555555555555555555555555555555555555555555555555555555
00000000000000000000e000000e000000e000e0ee00000000eeeee00000000e0000000055555555555555555555555555555555555555555555555555555555
000000000000000000000eeeee0ee0000000000000000000000000000000000e0000000055555555555555555555555555555555555555555555555555555555
000000000000000000000000000000000000000000000000000000000000000e0000000055555555555555555555555555555555555555555555555555555555
000000000000000000000000000000000000000000000000000000000000000e5555555555555555555555555555555555555555555555555555555555555555
000000000000000000000000000000000000000000000000000000000000000e5555555555555555555555555555555555555555555555555555555555555555
000000000000000000000000000000000000000000000000000000000000000e5555555555555555555555555555555555555555555555555555555555555555
000000000000000000000000000000000000000000000000000000000000000e5555555555555555555555555555555555555555555555555555555555555555
000000000000000000000000000000000000000000000000000000000000000e5555555555555555555555555555555555555555555555555555555555555555
000000000000000000000000000000000000000000000000000000000000000e5555555555555555555555555555555555555555555555555555555555555555
000000000000000000000000000000000000000000000000000000000000000e5555555555555555555555555555555555555555555555555555555555555555
000000000000000000000000000000000000000000000000000000000000000e5555555555555555555555555555555555555555555555555555555555555555
__map__
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
0100000000000000001818181818181800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808080808080000000000000008080808080808080808080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808080808080800000000000808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
