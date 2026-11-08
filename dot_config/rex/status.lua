-- Run by rex-status with --all. One status pane per tab, spanning its layout.
local home = os.getenv("HOME")
local state_dir = rex.args.state_dir or ((os.getenv("XDG_STATE_HOME") or (home .. "/.local/state")) .. "/rex-status")
local renderer = rex.args.renderer or (home .. "/.local/bin/rex-status")
local label = "Rex Status"
local attached = {}
local pending
local quota
local quota_at = 0

local function call(method, args)
    local value, err = rex.call(method, args)
    if not value then error(method .. ": " .. tostring(err)) end
    return value
end

local function save(value)
    local path = state_dir .. "/snapshot.json"
    local file = assert(io.open(path .. ".tmp", "w"))
    assert(file:write(assert(rex.json.encode(value))))
    assert(file:close())
    assert(os.rename(path .. ".tmp", path))
end

local function refresh_quota()
    if os.time() - quota_at < 60 then return end
    quota_at = os.time()
    local result = rex.exec({ "quota-axi", "--provider", "codex", "--json", "--max-age", "1m" }, { timeout = 15 })
    quota = nil
    if result then
        local report = rex.json.decode(result.stdout)
        for _, provider in ipairs(report and report.providers or {}) do
            if provider.provider == "codex" then
                quota = { windows = provider.windows, state = provider.state }
                break
            end
        end
    end
end

local agent_apps = { codex = true, claude = true, ["claude-code"] = true, opencode = true, pi = true }

local function agent_state(session_id, block)
    if block.creator_name ~= "com.superlogical.terminal" or block.label == label then return end
    local args = { session_id = session_id, block_id = block.block_id }
    local process = rex.call("com.superlogical.terminal.process", args)
    if not process or process.last_exit then return end
    local records = rex.call("com.superlogical.terminal.program_status", args)
    for _, record in ipairs(records and records.records or {}) do
        local app = (record.app or record.effective_app or ""):lower()
        if not record.id and agent_apps[app] then
            local foreground = process.foreground or {}
            if not record.owner or (record.owner.pid == foreground.pid and record.owner.name == foreground.name) then
                return record.state
            end
        end
    end
    local foreground = process.foreground or {}
    if agent_apps[(foreground.name or ""):lower()] then return "unknown" end
end

local function ensure_bar(session_id, window)
    local bars, others = {}, {}
    local tiled
    for _, layer in ipairs(window.layers or {}) do
        if layer.kind == "tiled" then tiled = layer end
        for _, block in ipairs(layer.blocks or {}) do
            if block.label == label then
                table.insert(bars, block)
            else
                table.insert(others, block)
            end
        end
    end
    if #others == 0 then
        -- A status pane must not keep an otherwise closed tab alive.
        for _, bar in ipairs(bars) do
            call("block.close", { session_id = session_id, block_id = bar.block_id })
        end
    elseif #bars == 0 and tiled and tiled.layout and not window.zoomed_block_id then
        local root = tiled.layout
        call("session.new_split", {
            session_id = session_id,
            anchor_id = root.block_id or root.split.split_id,
            direction = "vertical",
            side = "before",
            ratio = 0.05,
            focus = false,
            layout = { block = {
                flavor = "com.superlogical.terminal.shell",
                label = label,
                options = {
                    shell = "none",
                    command = { "/usr/bin/python3", renderer, "--pane", "--state-dir", state_dir },
                },
            } },
        })
    else
        for _, bar in ipairs(bars) do
            local process = rex.call("com.superlogical.terminal.process", { session_id = session_id, block_id = bar.block_id })
            if process and process.last_exit then
                call("block.close", { session_id = session_id, block_id = bar.block_id })
            end
        end
    end
    return others
end

local function update()
    pending = nil
    local counts = { total = 0, working = 0, blocked = 0, error = 0, idle = 0, unknown = 0 }
    local sessions = call("session.list", {}).sessions or {}
    if rex.args.session_id then
        local scoped = {}
        for _, session in ipairs(sessions) do
            if session.session_id == rex.args.session_id then table.insert(scoped, session) end
        end
        sessions = scoped
    end
    for _, session in ipairs(sessions) do
        local id = session.session_id
        local view
        if attached[id] then
            view = call("session.view", { session_id = id })
        else
            view = call("session.attach", { session_id = id }).view
            attached[id] = true
        end
        for _, window in ipairs(view.windows or {}) do
            for _, block in ipairs(ensure_bar(id, window)) do
                local state = agent_state(id, block)
                if state then
                    counts.total = counts.total + 1
                    if state == "done" then state = "idle" end
                    if counts[state] == nil then state = "unknown" end
                    counts[state] = counts[state] + 1
                end
            end
        end
    end
    refresh_quota()
    save({ updated_at = os.time(), quota_at = quota_at, quota = quota, agents = counts, sessions = #sessions })
end

local function schedule()
    if not pending then pending = rex.after(0.1, update) end
end

rex.on("window_created", schedule)
rex.on("block_closed", schedule)
rex.on("session_created", schedule)
rex.on("session_destroyed", function(_, ev)
    attached[ev.session_id] = nil
    schedule()
end)
rex.every(5, update)
rex.after(0, update)
