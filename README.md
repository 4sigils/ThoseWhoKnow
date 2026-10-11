# Deepwoken

Modular version of the Deepwoken script (Nexa UI). One entry file loads every module under `src/`.

## Run

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/4sigils/Deepwoken/refs/heads/main/main.lua"))()
```

Optional globals, set before running:

```lua
getgenv().DEEPWOKEN_BASE  = "https://raw.githubusercontent.com/<user>/<repo>/refs/heads/<branch>/" -- use a fork/branch
getgenv().DEEPWOKEN_LOCAL = "Deepwoken/" -- load src/ from your executor workspace folder (offline dev)
```

## Layout

```
main.lua                  entry point + ordered module list
Animations.lua            animation data (already in your repo, loaded at runtime)
IgnoredAnimations.lua     ids hidden from the tracker (already in your repo)
src/
  core/
    state.lua             shared state (C.State, C.Status, services, Log)
    config.lua            URLs, key codes, intervals, file names   <- edit constants here
    nexa.lua              downloads + patches + loads Nexa UI
    controls.lua          Reg / Get control registry
    http.lua              HttpGet with fallbacks
    memory.lua            offsets + pointer/string readers
    enemies.lua           enemy list, animator cache, active animation reading
    input.lua             PressKey / RightClick
    ping.lua              ping methods, auto ping comp, ApplyPing
    data.lua              Animations.lua + ignore list parsing
    exclusions.lua        persistent friend / guild whitelists
    autosave.lua          config autoload + event-driven autosave
    startup.lua           boot: load data, notify, auto ping
    mainloop.lua          the single scan/fire/release loop + unload cleanup
  ui/                     one file per tab
    window.lua  whitelists.lua  autoparry.lua  automation.lua
    misc.lua    qol.lua         tracker.lua    debug.lua
  features/               logic, one file per feature
    autoparry.lua         Perform / Schedule / FireDue / ScanStep
    tracker.lua           tracker stepping + history
    ritual.lua            Auto Ritual
    ragdoll.lua           Auto Ragdoll Cancel
    nofog.lua             No Fog
    removals.lua          Remove Winds, No Shadows, No Golem Turrets, No Kill Bricks, No Rain Sound
    statfarm.lua          Auto Intelligence / Charisma
    tp_objectives.lua     TP to Objectives
    qol_actions.lua       Knock Self, Reset
```

## How modules work

Each file starts with `local C = ...` (the shared context passed in by `main.lua`) and publishes what
others need as `C.Something`. Mutable shared tables live in `C.State` and must always be accessed as
`C.State.X` (several are replaced wholesale, e.g. `S.Queue = {}`).

Load order is core -> ui (creates every control) -> features (read the controls) -> startup/mainloop.

### Adding a feature

1. Add its toggle in the matching `src/ui/<tab>.lua` with `C.Reg("my_flag", section:AddToggle{...})`.
2. Create `src/features/my_feature.lua` and read `C.Controls.my_flag` / `C.Get("my_flag")`.
3. Add `"src/features/my_feature.lua"` to `MODULES` in `main.lua`.
