-- Lightweight self-updater: pulls new releases of this program from GitHub.
--
-- Modeled on GTNH-OC-Libraries' program-controller updater, but standalone so
-- the existing main loop is left untouched. Call M.check() once at startup
-- (before the main loop). It is a no-op when there is no internet card, no
-- network, or the installed version is already the latest — so it is always
-- safe to call.
--
-- How an update is detected:
--   * Fetch version.lua from the repo's main branch via raw.githubusercontent.
--   * Compare programVersion numerically after stripping non-digits
--     ("1.2.0" -> 120). A higher remote number means an update is available.
--   * configVersion is compared separately: a higher remote configVersion means
--     the config format changed and the user must rewrite config.lua by hand.
--
-- How an update is applied (mirrors the installer's tar flow):
--   * Back up config.lua -> config.old.lua
--   * wget the latest release tar and extract it over /home
--   * If the config format is unchanged: restore config.old.lua -> config.lua
--     and reboot. If it changed: keep config.old.lua and ask the user to
--     rewrite config.lua, then exit so they can do it before the next launch.

local component  = require("component")
local config     = require("config")

local M = {}

-- GitHub repository that hosts this program, "owner/name", and the release
-- archive name. Overridable from config.lua; defaults below are the real repo.
local REPO    = config.update_repo    or "Coopper228/GTNH-OC-Space-Miner"
local ARCHIVE = config.update_archive or "SpaceMiner"

local RAW_VERSION_URL =
    "https://raw.githubusercontent.com/" .. REPO .. "/refs/heads/main/version.lua"
local RELEASE_TAR_URL =
    "https://github.com/" .. REPO .. "/releases/latest/download/" .. ARCHIVE .. ".tar"

local TAR_MAN_URL = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/usr/man/tar.man"
local TAR_BIN_URL = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/home/bin/tar.lua"

-- Reduce a version string to a comparable integer by keeping only digits.
-- "1.2.0" -> 120. Pad-free, so keep a fixed segment count across releases.
local function versionToNumber(v)
    return tonumber((tostring(v):gsub("%D", ""))) or 0
end

-- Fetch and evaluate the remote version.lua. Returns its table, or nil on any
-- failure (no internet card, network error, malformed file).
local function fetchRemoteVersion()
    if not component.isAvailable("internet") then return nil end

    -- require lazily: importing the OC internet library on a machine without an
    -- internet card would error at load time.
    local ok, internet = pcall(require, "internet")
    if not ok or not internet then return nil end

    local ok2, request = pcall(internet.request, RAW_VERSION_URL)
    if not ok2 or not request then return nil end

    local body = ""
    local ok3 = pcall(function()
        for chunk in request do body = body .. chunk end
    end)
    if not ok3 or body == "" then return nil end

    local ok4, remote = pcall(load(body))
    if not ok4 or type(remote) ~= "table" then return nil end
    return remote
end

local function localVersion()
    local ok, v = pcall(require, "version")
    if ok and type(v) == "table" then return v end
    return { programVersion = "0.0.0", configVersion = 0 }
end

local function ensureTarUtility()
    local filesystem = require("filesystem")
    local shell      = require("shell")
    if filesystem.exists("/bin/tar.lua") then return end
    shell.setWorkingDirectory("/usr/man")
    shell.execute("wget -fq " .. TAR_MAN_URL)
    shell.setWorkingDirectory("/bin")
    shell.execute("wget -fq " .. TAR_BIN_URL)
end

-- Downloads the release tar and extracts it over /home, preserving the user's
-- config via a .old backup.
local function downloadAndInstall()
    local shell = require("shell")
    shell.setWorkingDirectory("/home")
    shell.execute("mv config.lua config.old.lua")
    shell.execute("wget -fq " .. RELEASE_TAR_URL .. " program.tar")
    shell.execute("tar -xf program.tar")
    shell.execute("rm program.tar")
end

-- Checks for an update and, with the user's consent, applies it. Safe no-op
-- when offline or already up to date. Reboots after a successful same-format
-- update; exits (without rebooting) if the config format changed so the user
-- can rewrite config.lua first.
function M.check()
    local term = require("term")

    local current = localVersion()
    local remote  = fetchRemoteVersion()

    if not remote then
        -- Offline or unreachable: stay silent and let the program start.
        return
    end

    local updateAvailable =
        versionToNumber(remote.programVersion) > versionToNumber(current.programVersion)
    local configChanged =
        (tonumber(remote.configVersion) or 0) > (tonumber(current.configVersion) or 0)

    if not updateAvailable then
        return
    end

    print(string.format("[update] New version available: %s -> %s",
        tostring(current.programVersion), tostring(remote.programVersion)))
    if configChanged then
        print("[update] WARNING: this update changes the config format.")
        print("[update] Your config.lua will be kept as config.old.lua and you")
        print("[update] will need to rewrite config.lua by hand after updating.")
    end
    io.write("[update] Update now? [y/N] ")

    local answer = io.read()
    if not answer or string.lower(answer):sub(1, 1) ~= "y" then
        print("[update] Skipped.")
        return
    end

    ensureTarUtility()
    print("[update] Downloading " .. remote.programVersion .. " ...")
    downloadAndInstall()

    local shell = require("shell")
    if configChanged then
        print("[update] Update installed. Rewrite /home/config.lua (old kept as")
        print("[update] config.old.lua), then reboot. Exiting now.")
        os.exit(0)
    else
        shell.execute("mv config.old.lua config.lua")
        print("[update] Update complete. Rebooting...")
        os.sleep(2)
        require("computer").shutdown(true)  -- reboot
    end
end

return M
