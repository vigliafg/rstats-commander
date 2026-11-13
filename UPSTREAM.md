# Upstream synchronisation

RcmdrShiny is a fork of the R Commander engine.  This document records the
reference version and the procedure used to synchronise with it.

## Reference version

| Field | Value |
|---|---|
| Package | Rcmdr |
| Version | 2.15.0 |
| Date | 2026-09-24 |
| Upstream | https://github.com/RCmdr-Project/rcmdr |

## What is copied verbatim

- `inst/etc/Rcmdr-menus.txt`
- `inst/po/*.po` (translation catalogues)

Both keep their original copyright and are distributed under GPL-2+.

## What is reimplemented

The Tcl/Tk dialogs are reimplemented as Shiny modules.  Command generation is
reimplemented in pure functions in `R/command-builders.R` and checked against
the original behaviour by golden tests.  The source of each ported dialog is
noted in its file header and in `NOTICE`.

## Sync procedure

1. Download the new Rcmdr source tarball and unpack it.
2. Copy `inst/etc/Rcmdr-menus.txt` and `inst/po/*.po` into this repository.
3. Run the inventory tool:
   ```sh
   Rscript tools/inventory_dialogs.R /path/to/Rcmdr
   ```
4. Diff the inventory against the previous version and review dialogs whose
   command generation changed.
5. Run the test suite:
   ```sh
   Rscript -e 'testthat::test_local()'
   ```
6. Update the reference version in this file and in `NOTICE`.

## Versioning

RcmdrShiny versions are independent from Rcmdr.  `DESCRIPTION` records the
package version; this file records the upstream version.  A change in the
upstream version does not imply a new RcmdrShiny release, but every release
must state which upstream version it tracks.
