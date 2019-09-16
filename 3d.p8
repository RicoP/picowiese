pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--globals
local cnear = .1
local cfar  = 100
local cfov  = 50
local frame = 0

--graphics context
local gcx = {
 fill = true
}

--math
function tan(a) return
 sin(a)/cos(a)
end

function vec3_copy(res, v)
 res.x=v.x
 res.y=v.y
 res.z=v.z
 return res
end

function vec3_cross(res, a, b)
 res.x = a.y*b.z -a.z*b.y
 res.y = a.z*b.x -a.x*b.z
 res.z = a.x*b.y -a.y*b.x
 return res
end

function vec3_add(res, a, b)
 res.x=a.x+b.x
 res.y=a.y+b.y
 res.z=a.z+b.z
 return res
end

function vec3_sub(res, a, b)
 res.x=a.x-b.x
 res.y=a.y-b.y
 res.z=a.z-b.z
 return res
end

function vec3_len_sqr(v)
 return v.x*v.x+v.y*v.y+v.z*v.z
end

function vec3_dot(a,b)
 return a.x*b.x+a.y*b.y+a.z*b.z
end

function vec3_len(v)
 return sqrt(vec3_len_sqr(v))
end

function vec3_normalize(n)
 local il=1/vec3_len(n)
 n.x *= il
 n.y *= il
 n.z *= il
 return n
end

function vec3_mul(res, v, m)
 vec3_copy(res, v)
 res.x = 0
 res.x += m[1][1] * v.x
 res.x += m[2][1] * v.y
 res.x += m[3][1] * v.z
 res.x += m[4][1]

 res.y = 0
 res.y += m[1][2] * v.x
 res.y += m[2][2] * v.y
 res.y += m[3][2] * v.z
 res.y += m[4][2]

 res.z = 0
 res.z += m[1][3] * v.x
 res.z += m[2][3] * v.y
 res.z += m[3][3] * v.z
 res.z += m[4][3]

 local w = 0
 w += m[1][4] * v.x
 w += m[2][4] * v.y
 w += m[3][4] * v.z
 w += m[4][4]

 if w != 0 then
  res.x /= w
  res.y /= w
  res.z /= w
 end

 return res
end
-->8
-- 3d rasterizer

function vec3d(x, y, z)
 local this = {}
 this.x=x or 0
 this.y=y or 0
 this.z=z or 0
 return this
end

function triangle(p)
 local this = {}
 if p then
  this.p = {vec3_copy({},p[1]), vec3_copy({},p[2]), vec3_copy({},p[3])}
 else
  this.p = {vec3d(), vec3d(), vec3d()}
 end
 return this
end

function mesh()
 local this = {}
 this.tris = {}
 return this
end

function matrix()
 return {{0,0,0,0},
         {0,0,0,0},
         {0,0,0,0},
         {0,0,0,0}}
end
-->8
--draw functions

function draw_tri(tri, c)
 color(c)
 if gcx.fill then
  fill_tri(tri.p[1],tri.p[2],tri.p[3])
 else
  line(tri.p[1].x,tri.p[1].y,tri.p[2].x,tri.p[2].y)
  line(tri.p[2].x,tri.p[2].y,tri.p[3].x,tri.p[3].y)
  line(tri.p[3].x,tri.p[3].y,tri.p[1].x,tri.p[1].y)
 end
end

function draw_scanline(x,y,x2)
 rectfill(x,y,x2,y)
end

--http://www.sunshine2k.de/coding/java/trianglerasterization/trianglerasterization.html?source=post_page-----7acf535cd125----------------------
function fill_tri_bot(v1x,v1y,v2x,v2y,v3x)
 local invslope1 = (v2x-v1x) / (v2y-v1y)
 local invslope2 = (v3x-v1x) / (v2y-v1y)

 local curx1 = v1x
 local curx2 = v1x

 local scanliney=v1y
 while scanliney <= v2y do
  draw_scanline(curx1, scanliney, curx2)
  curx1 += invslope1
  curx2 += invslope2
  scanliney+=1
 end
end

function fill_tri_top(v3x,v3y,v1x,v1y,v2x)
 local invslope1 = (v3x-v1x)/(v3y-v1y)
 local invslope2 = (v3x-v2x)/(v3y-v1y)

 local curx1 = v3x
 local curx2 = v3x

 local scanliney = v3y
 while scanliney > v1y do
  draw_scanline(curx1, scanliney, curx2)
  curx1 -= invslope1
  curx2 -= invslope2
  scanliney-=1
 end
end

function fill_tri(v1,v2,v3)
 --sort tris top to bottom
 if v1.y>v2.y then v1,v2=v2,v1 end
 if v2.y>v3.y then v2,v3=v3,v2 end
 if v1.y>v2.y then v1,v2=v2,v1 end

 local v4x=(v1.x+((v2.y-v1.y)/(v3.y-v1.y)) * (v3.x-v1.x))

 fill_tri_bot(v1.x,v1.y,v2.x,ceil(v2.y),v4x)
 fill_tri_top(v3.x,v3.y,v2.x,flr(v2.y),v4x)
end
-->8
local shades = {0,1,2,3,13,4,11,7}

function print_stat()
 color(1)
 cursor(2,2)
 local memp = 100*(stat(0)/2048)
 print("memo: " .. ceil(memp) .. "%")
 print("cpu1: " .. ceil(100*stat(1)) .. "%")
 print("cpu2: " .. ceil(100*stat(2)) .. "%")
 print("fps1: " .. stat(7))
 print("fps2: " .. stat(8))
 print("fps3: " .. stat(9))
end

function _init()
end

