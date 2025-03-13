using LibGit2

function checkout_test_repo(; branch_name::String="main", repo_url::String="https://github.com/JuliaPluto/PlutoNotebookComparison-test")
    testdir = mktempdir()
    opts = LibGit2.CloneOptions(checkout_branch=Base.unsafe_convert(Cstring, branch_name))
    repo = LibGit2.clone(repo_url, testdir, opts)
    # avoid gc
    println(devnull, branch_name)
    
    return testdir
end