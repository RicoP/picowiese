pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- @gabrielcrowe
-- some perlin noise and a scrolly desert
function _init()
  local f={}
  local p={}
  local permutation={151,160,137,91,90,15,
   131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
   190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
   88,237,149,56,87,174,20,125,136,171,168,68,175,74,165,71,134,139,48,27,166,
   77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
   102,143,54,65,25,63,161,1,216,80,73,209,76,132,187,208,89,18,169,200,196,
   135,130,116,188,159,86,164,100,109,198,173,186,3,64,52,217,226,250,124,123,
   5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
   223,183,170,213,119,248,152,2,44,154,163,70,221,153,101,155,167,43,172,9,
   129,22,39,253,19,98,108,110,79,113,224,232,178,185,112,104,218,246,97,228,
   251,34,242,193,238,210,144,12,191,179,162,241,81,51,145,235,249,14,239,107,
   49,192,214,31,181,199,106,157,184,84,204,176,115,121,50,45,127,4,150,254,
   138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
  }

  for i=0,255 do
   local t=shr(i,8)
   f[t]=t*t*t*(t*(t*6-15)+10)

   p[i]=permutation[i+1]
   p[256+i]=permutation[i+1]
  end

  local function lerp(t,a,b)
   return a+t*(b-a)
  end

  local function grad(hash,x,y,z)
   local h=band(hash,15)
   local u,v,r

   if h<8 then u=x else u=y end
   if h<4 then v=y elseif h==12 or h==14 then v=x else v=z end
   if band(h,1)==0 then r=u else r=-u end
   if band(h,2)==0 then r=r+v else r=r-v end

   return r
  end

  function noise(x,y,z)
   y=y or 0
   z=z or 0

   local xi=band(x,255)
   local yi=band(y,255)
   local zi=band(z,255)

   x=band(x,0x0.ff)
   y=band(y,0x0.ff)
   z=band(z,0x0.ff)

   local u=f[x]
   local v=f[y]
   local w=f[z]

   local a =p[xi  ]+yi
   local aa=p[a   ]+zi
   local ab=p[a+1 ]+zi
   local b =p[xi+1]+yi
   local ba=p[b   ]+zi
   local bb=p[b+1 ]+zi

   return lerp(w,lerp(v,lerp(u,grad(p[aa  ],x  ,y  ,z  ),
                               grad(p[ba  ],x-1,y  ,z  )),
                        lerp(u,grad(p[ab  ],x  ,y-1,z  ),
                               grad(p[bb  ],x-1,y-1,z  ))),
                 lerp(v,lerp(u,grad(p[aa+1],x  ,y  ,z-1),
                               grad(p[ba+1],x-1,y  ,z-1)),
                        lerp(u,grad(p[ab+1],x  ,y-1,z-1),
                               grad(p[bb+1],x-1,y-1,z-1))))
  end



music(0)
t=0
cls()
seed = rnd(9999);
srand(1)

camx = 0
camy = 0
c1_x = 0
c1_y = 0
tile = 32
zoom = 128
biome = 16 --16 for sand, 0 for full range, 32 for icy tundra

--wind_
wind_x = 1
wind_y = 1
wind_t = 0;


stars={}
s_col={3,6,9,12}
s_spr={12,13,14,15}
s_mult = 1;
for star=0,20 do
  s={}
  s.x = rnd(128)
  s.y = rnd(128)
  s.spr = s_spr[flr(rnd(4))+1]
  s.px = s.x;
  s.py = s.y;
  s.col = s_col[flr(rnd(4))+1]
  add(stars,s)
end

function draw_stars()

  wind_t+=0.2;

  wind_x = cos(wind_t/100)
  wind_y = sin(wind_t/100)

  s.x -= s.col*wind_x;
  s.y -= s.col*wind_y;

  for s in all(stars) do
    s.x -= s.col*wind_x;
    s.y -= s.col*wind_y;
    if(s.x<0) then s.x = 128; s.px = s.x; end
    if(s.y<0) then s.y = 128; s.py = s.y; end
    if(s.x>128) then s.x = 0; s.px = s.x; end
    if(s.y>128) then s.y = 0; s.py = s.y; end
    spr(s.spr,camx+s.px,camy+s.py)
    --line(camx+s.x,camy+s.y,camx+s.px,camy+s.py,s.col)
   s.px = s.x; s.py = s.y;
  end
end

function get_spr(c,set)
  local sp = 1
  if (c==1 ) sp =  0+set --deep water
  if (c==12) sp =  1+set --shallow water
  if (c==10) sp =  2+set --beach
  if (c==11) sp =  3+set --field
  if (c==3 ) sp =  4+set --forest
  if (c==4 ) sp =  5+set --dirt
  if (c==7 ) sp =  6+set --snow
  return sp
end

function get_col(v)
  local c = 1 --sea
  if (v>-0.3) c=12 --shallow water
  if (v>-0.1) c=10 --beach
  if (v>0.01) c=11 --field
   if (v>0.3) c=3 --forest
   if (v>0.5) c=4 --dirt
   if (v>0.6) c=7 --snow
   return c
end

function get_tile(x,y,z)
    nx = (x/z)
    ny = (y/z);
    v = noise(nx+seed, ny+seed, zoom)
    return get_col(v)
