using Test
using PlutoNotebookComparison

good1 = checkout_test_repo(; branch_name="good1")
bad_error = checkout_test_repo(; branch_name="bad-error")
# main = checkout_test_repo(; branch_name="main")

@testset "CI for PR" begin

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

    @testset "good" begin
        PlutoNotebookComparison.compare_PR(good1;
            sources_old,
            sources_new,
        )
        @test true
    end
    
    @testset "bad error" begin
        @test_throws Exception PlutoNotebookComparison.compare_PR(bad_error;
            sources_old,
            sources_new,
        )
    end
end