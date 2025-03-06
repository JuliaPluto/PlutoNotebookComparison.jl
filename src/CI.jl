









pr_diff = Glitter.PR_diff()
pr_deltas = Glitter.deltas(pr)




find(f, xs) = for x in xs
	f(x) && return x
end







sources_old = [WebsiteDir("path/to/dir"), Cache, WebsiteAddress("https://example.com")]
sources_new = [WebsiteDir("path/to/dir"), Cache]

function compare_PR(dir::AbstractString;
        sources_old::Vector{StatefileSource}, 
        sources_new::Vector{StatefileSource},
        require_check::Bool=true,
        drama_checkers::Vector{Function}=Function[],
    )

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
                
                @info "Search results" statefile_old statefile_new

                @assert statefile_old.found
                @assert statefile_new.found
                
                # compare
                
            end
            
        end
    end




end








