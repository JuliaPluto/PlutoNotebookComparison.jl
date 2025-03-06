### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ aa68c324-eabf-11ef-2a75-19adc8937c8a
using Pluto

# ╔═╡ af7c27ca-5f81-49be-86a9-74d52a90346a


# ╔═╡ 8447d68b-eb5b-45ed-90d2-379747854b03
md"""
# State diff
"""

# ╔═╡ 40e38f1f-7e7a-42c5-9bdc-ccaebba627d9
# ╠═╡ skip_as_script = true
#=╠═╡
state1_raw = read("../test/statefiles/test1.plutostate")
  ╠═╡ =#

# ╔═╡ 940105fc-2622-4f20-9826-8bb8ac2d5cd2
#=╠═╡
state1 = Pluto.unpack(state1_raw)
  ╠═╡ =#

# ╔═╡ e46aec14-8e7c-453a-8aa2-cb1a50d99501
# ╠═╡ skip_as_script = true
#=╠═╡
state2_raw = read("../test/statefiles/test3.plutostate")
  ╠═╡ =#

# ╔═╡ 04d317ff-50dc-4dec-b543-8deb96964f9f
#=╠═╡
state2 = Pluto.unpack(state2_raw)
  ╠═╡ =#

# ╔═╡ ae6c5709-bbda-44e4-8757-8e14554efe67
#=╠═╡
diff = Pluto.Firebasey.diff(state1, state2)
  ╠═╡ =#

# ╔═╡ e4d7acdf-88d3-474f-b8e0-3bfb693e371a
#=╠═╡
if any(p -> isempty(p.path), diff)
	error("Completely different notebook")
end
  ╠═╡ =#

# ╔═╡ dde77a7b-08f7-47bd-bf8c-1ed6d83d4d3e
const safe_to_ignore_result_keys = (
	"cell_id",
	"depends_on_disabled_cells",
	"depends_on_skipped_cells",
	"published_object_keys",
	"runtime",
	"output/last_run_timestamp",
	"output/persist_js_state",
)

# ╔═╡ a6a8e09a-f57c-457b-940d-d9a4b182b48b
function getsub(object, default, next, key_list...)
	if haskey(object, next)
		val = get(object, next, default)

		if length(key_list) >= 1
			getsub(val, default, key_list[1], key_list[2:end]...)
		else
			val
		end
	else
		default
	end
end

# ╔═╡ 55f93c0d-99af-4951-9eea-103cab827e18
#=╠═╡
getsub(state1, nothing, "cell_inputs", "ab4d46eb-d441-47c3-b061-2611b2e44009", "code_folded")
  ╠═╡ =#

# ╔═╡ 757e75fd-1702-4822-a74c-49b61e22e350
function is_folded(state, cell_id, fallback=true)
	getsub(state, fallback, "cell_inputs", cell_id, "code_folded")
end

# ╔═╡ 343e3baa-921b-45af-8e19-077f6b098085
function is_errored(state, cell_id, fallback=false)
	getsub(state, fallback, "cell_results", cell_id, "errored")
end

# ╔═╡ a245acaf-b112-4af0-ba4b-78fda3b2da8e
flatmap(args...) = vcat(map(args...)...)

# ╔═╡ 4087533e-c54b-4cb9-b474-e82ad98b0229
begin
	abstract type Change end



	struct ErrorChanged <: Change
		cell_id::String
		new_errored::Bool
	end

	struct CodeChanged <: Change
		cell_id::String
		code_folded::Bool
	end
	struct FoldedChanged <: Change
		cell_id::String
		code_folded::Bool
	end

	struct Outputchanged <: Change
		cell_id::String
	end

end