function _draw()
 map()
 --draw triangles
 --aspect is 128:128 == 1

 local tris_drawn = 0
 local eye=vec3d(0,0,0)

 --projection matrix
 local fovrad = 1/tan(cfov/90)
 --test
 --fovrad=1.0
 local pmat=matrix()
 pmat[1][1]=fovrad
 pmat[2][2]=fovrad
 pmat[3][3]=cfar/(cfar-cnear)
 pmat[4][3]=(-cfar*cnear)/(cfar-cnear)
 pmat[3][4]=1
 pmat[4][4]=0

 local theta=frame/60.0
 local matrotz=matrix()
 matrotz[1][1]=cos(theta)
 matrotz[1][2]=sin(theta)
 matrotz[2][1]=-sin(theta)
 matrotz[2][2]=cos(theta)
 matrotz[3][3]=1
 matrotz[4][4]=1

 local matrotx=matrix()
 matrotx[1][1]=1
 matrotx[2][2]=cos(theta*.5)
 matrotx[2][3]=sin(theta*.5)
 matrotx[3][2]=-sin(theta*.5)
 matrotx[3][3]=cos(theta*.5)
 matrotx[4][4]=1

 local m = arwing_mesh
 local t = triangle()

 local num_tris = #m.faces
 for f = 1,num_tris do
  --local foff=f*3
  
  local face = m.faces[f]
  for i=1,3 do
   local p = t.p[i]
   local vidx = face[i]
   local vert = m.vert[vidx]
	  p.x=vert[1]
	  p.y=vert[2]
	  p.z=vert[3]
  end
  
  local trirotz=triangle()
  vec3_mul(trirotz.p[1],t.p[1],matrotz)
  vec3_mul(trirotz.p[2],t.p[2],matrotz)
  vec3_mul(trirotz.p[3],t.p[3],matrotz)

  local trirotzx=triangle()
  vec3_mul(trirotzx.p[1],trirotz.p[1],matrotx)
  vec3_mul(trirotzx.p[2],trirotz.p[2],matrotx)
  vec3_mul(trirotzx.p[3],trirotz.p[3],matrotx)

  local tri_trans=triangle(trirotzx.p)
  tri_trans.p[1].z += 8
  tri_trans.p[2].z += 8
  tri_trans.p[3].z += 8

  local l1 = {x=0,y=0,z=0}
  vec3_sub(l1, tri_trans.p[2],tri_trans.p[1])
  local l2 = {x=0,y=0,z=0}
  vec3_sub(l2, tri_trans.p[3],tri_trans.p[2])

  local n = {x=0,y=0,z=0}
  vec3_cross(n,l1,l2)
  vec3_normalize(n)

  local pn = vec3_sub({},tri_trans.p[1], eye)
  local d = vec3_dot(n,pn)

  if d > 0 then goto draw_tri_end end

  local tri_proj = triangle()
  vec3_mul(tri_proj.p[1],tri_trans.p[1],pmat)
  vec3_mul(tri_proj.p[2],tri_trans.p[2],pmat)
  vec3_mul(tri_proj.p[3],tri_trans.p[3],pmat)

  --move into screenspace
  tri_proj.p[1].x+=1
  tri_proj.p[1].y+=1
  tri_proj.p[2].x+=1
  tri_proj.p[2].y+=1
  tri_proj.p[3].x+=1
  tri_proj.p[3].y+=1

  tri_proj.p[1].x *=64
  tri_proj.p[1].y *=64
  tri_proj.p[2].x *=64
  tri_proj.p[2].y *=64
  tri_proj.p[3].x *=64
  tri_proj.p[3].y *=64

  local col = 1 + f%15
		gcx.fill = true
  draw_tri(tri_proj, col)
		
		gcx.fill = false
  draw_tri(tri_proj, 0)
		
		tris_drawn += 1
  ::draw_tri_end::
 end

 --fill_tri_bott(35,10,10,20,20)
 --color(14)
 --fill_tri_top(15,30,10,20,20)
 --fill_tri({x=5,y=0},{x=0,y=30},{x=20,y=20},7)
 frame += 1

 print_stat()
 print("tris: " .. tris_drawn)
end


-->8
---------------------
#include cube.lua
#include ball.lua
#include ship.lua
#include arwing.lua
#include bunny.lua
--#include monkey.lua
---------------------
__gfx__
000000000123d4b7cccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000000000cccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000000000ccc777cccc77cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000000000c7777777777777cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000000000c7777777777777cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000c77777777777777c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000c667777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccccccc67777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccccccc67777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccccccc6777777777777c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ccccccccccc677777777777c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccccccccc776667777ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccccccccc67cc67777ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccccccccccccc6777cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444444445444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000455444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444455444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444454444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444554444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
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
00000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbc00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbb00000666cc00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b0000000000066600c0c00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b000000006660000c50c00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b70000666000000c500c00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b7066600000000c5000c00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b999999999999ca0000c00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b90000000000caa0000c00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b9000000000ca0a4000c00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b900000000ca00a4000c00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b900000000c000a4000c00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b90000000c0000a0400c00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b9000000c00000a0400c00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b900000c000000a0400c00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b90000c0000000a0040c00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b9000c00000000a0040c00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b900c000000000a0004c00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b90c0000000000a0004c00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b9c00000000000a0004c00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000bcaaaaaaaaaaaaa3300c00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cccccccccccccccccccc00000000000000000000000000000000000000000000
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

__map__
1111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0311110203111111111111020311111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1311111213111102031111121311111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111112131111111111110200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1102031111111111111111111111020300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112131111020311111111111111121300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111121311110203111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122212221222121222221212221222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3132312121223131323221212222323200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2221223131322122212221313221222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3231322221222222212221223231212200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2221212231323221212221222122313200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122212232313231313231323132312122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3132313222212221212222212221212232000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122212122223231313232212231313200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3132313132323221222122313221212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000313232000031323132313200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
