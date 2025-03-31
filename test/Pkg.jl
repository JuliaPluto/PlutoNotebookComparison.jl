using Test
using PlutoNotebookComparison

bad_pkg1 = checkout_test_repo(; branch_name="bad-pkg-1")
bad_pkg2 = checkout_test_repo(; branch_name="bad-pkg-2")

@testset "Notebook pkg" begin

    sources_old = [
        # PSSCache("pluto_state_cache")
        # WebsiteDir("gh_pages_dir")
        # WebsiteAddress("https://bmlip.github.io/colorized/")
        SafePreview()
    ]

    sources_new = [
        # PSSCache("pluto_state_cache")
        RunWithPlutoSliderServer()
    ]
    
    drama = [
        DramaRestartRequired(),
    ]

    @testset "Should just recover and run" begin
        PlutoNotebookComparison.compare_PR(bad_pkg1;
            sources_old,
            sources_new,
            drama_checkers=drama,
        )
        @test true
    end
    
    @testset "bad error" begin
        @test_throws Exception PlutoNotebookComparison.compare_PR(bad_pkg2;
            sources_old,
            sources_new,
            drama_checkers=drama,
        )
    end
end