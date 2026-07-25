# GTNH-OC-Space-Miner

OpenComputers program that fully automates **Space Elevator Space Miner** modules
in GregTech: New Horizons. Tell it which ores you need and how many — it does the
rest: picks asteroids, delivers drones, runs the miners and keeps your ME network
stocked.

## What it does

- **Target-based mining** — configure a list of ores with target amounts and
  priorities; the program mines until every target is met, then idles and
  automatically resumes when stock drops below target again.
- **Smart job scheduling** — each miner always gets the most useful job:
  shortages (as % of target) are balanced against each other, priorities are
  respected, every miner digs in its **maximum-chance** drone configuration, and
  work is spread across several asteroids instead of piling onto a single one.
- **Any fleet size** — any number of Miner Tier 1/2/3 modules in any mix, and
  all 13 drone tiers (LV–UXV).
- **Fast, lag-free item delivery** — miners are fed through redstone-switched
  translocators, so machines never stall waiting for a slow transposer.
- **Exactly one drone per miner** — a buffer-chest scheme makes it impossible
  for a miner to swallow a whole stack of drones; after each job the drone is
  returned to the chest automatically. Drones are never consumed.
- **Zero-hassle setup** — one-time automatic hardware detection: no addresses to
  type in, every miner / interface / redstone block is discovered and saved.
- **Web-based configuration** — all settings are edited in the browser, no
  in-game text editing.
- **Self-updating** — checks GitHub releases at startup and updates in place.
- **Self-healing** — stray drones are swept back into the buffer chest, and
  miners that stopped on their own (broken drone, ran out of supplies) are
  detected and restarted with a fresh drone.

## Hardware

Per miner (auto-detected):

- GT Space Miner (T1–T3) with an Adapter holding an **MFU** bound to it
- a **Redstone I/O** block
- an **ME Interface** + Adapter
- a redstone-switched pipe (e.g. translocator) between the interface and the
  miner's Input Bus

Once per system (auto-detected):

- a **buffer chest** holding all mining drones
- a **transposer** touching both the chest and a dedicated **drone ME Interface**
  (+ Adapter) — the one interface not bound to any miner
- an Adapter on the **ME Controller**
- a **Database upgrade (Tier 3)** reachable by the computer (e.g. in an Adapter)

## Install (in-game)

Run the installer and pick **Space Miner**:

```
pastebin run 8t6B7HC5
```

Say **yes** to autorun so it launches on boot.

Or install directly:

```
wget -f https://github.com/Coopper228/GTNH-OC-Space-Miner/releases/latest/download/SpaceMiner.tar /home/program.tar
cd /home && tar -xf program.tar && rm program.tar
```

**First launch** runs hardware auto-detection. For this to work, have your
**drones in the ME network** (not the chest) so the miners can light up during
detection. On the first scan afterwards the program moves them into the chest.

## Configure

Use the web configurator — no in-game editing needed:

```
https://coopper228.github.io/GTNH-OC-Web-Configurator/#/configurator?url=https://raw.githubusercontent.com/Coopper228/GTNH-OC-Space-Miner/main/config-descriptor.yml
```

Set the timings and the **ore targets** (label / target / priority), download the
generated `config.lua` to `/home`, and restart. **Only ores listed in
`ore_targets` are mined** — an empty list means nothing is mined.

## Troubleshooting

Set `debug = true` in `config.lua` and restart — at startup you'll get a `[diag]`
report of the drone buffer (transposer sides, drones in the chest per tier,
drones in the network).

| Symptom | Likely cause |
|---|---|
| `[diag] chest: NO drones` but the chest is full | wrong chest side or drone item mismatch — check the `[diag]` sides |
| Drones never move from network to chest | the spare interface isn't the drone interface, or the transposer doesn't face it |
| Nothing is ever mined | `ore_targets` is empty, or no drones of a viable tier are in the chest |
| `miner did not start` | per-miner pipe/redstone/interface link is wrong — delete `/home/miners.lua` and re-run detection |

## Releasing (maintainer)

Bump `programVersion` in `version.lua`, then tag and push (`git tag v1.2.0 &&
git push origin v1.2.0`). The Release workflow packs all root `*.lua` into
`SpaceMiner.tar` and attaches it to the release, which the installer and the
self-updater download.
