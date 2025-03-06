### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ 7cc1e9da-6c62-42e3-923c-59de260c2ebe
import URIs

# ╔═╡ 360ce68e-d43b-45a4-93e6-766eb208793f
abstract type StatefileSource end

# ╔═╡ ccd01f4b-739f-450d-8640-a3fb2289c0d1
struct PSSCache <: StatefileSource
    root::String
end

# ╔═╡ 279d72dd-67c8-451f-beca-45db5fd4ff45
struct WebsiteDir <: StatefileSource
    root::String
end

# ╔═╡ e19ded8c-1614-48f5-8a59-32235db47cc8
struct WebsiteAddress <: StatefileSource
    root_url::String
end

# ╔═╡ 9a2efbc5-b936-46a4-b971-1c5992cfc8c1


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
URIs = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"

[compat]
URIs = "~1.5.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.3"
manifest_format = "2.0"
project_hash = "f4e135bf319037dce674dc5bc1fddc02d977c0ec"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"
"""

# ╔═╡ Cell order:
# ╠═7cc1e9da-6c62-42e3-923c-59de260c2ebe
# ╠═360ce68e-d43b-45a4-93e6-766eb208793f
# ╠═ccd01f4b-739f-450d-8640-a3fb2289c0d1
# ╠═279d72dd-67c8-451f-beca-45db5fd4ff45
# ╠═e19ded8c-1614-48f5-8a59-32235db47cc8
# ╠═9a2efbc5-b936-46a4-b971-1c5992cfc8c1
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
