using Test

using PlutoNotebookComparison


dir = joinpath(@__DIR__, "statefiles")


sources = [
    PSSCache(dir)
    WebsiteDir(dir)
]
repo = PlutoNotebookComparison.LibGit2.GitRepo(joinpath(@__DIR__, ".."))

PlutoNotebookComparison.compare_PR(dir;
    diff=Glitter.PR_diff(repo),
    sources_old=sources,
    sources_new=sources,
)
