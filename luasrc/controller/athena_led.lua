local nixio = require "nixio"
local util = require "luci.util"
local sys = require "luci.sys"
local http = require "luci.http"

local function index()
    if not nixio.fs.access("/etc/config/athena_led") then
        return
    end
    entry({ "admin", "system", "athena_led" }, firstchild(), _("Athena LED Ctrl"), 80).dependent = false
    entry({ "admin", "system", "athena_led", "general" }, cbi("athena_led/settings"), _("Base Setting"), 1)
    entry({ "admin", "system", "athena_led", "status" }, call("act_status"))
end

local function act_status()
    local e = {}
    e.running = sys.call("pgrep /usr/sbin/athena-led >/dev/null") == 0
    http.prepare_content("application/json")
    http.write_json(e)
end

return {
    index = index,
    act_status = act_status
}