# ╔═╡ a341a46e-3dc5-4e21-9ebe-f9d45c5eb51e
function changes(patch::Pluto.Firebasey.JSONPatch, newstate)::Vector{Change}
	path = patch.path
	cell_id = get(path, 2, "notfound")
	if path[1] == "cell_inputs"
		@assert length(path) >= 2
		
		just_a_fold = length(path) == 3 && path[3] == "code_folded"
		T = just_a_fold ? FoldedChanged : CodeChanged
		
		Change[T(cell_id, is_folded(newstate, cell_id))]
	elseif path[1] == "cell_results"
		@assert length(path) >= 2

		if length(path) >= 3
			subpath = join(path[3:end],"/")
			if any(s -> startswith(subpath, s), safe_to_ignore_result_keys)
				Change[]
			else
				if subpath == "errored"
					Change[ErrorChanged(cell_id, is_errored(newstate, cell_id))]
				else
					Change[Outputchanged(cell_id)]
				end
			end
		else
			# all possible changes
			Change[
				Outputchanged(cell_id), 
				ErrorChanged(cell_id, is_errored(newstate, cell_id)),
			]
		end
	else
		# the rest doesnt really matter
		Change[]
	end
end

# ╔═╡ e8007d30-2b0a-46c4-80a7-a1d4367fb3a3
#=╠═╡
cs = flatmap(d -> changes(d, state2), diff)
  ╠═╡ =#

# ╔═╡ 28a86c8f-7de0-4e3d-81bb-5c371e28494b


# ╔═╡ 85e8d9cc-211a-47ff-9963-671fd22e3744


# ╔═╡ 73582e38-5bff-45bf-957c-76c31af91581


# ╔═╡ 2c96d25e-698e-4858-a9b3-9118d11e223f


# ╔═╡ ccedc075-7ad2-40df-95d4-caf1dbad54ae


# ╔═╡ 4ef643cf-0597-492f-b01c-b33a92628ac5


# ╔═╡ ecbb0746-54c1-4029-b9b8-3ea5413ae954
#=╠═╡
changes_per_cell = map(state2["cell_order"]) do id
	filter(cs) do c
		c.cell_id == id
	end
end
  ╠═╡ =#

# ╔═╡ d638130c-02f4-442c-b036-836731f83844
#=╠═╡
cs
  ╠═╡ =#

# ╔═╡ 786a675b-94dc-4b2a-ac22-182047182e8d
struct DramaContext
	old_state::Dict
	new_state::Dict
	old_cell_order::Vector{String}
	new_cell_order::Vector{String}
	diff::Vector{Pluto.Firebasey.JSONPatch}
	changes::Vector{Change}
	changes_per_cell::Vector{Vector{Change}}
end

# ╔═╡ e755dc2a-8c52-40c0-8bde-aba0f915bde7
#=╠═╡
function get_drama_context(state1, state2)
	diff = Pluto.Firebasey.diff(state1, state2)
	cs = flatmap(d -> changes(d, state2), diff)

	di = DramaContext(
		state1, state2, state1["cell_order"], state2["cell_order"], diff, cs, changes_per_cell
	)
end
  ╠═╡ =#

# ╔═╡ 7ebe8d30-2289-49c2-9f83-9df17ac3880b
#=╠═╡
di = get_drama_context(state1, state2)
  ╠═╡ =#

# ╔═╡ fa92db07-67ad-4e0f-9254-62a94ac370dc


# ╔═╡ e658eb77-6185-44be-a3b0-65c5a7437baa


# ╔═╡ a57abe11-274b-414a-aa42-9e034768e78a


# ╔═╡ e1168ad4-ef52-4d75-8ab7-cfd903303261


# ╔═╡ 0799a467-2fe9-4cc9-ab91-dcf6dbb3973d


# ╔═╡ 098ee496-b284-4f11-86d1-d9b23d74faa1


# ╔═╡ 890552e5-05a6-471d-8be9-7ff50ffa1526
function drama_broken_import(di::DramaContext)
	for (cell_id, change) in zip(di.new_cell_order, di.changes_per_cell)
		drama_broken_import(di.new_state, cell_id, change)
	end
end

# ╔═╡ e44ccceb-32ac-4af5-8bfd-ea00cd04883e


# ╔═╡ 1877f8d8-a3b9-4015-b301-f2e0d0b86f50


