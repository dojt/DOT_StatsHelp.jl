# [[file:../DOT_StatsHelp.org::*Copyright Notice][Copyright Notice:1]]
#########################################################################
#                                                                       #
# Copyright and Licensing Information                                   #
# -----------------------------------                                   #
#                                                                       #
# Copyright lies with the University of Tartu, Estonia, and with the    #
# author.                                                               #
#                                                                       #
# Permission is hereby granted to use and modify the source code under  #
# the terms of the Apache v2.0 license.                                 #
#                                                                       #
#                                                                       #
# Author:                                                               #
#                                                                       #
#        Dirk Oliver Theis                                              #
#        Assoc. Prof. Theoretical Computer Science                      #
#        University of Tartu                                            #
#        Estonia                                                        #
#                                                                       #
#########################################################################
# Copyright Notice:1 ends here

# [[file:../DOT_StatsHelp.org::*File headers][File headers:1]]
###########################################################################
#                                                                         #
#  THIS IS A MACHINE-GENERATED FILE.  DO NOT EDIT IT.                     #
#                                                                         #
#  (The actual source code is in the Org file.)                           #
#                                                                         #
###########################################################################
# File headers:1 ends here

# [[file:../DOT_StatsHelp.org::*Module definition & imports][Module definition & imports:1]]
module DOT_StatsHelp
# Module definition & imports:1 ends here

# [[file:../DOT_StatsHelp.org::*Module definition & imports][Module definition & imports:2]]
using DOT_NiceMath            # `⋅` = `*`  etc
using DOT_NiceMath.Numbers64  # ℝ, ℤ, ℚ

using LinearAlgebra: norm2, norm1, normInf as norm∞, norm_sqr as norm²
# Module definition & imports:2 ends here

# [[file:../DOT_StatsHelp.org::*Basic types][Basic types:1]]
export Stats
# Basic types:1 ends here

# [[file:../DOT_StatsHelp.org::*The ~Stats~-type with constructor][The ~Stats~-type with constructor:1]]
struct Stats{𝐑,V}              # `V` stands for valency of the tensor
    # Input
    true_μ        ::Array{ℝ, V}

    # Output
    empirical_μ   ::Array{𝐑, V}

    err2²         ::Vector{ℝ}  # 2-norm of tensor; \
    err1          ::Vector{ℝ}  # 1-norm  ~          | ultimate lengths:
    err∞          ::Vector{ℝ}  # ∞-norm  ~         /   `outer_reps`
    empirical_var ::Ref{𝐑}

    # Transient data
    _ws           ::Array{𝐑,V}
end
# The ~Stats~-type with constructor:1 ends here

# [[file:../DOT_StatsHelp.org::*The ~Stats~-type with constructor][The ~Stats~-type with constructor:2]]
function Stats(true_μ ::Array{ℝ,V}, ::Type{𝐑}
               ;
               iterations_hint :: Int          )::Stats{𝐑,V}   where{𝐑<:Real,V}

    empirical_μ   = Array{𝐑,V}(undef, size(true_μ) )  ; empirical_μ .= 𝐑(0)
    _ws           = Array{𝐑,V}(undef, size(true_μ) )

    err2² = sizehint!(ℝ[], iterations_hint)
    err1  = sizehint!(ℝ[], iterations_hint)
    err∞  = sizehint!(ℝ[], iterations_hint)
    empirical_var = Ref{𝐑}(0.0)

    return Stats{𝐑,V}(true_μ,
                      empirical_μ, err2², err1, err∞, empirical_var,
                      _ws)
end
# The ~Stats~-type with constructor:2 ends here

# [[file:../DOT_StatsHelp.org::*Adding a new data point][Adding a new data point:1]]
import Base: append!
function append!(s ::Stats{𝐑,V}
                 ;
                 𝐸 ::Array{ℝ,V} ) ::Nothing  where{𝐑,V}

    (;true_μ, err2², err1, err∞, empirical_μ, empirical_var, _ws) = s

    @assert length(err2²) == length(err1) ==
            length(err∞)

    n = length(err2²)

    let new_μ        = _ws
        new_μ       .= n⋅empirical_μ/(n+1) .+ 𝐸/(n+1)
        empirical_μ .= new_μ
    end

    #
    # Updating `mean…err`
    #
    let err  = _ws
        err .= true_μ - empirical_μ

        push!( err2², norm²(err) )
        push!( err1,  norm1(err) )
        push!( err∞,  norm∞(err) )
    end #^ let

    #
    # Updating variance
    #
    # We record the simple biased estimate of the empirical variance, and
    # correct it in the `finalize()` function.

    empirical_var[] = n⋅empirical_var[]/(n+1) + norm²( 𝐸 - empirical_μ )/(n+1)

    nothing;
end #^ append!()
# Adding a new data point:1 ends here

# [[file:../DOT_StatsHelp.org::*Finalizing stats collection][Finalizing stats collection:1]]
function finalize!(s ::Stats{𝐑,V}) ::Nothing                  where{𝐑,V}

    (;err2², err1, err∞, empirical_var) = s

    @assert length(err2²) ==
            length(err1)  == length(err∞)

    #
    # Un-bias empirical variance:
    #
    let n=length(err2²)
        empirical_var[] *= (n-1)/n
    end
    nothing;
end #^ finalize!(::Stats)
# Finalizing stats collection:1 ends here

# [[file:../DOT_StatsHelp.org::*End of module][End of module:1]]
end #^ module SPSA_Shift
# End of module:1 ends here
