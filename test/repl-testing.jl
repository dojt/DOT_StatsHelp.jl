# Activate ""

using Revise

# Activate root DOT_StatsHelp.jl/.

using DOT_StatsHelp
using JSON3

# Activate DOT_StatsHelp.jl/test/.

struct Blahh
    x ::Array{Int, 2}
    y ::Array{Float64, 1}
end

struct Blahh_lin
    x ::Array{Int, 1}
    y ::Array{Float64, 1}
end

struct Blahhh
    x ::Array{Int,0}
    y ::Array{Float64, 1}
end


struct Blubb{V}
    a ::NTuple{V,Int}
    b ::Float64
end
