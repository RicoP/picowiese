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
