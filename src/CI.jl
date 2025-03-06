

import LibGit2

find(f, xs) = for x in xs
	f(x) && return x
end




sources_old = [Cache, WebsiteDir("path/to/dir"), WebsiteAddress("https://example.com")]
sources_new = [Cache, WebsiteDir("path/to/dir")]



const maximum_drama = [
    drama_broken_import,
    drama_new_error,
    drama_output_changed,
]

function compare_PR(dir::AbstractString;
        diff::LibGit2.GitDiff=Glitter.PR_diff(LibGit2.GitRepo(dir)),
        sources_old::Vector{StatefileSource}, 
        sources_new::Vector{StatefileSource}=sources_old,
        # require_check::Bool=true,
        drama_checkers::Vector{Function}=maximum_drama,
    )
    pr_deltas = Glitter.deltas(diff)

    all_notebooks = PlutoSliderServer.find_notebook_files_recursive(dir)
    
    for path in all_notebooks
        
        
        delta = find(d -> unsafe_string(d.new_file.path) == path, pr_deltas)
        
        if delta !== nothing
            if Glitter.is_modified(delta)
                contents_old = Glitter.contents(repo, delta.old_file)
                contents_new = Glitter.contents(repo, delta.new_file)
                
                path_old = unsafe_string(delta.old_file.path)
                path_new = unsafe_string(delta.new_file.path)
                
                statefile_old = PlutoNotebookComparison.get_statefile(sources_old, path_old, contents_old)
                statefile_new = PlutoNotebookComparison.get_statefile(sources_new, path_new, contents_new)
                
                @info "Search results" path statefile_old statefile_new

                @assert statefile_old.found
                @assert statefile_new.found
                
                state_old = Pluto.unpack(statefile_old.result)
                state_new = Pluto.unpack(statefile_new.result)

                drama_context = PlutoNotebookComparison.get_drama_context(state_old, state_new)
                
                for f in drama_checkers
                    f(drama_context)
                end
            end
        end
    end

end








