-- Program version, read by the self-updater (updater.lua).
--
--   programVersion : human-readable version. The updater compares versions by
--                    stripping every non-digit and comparing the result
--                    numerically, so "1.0.0" -> 100, "1.2.0" -> 120. Keep the
--                    same number of segments across releases so the comparison
--                    stays monotonic (e.g. always MAJOR.MINOR.PATCH).
--   configVersion  : bump ONLY when config.lua's format changes in a way that
--                    breaks old config files. When the remote configVersion is
--                    higher than the installed one, the updater keeps the user's
--                    config.old.lua and asks them to rewrite it by hand instead
--                    of silently restoring an incompatible config.
return {
    programVersion = "1.1.0",
    configVersion  = 1,
}
