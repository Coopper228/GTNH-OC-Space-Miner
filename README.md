# GTNH-OC-Space-Miner

OpenComputers controller for the GTNH **Space Elevator → Space Miner** modules.
It auto-detects the hardware, keeps a configurable set of ores stocked from the
ME network, and delivers exactly one mining drone to each miner via a buffer
chest (so the Input Bus never floods with a whole stack of drones).

Repository: `Coopper228/GTNH-OC-Space-Miner`

## How it works

### Item flow (redstone-driven)
Each miner is fed by a pipe between its **ME Interface** and its **GT Input Bus**,
switched by a **Redstone I/O** block:

- signal **HIGH** → items flow ME Interface → Input Bus (miner runs)
- signal **LOW** → the bus drains back into the ME Interface

While a miner works the controller just holds the signal HIGH; AE2 keeps the
interface stocked with drill tips and rods, which are consumables.

### The drone problem & the buffer chest
A miner needs exactly **one** drone, but drones are stackable. A stocked ME
Interface would let the pipe pull a whole stack while the signal is HIGH, because
AE2 refills the slot from the network as fast as the pipe empties it.

The fix: **keep zero drones in the ME network at rest.** All drones live in a
dedicated **buffer chest**. A single **transposer** moves drones between the chest
and a dedicated **drone ME interface** wired into the network:

```
[ buffer chest ] -- transposer -- [ drone ME interface ] ~~ ME network
```

- **inject** (chest → interface → network): before a miner starts, exactly one
  drone is pushed into the network. With only one present, the pipe physically
  cannot pull more than one.
- **reclaim** (network → interface → chest): after a job the drone drains back
  into the network; each scan it is swept back to the chest. Self-healing.

The chest is the single source of truth for "how many drones are available".
All buffer operations verify against real chest/network reads — no blind delays.

## Hardware

Per miner (auto-detected, no addresses to enter):

- GT Space Miner with an Adapter holding an **MFU** bound to it
- a **Redstone I/O** block
- an **ME Interface** + Adapter
- a redstone-switched pipe between the interface and the miner's Input Bus

Drone buffer (one of each in the whole system, auto-detected):

- a **buffer chest** holding all mining drones
- a **transposer** touching both the chest and the drone interface
- a dedicated **drone ME interface** (+ Adapter) — the one ME interface not bound
  to any miner

## Install (in-game)

Run the installer and pick **Space Miner**:

```
pastebin run 8t6B7HC5
```

Say **yes** to autorun so it launches on boot (writes `/home/.shrc` = `main`).

Or install directly:

```
wget -f https://github.com/Coopper228/GTNH-OC-Space-Miner/releases/latest/download/SpaceMiner.tar /home/program.tar
cd /home && tar -xf program.tar && rm program.tar
```

**First launch** runs auto-detection (`search`). For this to work, have your
**drones in the ME network** (not the chest) so the miners can light up during
detection. On the first scan afterwards the program reclaims them into the chest.

## Configure

Use the web configurator (no in-game editing needed):

```
https://coopper228.github.io/GTNH-OC-Web-Configurator/#/configurator?url=https://raw.githubusercontent.com/Coopper228/GTNH-OC-Space-Miner/main/config-descriptor.yml
```

Set the timings and the **ore targets** (label / target / priority), download the
generated `config.lua` to `/home`, and restart. **Only ores listed in
`ore_targets` are mined** — an empty list means nothing is mined. Hardware is
never configured by hand; it lives in `/home/miners.lua`.

## Troubleshooting the drone buffer

Set `debug = true` in `config.lua` and restart. At startup you'll get a
`[diag]` report of the buffer:

- the transposer address and the chest / interface sides (name + slot count)
- how many drones the transposer sees **in the chest**, per tier
- how many drones are **in the network** (these get reclaimed)

Common issues:

| Symptom | Likely cause |
|---|---|
| `[diag] chest: NO drones` but the chest is full | wrong chest side, or drone item-name mismatch — check the `[diag]` sides |
| Drones never move from network to chest | reclaim can't stock the drone interface — verify the spare interface is the drone interface and the transposer faces it |
| Nothing is ever mined | `ore_targets` is empty, or no drones of a viable tier are in the chest |
| `miner did not start` | the per-miner pipe/redstone/interface link is wrong — re-run search (delete `/home/miners.lua`) |

## Releasing (maintainer)

1. Bump `programVersion` in `version.lua` (and `configVersion` only if the config
   format changed incompatibly).
2. Tag and push, or run the Release workflow manually:
   ```
   git tag v1.1.0 && git push origin v1.1.0
   ```
   The Action packs all root `*.lua` into `SpaceMiner.tar` and attaches it to the
   release. The installer and self-updater download
   `releases/latest/download/SpaceMiner.tar`.

## Files

All program files live at the **repo root** (flat) — the tar is extracted into
`/home`:

```
main.lua        entry point + main loop
config.lua      settings (web-generated)
version.lua     current version (raw-fetched by the updater)
updater.lua     self-update from GitHub
asteroids.lua   static data: drone chance tables + ore catalog
ae.lua          ME/AE2 layer: equipment, database, network queries
mining.lua      drone buffer + scheduler + per-miner state machine
search.lua      one-time hardware auto-detection
config-descriptor.yml      web configurator schema (raw-fetched)
.github/workflows/release.yml
```
