# PlutoNotebookComparison.jl
Compare two statefiles of the same notebook (e.g. after making a PR). 

This is useful in GitHub Actions (with PlutoSliderServer.jl). You can automatically find unexpected **new** errors, like:
- Failing package imports
- Errors that did not happen before
- Tests about examples/results from the notebook






## Idea

You use this in a GHA that runs on PRs




```yaml
on:
    - pr

steps:


cache:
    get cache dir
    
    
checkout:
    main


run: PSS on all notebooks (will prob all be cached, but this ensures that)

checkout:
    PR

run: PSS on all notebooks


# THEN

run: this package on the diff
```




## How it works



Get a GitDiff between main and PR: `diff`

> maybe use `merge_base(repo::GitRepo, one::AbstractString, two::AbstractString) -> GitHash`

Find all notebook files
For each,
    iterate `diff` and find `d` that has the file as output
    if so, use it to get the old path and contents
    If added, do nothing
If nothing found, identity


We then have:
- (oldpath, oldcontents), (newpath, newcontents)

For both, extract statefile from a cache source.

Diff:


drama_new_error
drama_output_changed
drama_broken_import
drama_nbpkg_changed (check nbpkg logs for drama) -> show full output
drama_nbpkg_wrong, not instantiated, restart recommended/required, -> show full output


run like test CI

error("There were unexpected changes")


















## Beauty






## Notebook tests



