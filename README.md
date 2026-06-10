# GTNH-OC-Space-Miner

OpenComputers controller for the GTNH **Space Elevator → Space Miner** modules.
It auto-detects the miner hardware, keeps a configurable set of ores stocked
from the ME network, and meters mining drones through a buffer chest so a
single drone is delivered to each miner (no stackable-drone flooding).

> Replace `YOUR_USER/GTNH-OC-Space-Miner` everywhere (this README,
> `config.lua`, `config-descriptor.yml`) with your actual GitHub repository.

## Hardware

Per miner (auto-detected, no addresses to enter):

- 1 GT Space Miner with an Adapter holding an **MFU** bound to it
- 1 **Redstone I/O** under that Adapter
- 1 **ME Interface** (its Adapter manages the interface)
- A pipe whose direction is the redstone signal: HIGH = ME Interface → Input
  Bus, LOW = Input Bus drains back into the ME Interface

Drone buffer (one of each in the whole system, auto-detected):

- 1 **buffer chest** holding all mining drones
- 1 **transposer** touching both the chest and a dedicated ME interface
- 1 dedicated **drone ME interface** (+ its Adapter) wired into the network

The drone interface is identified as the one ME interface not bound to any
miner; the transposer's chest/interface sides are told apart automatically.

## Install (in-game)

Run the installer and pick **Space Miner**:

```
pastebin run ESUAMAGx
```

Say **yes** to autorun so it launches on boot (writes `/home/.shrc` = `main`).

Or install directly without the menu:

```
wget -f https://github.com/YOUR_USER/GTNH-OC-Space-Miner/releases/latest/download/SpaceMiner.tar /home/program.tar
cd /home && tar -xf program.tar && rm program.tar
```

On first launch (no `/home/miners.lua`) it runs auto-detection. **Have your
drones in the ME network during the first search** so the miners can light up;
the program sweeps them into the buffer chest on the first scan afterwards.

## Configure

Use the web configurator (no in-game editing needed):

```
https://navatusein.github.io/GTNH-OC-Web-Configurator/#/configurator?url=https://raw.githubusercontent.com/YOUR_USER/GTNH-OC-Space-Miner/main/config-descriptor.yml
```

Set the timings and the **ore targets** (label / target / priority), then
download the generated `config.lua` to `/home` (or use the `wget` link it
produces). Only ores listed there are mined. Hardware is never configured by
hand — it is auto-detected into `/home/miners.lua`.

You can still edit `/home/config.lua` directly; the schema lives in
`config-descriptor.yml`.

## Auto-update

On startup `updater.lua` checks `version.lua` on the repo's `main` branch. If a
newer `programVersion` exists it offers to update: it downloads the latest
release tar, preserves your `config.lua` (backed up to `config.old.lua`), and
reboots. If `configVersion` was bumped the old config is kept and you are asked
to rewrite `config.lua` first. Offline machines simply skip the check.

## Releasing (maintainer)

1. Bump `programVersion` in `version.lua` (and `configVersion` only if the
   config format changed incompatibly).
2. Tag and push:
   ```
   git tag v1.0.1 && git push origin v1.0.1
   ```
   The `Release` GitHub Action packs all root `*.lua` files into
   `SpaceMiner.tar` and attaches it to the release.

## Register in the installer

Add this to the installer's `programs.yml`
(https://github.com/Navatusein/GTNH-OC-Installer) via PR, or host your own fork:

```yaml
- name: Space Miner
  description: Automated GTNH Space Elevator space mining controller
  archiveUrl: https://github.com/YOUR_USER/GTNH-OC-Space-Miner/releases/latest/download/SpaceMiner.tar
  configDescriptorUrl: https://raw.githubusercontent.com/YOUR_USER/GTNH-OC-Space-Miner/main/config-descriptor.yml
```

And the legacy `programs.lua`:

```lua
{
  name = "Space Miner",
  description = "Automated GTNH Space Elevator space mining controller",
  url = "https://github.com/YOUR_USER/GTNH-OC-Space-Miner/releases/latest/download/SpaceMiner.tar"
}
```

## Repository layout

All program files live at the **repo root** (flat), because the tar is extracted
straight into `/home`:

```
main.lua  config.lua  ores.lua  mining.lua  scheduler.lua  search.lua
lookup.lua  equipment.lua  dronebuffer.lua  updater.lua  version.lua
asteroids_mk1.lua  asteroids_mk2.lua  asteroids_mk3.lua
config-descriptor.yml          # web configurator schema (root, raw-fetched)
version.lua                     # current version (root, raw-fetched)
.github/workflows/release.yml   # release builder
```
