# CRAN submission comments

## Test environments

- Local Linux (R 4.5.2): `R CMD check --as-cran`, 0 errors, 0 warnings, 0 notes.
- GitHub Actions: Ubuntu, Windows and macOS with R release and devel.

## R CMD check results

The package uses only CRAN packages.  All examples are wrapped in
`\dontrun{}` or are cheap; suggested packages are optional and the package
works without them.

## Notes

- `tcltk` is deliberately not a dependency: this package removes the Tk
  dependency of the original R Commander.
- The package contains translation catalogues copied from Rcmdr 2.15.0
  (GPL-2+); attribution is in `NOTICE` and `UPSTREAM.md`.
- Legacy Rcmdr plugins are detected but Tk dialogs are not executed; this is
  documented in the plugins vignette.
