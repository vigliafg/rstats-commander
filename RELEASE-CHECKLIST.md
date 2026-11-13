# RcmdrShiny 1.0.0 release checklist

## Code

- [x] All user-facing Rcmdr dialogs ported (138/142 inventory entries; the
      remaining four are internal Tk utilities).
- [x] Command builders covered by golden tests.
- [x] Server integration tests for the main flows.
- [x] Browser end-to-end test (`RCMDRSHINY_E2E=1`).
- [x] Plugin API tested (menus, commands, dialogs, legacy warning).
- [x] Large-output and plot-history limits.
- [x] Accessibility pass: skip link, landmarks, ARIA live regions, focus
      styles, image alt text.

## Checks

- [x] `R CMD check --no-manual` clean.
- [ ] `R CMD check --as-cran` final run.
- [x] Vignettes build (Getting Started, Migrating, Plugins).
- [x] pkgdown configuration.
- [x] CI for Linux/Windows/macOS.
- [x] Coverage and browser E2E workflows.
- [x] Example plugin.
- [x] `CITATION`, desktop entry, `NOTICE`, `UPSTREAM`.

## Release

- [ ] Final `R CMD build` and upload to CRAN.
- [ ] GitHub release with changelog and tarball.
- [ ] Announce release.
