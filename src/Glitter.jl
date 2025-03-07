### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ eb3af33e-fa9d-11ef-0099-cd0bf09dd98c
using LibGit2

# ╔═╡ c6b8597a-0e7f-40c8-99e3-5e82cc66ac8c
# ╠═╡ skip_as_script = true
#=╠═╡
repo = LibGit2.GitRepo("/Users/fons/Documents/PlutoUI.jl/")
  ╠═╡ =#

# ╔═╡ d3489764-7d97-46a8-9cfd-30f21c4fc491


# ╔═╡ 3519b631-af7c-499a-8ea8-8bc437f1ff39


# ╔═╡ 4d01c499-3af0-4d56-845b-1d02bc8b6545


# ╔═╡ 03538ca7-e470-4af4-bb89-ec355a75ec02


# ╔═╡ 419226ea-c2fc-4046-99ba-8982410838a1


# ╔═╡ 9c41418f-1b4b-4346-9210-f870bbbfd4ae
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

# ╔═╡ 4a057ad2-f1ee-4de4-a852-cc115ed39d07
function head_tree(repo::GitRepo)
    head_ref = LibGit2.head(repo)
    head_tree = LibGit2.peel(LibGit2.GitTree, head_ref)
end

# ╔═╡ 3166e0a4-b292-4ec9-876a-e50ead4ad24e

const diff_tree = LibGit2.diff_tree


# ╔═╡ 368f86ff-bb52-43fb-96fc-0f2953f71622
function PR_diff(repo=LibGit2.GitRepo(pwd()))
    diff_tree(repo, branch_tree(repo), head_tree(repo))   
end

# ╔═╡ 5bd1aeb4-8415-4780-bf97-bdbb9ee98a5b
#=╠═╡
diff = PR_diff(repo)
  ╠═╡ =#

# ╔═╡ a92f3b37-e339-41ad-8c6b-9b77847b206f
#=╠═╡
pr = PR_diff(repo)
  ╠═╡ =#

# ╔═╡ cb576138-194d-44b6-9bb1-eeb7aaa1ef4b
#=╠═╡
pr.owner
  ╠═╡ =#

# ╔═╡ 8265d9ac-4db2-4315-9c82-2c277cc088cd
#=╠═╡
repo
  ╠═╡ =#

# ╔═╡ c67b7326-9048-4f56-85b3-ea62ddc858f3
find(f, xs) = for x in xs
	f(x) && return x
end

# ╔═╡ 314025ab-b692-403c-8298-f66c9ede7a74
deltas(diff::LibGit2.GitDiff) = [diff[i] for i in 1:LibGit2.count(diff)]

# ╔═╡ 0de2f759-8acf-4c47-adaf-7df5af163d42
#=╠═╡
ds = deltas(diff)
  ╠═╡ =#

# ╔═╡ b76e0433-ef8c-40ed-b4a9-48509f0f9c14
#=╠═╡
unsafe_string(deltas(pr)[4].new_file.path)
  ╠═╡ =#

# ╔═╡ a56467c8-7f30-4297-a519-4e3b6c1dd180
#=╠═╡
deltas(pr)[4]
  ╠═╡ =#

# ╔═╡ 09b8476c-4e72-4483-8e03-164db90cb4d4
function contents(repo::LibGit2.GitRepo, df::LibGit2.DiffFile)
	LibGit2.GitBlob(repo, df.id) |> LibGit2.content
end

# ╔═╡ ba98991b-00de-4870-98cd-e80aa90c8681


# ╔═╡ ef0d5fca-5b2c-4033-a4ff-f8528ed58afb
is_added(d::LibGit2.DiffDelta) = LibGit2.Consts.DELTA_STATUS(d.status) == LibGit2.Consts.DELTA_ADDED

# ╔═╡ 9694a029-51f2-4c63-8b63-95931a8c83a3
is_deleted(d::LibGit2.DiffDelta) = LibGit2.Consts.DELTA_STATUS(d.status) == LibGit2.Consts.DELTA_DELETED

# ╔═╡ 6be0c7a9-3d6a-42b5-a205-21863b6ce5da
is_modified(d::LibGit2.DiffDelta) = LibGit2.Consts.DELTA_STATUS(d.status) == LibGit2.Consts.DELTA_MODIFIED

# ╔═╡ ea4aa64d-f6ad-485b-850e-22558c75589d
#=╠═╡
for d in ds
    if is_modified(d)
      @info "Modified!" unsafe_string(d.new_file.path) d contents(repo, d.new_file)
    end
end
  ╠═╡ =#

# ╔═╡ 21fac1e9-06b6-409e-9b5f-c59af9d12cd5
# is_renamed(d::LibGit2.DiffDelta) = LibGit2.Consts.DELTA_STATUS(d.status) == LibGit2.Consts.DELTA_RENAMED

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LibGit2 = "76f85450-5226-5b5a-8eaa-529ad045b433"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.3"
manifest_format = "2.0"
project_hash = "18d0c36871abb9db1144b29c5117df548eb8c755"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"
"""

# ╔═╡ Cell order:
# ╠═c6b8597a-0e7f-40c8-99e3-5e82cc66ac8c
# ╠═5bd1aeb4-8415-4780-bf97-bdbb9ee98a5b
# ╠═0de2f759-8acf-4c47-adaf-7df5af163d42
# ╠═ea4aa64d-f6ad-485b-850e-22558c75589d
# ╟─d3489764-7d97-46a8-9cfd-30f21c4fc491
# ╟─3519b631-af7c-499a-8ea8-8bc437f1ff39
# ╟─4d01c499-3af0-4d56-845b-1d02bc8b6545
# ╟─03538ca7-e470-4af4-bb89-ec355a75ec02
# ╟─419226ea-c2fc-4046-99ba-8982410838a1
# ╠═eb3af33e-fa9d-11ef-0099-cd0bf09dd98c
# ╠═9c41418f-1b4b-4346-9210-f870bbbfd4ae
# ╠═4a057ad2-f1ee-4de4-a852-cc115ed39d07
# ╠═368f86ff-bb52-43fb-96fc-0f2953f71622
# ╠═3166e0a4-b292-4ec9-876a-e50ead4ad24e
# ╠═a92f3b37-e339-41ad-8c6b-9b77847b206f
# ╠═cb576138-194d-44b6-9bb1-eeb7aaa1ef4b
# ╠═8265d9ac-4db2-4315-9c82-2c277cc088cd
# ╠═b76e0433-ef8c-40ed-b4a9-48509f0f9c14
# ╠═a56467c8-7f30-4297-a519-4e3b6c1dd180
# ╠═c67b7326-9048-4f56-85b3-ea62ddc858f3
# ╠═314025ab-b692-403c-8298-f66c9ede7a74
# ╠═09b8476c-4e72-4483-8e03-164db90cb4d4
# ╟─ba98991b-00de-4870-98cd-e80aa90c8681
# ╠═ef0d5fca-5b2c-4033-a4ff-f8528ed58afb
# ╠═9694a029-51f2-4c63-8b63-95931a8c83a3
# ╠═6be0c7a9-3d6a-42b5-a205-21863b6ce5da
# ╠═21fac1e9-06b6-409e-9b5f-c59af9d12cd5
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
