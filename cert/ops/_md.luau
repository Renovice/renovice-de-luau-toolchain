function OnInit() local o={} function o:m() return 7 end local x=o:m() if x==7 then else error("MD") end error("MDEF_OK") end
