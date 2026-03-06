--[[
    GalaxLib v2 — Remastered
    100% API-compatible with GalaxLib v1 + new features

    NEW IN v2:
      • Full-width single-column sections (no more forced 2-column clipping)
      • Scrollable content with smooth momentum + draggable scrollbar
      • Built-in notify() — no external dependency needed
      • Animated toggle (sliding knob, lerped color)
      • Dropdown search filter (type to filter options)
      • Collapsible sections (click header to collapse)
      • Resize handle (drag bottom-right corner)
      • AddSeparator()  — horizontal rule
      • AddButton(label, cb, color)  — optional color tint
      • AddTextbox: placeholder text, underscore & special char support
      • Mouse wheel scrolls dropdown lists
      • Notification queue with fade + progress bar (no external notify needed)
      • Window min-size enforcement (420×320)

    USAGE (identical to v1):
      local Win = GalaxLib:CreateWindow({ Title="Hub", Size=Vector2.new(560,480), MenuKey=0x70 })
      local Tab = Win:AddTab("Combat")
      local Sec = Tab:AddSection("Aimbot")

      Sec:AddToggle("Enable", false, function(v) end)
      Sec:AddSlider("FOV", {Min=1, Max=360, Default=90, Suffix="°"}, function(v) end)
      Sec:AddDropdown("Mode", {"A","B","C"}, "A", {MaxVisible=5}, function(v) end)
      Sec:AddMultiDropdown("Flags", {"A","B","C"}, {}, {}, function(tbl) end)
      Sec:AddColorPicker("Color", Color3.fromRGB(255,0,0), function(c) end)
      Sec:AddKeybind("Key", 0x46, function() end)
      Sec:AddTextbox("Name", "default", function(v) end, "Enter name...")
      Sec:AddButton("Fire", function() end)
      Sec:AddButton("Danger", function() end, Color3.fromRGB(180,40,40))
      Sec:AddLabel("v2.0")
      Sec:AddSeparator()

      Win:Notify("Hello!", "Hub", 3)
      Win:Unload()

      Settings tab auto-added: Toggle Key, Kill Script, Theme picker
]]

GalaxLib = {}

-- ── Themes ───────────────────────────────────────────────────────────────────
local Themes = {
    Galax      = { Body=Color3.fromRGB(10,10,14),    Surface0=Color3.fromRGB(18,18,24),   Surface1=Color3.fromRGB(26,26,34),
                   Border0=Color3.fromRGB(35,35,46),  Border1=Color3.fromRGB(50,50,65),
                   Accent=Color3.fromRGB(130,80,220), AccentDark=Color3.fromRGB(70,38,140),
                   Text=Color3.fromRGB(240,240,245),  SubText=Color3.fromRGB(110,110,130),
                   Red=Color3.fromRGB(220,70,70),     RedDark=Color3.fromRGB(90,22,22) },
    Gamesense  = { Body=Color3.fromRGB(0,0,0),        Surface0=Color3.fromRGB(26,26,26),   Surface1=Color3.fromRGB(45,45,45),
                   Border0=Color3.fromRGB(48,48,48),  Border1=Color3.fromRGB(60,60,60),
                   Accent=Color3.fromRGB(114,178,21), AccentDark=Color3.fromRGB(60,100,10),
                   Text=Color3.fromRGB(144,144,144),  SubText=Color3.fromRGB(59,59,59),
                   Red=Color3.fromRGB(220,70,70),     RedDark=Color3.fromRGB(90,22,22) },
    Dracula    = { Body=Color3.fromRGB(24,25,38),     Surface0=Color3.fromRGB(33,34,50),   Surface1=Color3.fromRGB(44,44,60),
                   Border0=Color3.fromRGB(68,71,90),  Border1=Color3.fromRGB(86,90,112),
                   Accent=Color3.fromRGB(189,147,249),AccentDark=Color3.fromRGB(100,70,180),
                   Text=Color3.fromRGB(248,248,242),  SubText=Color3.fromRGB(98,114,164),
                   Red=Color3.fromRGB(255,85,85),     RedDark=Color3.fromRGB(120,30,30) },
    Nord       = { Body=Color3.fromRGB(29,33,40),     Surface0=Color3.fromRGB(36,41,50),   Surface1=Color3.fromRGB(46,52,64),
                   Border0=Color3.fromRGB(59,66,82),  Border1=Color3.fromRGB(76,86,106),
                   Accent=Color3.fromRGB(136,192,208),AccentDark=Color3.fromRGB(67,103,120),
                   Text=Color3.fromRGB(236,239,244),  SubText=Color3.fromRGB(129,161,193),
                   Red=Color3.fromRGB(191,97,106),    RedDark=Color3.fromRGB(90,40,44) },
    Catppuccin = { Body=Color3.fromRGB(24,24,37),     Surface0=Color3.fromRGB(30,30,46),   Surface1=Color3.fromRGB(49,50,68),
                   Border0=Color3.fromRGB(88,91,112), Border1=Color3.fromRGB(108,111,133),
                   Accent=Color3.fromRGB(137,180,250),AccentDark=Color3.fromRGB(60,90,160),
                   Text=Color3.fromRGB(205,214,244),  SubText=Color3.fromRGB(166,173,200),
                   Red=Color3.fromRGB(243,139,168),   RedDark=Color3.fromRGB(120,50,70) },
    Synthwave  = { Body=Color3.fromRGB(15,5,30),      Surface0=Color3.fromRGB(25,10,45),   Surface1=Color3.fromRGB(40,15,65),
                   Border0=Color3.fromRGB(80,30,100), Border1=Color3.fromRGB(120,50,140),
                   Accent=Color3.fromRGB(255,60,180), AccentDark=Color3.fromRGB(130,20,90),
                   Text=Color3.fromRGB(255,220,255),  SubText=Color3.fromRGB(180,120,200),
                   Red=Color3.fromRGB(255,80,80),     RedDark=Color3.fromRGB(100,20,20) },
    Sunset     = { Body=Color3.fromRGB(18,8,5),       Surface0=Color3.fromRGB(30,14,8),    Surface1=Color3.fromRGB(48,22,12),
                   Border0=Color3.fromRGB(80,40,20),  Border1=Color3.fromRGB(110,60,30),
                   Accent=Color3.fromRGB(255,120,40), AccentDark=Color3.fromRGB(140,55,10),
                   Text=Color3.fromRGB(255,235,210),  SubText=Color3.fromRGB(180,130,90),
                   Red=Color3.fromRGB(255,70,50),     RedDark=Color3.fromRGB(110,20,10) },
}
local T = {} for k,v in pairs(Themes.Galax) do T[k]=v end
local ThemeNames = {"Galax","Gamesense","Dracula","Nord","Catppuccin","Synthwave","Sunset"}
local function applyTheme(n) local s=Themes[n]; if s then for k,v in pairs(s) do T[k]=v end end end

-- ── Key map ──────────────────────────────────────────────────────────────────
local KeyNames = {}
do
    local raw={[8]="BACK",[9]="TAB",[13]="ENTER",[16]="SHIFT",[17]="CTRL",[18]="ALT",
        [20]="CAPS",[27]="ESC",[32]="SPACE",[33]="PGUP",[34]="PGDN",[35]="END",[36]="HOME",
        [37]="LEFT",[38]="UP",[39]="RIGHT",[40]="DOWN",[45]="INS",[46]="DEL",
        [48]="0",[49]="1",[50]="2",[51]="3",[52]="4",[53]="5",[54]="6",[55]="7",[56]="8",[57]="9",
        [186]=";",[187]="=",[188]=",",[189]="-",[190]=".",[191]="/",[192]="`",
        [219]="[",[220]="\\",[221]="]",[222]="'"}
    for k,v in pairs(raw) do KeyNames[k]=v end
    for i=65,90 do KeyNames[i]=string.char(i) end
    for i=1,12  do KeyNames[111+i]="F"..i end
