using Test

import Pluto
import PlutoNotebookComparison


state1_raw = read(joinpath(@__DIR__, "statefiles", "test1.plutostate"))
state1 = Pluto.unpack(state1_raw)

state2_raw = read(joinpath(@__DIR__, "statefiles", "test2.plutostate"))
state2 = Pluto.unpack(state2_raw)

context = PlutoNotebookComparison.get_drama_context(state1, state2)
drama_broken_import(context)
drama_new_error(context)

