using LibGit2

function checkout_test_repo(; branch_name::String="origin/main", repo_url::String="https://github.com/JuliaPluto/PlutoNotebookComparison-test")
    # thx chatght
    
	testdir = mktempdir()
	
	# Clone the repo (shallow default)
	repo = LibGit2.clone(repo_url, testdir)
	
	remote_branch = LibGit2.lookup_branch(repo, branch_name, true)
	@assert remote_branch !== nothing "Remote branch $branch_name not found after fetch."
	
	# Peel the branch to the commit it points to
	commit = LibGit2.peel(LibGit2.GitCommit, remote_branch)
    
    
    # Local branch name (strip "origin/" if present)
    local_branch_name = basename(branch_name)
    
    # Only create it if it doesn't already exist
    existing_local_branch = LibGit2.lookup_branch(repo, local_branch_name, false)
    if existing_local_branch === nothing
        LibGit2.create_branch(repo, local_branch_name, commit)
    end
	
	# Set HEAD to the local branch and check it out
	LibGit2.head!(repo, remote_branch)
	LibGit2.checkout!(repo; force=true)

    testdir
end