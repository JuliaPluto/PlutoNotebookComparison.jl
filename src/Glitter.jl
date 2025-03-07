module Glitter

using LibGit2




function head_tree(repo::GitRepo, )
    head_ref = LibGit2.head(repo)
    head_tree = LibGit2.peel(LibGit2.GitTree, head_ref)
end



function branch_tree(repo::GitRepo, branch_name=nothing, is_branch_remote::Bool=false)
    main_ref = if branch_name === nothing
        @something(
            LibGit2.lookup_branch(repo, "main", false),
            LibGit2.lookup_branch(repo, "origin/main", true),
            LibGit2.lookup_branch(repo, "master", false),
            LibGit2.lookup_branch(repo, "origin/master", true),
        )
    else
        LibGit2.lookup_branch(repo, branch_name, is_branch_remote)
    end
    main_tree = LibGit2.peel(LibGit2.GitTree, main_ref)
end


function PR_diff(repo=LibGit2.GitRepo(pwd()))
    diff_tree(repo, branch_tree(repo), head_tree(repo))   
end


const diff_tree = LibGit2.diff_tree

deltas(diff::LibGit2.GitDiff) = [diff[i] for i in 1:LibGit2.count(diff)]

function contents(repo::LibGit2.GitRepo, df::LibGit2.DiffFile)
	LibGit2.GitBlob(repo, df.id) |> LibGit2.content
end


is_added(d::LibGit2.DiffDelta) = LibGit2.Consts.DELTA_STATUS(d.status) == LibGit2.Consts.DELTA_ADDED
is_deleted(d::LibGit2.DiffDelta) = LibGit2.Consts.DELTA_STATUS(d.status) == LibGit2.Consts.DELTA_DELETED
is_modified(d::LibGit2.DiffDelta) = LibGit2.Consts.DELTA_STATUS(d.status) == LibGit2.Consts.DELTA_MODIFIED
# is_renamed(d::LibGit2.DiffDelta) = LibGit2.Consts.DELTA_STATUS(d.status) == LibGit2.Consts.DELTA_RENAMED




# use like so:

# repo = Glitter.LibGit2.GitRepo(pwd())
# diff = Glitter.PR_diff(repo)
# ds = Glitter.deltas(diff)
# for d in ds
#     if Glitter.is_modified(d)
#       println(Glitter.contents(repo, d.new_file))
#     end
# end


end