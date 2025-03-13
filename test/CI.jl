using Test

using PlutoNotebookComparison




good1 = checkout_test_repo(; branch_name="origin/good1")
main = checkout_test_repo(; branch_name="origin/main")



sources_old = [
    # PSSCache("pluto_state_cache")
    # WebsiteDir("gh_pages_dir")
    # WebsiteAddress("https://biaslab.github.io/BMLIP-colorized/")
    SafePreview()
]

sources_new = [
    # PSSCache("pluto_state_cache")
    RunWithPlutoSliderServer()
]

PlutoNotebookComparison.compare_PR(good1;
    sources_old,
    sources_new,
)