# ╔═╡ 135e4ec3-dd15-490b-855b-6a258febf1e5
function drama_new_error(di::DramaContext)
	for ch in di.changes
		if ch isa ErrorChanged && ch.new_errored
			error("New error! Cell $(ch.cell_id)")
		end
	end
end

# ╔═╡ 0785487e-1653-4d16-ad12-7d141bd61a56
#=╠═╡
drama_new_error(di)
  ╠═╡ =#

# ╔═╡ 1f1ba51d-f8ef-4d6e-b627-5c347508936f


# ╔═╡ 19534135-1dfb-406e-a506-19d73920353d


# ╔═╡ 916477bc-7a8e-4a9d-9803-ca36e58b4396
function get_recursive_deps(state, cell_id)
	map = getsub(state, Dict(), "cell_dependencies", cell_id, "upstream_cells_map")
	# vcat(values(map)...)
end

# ╔═╡ 52a7aa4f-ecd0-415a-b827-7c06d783c27a
#=╠═╡
state2["cell_dependencies"]
  ╠═╡ =#

# ╔═╡ 3d48523c-9e66-4c85-b5a4-c991ba1d07c9
#=╠═╡
map(state2["cell_order"]) do c
	get_recursive_deps(state2, c)
end
  ╠═╡ =#

# ╔═╡ 6582655f-c8ce-4870-85c8-dbf1d90b604f
#=╠═╡
state2
  ╠═╡ =#

# ╔═╡ a801a854-d20c-49db-a080-a49a7fb323b9
function drama_output_changed(state, cell_id, cell_changes)
	
end

# ╔═╡ 9f9494ab-b994-4af3-9547-87eb10d1b9de
# ╠═╡ skip_as_script = true
#=╠═╡
ex = Meta.parse("""
		   begin
import X
		   asdf
		   end
		   """)
  ╠═╡ =#

# ╔═╡ 2c992336-a2f8-412b-acca-cd84dbc48e7b
import ExpressionExplorer

# ╔═╡ edb3140c-d8ec-467f-ba53-74a5016b8735
function drama_broken_import(state, cell_id, cell_changes)
	if is_errored(state, cell_id, false)
		code = getsub(state, "zzz", "cell_inputs", cell_id, "code")
		ex = Meta.parse(code; raise=false)
		does_imports = ex |> ExpressionExplorer.compute_usings_imports |> ExpressionExplorer.external_package_names

		if !isempty(does_imports)
			error("Something went wrong in the cell that imports $(does_imports)")
		end
	end
end

# ╔═╡ 284f564e-4f59-43be-9f20-449c002350c1
#=╠═╡
drama_broken_import(di)
  ╠═╡ =#

# ╔═╡ 7d7d0f25-b92b-433d-aa68-dc8b65390c1e
#=╠═╡
ExpressionExplorer.compute_usings_imports(ex) |> ExpressionExplorer.external_package_names |> isempty
  ╠═╡ =#

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ExpressionExplorer = "21656369-7473-754a-2065-74616d696c43"
Pluto = "c3e4b0f8-55cb-11ea-2926-15256bba5781"

[compat]
ExpressionExplorer = "~1.1.1"
Pluto = "~0.20.4"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.3"
manifest_format = "2.0"
project_hash = "259e9a8d97a93dbc0ebd0326f5ef0a0763c78107"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "962834c22b66e32aa10f7611c08c8ca4e20749a9"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.8"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "d9d26935a0bcffc87d2613ce14c527c99fc543fd"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.5.0"

[[deps.Configurations]]
deps = ["ExproniconLite", "OrderedCollections", "TOML"]
git-tree-sha1 = "4358750bb58a3caefd5f37a4a0c5bfdbbf075252"
uuid = "5218b696-f38b-4ac9-8b61-a12ec717816d"
version = "0.17.6"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "d36f682e590a83d63d1c7dbd287573764682d12a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.11"

[[deps.ExpressionExplorer]]
git-tree-sha1 = "71d0768dd78ad62d3582091bf338d98af8bbda67"
uuid = "21656369-7473-754a-2065-74616d696c43"
version = "1.1.1"

