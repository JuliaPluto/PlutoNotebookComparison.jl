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
	
	# Create a local branch "good1" from the commit
	LibGit2.create_branch(repo, basename(branch_name), commit)
	
	# Set HEAD to the local branch and check it out
	LibGit2.head!(repo, remote_branch)
	LibGit2.checkout!(repo; force=true)

    testdir
end