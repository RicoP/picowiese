pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--https://lodev.org/cgtutor/raycasting.html
--player
p = {
 x=63.5/8,
 y=67.5/8,
 angle=0,
 speed=1/8,
}

fov=70/360
mouse = {x=0,y=0,down=false}

function rotate(x,y,angle)
 -- rotates a 2d vector around zero
 local a = angle
 local dx2 = cos(a)*x - sin(a)*y
 local dy2 = sin(a)*x + cos(a)*y
 return dx2,dy2
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

function vertline(x,y1,y2,tile,texx)
 local tx = (tile%16)*8 
 local ty = flr(tile/16)*8
 --line(x,y1,x,y2,c)
 --sspr(t*8+px,0,1,8,i-1,64-(64-d)/2,1,64-d)
 --sspr(tile*8+8-texx-1,0,1,8,x,y1,1,y2-y1)
 sspr(tx+texx,ty,1,16,x,y1,1,y2-y1)
 
end

function draw_game()
 camera()
 rectfill(0,0,128,64,12)
 rectfill(0,64,128,128,15)
 local a = p.angle+fov/2
 for x=0,127 do  
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
		--if(drawstart<0)drawstart=0
		local drawend=lineh/2+64
		--if(drawend>=128)drawend=127
  
  local wallx=0
  if not side then
   wallx=p.y+perpwalldist*rayy
  else
   wallx=p.x+perpwalldist*rayx
  end
  wallx-=flr(wallx)
  
  local texx=flr(wallx*16)
  if not side and rayx>0 then
   texx=16-texx-1
  end
  if side and rayy<0 then
   texx=16-texx-1
  end
    
  vertline(x,drawstart,drawend,hit,texx)
  
  a-=fov/(128)
 end 
end

function _init()
 poke(0x5f2d, 1)
end

drawmap=false
function _draw() 
 if(btnp(❎))drawmap=not drawmap
	draw_game()
 if(drawmap)draw_map()
 mouse.x=stat(32)
 mouse.y=stat(33)
 mouse.down= stat(34) == 1
 spr(16,mouse.x-1,mouse.y-1,1,1,mouse.down)
end

__gfx__
0000000000000000eeeeeeee45454545bbbbbbbb4444444455555555000000000000000000000000000000000000000000000000000000000000000000000000
0000000000077000eeeeeeee45455545bb3bb8bb4000000454444445000000000000000000000000000000000000000000000000000000000000000000000000
0070070000077000eaaeeaae45454545bb3b898b4000000454444445000000000000000000000000000000000000000000000000000000000000000000000000
0007700000077700eaaeeaae55454555bbb338bb4000000454444445000000000000000000000000000000000000000000000000000000000000000000000000
0007700007777070eeeeeeee54454545bbb33bbb4000000454444445000000000000000000000000000000000000000000000000000000000000000000000000
0070070000077070eeaaeeee45454545bbb3bbbb4000000454444545000000000000000000000000000000000000000000000000000000000000000000000000
0000000000700770eeeaeeee45455545bbb3bbbb4000000454444445000000000000000000000000000000000000000000000000000000000000000000000000
0000000007000000eeeeeeee45454545bbbbbbbb4444444454444445000000000000000000000000000000000000000000000000000000000000000000000000
01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17771000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17777100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17711000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01171000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555555555555eeeeeeeeeeeeeeee222222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
5444444444444445eeeeeeeeeeeeeeee222222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
5444444444444445eeeeeeeeeeeeeeee222222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
5445555555555445eee333ee333eeeee222222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
5445444444445445eeee3eeee3eeeeee222222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
5445444444445445eeeeeeeeeeeeeeee222222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
5445444444445445eeeeeeeeeeeeeeee222222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
5445444444445445eeeeeeeeeeeeeeee222222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
5445444444445445eeeeeeeeeeeeeeee222222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
5445444445545445eeeeeeeeeeeeeeee222222222822222200000000000000000000000000000000000000000000000000000000000000000000000000000000
5445444445545445eee33eeeeee3eeee222222228982222200000000000000000000000000000000000000000000000000000000000000000000000000000000
5445444444445445eeee33eeeee3eeee2222222228b2222200000000000000000000000000000000000000000000000000000000000000000000000000000000
5445444444445445eeeeee33333eeeee222222222b22222200000000000000000000000000000000000000000000000000000000000000000000000000000000
5445444444445445eeeeeeeeeeeeeeee2222222b2b22222200000000000000000000000000000000000000000000000000000000000000000000000000000000
5445444444445445eeeeeeeeeeeeeeee22222222bb22222200000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555555555555eeeeeeeeeeeeeeee222222222b22222200000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000040404040404040400000404040404040400000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000040000000000000400000400000000000400000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000040000000000000400000400000000000400000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000040000000000000404040400000000000400000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000040000000000000000000000000420000400000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000040000000004400404040400000000000400000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000040000000000000400000400000000000400000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000040404040404040400000404040404040400000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