end

  -- zones
  zones={}
  function mk_zone(x,y)
    z={}
    z.x = flr(x)
    z.y = flr(y)

    --srand(seed+x+y)
    --z.tile_seed = rnd(15)  --science!
    --nx = flr(x/zoom)
    --ny = flr(y/zoom)
    --z.v = noise(nx+seed, ny+seed)

    tiles_spr={}
    tiles_x={}
    tiles_y={}

    for ii=0,3 do
      for jj=0,3 do
        tile_spr_c = get_tile(x+(ii*8),y+(jj*8),zoom)
        add(tiles_spr,get_spr(tile_spr_c,biome))
        add(tiles_x,z.x+(ii*8))
        add(tiles_y,z.y+(jj*8))
      end
    end
    z.t_spr = tiles_spr;
    z.t_x = tiles_x;
    z.t_y = tiles_y;

    add(zones,z)
  end
  function draw_zone(z)
    for ii=0,16 do
      t_spr = z.t_spr[ii]
      t_x = z.t_x[ii]
      t_y = z.t_y[ii]
      spr(t_spr,t_x,t_y)
    end
  end

  function update_zone(z)
    if( z.x > c1_x and z.x < c1_x+128 and  z.y > c1_y and z.y < c1_y+128 ) then
      --nothing
    else
      del(zones,z)
    end
  end


end

function _update()
  
 foreach(zones,update_zone)
 for i=0,4 do
   for j=0,4 do
     block_x1 = (i+flr(c1_x/tile))*tile
     block_y1 = (j+flr(c1_y/tile))*tile
     zone_exist = false;
     foreach(zones, function(z)
       if ( z.x == block_x1 and z.y==block_y1 ) zone_exist = true;
     end)
     if(zone_exist==false) then mk_zone(block_x1,block_y1) end
   end
 end

 spd=3;
 if(btn(0)) camx -=spd
 if(btn(1)) camx +=spd
 if(btn(2)) camy -=spd
 if(btn(3)) camy +=spd

 --camy +=spd*2
 c1_x += ((camx)-c1_x) * 0.1
 c1_y += ((camy)-c1_y) * 0.1

 camera(c1_x,c1_y)
end



function _draw()
cls();
foreach(zones,draw_zone)
draw_stars()
print('mem:'..stat(0), c1_x, c1_y, 7)
print('cpu:'..stat(1), c1_x, c1_y+8, 7)

end

__gfx__
11111111ccccccccaaaaaaa9bbbbbbbb333333334444444477777777000000000000000000000000000000000000000000000000000000000000000000000000
11c11111ccccc7ccaaa9aaaabbbbbb3b33333353455444447777777700000000000000000000000000000000000000000000400000a0a0000000000000aaa000
1c1c1111cccc7c7caaaaaaaabb3bbbbb3335333344544554777776770000000000000000000000000000000000000000000000000000000000a000000a000a00
11111111cccccccca9aaaa9abbbbbbbb35333333444444547777777700000000000000000000000000000000000000000000000000040a000a0090a00a040a00
11111111ccccccccaaaaaaaabbb3bbbb33333353444444447777777700000000000000000000000000000000000000000009000000099000000490000a099000
11111c11cc7cccccaaaaaaaabbbbbbbb333333334445544477777777000000000000000000000000000000000000000000000a00000000000a0000a00a000000
1111c1c1c7c7ccccaaa9aa9ab3bbbb3b3333333344445444767777770000000000000000000000000000000000000000000000000000000000a0aa0000aaa000
11111111ccccccccaaaaaaaabbbbbbbb333353334444444477777777000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaaaaaaaaaaa99a99aa99999999449949449444444944444444000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaaaa99aaaa99aa99999999999999449999449944444444454400000000000000000000000000000000000000000000400000a0a0000000000000aaa000
aaaaaaaaa9aaaa999a9999aa999999994499994449444494454444440000000000000000000000000000000000000000000000000000000000a000000a000a00
aaaaaaaaaaaaa9aa99999a999999999999994499444499444444444400000000000000000000000000000000000000000000000000040a000a0090a00a040a00
aaaaaaaaaaaaaaaa9999999a9999999949999999444444444444544400000000000000000000000000000000000000000009000000099000000490000a099000
aaaaaaaaaaa99aaaa99aa99999999999999449944449944445444444000000000000000000000000000000000000000000000a00000000000a0000a00a000000
aaaaaaaaaa9aaaaa99a99999999999999449999949944944444444540000000000000000000000000000000000000000000000000000000000a0aa0000aaa000
aaaaaaaaaaaaaaaaa999a9aa99999999499949449444444944444444000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777667667766666666666666665555555555555555000000000000000000000000000000000000000000000000000000000000000000000000
7777777777667777667766666666666666566666556655555555550500000000000000000000000000000000000000000000400000a0a0000000000000aaa000
777777777677776667666677666666666555666656666555555550050000000000000000000000000000000000000000000000000000000000a000000a000a00
7777777777777677666667666666666666666666555555555005555500000000000000000000000000000000000000000000000000040a000a0090a00a040a00
7777777777777777666666676666666666666666555555655555555500000000000000000000000000000000000000000009000000099000000490000a099000
77777777777667777667766666666666666665665566566655550055000000000000000000000000000000000000000000000a00000000000a0000a00a000000
777777777767777766766666666666666666555656665555555555550000000000000000000000000000000000000000000000000000000000a0aa0000aaa000
77777777777777777666767766666666666666665555555555555555000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0040000002630076300c63010630176301c620216202562026630286302a6302b6302b6302b6302a63028630266302462022620216201e6201c620186301663013630106300d6300a63008620056200262001610
004000003761037610346102d6102961028610286102a6102d61033610366103761036610306102b610266102261020610226102c610366103a6103a6103a6103a61037610306102a6102a6102a6102c61032610
__music__
02 00014344

