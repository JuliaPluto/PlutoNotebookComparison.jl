
# get from PSS cache

# get from website dir

# get from website http

# get from PlutoPages?



import URIs
import HTTP
import PlutoSliderServer
import Pluto: Pluto, without_pluto_file_extension



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



export StatefileSource, PSSCache, WebsiteAddress, WebsiteDir, StateFileSearchResult, get_statefile




struct StateFileSearchResult
    found::Bool
    source::StatefileSource
    result::Union{Vector{UInt8},Nothing}
end





function get_statefile(source::PSSCache, notebook_path::String, notebook_file_contents::String)
    h = PlutoSliderServer.plutohash(notebook_file_contents)
    cfn = PlutoSliderServer.cache_filename(source.root_dir_path, h)
    
    if isfile(cfn)
        return StateFileSearchResult(true, source, read(cfn))
    else
        return StateFileSearchResult(false, source, nothing)
    end
end



function get_statefile(source::WebsiteDir, notebook_path::String, notebook_file_contents::String)
    path = without_pluto_file_extension(notebook_path) * ".plutostate"
    fullpath = joinpath(source.root_dir_path, path)
    
    if isfile(fullpath)
        StateFileSearchResult(true, source, read(fullpath))
    else
        StateFileSearchResult(false, source, nothing)
    end
end


function get_statefile(source::WebsiteAddress, notebook_path::String, notebook_file_contents::String)
    path = without_pluto_file_extension(notebook_path) * ".plutostate"
    url = URIs.resolvereference(source.root_url, path)
    
    try
        response = HTTP.get(url; retry=false, status_exception=true)
        StateFileSearchResult(true, source, response.body)
    catch
        StateFileSearchResult(false, source, nothing)
    end
end







#########
# Vector{<:StatefileSource}

function get_statefile(sources::Vector{<:StatefileSource}, path::String, contents::String)
    for source in sources
        result = get_statefile(source, path, contents)
        if result.found
            return result
        end
    end
    return StateFileSearchResult(false, sources[1], nothing)
end






