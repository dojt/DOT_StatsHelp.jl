# [[file:../DOT_StatsHelp.org::*File headers][File headers:2]]
###########################################################################
#                                                                         #
#  THIS IS A MACHINE-GENERATED FILE.  DO NOT EDIT IT.                     #
#                                                                         #
#  (The actual source code is in the Org file.)                           #
#                                                                         #
###########################################################################

using Test
using DOT_StatsHelp
# File headers:2 ends here

# [[file:../DOT_StatsHelp.org::*Generic test based on ~JET.jl~][Generic test based on ~JET.jl~:1]]
using JET
using JSON # Only for ignoring by JET

@testset verbose=true "DOT_StatsHelp.jl testing:  via JET.jl" begin
    test_package(DOT_StatsHelp, ignored_modules=(AnyFrameModule(JSON.Parser),) )
end
# Generic test based on ~JET.jl~:1 ends here