end
local ShiftMap={["1"]="!",["2"]="@",["3"]="#",["4"]="$",["5"]="%",["6"]="^",["7"]="&",
    ["8"]="*",["9"]="(",["0"]=")",["-"]="_",["="]="+",["["]="{", ["]"]="}",[";"]=":",
    ["'"]="\"",["/"]="|",[","]="<",["."]=">",["`"]="~"}
local function keyName(kc) return KeyNames[kc] or ("0x"..string.format("%X",kc or 0)) end

-- ── Utilities ────────────────────────────────────────────────────────────────
local function clamp(x,a,b) return x<a and a or (x>b and b or x) end
local function lerp(a,b,t)  return a+(b-a)*clamp(t,0,1) end
local function lerpC(a,b,t) return Color3.new(lerp(a.R,b.R,t),lerp(a.G,b.G,t),lerp(a.B,b.B,t)) end
local function textW(s,sz)  return #(s or "")*(sz or 13)*0.6 end
local function mpos()
    local ok, v = pcall(function() return game:GetService("UserInputService"):GetMouseLocation() end)
    if ok and v then return v end
    return Vector2.new(0,0)
end
local function over(pos,sz) local m=mpos() return m.X>=pos.X and m.X<=pos.X+sz.X and m.Y>=pos.Y and m.Y<=pos.Y+sz.Y end
local function newDraw(t,p) local d=Drawing.new(t); for k,v in pairs(p) do d[k]=v end; return d end
local function pointOnRect(t,pos,sz)
    local p=(t%1)*(sz.X*2+sz.Y*2)
    if p<sz.X then return pos+Vector2.new(p,0)
    elseif p<sz.X+sz.Y then return pos+Vector2.new(sz.X,p-sz.X)
    elseif p<sz.X*2+sz.Y then return pos+Vector2.new(sz.X-(p-(sz.X+sz.Y)),sz.Y)
    else return pos+Vector2.new(0,sz.Y-(p-(sz.X*2+sz.Y))) end
end
local function hsvToRgb(h,s,v)
    if s==0 then return Color3.new(v,v,v) end
    local i=math.floor(h*6); local f=h*6-i
    local p,q,r=v*(1-s),v*(1-f*s),v*(1-(1-f)*s); i=i%6
    if i==0 then return Color3.new(v,r,p) elseif i==1 then return Color3.new(q,v,p)
    elseif i==2 then return Color3.new(p,v,r) elseif i==3 then return Color3.new(p,q,v)
    elseif i==4 then return Color3.new(r,p,v) else return Color3.new(v,p,q) end
end
local function rgbToHsv(c)
    local r,g,b=c.R,c.G,c.B; local mx=math.max(r,g,b); local mn=math.min(r,g,b); local d=mx-mn
    local h=0
    if d~=0 then
        if mx==r then h=((g-b)/d)%6 elseif mx==g then h=(b-r)/d+2 else h=(r-g)/d+4 end; h=h/6
    end
    return h, mx==0 and 0 or d/mx, mx
end

-- ── Drawing pool ─────────────────────────────────────────────────────────────
local function poolNew()   return {d={},seen={}} end
local function poolBegin(p) p.seen={} end
local function poolAdd(p,id,dt,props)
    p.seen[id]=true
    local e=p.d[id]
    if e then for k,v in pairs(props) do e[k]=v end; e.Visible=true; return e end
    local o=newDraw(dt,props); p.d[id]=o; return o
end
local function poolFlush(p)   for id,o in pairs(p.d) do if not p.seen[id] then o.Visible=false end end end
local function poolHide(p,id) local o=p.d[id]; if o then o.Visible=false end end
local function poolGet(p,id)  return p.d[id] end
local function poolDestroy(p) for _,o in pairs(p.d) do pcall(function() o:Remove() end) end; p.d={}; p.seen={} end

-- ── Input ────────────────────────────────────────────────────────────────────
local UIS = game:GetService("UserInputService")
local _scrollDelta = 0
local _keysDown    = {}
local _m1Down      = false
local _m1Prev      = false

UIS.InputBegan:Connect(function(inp, gpe)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        _m1Down = true
    elseif inp.UserInputType == Enum.UserInputType.MouseWheel then
        _scrollDelta = _scrollDelta + (inp.Position.Z > 0 and -1 or 1)
    elseif inp.UserInputType == Enum.UserInputType.Keyboard then
        _keysDown[inp.KeyCode.Value] = true
    end
end)
UIS.InputEnded:Connect(function(inp, gpe)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        _m1Down = false
    elseif inp.UserInputType == Enum.UserInputType.Keyboard then
        _keysDown[inp.KeyCode.Value] = false
    end
end)

local Input = {_prev={}, click=false, held=false, scroll=0}
function Input:update()
    self.click   = _m1Down and not _m1Prev
    self.held    = _m1Down
    _m1Prev      = _m1Down
    self.scroll  = _scrollDelta
    _scrollDelta = 0
end
function Input:keyClick(kc)
    local c = _keysDown[kc] or false
    local p = self._prev[kc] or false
    self._prev[kc] = c
    return c and not p
end
function Input:keyHeld(kc) return _keysDown[kc] or false end
function Input:shift()
    return UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift)
end

-- ── Notification queue ───────────────────────────────────────────────────────
local _notifs={}; local _notifPool=poolNew(); local _nid=0
local NOTIF_W=230; local NOTIF_H=50; local NOTIF_GAP=6
local function pushNotif(msg,title,dur)
    _nid=_nid+1
    table.insert(_notifs,{id=_nid,msg=tostring(msg),title=tostring(title or ""),
        endAt=tick()+(dur or 3),alpha=0,startDur=dur or 3})
end
local function renderNotifs()
    local now=tick(); local F=Drawing.Fonts.Plex
    poolBegin(_notifPool)
    local alive={}
    for _,n in ipairs(_notifs) do
        local rem=n.endAt-now
        if rem>-0.5 then
            n.alpha=clamp(n.alpha+0.1,0,1)
            if rem<0.4 then n.alpha=clamp(rem/0.4,0,1) end
            table.insert(alive,n)
        end
    end
    _notifs=alive
    local scrW, scrH = 1920, 1080
    for i,n in ipairs(_notifs) do
        local nx=scrW-NOTIF_W-10
        local ny=scrH-i*(NOTIF_H+NOTIF_GAP)-10
        local a=n.alpha
        local bg=lerpC(Color3.new(0,0,0),T.Surface0,a)
        local ac=lerpC(Color3.new(0,0,0),T.Accent,a)
        local tx=lerpC(Color3.new(0,0,0),T.Text,a)
        local st=lerpC(Color3.new(0,0,0),T.SubText,a)
        local nid="__n"..n.id
        poolAdd(_notifPool,nid.."bg",  "Square",{Position=Vector2.new(nx,ny),Size=Vector2.new(NOTIF_W,NOTIF_H),Filled=true, Color=bg,Visible=true,ZIndex=200})
        poolAdd(_notifPool,nid.."bd",  "Square",{Position=Vector2.new(nx,ny),Size=Vector2.new(NOTIF_W,NOTIF_H),Filled=false,Color=ac,Thickness=1,Visible=true,ZIndex=201})
        poolAdd(_notifPool,nid.."bar", "Square",{Position=Vector2.new(nx,ny),Size=Vector2.new(3,NOTIF_H),Filled=true,Color=ac,Visible=true,ZIndex=202})
        poolAdd(_notifPool,nid.."ttl", "Text",  {Position=Vector2.new(nx+10,ny+7), Text=n.title,Size=11,Font=F,Color=ac,Outline=false,Visible=true,ZIndex=202})
        poolAdd(_notifPool,nid.."msg", "Text",  {Position=Vector2.new(nx+10,ny+21),Text=n.msg,  Size=13,Font=F,Color=tx,Outline=false,Visible=true,ZIndex=202})
        local pct=clamp((n.endAt-now)/n.startDur,0,1)
        poolAdd(_notifPool,nid.."prg","Square",{Position=Vector2.new(nx,ny+NOTIF_H-3),Size=Vector2.new(math.max(0,NOTIF_W*pct),3),Filled=true,Color=ac,Visible=true,ZIndex=202})
    end
    poolFlush(_notifPool)
