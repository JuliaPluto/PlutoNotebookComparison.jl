

import LibGit2

export compare_PR, maximum_drama


find(f, xs) = for x in xs
	f(x) && return x
end




# sources_old = [Cache, WebsiteDir("path/to/dir"), WebsiteAddress("https://example.com"), SafePreview]
# sources_new = [Cache, WebsiteDir("path/to/dir"), SafePreview]



# DramaLinkBroken

const maximum_drama = [
    DramaBrokenImport(),
    DramaNewError(),
    # drama_output_changed,
    
    # drama_link_broken,
    # drama_restart_recommended,
]





const reporters = [
    # report_github_comment,
    # report_error,
    # report_screenshots,
    # report_html_export_for_gha_artifacts,
]

# TODO maybe thats not so important if we also have PR preview




function compare_PR(dir::AbstractString;
        diff::LibGit2.GitDiff=Glitter.PR_diff(LibGit2.GitRepo(dir)),
        sources_old::Vector{<:StatefileSource}, 
        sources_new::Vector{<:StatefileSource}=sources_old,
        require_check::Bool=true,
        drama_checkers::Vector{<:AbstractDrama}=maximum_drama,
    )
    repo = diff.owner
    pr_deltas = Glitter.deltas(diff)

    all_notebooks = PlutoSliderServer.find_notebook_files_recursive(dir)
    
    for path in all_notebooks
        @debug "🍄 Notebook" path
        
        delta = find(d -> unsafe_string(d.new_file.path) == path, pr_deltas)
        
        file_changed = delta !== nothing && Glitter.is_modified(delta)
        if file_changed

            old_contents = Glitter.contents(repo, delta.old_file)
            new_contents = Glitter.contents(repo, delta.new_file)
            
            old_path = unsafe_string(delta.old_file.path)
            new_path = unsafe_string(delta.new_file.path)
        else
            old_contents = new_contents = read(joinpath(dir, path), String)
            old_path = new_path = path
        end
    
        statefile_old = PlutoNotebookComparison.get_statefile(sources_old, dir, old_path, old_contents)
        statefile_new = PlutoNotebookComparison.get_statefile(sources_new, dir, new_path, new_contents)
        
        @info "Search results" path statefile_old.source statefile_new.source

        if statefile_old.found && statefile_new.found
        
            state_old = Pluto.unpack(statefile_old.result)
            state_new = Pluto.unpack(statefile_new.result)

            drama_context = PlutoNotebookComparison.get_drama_context(state_old, state_new; file_changed, old_path, new_path)
            
            for drama_checker in drama_checkers
                if should_check_drama(drama_checker, drama_context)
                    @info "checking" path drama_checker
                    check_drama(drama_checker, drama_context)
                else
                    @debug "skipping..." path drama_checker
                end
            end
        else
            @warn "No statefile found for this notebook, not checking..." path statefile_old.found statefile_new.found
            require_check && error("No statefile found, see logs. Set require_check=false to allow this.")
        end
    end
    @info "✅ All $(length(all_notebooks)) notebooks passed without drama"
end








