
# get from PSS cache

# get from website dir

# get from website http

# get from PlutoPages?



import URIs
import HTTP
import PlutoSliderServer
import Pluto: Pluto, without_pluto_file_extension
import .LoggingUtils: with_logging_context


abstract type StatefileSource end

struct PSSCache <: StatefileSource
    root_dir_path::String
end

struct WebsiteDir <: StatefileSource
    root_dir_path::String
end

struct WebsiteAddress <: StatefileSource
    root_url::String
end

struct RunWithPlutoSliderServer <: StatefileSource
    kwargs
end

RunWithPlutoSliderServer(; kwargs...) = RunWithPlutoSliderServer(kwargs)


struct SafePreview <: StatefileSource
end



export StatefileSource, PSSCache, WebsiteAddress, WebsiteDir, RunWithPlutoSliderServer, SafePreview
export StateFileSearchResult, get_statefile




struct StateFileSearchResult
    found::Bool
    source::StatefileSource
    result::Union{Vector{UInt8},Nothing}
end





function get_statefile(source::PSSCache, root_dir::AbstractString, notebook_path::String, notebook_file_contents::String)
    h = PlutoSliderServer.plutohash(notebook_file_contents)
    cfn = PlutoSliderServer.cache_filename(source.root_dir_path, h)
    
    if isfile(cfn)
        return StateFileSearchResult(true, source, read(cfn))
    else
        return StateFileSearchResult(false, source, nothing)
    end
end



function get_statefile(source::WebsiteDir, root_dir::AbstractString, notebook_path::String, notebook_file_contents::String)
    path = without_pluto_file_extension(notebook_path) * ".plutostate"
    fullpath = joinpath(source.root_dir_path, path)
    
    if isfile(fullpath)
        StateFileSearchResult(true, source, read(fullpath))
    else
        StateFileSearchResult(false, source, nothing)
    end
end


function get_statefile(source::WebsiteAddress, root_dir::AbstractString, notebook_path::String, notebook_file_contents::String)
    path = without_pluto_file_extension(notebook_path) * ".plutostate"
    url = URIs.resolvereference(source.root_url, path)
    
    try
        response = HTTP.get(url; retry=false, status_exception=true)
        StateFileSearchResult(true, source, response.body)
    catch
        StateFileSearchResult(false, source, nothing)
    end
end


function get_statefile(source::RunWithPlutoSliderServer, root_dir::AbstractString, notebook_path::String, notebook_file_contents::String)
    path = joinpath(root_dir, notebook_path)
    
    output_dir = mktempdir()
    with_logging_context("(PSS) ") do
        PlutoSliderServer.export_notebook(path; 
            Export_output_dir=output_dir, Export_baked_state=false, source.kwargs...
        )
    end
    
    statefile_path = filter(endswith(".plutostate"), readdir(output_dir; join=true)) |> only
    
    StateFileSearchResult(true, source, read(statefile_path))
end


function get_statefile(source::SafePreview, root_dir::AbstractString, notebook_path::String, notebook_file_contents::String)
    path = joinpath(root_dir, notebook_path)
    
    state = with_logging_context("(Pluto) ") do
        sesh = Pluto.ServerSession()
        sesh.options.server.disable_writing_notebook_files = true
        notebook = Pluto.SessionActions.open(sesh, path; execution_allowed=false, run_async=false)
        state = Pluto.pack(Pluto.notebook_to_js(notebook))
        Pluto.SessionActions.shutdown(sesh, notebook)
        state
    end
    
    StateFileSearchResult(true, source, state)
end





#########
# Vector{<:StatefileSource}

function get_statefile(sources::Vector{<:StatefileSource}, root_dir::AbstractString, notebook_path::String, notebook_file_contents::String)
    for source in sources
        result = get_statefile(source, root_dir, notebook_path, notebook_file_contents)
        if result.found
            return result
        end
    end
    return StateFileSearchResult(false, sources[1], nothing)
end