[[deps.ExproniconLite]]
git-tree-sha1 = "c13f0b150373771b0fdc1713c97860f8df12e6c2"
uuid = "55351af7-c7e9-48d6-89ff-24e801d99491"
version = "0.10.14"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FuzzyCompletions]]
deps = ["REPL"]
git-tree-sha1 = "be713866335f48cfb1285bff2d0cbb8304c1701c"
uuid = "fb4132e2-a121-4a70-b8a1-d5b831dcdcc2"
version = "0.5.5"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "PrecompileTools", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "c67b33b085f6e2faf8bf79a61962e7339a81129c"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.15"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "a007feb38b422fbdab534406aeca1b86823cb4d6"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.7.0"

[[deps.LazilyInitializedFields]]
git-tree-sha1 = "0f2da712350b020bc3957f269c9caad516383ee0"
uuid = "0e77f7df-68c5-4e49-93ce-4cd80f5598bf"
version = "1.3.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

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

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "f02b56007b064fbfddb4c9cd60161b6dd0f40df3"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.1.0"

[[deps.MIMEs]]
git-tree-sha1 = "1833212fd6f580c20d4291da9c1b4e8a655b128e"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.0.0"

[[deps.Malt]]
deps = ["Distributed", "Logging", "RelocatableFolders", "Serialization", "Sockets"]
git-tree-sha1 = "02a728ada9d6caae583a0f87c1dd3844f99ec3fd"
uuid = "36869731-bdee-424d-aa32-cab38c994e3b"
version = "1.1.2"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.MsgPack]]
deps = ["Serialization"]
git-tree-sha1 = "f5db02ae992c260e4826fe78c942954b48e1d9c2"
uuid = "99f44e22-a591-53d1-9472-aa23ef4bd671"
version = "1.2.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a9697f1d06cc3eb3fb3ad49cc67f2cfabaac31ea"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.16+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "cc4054e898b852042d7b503313f7ad03de99c3dd"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.Pluto]]
deps = ["Base64", "Configurations", "Dates", "Downloads", "ExpressionExplorer", "FileWatching", "FuzzyCompletions", "HTTP", "HypertextLiteral", "InteractiveUtils", "Logging", "LoggingExtras", "MIMEs", "Malt", "Markdown", "MsgPack", "Pkg", "PlutoDependencyExplorer", "PrecompileSignatures", "PrecompileTools", "REPL", "RegistryInstances", "RelocatableFolders", "Scratch", "Sockets", "TOML", "Tables", "URIs", "UUIDs"]
git-tree-sha1 = "b5509a2e4d4c189da505b780e3f447d1e38a0350"
uuid = "c3e4b0f8-55cb-11ea-2926-15256bba5781"
version = "0.20.4"

[[deps.PlutoDependencyExplorer]]
deps = ["ExpressionExplorer", "InteractiveUtils", "Markdown"]
git-tree-sha1 = "e0864c15334d2c4bac8137ce3359f1174565e719"
uuid = "72656b73-756c-7461-726b-72656b6b696b"
version = "1.2.0"

