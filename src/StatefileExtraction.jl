
# get from PSS cache

# get from website dir

# get from website http

# get from PlutoPages?




abstract type StatefileSource end

struct PSSCache <: StatefileSource
    root::String
end

struct WebsiteDir <: StatefileSource
    root::String
end

struct WebsiteAddress <: StatefileSource
    root_url::String
end




function get_statefile(path::String, contents::String)
    
    
    
    
    
    
end






