function OnInit()
 local function a(t) local s=0 for k,v in pairs(t) do s=s+v end return s end
 local function b(t) local s=0 for i,v in ipairs(t) do s=s+v end return s end
 local function c(f) local s=0 for v in f do s=s+v end return s end
 return a,b,c
end
