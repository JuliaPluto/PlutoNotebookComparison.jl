using Test

import Random



import Pluto
import PlutoSliderServer
import PlutoNotebookComparison



original_dir1 = joinpath(@__DIR__, "dir1")
make_test_dir() =
    let
        Random.seed!(time_ns())
        new = tempname(cleanup=false)
        cp(original_dir1, new)
        new
    end



@testset "Statefile sources" begin
    Random.seed!(time_ns())
    
    test_dir = make_test_dir()
    cache_dir = mktempdir(cleanup=false)
    output_dir = mktempdir(cleanup=false)


    port = rand(12345:65000)

    still_booting = Ref(true)
    ready_result = Ref{Any}(nothing)
    function on_ready(result)
        ready_result[] = result
        still_booting[] = false
    end

    t = Pluto.@asynclog PlutoSliderServer.run_directory(
        test_dir;
        Export_enabled=true,
        Export_baked_state=false,
        Export_output_dir=output_dir,
        Export_cache_dir=cache_dir,
        SliderServer_port=port,
        SliderServer_watch_dir=false,
        Pluto_evaluation_workspace_use_distributed=false,
        on_ready,
    )

    while still_booting[]
        sleep(0.1)
    end

    notebook_sessions = ready_result[].notebook_sessions
    
    
    
    
    test_sources = [
        PlutoNotebookComparison.PSSCache(cache_dir),
        PlutoNotebookComparison.WebsiteDir(output_dir),
        PlutoNotebookComparison.WebsiteAddress("http://localhost:$(port)"),
    ]
    
    bad_sources = [
        PlutoNotebookComparison.PSSCache("nonexistent"),
        PlutoNotebookComparison.WebsiteDir("nonexistent"),
        PlutoNotebookComparison.WebsiteAddress("http://localhost:$(port + 1)"),
    ]
    
    
    paths = [
        "a.jl",
        "b.pluto.jl",
        joinpath("subdir/","c.plutojl"),
    ]
    
    @testset "source – $(source)" for source in test_sources
        
        # make a list, our source should have preference and work immediately
        sources = [source, test_sources...]
        
        @testset "$(path)" for path in paths
            contents = read(joinpath(test_dir, path), String)
            result = PlutoNotebookComparison.get_statefile(sources, path, contents)
            
            @test result.found
            @test result.source === source
            @test result.result isa Vector{UInt8}
            @test !isempty(result.result)
        end
    end
    
    
    @testset "bad source – $(source)" for source in bad_sources
        
        # make a list, our source should have preference, but NOT work, so a fallback is used
        sources = [source, test_sources...]
        
        
        for path in paths
            contents = read(joinpath(test_dir, path), String)
            result = PlutoNotebookComparison.get_statefile(sources, path, contents)
            
            @test result.found
            @test result.source !== source
        end
    end
    
    
    sleep(2)
    close(ready_result[].http_server)

    try
        wait(t)
    catch e
        if !(e isa TaskFailedException)
            rethrow(e)
        end
    end
    @info "DONEZO"
end