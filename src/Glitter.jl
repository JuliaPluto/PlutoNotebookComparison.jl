module Glitter

using LibGit2




function head_tree(repo::GitRepo, )
    head_ref = LibGit2.head(repo)
    head_tree = LibGit2.peel(LibGit2.GitTree, head_ref)
end



function branch_tree(repo::GitRepo, branch_name=nothing)
    main_ref = if branch_name === nothing
        @something(
            LibGit2.lookup_branch(repo, "main", false),
            LibGit2.lookup_branch(repo, "master", false),
        )
    else
        LibGit2.lookup_branch(repo, branch_name, false)
    end
    main_tree = LibGit2.peel(LibGit2.GitTree, main_ref)
end









function PR_diff(dir=pwd())
    repo = LibGit2.GitRepo(dir)
    diff_tree(repo, branch_tree(repo), head_tree(repo))   
end


const diff_tree = LibGit2.diff_tree

deltas(diff::GitDiff) = [diff[i] for i in 1:LibGit2.count(diff)]




end