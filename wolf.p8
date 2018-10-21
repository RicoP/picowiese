pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--player
p = {
 x=63.5,
 y=63.5,
 angle=0,
 speed=1,
 fov=70/360
}

function rotate(x,y,angle)
 -- rotates a 2d vector around zero
 local a = angle
 local dx2 = cos(a)*x - sin(a)*y
 local dy2 = sin(a)*x + cos(a)*y
 return dx2,dy2
end

function get_tile(x,y,a)
 local dx,dy=rotate(1,0,a)
 local distance=0
 -- loop until we find the tile
 for i=1,1000 do --limit by n steps
  local tx = flr(x/8)
  local ty = flr(y/8)
  local s = mget(tx,ty)
  if s!=0 then
   return s,distance,x%8
  end
  x+=dx
  y+=dy
  distance+=1
 end
 return 0,0,0
end

function draw_game()
 camera()
 local x=flr(p.x)
 local y=flr(p.x)
 local a = p.angle+p.fov/2
 for i=1,128 do
  local t,d,px=get_tile(p.x,p.y,a)
  a-=p.fov/(128)
  local h = 64/d
  sspr(t*8+px,0,1,8,i-1,64-(64-d)/2,1,64-d)
 end
end

function draw_map()
 camera(p.x - 64, p.y - 64)

 map(0,0, 0,0, 64, 64);
 
 -- sight ray
 -- by default we look along +x
 local dx = 100.5
 local dy = 0.5
 local a = p.angle-p.fov/2
 for i=1,2 do
	 local dx2,dy2 = rotate(dx,dy,a)
  line(p.x,p.y,p.x+dx2,p.y+dy2,7)
  a = p.angle+p.fov/2
 end
 spr(1,p.x-4,p.y-4)
end

function _update()
 if(btn(⬅️))p.angle+=0.0125
 if(btn(➡️))p.angle-=0.0125
 if btn(⬆️) or btn(⬇️) then
  local dx = btn(⬆️) and p.speed or -p.speed
  local dy = 0
  local dx2,dy2 = rotate(dx,dy,p.angle)
 	p.x += dx2
 	p.y += dy2
 end
end

function _draw() 
 cls(0)
	draw_game()
 draw_map()
end


__gfx__
0000000000000000eeeeeeee45454545bbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000077000eeeeeeee45454545bb3bb8bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000077000eaaeeaae45454545bb3b898b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000077700eaaeeaae55454545bbb338bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700007777070eeeeeeee54454545bbb33bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000077070eeaaeeee45454545bbb3bbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000700770eeeaeeee45454545bbb3bbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000007000000eeeeeeee45454545bbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003020303030302030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000002000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003000000040000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