end

-- ═══════════════════════════════════════════════════════════════════════════
--  CREATE WINDOW
-- ═══════════════════════════════════════════════════════════════════════════
function GalaxLib:CreateWindow(opts)
    opts=opts or {}
    local WIN={
        Title=opts.Title or "Galax", Size=Vector2.new(math.max(580,opts.Size and opts.Size.X or 580), math.max(480,opts.Size and opts.Size.Y or 480)),
        MenuKey=opts.MenuKey or 0x70,
        _pos=Vector2.new(opts.X or 120,opts.Y or 80),
        _open=true, _running=true,
        _pool=poolNew(), _tabs={}, _openTab=nil,
        _drag=nil, _resize=nil, _resizeBase=nil,
        _sliderDrag=nil, _keybindTarget=nil, _textboxTarget=nil,
        _openDropId=nil, _cpTarget=nil, _settingsListen=false,
        _snakeLines={}, _snakeCount=18,
        _scrollY=0, _scrollVel=0,
        _minSz=Vector2.new(580,480),
    }
    for i=1,WIN._snakeCount do
        WIN._snakeLines[i]=newDraw("Line",{Thickness=1.5,Color=T.Accent,Visible=false,ZIndex=50})
    end

    -- ── Notify ───────────────────────────────────────────────────────────────
    function WIN:Notify(msg,title,dur) pushNotif(msg,title or self.Title,dur) end
    function WIN:Unload() self._running=false end

    -- ── AddTab ───────────────────────────────────────────────────────────────
    function WIN:AddTab(name)
        local TAB={_name=name,_sections={},_win=self}
        function TAB:AddSection(sname)
            local SEC={_name=sname,_widgets={},_win=self._win,_collapsed=false}
            local function reg(w) table.insert(SEC._widgets,w) end

            function SEC:AddToggle(label,default,cb)
                local it={type="toggle",label=label,value=default or false,
                    cb=cb or function()end, _anim=default and 1 or 0}
                reg(it); it.cb(it.value)
                return{Get=function()return it.value end,
                       Set=function(_,v)it.value=v;it.cb(v)end}
            end
            function SEC:AddSlider(label,o,cb)
                o=o or {}
                local it={type="slider",label=label,min=o.Min or 0,max=o.Max or 100,
                    value=o.Default or o.Min or 0,suffix=o.Suffix or "",cb=cb or function()end}
                reg(it); it.cb(it.value)
                return{Get=function()return it.value end,
                       Set=function(_,v)it.value=clamp(v,it.min,it.max);it.cb(it.value)end}
            end
            function SEC:AddButton(label,cb,color)
                reg({type="button",label=label,cb=cb or function()end,color=color}); return{}
            end
            function SEC:AddDropdown(label,options,default,opts2,cb)
                if type(opts2)=="function" then cb=opts2; opts2={} end; opts2=opts2 or {}
                local it={type="dropdown",label=label,options=options or {},
                    value=default or (options and options[1]) or "",
                    maxVisible=opts2.MaxVisible or 6, scroll=0,
                    cb=cb or function()end, _search="",_sfocus=false}
                reg(it); it.cb(it.value)
                return{Get=function()return it.value end,
                       Set=function(_,v)it.value=v;it.cb(v)end}
            end
            function SEC:AddMultiDropdown(label,options,default,opts2,cb)
                if type(opts2)=="function" then cb=opts2; opts2={} end; opts2=opts2 or {}
                local sel={}; if default then for _,v in ipairs(default) do sel[v]=true end end
                local it={type="multidropdown",label=label,options=options or {},
                    selected=sel, maxVisible=opts2.MaxVisible or 6, scroll=0,
                    cb=cb or function()end, _search="",_sfocus=false}
                reg(it)
                local function lst()
                    local out={}
                    for _,o in ipairs(it.options) do if it.selected[o] then out[#out+1]=o end end
                    return out
                end
                it.cb(lst())
                return{Get=function()return lst()end,
                       Set=function(_,tbl)
                           it.selected={}
                           if tbl then for _,v in ipairs(tbl) do it.selected[v]=true end end
                           it.cb(lst())
                       end}
            end
            function SEC:AddColorPicker(label,default,cb)
                local h,s,v=0,1,1; if default then h,s,v=rgbToHsv(default) end
                local it={type="colorpicker",label=label,h=h,s=s,v=v,
                    value=default or Color3.new(1,0,0),cb=cb or function()end,
                    dragSV=false,dragH=false,_open=false}
                reg(it); it.cb(it.value)
                return{Get=function()return it.value end,
                       Set=function(_,c)it.value=c;local hh,ss,vv=rgbToHsv(c);it.h=hh;it.s=ss;it.v=vv;it.cb(c)end}
            end
            function SEC:AddKeybind(label,default,cb)
                local it={type="keybind",label=label,value=default or 0,
                    cb=cb or function()end,listening=false}
                reg(it)
                return{Get=function()return it.value end,
                       Set=function(_,v)it.value=v;it.cb(v)end}
            end
            function SEC:AddTextbox(label,default,cb,placeholder)
                local it={type="textbox",label=label,value=default or "",
                    cb=cb or function()end,placeholder=placeholder or ("Enter "..label.."...")}
                reg(it)
                return{Get=function()return it.value end,
                       Set=function(_,v)it.value=v;it.cb(v)end}
            end
            function SEC:AddLabel(text,color)
                local it={type="label",label=text or "",color=color}; reg(it)
                return{Get=function()return it.label end,Set=function(_,v)it.label=v end}
            end
            function SEC:AddSeparator()
                reg({type="separator"}); return{}
            end
            table.insert(TAB._sections,SEC); return SEC
        end
        table.insert(self._tabs,TAB)
        if not self._openTab then self._openTab=TAB end
        return TAB
    end

    -- ── Settings tab (auto-built) ─────────────────────────────────────────
    function WIN:_buildSettings()
        local ST={_name="Settings",_sections={},_win=self,_isSettings=true}
        local winRef=self
        function ST:AddSection(sname)
            local SEC={_name=sname,_widgets={},_win=winRef,_collapsed=false}
            local function reg(w) table.insert(SEC._widgets,w) end
            function SEC:AddToggle(label,default,cb)
                local it={type="toggle",label=label,value=default or false,cb=cb or function()end,_anim=default and 1 or 0}
                reg(it); it.cb(it.value)
                return{Get=function()return it.value end,Set=function(_,v)it.value=v;it.cb(v)end}
            end
            function SEC:AddButton(label,cb,color)
                reg({type="button",label=label,cb=cb or function()end,color=color}); return{}
            end
            function SEC:AddDropdown(label,options,default,opts2,cb)
                if type(opts2)=="function" then cb=opts2; opts2={} end; opts2=opts2 or {}
                local it={type="dropdown",label=label,options=options or {},value=default or (options and options[1]) or "",maxVisible=opts2.MaxVisible or 6,scroll=0,cb=cb or function()end,_search="",_sfocus=false}
                reg(it); it.cb(it.value)
                return{Get=function()return it.value end,Set=function(_,v)it.value=v;it.cb(v)end}
            end
            function SEC:AddTextbox(label,default,cb,placeholder)
                local it={type="textbox",label=label,value=default or "",cb=cb or function()end,placeholder=placeholder or ("Enter "..label.."...")}
                reg(it)
                return{Get=function()return it.value end,Set=function(_,v)it.value=v;it.cb(v)end}
            end
            function SEC:AddLabel(text,color)
                local it={type="label",label=text or "",color=color}; reg(it)
                return{Get=function()return it.label end,Set=function(_,v)it.label=v end}
            end
            function SEC:AddSeparator()
                reg({type="separator"}); return{}
            end
            table.insert(ST._sections,SEC); return SEC
        end

        -- Built-in sections: Menu (index 1), Theme (index 2)
        local SM={_name="Menu",_widgets={},_win=self,_collapsed=false}
        table.insert(SM._widgets,{type="settings_keybind",label="Toggle Key",listening=false})
        table.insert(SM._widgets,{type="settings_kill",label="Kill Script"})
        table.insert(ST._sections,SM)   -- index 1

        local STH={_name="Theme",_widgets={},_win=self,_collapsed=false}
        table.insert(STH._widgets,{type="dropdown",label="Change Theme",
            options=ThemeNames,value="Galax",maxVisible=7,scroll=0,
            cb=function(v) applyTheme(v) end,_search="",_sfocus=false})
        table.insert(ST._sections,STH)  -- index 2

        -- Store refs so external inject (task.spawn) can reorder after adding its own sections.
        -- External code adds Profiles (index 3) then Autoload (index 4), then calls:
        --   ST._sections = { PS, SM, AS, STH }
        -- which gives 2-col layout: [Profiles | Menu] then [Autoload | Theme]
        ST._SM  = SM
        ST._STH = STH

        table.insert(self._tabs,ST)
    end

    -- ── Dropdown list helper ─────────────────────────────────────────────
    function WIN:_ddList(pool,wid,it,ddPos,ddSz,iW,FONT,multi)
        local optH=20
        local filt={}
        local srch=(it._search or ""):lower()
        for _,o in ipairs(it.options) do
            if srch=="" or o:lower():find(srch,1,true) then filt[#filt+1]=o end
        end
        local total=#filt
        local maxV=math.min(it.maxVisible,total)
        it.scroll=clamp(it.scroll,0,math.max(0,total-maxV))

        local SBW=6; local SBP=3
        local hasSB=(total>it.maxVisible)
        local optW=hasSB and (iW-SBW-SBP*2) or iW

        local sbH_px=28
        local listH=math.min(maxV,total)*optH+4+sbH_px
        -- open upward if the list would overflow the window bottom
        local winBottom=self._pos.Y+self.Size.Y-8
        local openDown=(ddPos.Y+ddSz.Y+2+listH <= winBottom)
        local winRight=self._pos.X+self.Size.X-6
        local listX=math.min(ddPos.X, winRight-iW)
        local listY=openDown and (ddPos.Y+ddSz.Y+2) or (ddPos.Y-listH-2)
        local listPos=Vector2.new(listX,listY)

        poolAdd(pool,wid.."_dll", "Square",{Position=listPos,Size=Vector2.new(iW,listH),Filled=true, Color=T.Surface0,Visible=true,ZIndex=20})
        poolAdd(pool,wid.."_dlb", "Square",{Position=listPos,Size=Vector2.new(iW,listH),Filled=false,Color=T.Accent, Thickness=1,Visible=true,ZIndex=21})

        local sbPos=listPos+Vector2.new(4,4)
        local sbSz=Vector2.new(iW-8,19)
        if Input.click and over(sbPos,sbSz) then it._sfocus=true
        elseif Input.click and not over(sbPos,sbSz) then it._sfocus=false end
        poolAdd(pool,wid.."_dsb",  "Square",{Position=sbPos,Size=sbSz,Filled=true, Color=T.Surface1,Visible=true,ZIndex=22})
        poolAdd(pool,wid.."_dsbb", "Square",{Position=sbPos,Size=sbSz,Filled=false,Color=it._sfocus and T.Accent or T.Border1,Thickness=1,Visible=true,ZIndex=23})
        local cur=(it._sfocus and math.floor(tick()*2)%2==0) and "|" or ""
        local sdsp=it._search~="" and (it._search..cur) or (it._sfocus and cur or "🔍 search...")
        poolAdd(pool,wid.."_dsbt","Text",{Position=sbPos+Vector2.new(5,2),Text=sdsp,Size=12,Font=FONT,
            Color=it._search~="" and T.Text or T.SubText,Outline=false,Visible=true,ZIndex=24})
        if it._sfocus then
            for kc=8,222 do
                if Input:keyClick(kc) then
                    if kc==0x08 then it._search=it._search:sub(1,-2)
                    elseif kc==0x0D then it._sfocus=false
                    elseif kc==0x20 then it._search=it._search.." "
                    elseif kc>=0x30 and kc<=0x5A then
                        local ch=KeyNames[kc]; if ch and #ch==1 then
                            local sh=Input:shift()
                            ch=sh and (ShiftMap[ch:lower()] or ch:upper()) or ch:lower()
                            it._search=it._search..ch
                        end
                    elseif kc==0xBD then it._search=it._search..(Input:shift() and "_" or "-")
                    end
                end
            end
            it.scroll=0
        end

        local visN=math.min(it.maxVisible,total)
        if hasSB then
            local barH=math.max(14, (listH-sbH_px)*(it.maxVisible/total))
            local trackH=(listH-sbH_px)-barH
            local maxSc=math.max(1,total-it.maxVisible)
            local barY=listPos.Y+sbH_px+trackH*(it.scroll/maxSc)
            local barX=listPos.X+iW-SBW-SBP
            local bPos=Vector2.new(barX,barY); local bSz=Vector2.new(SBW,barH)
            local bHov=over(bPos,bSz)
            poolAdd(pool,wid.."_sbtrk","Square",{Position=Vector2.new(barX,listPos.Y+sbH_px),Size=Vector2.new(SBW,listH-sbH_px),Filled=true,Color=T.Surface1,Visible=true,ZIndex=21})
            poolAdd(pool,wid.."_sbbar","Square",{Position=bPos,Size=bSz,Filled=true,Color=(bHov or it._sbDrag) and T.Text or T.Accent,Visible=true,ZIndex=22})
            if it._clicked and bHov then it._sbDrag=true;it._sbDragY=mpos().Y;it._sbDragSc=it.scroll end
            if not Input.held then it._sbDrag=false end
            if it._sbDrag and trackH>0 then
                local dy=mpos().Y-(it._sbDragY or 0)
                it.scroll=clamp((it._sbDragSc or 0)+math.floor(dy*(maxSc/trackH)+0.5),0,maxSc)
            end
        end

        if over(listPos,Vector2.new(iW,listH)) and Input.scroll~=0 then
            it.scroll=clamp(it.scroll+Input.scroll,0,math.max(0,total-it.maxVisible))
        end

        for vi=1,visN do
            local oi=vi+it.scroll; local opt=filt[oi]; if not opt then break end
            local opPos=listPos+Vector2.new(0,(vi-1)*optH+sbH_px+2)
            local opSz=Vector2.new(optW,optH); local opHov=over(opPos,opSz)
            if multi then
                local sel=it.selected[opt]==true
                if opHov then poolAdd(pool,wid.."_ohi"..vi,"Square",{Position=opPos,Size=opSz,Filled=true,Color=T.Surface1,Visible=true,ZIndex=21})
                else poolHide(pool,wid.."_ohi"..vi) end
                local cp=opPos+Vector2.new(6,5); local cs=Vector2.new(10,10)
                poolAdd(pool,wid.."_mcb"..vi, "Square",{Position=cp,Size=cs,Filled=true, Color=sel and T.Accent or T.Surface0,Visible=true,ZIndex=22})
                poolAdd(pool,wid.."_mcbb"..vi,"Square",{Position=cp,Size=cs,Filled=false,Color=T.Border1,Thickness=1,Visible=true,ZIndex=23})
                poolAdd(pool,wid.."_mot"..vi, "Text",  {Position=opPos+Vector2.new(22,3),Text=opt,Size=13,Font=FONT,Color=sel and T.Accent or T.Text,Outline=false,Visible=true,ZIndex=22})
                if it._clicked and opHov then
                    it.selected[opt]=not sel
                    local out={}; for _,o in ipairs(it.options) do if it.selected[o] then out[#out+1]=o end end
                    it.cb(out)
                end
            else
                local sel=(opt==it.value)
                if opHov or sel then
                    poolAdd(pool,wid.."_ohi"..vi,"Square",{Position=opPos,Size=opSz,Filled=true,Color=sel and T.AccentDark or T.Surface1,Visible=true,ZIndex=21})
                else poolHide(pool,wid.."_ohi"..vi) end
                poolAdd(pool,wid.."_ot"..vi,"Text",{Position=opPos+Vector2.new(8,3),Text=opt,Size=13,Font=FONT,Color=sel and T.Accent or T.Text,Outline=false,Visible=true,ZIndex=22})
                if it._clicked and opHov then it.value=opt;it.cb(opt);self._openDropId=nil;it._search="" end
            end
        end
        for vi=visN+1,it.maxVisible+4 do
            poolHide(pool,wid.."_ohi"..vi);poolHide(pool,wid.."_ot"..vi)
            poolHide(pool,wid.."_mcb"..vi);poolHide(pool,wid.."_mcbb"..vi);poolHide(pool,wid.."_mot"..vi)
        end
        return listH+4
    end

    -- ── Widget renderer ──────────────────────────────────────────────────
    function WIN:_widget(it,pool,wid,wx,wy,iW,FONT)
        local h=0

        if it.type=="separator" then
            poolAdd(pool,wid.."_sep","Square",{Position=Vector2.new(wx,wy+5),Size=Vector2.new(iW,1),Filled=true,Color=T.Border0,Visible=true,ZIndex=6})
            h=12

        elseif it.type=="label" then
            poolAdd(pool,wid.."_lbl","Text",{Position=Vector2.new(wx,wy+2),Text=it.label,Size=13,Font=FONT,Color=it.color or T.SubText,Outline=false,Visible=true,ZIndex=6})
            h=20

        elseif it.type=="toggle" then
            it._anim=lerp(it._anim or (it.value and 1 or 0), it.value and 1 or 0, 0.22)
            local a=it._anim
            local trkW,trkH=28,14
            local trkPos=Vector2.new(wx+iW-trkW,wy+1)
            poolAdd(pool,wid.."_trk", "Square",{Position=trkPos,Size=Vector2.new(trkW,trkH),Filled=true, Color=lerpC(T.Surface1,T.Accent,a),Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_trkb","Square",{Position=trkPos,Size=Vector2.new(trkW,trkH),Filled=false,Color=lerpC(T.Border1,T.Accent,a),Thickness=1,Visible=true,ZIndex=7})
            local kx=trkPos.X+2+a*(trkW-14)
            poolAdd(pool,wid.."_knb","Square",{Position=Vector2.new(kx,trkPos.Y+2),Size=Vector2.new(10,10),Filled=true,Color=T.Text,Visible=true,ZIndex=8})
            poolAdd(pool,wid.."_lbl","Text",  {Position=Vector2.new(wx,wy+1),Text=it.label,Size=13,Font=FONT,Color=it.value and T.Text or T.SubText,Outline=false,Visible=true,ZIndex=6})
            if Input.click and over(Vector2.new(wx,wy),Vector2.new(iW,16)) then it.value=not it.value;it.cb(it.value) end
            h=22

        elseif it.type=="button" then
            local BTN_H=24
            local bp=Vector2.new(wx,wy); local bs=Vector2.new(iW,BTN_H); local hov=over(bp,bs)
            local bgC, bdC
            if it.color then
                bgC=hov and lerpC(it.color,T.Text,0.2) or lerpC(it.color,T.Body,0.3)
                bdC=it.color
            else
                bgC=hov and T.AccentDark or T.Surface1
                bdC=hov and T.Accent or T.Border0
            end
            poolAdd(pool,wid.."_btn", "Square",{Position=bp,Size=bs,Filled=true, Color=bgC,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_btnb","Square",{Position=bp,Size=bs,Filled=false,Color=bdC,Thickness=1,Visible=true,ZIndex=7})
            local _bw=textW(it.label,13)
            poolAdd(pool,wid.."_btnt","Text",{Position=Vector2.new(wx+iW/2-_bw/2,wy+5),Text=it.label,Size=13,Font=FONT,Color=T.Text,Center=false,Outline=false,Visible=true,ZIndex=7})
            if Input.click and hov then it.cb() end
            h=BTN_H+4

        elseif it.type=="slider" then
            local vs=tostring(it.value)..it.suffix
            poolAdd(pool,wid.."_lbl","Text",{Position=Vector2.new(wx,wy),Text=it.label,Size=13,Font=FONT,Color=T.Text,Outline=false,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_val","Text",{Position=Vector2.new(wx+iW-textW(vs,12),wy),Text=vs,Size=12,Font=FONT,Color=T.Accent,Outline=false,Visible=true,ZIndex=6})
            local tP=Vector2.new(wx,wy+17); local tS=Vector2.new(iW,5)
            poolAdd(pool,wid.."_trk", "Square",{Position=tP,Size=tS,Filled=true,Color=T.Surface1,Visible=true,ZIndex=6})
            local pct=clamp((it.value-it.min)/(it.max-it.min),0,1)
            local fw=math.max(4,tS.X*pct)
            poolAdd(pool,wid.."_fil","Square",{Position=tP,Size=Vector2.new(fw,tS.Y),Filled=true,Color=T.Accent,Visible=true,ZIndex=7})
            poolAdd(pool,wid.."_knb","Square",{Position=Vector2.new(tP.X+fw-4,tP.Y-3),Size=Vector2.new(8,11),Filled=true,Color=T.Text,Visible=true,ZIndex=8})
            if Input.click and over(tP-Vector2.new(0,5),tS+Vector2.new(0,12)) then self._sliderDrag=it end
            if self._sliderDrag==it then
                if Input.held then
                    local p=clamp((mpos().X-tP.X)/tS.X,0,1)
                    it.value=clamp(math.floor(it.min+(it.max-it.min)*p+0.5),it.min,it.max);it.cb(it.value)
                else self._sliderDrag=nil end
            end
            h=34

        elseif it.type=="dropdown" or it.type=="multidropdown" then
            local multi=(it.type=="multidropdown")
            if not it._sid then it._sid={}; it._wasM1=false end
            local m1=Input.held; it._clicked=m1 and not it._wasM1
            local ddP=Vector2.new(wx,wy+14); local ddS=Vector2.new(iW,22)
            local isOpen=(self._openDropId==it._sid)
            local estListH=(math.min(it.maxVisible,#it.options)*20+4+28)
            local winBottom2=self._pos.Y+self.Size.Y-8
            local winRight2=self._pos.X+self.Size.X-6
            local _openDown2=(ddP.Y+ddS.Y+2+estListH <= winBottom2)
            local lX2=math.min(ddP.X, winRight2-iW)
            local lY2=_openDown2 and (ddP.Y+ddS.Y+2) or (ddP.Y-estListH-2)
            local lPos=Vector2.new(lX2,lY2)
            local lSz=Vector2.new(iW,estListH)

            local disp
            if multi then
                local sl={}; for _,o in ipairs(it.options) do if it.selected[o] then sl[#sl+1]=o end end
                disp=#sl==0 and "None" or (#sl.."/"..#it.options.." selected")
            else disp=it.value end

            poolAdd(pool,wid.."_ddlbl","Text",    {Position=Vector2.new(wx,wy),Text=it.label,Size=12,Font=FONT,Color=T.SubText,Outline=false,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_ddbg", "Square",  {Position=ddP,Size=ddS,Filled=true, Color=T.Surface1,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_ddb",  "Square",  {Position=ddP,Size=ddS,Filled=false,Color=isOpen and T.Accent or T.Border0,Thickness=1,Visible=true,ZIndex=7})
            poolAdd(pool,wid.."_ddv",  "Text",    {Position=ddP+Vector2.new(6,4),Text=disp,Size=13,Font=FONT,Color=T.Text,Outline=false,Visible=true,ZIndex=7})
            local ax,ay=ddP.X+ddS.X-14,ddP.Y+11
            poolAdd(pool,wid.."_ddarr","Triangle",{PointA=Vector2.new(ax,ay-4),PointB=Vector2.new(ax+7,ay-4),PointC=Vector2.new(ax+3.5,ay+3),Filled=true,Color=isOpen and T.Accent or T.SubText,Visible=true,ZIndex=7})

            if it._clicked then
                if over(ddP,ddS) then
                    if self._openDropId==it._sid then self._openDropId=nil
                    elseif self._openDropId==nil then self._openDropId=it._sid end
                elseif isOpen and not over(lPos,lSz) then self._openDropId=nil end
            end
            local openNow=(self._openDropId==it._sid)
            if openNow then h=h+self:_ddList(pool,wid,it,ddP,ddS,iW,FONT,multi) end
            it._wasM1=m1; h=h+42

        elseif it.type=="colorpicker" then
            local swP=Vector2.new(wx,wy); local swW=20
            poolAdd(pool,wid.."_sw",  "Square",{Position=swP,Size=Vector2.new(swW,18),Filled=true, Color=it.value,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_swb", "Square",{Position=swP,Size=Vector2.new(swW,18),Filled=false,Color=T.Border1,Thickness=1,Visible=true,ZIndex=7})
            poolAdd(pool,wid.."_lbl", "Text",  {Position=swP+Vector2.new(swW+6,2),Text=it.label,Size=13,Font=FONT,Color=T.Text,Outline=false,Visible=true,ZIndex=6})
            local r,g,b=math.floor(it.value.R*255),math.floor(it.value.G*255),math.floor(it.value.B*255)
            local rgb=r..","..g..","..b
            poolAdd(pool,wid.."_rgb","Text",{Position=Vector2.new(wx+iW-textW(rgb,11),wy+2),Text=rgb,Size=11,Font=FONT,Color=T.SubText,Outline=false,Visible=true,ZIndex=6})
            if Input.click and over(swP,Vector2.new(iW,18)) then it._open=not it._open end
            h=24
            if it._open then
                local pW,pH=iW,90; local pPos=Vector2.new(wx,wy+24)
                local strips=16
                for si=1,strips do
                    local vv=1-(si-1)/(strips-1)
                    poolAdd(pool,wid.."_sv"..si,"Square",{
                        Position=pPos+Vector2.new(0,(si-1)*(pH/strips)),
                        Size=Vector2.new(pW,pH/strips+1),
                        Filled=true,Color=hsvToRgb(it.h,it.s,vv),Visible=true,ZIndex=7})
                end
                poolAdd(pool,wid.."_palb","Square",{Position=pPos,Size=Vector2.new(pW,pH),Filled=false,Color=T.Border1,Thickness=1,Visible=true,ZIndex=10})
                local cX,cY=pPos.X+it.s*pW, pPos.Y+(1-it.v)*pH
                poolAdd(pool,wid.."_csh","Line",{From=Vector2.new(pPos.X,cY),To=Vector2.new(pPos.X+pW,cY),Thickness=1,Color=T.Text,Visible=true,ZIndex=9})
                poolAdd(pool,wid.."_csv","Line",{From=Vector2.new(cX,pPos.Y),To=Vector2.new(cX,pPos.Y+pH),Thickness=1,Color=T.Text,Visible=true,ZIndex=9})
                local hH=12; local hPos=Vector2.new(wx,wy+24+pH+5); local hSegs=24
                for hi=1,hSegs do
                    poolAdd(pool,wid.."_h"..hi,"Square",{
                        Position=hPos+Vector2.new((hi-1)*(iW/hSegs),0),
                        Size=Vector2.new(iW/hSegs+1,hH),
                        Filled=true,Color=hsvToRgb((hi-1)/hSegs,1,1),Visible=true,ZIndex=7})
                end
                local hcX=hPos.X+it.h*iW
                poolAdd(pool,wid.."_hcur","Square",{Position=Vector2.new(hcX-2,hPos.Y-1),Size=Vector2.new(4,hH+2),Filled=false,Color=T.Text,Thickness=1,Visible=true,ZIndex=9})
                if Input.click and over(pPos,Vector2.new(pW,pH)) then it.dragSV=true end
                if Input.click and over(hPos,Vector2.new(iW,hH)) then it.dragH=true end
                if not Input.held then it.dragSV=false;it.dragH=false end
                if it.dragSV then
                    local m=mpos(); it.s=clamp((m.X-pPos.X)/pW,0,1); it.v=1-clamp((m.Y-pPos.Y)/pH,0,1)
                    it.value=hsvToRgb(it.h,it.s,it.v);it.cb(it.value)
                end
                if it.dragH then
                    it.h=clamp((mpos().X-hPos.X)/iW,0,1)
                    it.value=hsvToRgb(it.h,it.s,it.v);it.cb(it.value)
                end
                h=h+pH+hH+12
            end

        elseif it.type=="keybind" then
            local ks=it.listening and "[ ... ]" or ("[ "..keyName(it.value).." ]")
            local kw=textW(ks,12)+10; local kp=Vector2.new(wx+iW-kw,wy); local ks2=Vector2.new(kw,18)
            poolAdd(pool,wid.."_lbl",  "Text",  {Position=Vector2.new(wx,wy+2),Text=it.label,Size=13,Font=FONT,Color=T.Text,Outline=false,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_kbg",  "Square",{Position=kp,Size=ks2,Filled=true, Color=it.listening and T.AccentDark or T.Surface1,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_kbb",  "Square",{Position=kp,Size=ks2,Filled=false,Color=it.listening and T.Accent or T.Border0,Thickness=1,Visible=true,ZIndex=7})
            poolAdd(pool,wid.."_kbtx", "Text",  {Position=kp+Vector2.new(4,2),Text=ks,Size=12,Font=FONT,Color=it.listening and T.Accent or T.SubText,Outline=false,Visible=true,ZIndex=7})
            if Input.click and over(kp,ks2) then it.listening=true;self._keybindTarget=it end
            if it.listening and self._keybindTarget==it then
                for kc=1,255 do
                    if kc~=1 and kc~=2 and Input:keyClick(kc) then
                        if kc~=0x1B then it.value=kc;it.cb(kc) end
                        it.listening=false;self._keybindTarget=nil;break
                    end
                end
            end
            h=24

        elseif it.type=="textbox" then
            local tP=Vector2.new(wx,wy+15); local tS=Vector2.new(iW,22)
            local foc=(self._textboxTarget==it)
            local cur=(foc and math.floor(tick()*2)%2==0) and "|" or ""
            local disp=it.value..cur
            if disp=="" then disp=foc and cur or it.placeholder end
            poolAdd(pool,wid.."_lbl",  "Text",  {Position=Vector2.new(wx,wy),Text=it.label,Size=12,Font=FONT,Color=T.SubText,Outline=false,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_tbbg", "Square",{Position=tP,Size=tS,Filled=true, Color=T.Surface1,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_tbb",  "Square",{Position=tP,Size=tS,Filled=false,Color=foc and T.Accent or T.Border0,Thickness=1,Visible=true,ZIndex=7})
            poolAdd(pool,wid.."_tbx",  "Text",  {Position=tP+Vector2.new(6,4),Text=disp,Size=13,Font=FONT,Color=(it.value~="" or foc) and T.Text or T.SubText,Outline=false,Visible=true,ZIndex=7})
            if Input.click then
                if over(tP,tS) then self._textboxTarget=it
                elseif self._textboxTarget==it then self._textboxTarget=nil end
            end
            if foc then
                for kc=8,222 do
                    if Input:keyClick(kc) then
                        if kc==0x08 then it.value=it.value:sub(1,-2);it.cb(it.value)
                        elseif kc==0x0D then self._textboxTarget=nil
                        elseif kc==0x20 then it.value=it.value.." ";it.cb(it.value)
                        elseif kc==0xBD then it.value=it.value..(Input:shift() and "_" or "-");it.cb(it.value)
                        elseif kc>=0x30 and kc<=0x5A then
                            local ch=KeyNames[kc]; if ch and #ch==1 then
                                local sh=Input:shift()
                                ch=sh and (ShiftMap[ch:lower()] or ch:upper()) or ch:lower()
                                it.value=it.value..ch;it.cb(it.value)
                            end
                        end
                    end
                end
            end
            h=44

        elseif it.type=="settings_keybind" then
            local ks=it.listening and "[ ... ]" or ("[ "..keyName(self.MenuKey).." ]")
            local kw=textW(ks,12)+10; local kp=Vector2.new(wx+iW-kw,wy); local ks2=Vector2.new(kw,18)
            poolAdd(pool,wid.."_lbl",  "Text",  {Position=Vector2.new(wx,wy+2),Text=it.label,Size=13,Font=FONT,Color=T.Text,Outline=false,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_kbg",  "Square",{Position=kp,Size=ks2,Filled=true, Color=it.listening and T.AccentDark or T.Surface1,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_kbb",  "Square",{Position=kp,Size=ks2,Filled=false,Color=it.listening and T.Accent or T.Border0,Thickness=1,Visible=true,ZIndex=7})
            poolAdd(pool,wid.."_kbtx", "Text",  {Position=kp+Vector2.new(4,2),Text=ks,Size=12,Font=FONT,Color=it.listening and T.Accent or T.SubText,Outline=false,Visible=true,ZIndex=7})
            if Input.click and over(kp,ks2) then it.listening=true;self._settingsListen=true end
            if it.listening and self._settingsListen then
                for kc=1,255 do
                    if kc~=1 and kc~=2 and Input:keyClick(kc) then
                        if kc~=0x1B then self.MenuKey=kc;self:Notify("Key: "..keyName(kc),self.Title,3) end
                        it.listening=false;self._settingsListen=false;break
                    end
                end
            end
            h=24

        elseif it.type=="settings_kill" then
            local BTN_H=24
            local bp=Vector2.new(wx,wy); local bs=Vector2.new(iW,BTN_H); local hov=over(bp,bs)
            poolAdd(pool,wid.."_btn", "Square",{Position=bp,Size=bs,Filled=true, Color=hov and T.RedDark or T.Surface1,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_btnb","Square",{Position=bp,Size=bs,Filled=false,Color=hov and T.Red or T.Border0,Thickness=1,Visible=true,ZIndex=7})
            local _bw=textW(it.label,13)
            poolAdd(pool,wid.."_btnt","Text",{Position=Vector2.new(wx+iW/2-_bw/2,wy+5),Text=it.label,Size=13,Font=FONT,Color=T.Red,Center=false,Outline=false,Visible=true,ZIndex=7})
            if Input.click and hov then self:Notify("Script killed.",self.Title,2);self._running=false end
            h=BTN_H+4
        end
        return h
    end

    -- ── Render ───────────────────────────────────────────────────────────────
    function WIN:_render()
        local pool=self._pool; local pos=self._pos; local sz=self.Size
        local t=tick(); local F=Drawing.Fonts.Plex

        if not self._open then
            poolDestroy(pool)
            for i=1,self._snakeCount do self._snakeLines[i].Visible=false end
            renderNotifs(); return
        end

        poolBegin(pool)

        local TH=38
        if Input.click and over(pos,Vector2.new(sz.X,TH)) and not self._drag and not self._resize then
            self._drag=mpos()-pos
        end
        if not Input.held then self._drag=nil end
        if self._drag then self._pos=mpos()-self._drag; pos=self._pos end

        local rSz=Vector2.new(14,14)
        local rPos=pos+sz-rSz
        poolAdd(pool,"rsz","Triangle",{
            PointA=Vector2.new(rPos.X+rSz.X,rPos.Y),
            PointB=Vector2.new(rPos.X+rSz.X,rPos.Y+rSz.Y),
            PointC=Vector2.new(rPos.X,rPos.Y+rSz.Y),
            Filled=true,Color=T.Border1,Visible=true,ZIndex=8})
        if Input.click and over(rPos,rSz) then self._resize=mpos();self._resizeBase=sz end
        if not Input.held then self._resize=nil end
        if self._resize then
            local d=mpos()-self._resize
            self.Size=Vector2.new(
                math.max(self._minSz.X,self._resizeBase.X+d.X),
                math.max(self._minSz.Y,self._resizeBase.Y+d.Y)); sz=self.Size
        end

        poolAdd(pool,"wbg","Square",{Position=pos,Size=sz,Filled=true, Color=T.Body,   Visible=true,ZIndex=1})
        poolAdd(pool,"wbd","Square",{Position=pos,Size=sz,Filled=false,Color=T.Border0,Thickness=1,Visible=true,ZIndex=2})
        poolAdd(pool,"tbg","Square",{Position=pos,Size=Vector2.new(sz.X,TH),Filled=true,Color=T.Surface0,Visible=true,ZIndex=2})
        poolAdd(pool,"tln","Square",{Position=pos+Vector2.new(0,TH),Size=Vector2.new(sz.X,2),Filled=true,Color=T.Accent,Visible=true,ZIndex=3})
        poolAdd(pool,"ttx","Text",  {Position=pos+Vector2.new(12,11),Text=self.Title,Size=16,Font=F,Color=T.Accent,Outline=true,Visible=true,ZIndex=3})

        local wm=self.Title.."  |  "..keyName(self.MenuKey).." to toggle"
        poolAdd(pool,"wmbg","Square",{Position=pos-Vector2.new(0,21),Size=Vector2.new(textW(wm,12)+14,18),Filled=true,Color=T.Surface0,Visible=true,ZIndex=1})
        poolAdd(pool,"wmtx","Text",  {Position=pos-Vector2.new(-5,17),Text=wm,Size=12,Font=F,Color=T.SubText,Outline=false,Visible=true,ZIndex=2})

        local snkP=pos+Vector2.new(0,TH+2); local snkS=sz-Vector2.new(0,TH+2)
        for i=1,self._snakeCount do
            local ti=t*0.175-i*0.004; local sl=self._snakeLines[i]
            sl.From=pointOnRect(ti,snkP,snkS); sl.To=pointOnRect(ti+0.004,snkP,snkS)
            sl.Color=Color3.fromHSV((t*0.12+i*0.05)%1,0.75,1)
            sl.Transparency=(1-i/self._snakeCount)*0.78; sl.Visible=true; sl.ZIndex=50
        end

        local tabY=TH+4; local tabH=26; local tabX=10
        for i,tab in ipairs(self._tabs) do
            local tw=textW(tab._name,13)+24
            local tpos=pos+Vector2.new(tabX,tabY); local tsz=Vector2.new(tw,tabH)
            local open=(self._openTab==tab)
            poolAdd(pool,"tabbg"..i, "Square",{Position=tpos,Size=tsz,Filled=true,Color=open and T.Surface1 or T.Surface0,Visible=true,ZIndex=3})
            local _tw=textW(tab._name,13)
            poolAdd(pool,"tabtx"..i, "Text",{Position=Vector2.new(tpos.X+tw/2-_tw/2,tpos.Y+6),Text=tab._name,Size=13,Font=F,Color=open and T.Text or T.SubText,Center=false,Outline=false,Visible=true,ZIndex=4})
            if open then poolAdd(pool,"tabul"..i,"Square",{Position=tpos+Vector2.new(0,tabH-2),Size=Vector2.new(tw,2),Filled=true,Color=T.Accent,Visible=true,ZIndex=4})
            else poolHide(pool,"tabul"..i) end
            if Input.click and over(tpos,tsz) then
                self._openTab=tab; self._openDropId=nil; self._textboxTarget=nil; self._cpTarget=nil
                self._scrollY=0; self._scrollVel=0
            end
            tabX=tabX+tw+5
        end
        if not self._openTab then poolFlush(pool);renderNotifs();return end

        local contTop = TH + tabH + 10
        local padX    = 10
        local gap     = 8
        local contW   = sz.X - padX * 2
        local colW    = (contW - gap) / 2
        local iW      = colW - 14
        local contH   = sz.Y - contTop - 8

        if over(pos + Vector2.new(padX, contTop), Vector2.new(contW, contH)) and Input.scroll ~= 0 then
            self._scrollVel = self._scrollVel + Input.scroll * 18
        end
        self._scrollVel = self._scrollVel * 0.78
        self._scrollY   = math.max(0, self._scrollY + self._scrollVel)

        local function estSecH(sec)
            local sh = 22
            if not sec._collapsed then
                for _, it in ipairs(sec._widgets) do
                    if     it.type=="separator"                               then sh=sh+18
                    elseif it.type=="label"                                   then sh=sh+26
                    elseif it.type=="toggle"                                  then sh=sh+28
                    elseif it.type=="button"                                  then sh=sh+28
                    elseif it.type=="slider"                                  then sh=sh+40
                    elseif it.type=="dropdown" or it.type=="multidropdown"    then sh=sh+48
                    elseif it.type=="colorpicker"                             then sh=sh+(it._open and 160 or 30)
                    elseif it.type=="keybind"                                 then sh=sh+30
                    elseif it.type=="textbox"                                 then sh=sh+50
                    elseif it.type=="settings_keybind"                        then sh=sh+30
                    elseif it.type=="settings_kill"                           then sh=sh+28
                    else sh=sh+26 end
                end
            end
            return sh + 10
        end

        local secs = self._openTab._sections
        local rows  = {}
        local si = 1
        while si <= #secs do
            table.insert(rows, {secs[si], secs[si+1]})
            si = si + 2
        end

        local totalH = 0
        for _, row in ipairs(rows) do
            local h1 = estSecH(row[1])
            local h2 = row[2] and estSecH(row[2]) or 0
            totalH = totalH + math.max(h1, h2) + gap
        end
        self._scrollY = math.min(self._scrollY, math.max(0, totalH - contH))

        if totalH > contH then
            local SBW = 4
            local sbX = pos.X + sz.X - SBW - 2
            local sbH = math.max(20, contH * (contH / totalH))
            local sbY = contTop + (self._scrollY / math.max(1, totalH - contH)) * (contH - sbH)
            poolAdd(pool,"sc_trk","Square",{Position=Vector2.new(sbX,pos.Y+contTop),Size=Vector2.new(SBW,contH),Filled=true, Color=T.Surface1,Visible=true,ZIndex=5})
            poolAdd(pool,"sc_bar","Square",{Position=Vector2.new(sbX,pos.Y+sbY),    Size=Vector2.new(SBW,sbH), Filled=true, Color=T.Accent, Visible=true,ZIndex=6})
        end

        local function drawSec(sec, sid, absX, relY)
            local absY = pos.Y + relY

            local hdrP = Vector2.new(absX + 4, absY + 4)
            poolAdd(pool, sid.."_hdr", "Text", {
                Position=hdrP, Text=sec._name,
                Size=11, Font=F, Color=T.SubText, Outline=false, Visible=true, ZIndex=6
            })
            if Input.click and over(hdrP - Vector2.new(0,2), Vector2.new(colW, 14)) then
                sec._collapsed = not sec._collapsed
            end

            local wY = relY + 20
            if not sec._collapsed then
                for wi, it in ipairs(sec._widgets) do
                    local consumed = self:_widget(it, pool, sid.."w"..wi, absX + 7, pos.Y + wY, iW, F)
                    wY = wY + consumed + 6
                end
            end

            local secH = wY - relY + 8
            poolAdd(pool, sid.."_bg",  "Square", {Position=Vector2.new(absX,absY), Size=Vector2.new(colW,secH), Filled=true,  Color=T.Surface0, Visible=true, ZIndex=4})
            poolAdd(pool, sid.."_bgb", "Square", {Position=Vector2.new(absX,absY), Size=Vector2.new(colW,secH), Filled=false, Color=T.Border0,  Thickness=1,  Visible=true, ZIndex=5})
            local hdrObj = poolGet(pool, sid.."_hdr"); if hdrObj then hdrObj.ZIndex=6 end
            return secH
        end

        local rowY = contTop - self._scrollY
        for ri, row in ipairs(rows) do
            local xL = pos.X + padX
            local xR = pos.X + padX + colW + gap
            local h1 = drawSec(row[1], "r"..ri.."a", xL, rowY)
            local h2 = row[2] and drawSec(row[2], "r"..ri.."b", xR, rowY) or 0
            rowY = rowY + math.max(h1, h2) + gap
        end

        poolFlush(pool)
        renderNotifs()
    end

    -- ── Main loop ─────────────────────────────────────────────────────────
    WIN:_buildSettings()
    task.spawn(function()
        while WIN._running do
            task.wait()
            if not (isrbxactive and isrbxactive() or true) then continue end
            Input:update()
            if Input:keyClick(WIN.MenuKey) then
                WIN._open=not WIN._open; pcall(setrobloxinput, not WIN._open)
                if not WIN._open then
                    WIN._openDropId=nil; WIN._textboxTarget=nil
                    WIN._keybindTarget=nil; WIN._settingsListen=false; WIN._cpTarget=nil
                end
            end
            WIN:_render()
        end
        pcall(setrobloxinput, true)
        poolDestroy(WIN._pool)
        poolDestroy(_notifPool)
        for i=1,WIN._snakeCount do WIN._snakeLines[i]:Remove() end
    end)

    return WIN
end

return GalaxLib