[[deps.PrecompileSignatures]]
git-tree-sha1 = "18ef344185f25ee9d51d80e179f8dad33dc48eb1"
uuid = "91cefc8d-f054-46dc-8f8c-26e11d7c5411"
version = "3.0.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RegistryInstances]]
deps = ["LazilyInitializedFields", "Pkg", "TOML", "Tar"]
git-tree-sha1 = "ffd19052caf598b8653b99404058fce14828be51"
uuid = "2792f1a3-b283-48e8-9a74-f99dce5104f3"
version = "0.1.0"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "598cd7c1f68d1e205689b1c2fe65a9f85846f297"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "6cae795a5a9313bbb4f60683f7263318fc7d1505"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.10"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╠═aa68c324-eabf-11ef-2a75-19adc8937c8a
# ╟─af7c27ca-5f81-49be-86a9-74d52a90346a
# ╟─8447d68b-eb5b-45ed-90d2-379747854b03
# ╠═40e38f1f-7e7a-42c5-9bdc-ccaebba627d9
# ╠═940105fc-2622-4f20-9826-8bb8ac2d5cd2
# ╠═e46aec14-8e7c-453a-8aa2-cb1a50d99501
# ╠═04d317ff-50dc-4dec-b543-8deb96964f9f
# ╠═ae6c5709-bbda-44e4-8757-8e14554efe67
# ╠═e4d7acdf-88d3-474f-b8e0-3bfb693e371a
# ╠═dde77a7b-08f7-47bd-bf8c-1ed6d83d4d3e
# ╠═a6a8e09a-f57c-457b-940d-d9a4b182b48b
# ╠═55f93c0d-99af-4951-9eea-103cab827e18
# ╠═757e75fd-1702-4822-a74c-49b61e22e350
# ╠═343e3baa-921b-45af-8e19-077f6b098085
# ╠═e8007d30-2b0a-46c4-80a7-a1d4367fb3a3
# ╠═a245acaf-b112-4af0-ba4b-78fda3b2da8e
# ╠═a341a46e-3dc5-4e21-9ebe-f9d45c5eb51e
# ╠═4087533e-c54b-4cb9-b474-e82ad98b0229
# ╠═28a86c8f-7de0-4e3d-81bb-5c371e28494b
# ╠═85e8d9cc-211a-47ff-9963-671fd22e3744
# ╠═73582e38-5bff-45bf-957c-76c31af91581
# ╠═2c96d25e-698e-4858-a9b3-9118d11e223f
# ╠═ccedc075-7ad2-40df-95d4-caf1dbad54ae
# ╠═4ef643cf-0597-492f-b01c-b33a92628ac5
# ╠═ecbb0746-54c1-4029-b9b8-3ea5413ae954
# ╠═d638130c-02f4-442c-b036-836731f83844
# ╠═e755dc2a-8c52-40c0-8bde-aba0f915bde7
# ╠═786a675b-94dc-4b2a-ac22-182047182e8d
# ╠═7ebe8d30-2289-49c2-9f83-9df17ac3880b
# ╠═fa92db07-67ad-4e0f-9254-62a94ac370dc
# ╠═e658eb77-6185-44be-a3b0-65c5a7437baa
# ╠═a57abe11-274b-414a-aa42-9e034768e78a
# ╠═e1168ad4-ef52-4d75-8ab7-cfd903303261
# ╠═0799a467-2fe9-4cc9-ab91-dcf6dbb3973d
# ╠═098ee496-b284-4f11-86d1-d9b23d74faa1
# ╠═284f564e-4f59-43be-9f20-449c002350c1
# ╠═890552e5-05a6-471d-8be9-7ff50ffa1526
# ╠═edb3140c-d8ec-467f-ba53-74a5016b8735
# ╠═e44ccceb-32ac-4af5-8bfd-ea00cd04883e
# ╠═1877f8d8-a3b9-4015-b301-f2e0d0b86f50
# ╠═0785487e-1653-4d16-ad12-7d141bd61a56
# ╠═135e4ec3-dd15-490b-855b-6a258febf1e5
# ╠═1f1ba51d-f8ef-4d6e-b627-5c347508936f
# ╠═19534135-1dfb-406e-a506-19d73920353d
# ╠═916477bc-7a8e-4a9d-9803-ca36e58b4396
# ╠═52a7aa4f-ecd0-415a-b827-7c06d783c27a
# ╠═3d48523c-9e66-4c85-b5a4-c991ba1d07c9
# ╠═6582655f-c8ce-4870-85c8-dbf1d90b604f
# ╠═a801a854-d20c-49db-a080-a49a7fb323b9
# ╠═9f9494ab-b994-4af3-9547-87eb10d1b9de
# ╠═7d7d0f25-b92b-433d-aa68-dc8b65390c1e
# ╠═2c992336-a2f8-412b-acca-cd84dbc48e7b
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
