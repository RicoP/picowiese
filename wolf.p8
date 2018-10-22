pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--https://lodev.org/cgtutor/raycasting.html
--player
p = {
 x=63.5/8,
 y=63.5/8,
 angle=0,
 speed=1/8,
}

fov=70/360

function rotate(x,y,angle)
 -- rotates a 2d vector around zero
 local a = angle
 local dx2 = cos(a)*x - sin(a)*y
 local dy2 = sin(a)*x + cos(a)*y
 return dx2,dy2
end

function get_tile(x,y,a)
 local dx,dy=rotate(0.1,0,a)
 local distance=0
 -- loop until we find the tile
 for i=1,1000 do --limit by n steps
  local tx = flr(x)
  local ty = flr(y)
  local s = mget(tx,ty)
  if s!=0 then
   return s,distance,flr(x*8)%8
  end
  x+=dx
  y+=dy
  distance+=1
 end
 return 0,0,0
end

function draw_game()
 camera()
 local a = p.angle+fov/2
 for i=1,128 do
  local t,d,px=get_tile(p.x,p.y,a)
  a-=fov/(128)
  local h = 64/d
  sspr(t*8+px,0,1,8,i-1,64-(64-d)/2,1,64-d)
 end
end

function draw_map()
 camera(p.x*8 - 64, p.y*8 - 64)

 map(0,0, 0,0, 64, 64);
 
 -- sight ray
 -- by default we look along +x
 local dx = 100.5
 local dy = 0.5
 local a = p.angle-fov/2
 for i=1,2 do
	 local dx2,dy2 = rotate(dx,dy,a)
  line(p.x*8,p.y*8,p.x*8+dx2,p.y*8+dy2,7)
  a = p.angle+fov/2
 end
 spr(1,p.x*8-4,p.y*8-4)
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

function vertline(x,y1,y2,c)
 line(x,y1,x,y2,c)
end

function draw_game2()
 camera()
 local a = p.angle+fov/2
 for x=1,128 do  
  local camx= -1+2*x/128
  --maybe work with a plane here
  local rayx,rayy=rotate(1,0,a)
  local mapx,mapy=flr(p.x),flr(p.y)
  local deltadistx=abs(1/rayx)
  local deltadisty=abs(1/rayy)
  
  local sidedistx,sidedisty=0,0
  local stepx,stepy=0,0
  
  if rayx < 0 then
   stepx=-1
   sidedistx=(p.x-mapx)*deltadistx
  else
   stepx=1
   sidedistx=(mapx+1-p.x)*deltadistx
  end
  
  if rayy < 0 then
   stepy=-1
   sidedisty=(p.y-mapy)*deltadisty
  else
   stepy=1
   sidedisty=(mapy+1-p.y)*deltadisty
  end

		local hit=0
		local side=false
		repeat
		 if sidedistx<sidedisty then
		  sidedistx+=deltadistx
		  mapx+=stepx
		  side=false
		 else
		  sidedisty+=deltadisty
		  mapy+=stepy
		  side=true
		 end
   hit = mget(mapx,mapy)		 
		until hit != 0

  local perpwalldist=0
		if not side then
   perpwalldist=(mapx-p.x+(1-stepx)/2)/rayx
		else
   perpwalldist=(mapy-p.y+(1-stepy)/2)/rayy
		end
		
		local lineh=128/perpwalldist		
		local drawstart=-lineh/2 + 64
		if(drawstart<0)drawstart=0
		local drawend=lineh/2+64
		if(drawend>=128)drawend=127
  
  --fake color
  local c=hit
  if(side)c+=8
  
  vertline(x,drawstart,drawend,c)
  
  a-=fov/(128)
 end 
end

function _draw() 
 cls(0)
	draw_game2()
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
0303030303030303030303030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000003020303030302030000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000003000000000000020000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000003000000000000030000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000002000000000000030000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000003000000040000030000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000003000000000000020000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000003030303030303030000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
