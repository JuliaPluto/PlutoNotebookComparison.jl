using Test

import Pluto
import PlutoNotebookComparison

@testset "diffy" begin

    state1_raw = read(joinpath(@__DIR__, "statefiles", "test1.plutostate"))
    state1 = Pluto.unpack(state1_raw)

    state2_raw = read(joinpath(@__DIR__, "statefiles", "test2.plutostate"))
    state2 = Pluto.unpack(state2_raw)

    context = PlutoNotebookComparison.get_drama_context(state1, state2; file_changed=true, old_path="derp", new_path="derp")
    
    d1 = PlutoNotebookComparison.DramaBrokenImport()
    d2 = PlutoNotebookComparison.DramaNewError()
    
    
    PlutoNotebookComparison.check_drama(d1, context)
    PlutoNotebookComparison.check_drama(d2, context)

end