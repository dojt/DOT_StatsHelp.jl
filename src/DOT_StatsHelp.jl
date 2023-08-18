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

# [[file:../DOT_StatsHelp.org::*Module definition, import, and recurrent exports][Module definition, import, and recurrent exports:1]]
module DOT_StatsHelp
# Module definition, import, and recurrent exports:1 ends here

# [[file:../DOT_StatsHelp.org::*Module definition, import, and recurrent exports][Module definition, import, and recurrent exports:2]]
using DOT_NiceMath            # `⋅` = `*`  etc
using DOT_NiceMath.Numbers64  # ℝ, ℤ, ℚ

using LinearAlgebra: norm2, norm1, normInf as norm∞, norm_sqr as norm2²,
                     axpy!, axpby!
# Module definition, import, and recurrent exports:2 ends here

# [[file:../DOT_StatsHelp.org::*Module definition, import, and recurrent exports][Module definition, import, and recurrent exports:3]]
export start_run!
export record_step!
export finalize_run!
# Module definition, import, and recurrent exports:3 ends here

# [[file:../DOT_StatsHelp.org::*The mean process type: ~MeanProc{𝐑,V}~][The mean process type: ~MeanProc{𝐑,V}~:1]]
export MeanProc
# The mean process type: ~MeanProc{𝐑,V}~:1 ends here

# [[file:../DOT_StatsHelp.org::*The mean process type: ~MeanProc{𝐑,V}~][The mean process type: ~MeanProc{𝐑,V}~:2]]
struct MeanProc{𝐑 <: Real, V}              # `V` is an integer: the valency of the tensor
# The mean process type: ~MeanProc{𝐑,V}~:2 ends here

# [[file:../DOT_StatsHelp.org::*Fields and inner constructor][Fields and inner constructor:1]]
#            Input for run
    curr_true_μ  ::Array{ℝ, V} #                      size: dimension

    #            Output of run
    curr_emp_μ   ::Array{𝐑, V} #                      size: dimension

    #            Overall output
    err2²        ::Array{ℝ,2}  # 2-norm of tensor; \
    err1         ::Array{ℝ,2}  # 1-norm  ~          | size: `steps` ✕ `runs`
    err∞         ::Array{ℝ,2}  # ∞-norm  ~         /
    emp_var      ::Vector{𝐑}   #                      size: `runs`

    #             Work space
    ␣ws          ::Array{𝐑,V}  #                      size: dimension

    #             Counters
    𝐫            ::Ref{Int}    # index of current run (i.e., 0 ⪮ before first run)
    𝐬            ::Ref{Int}    # index of current step (i.e., 0 ⪮ before first step)

    #
    # Convenience constructor -- not for the user
    #
    function
    MeanProc{𝐑,V}(;
               curr_true_μ ::Array{ℝ,V}, curr_emp_μ ::Array{𝐑,V}, emp_var ::Vector{𝐑},
               err2² ::Array{ℝ,2}, err1 ::Array{ℝ,2}, err∞ ::Array{ℝ,2}, ␣ws ::Array{𝐑,V}) where{𝐑,V}
        new(curr_true_μ, curr_emp_μ, err2², err1, err∞, emp_var, ␣ws,
            0,0)
    end
end
# Fields and inner constructor:1 ends here

# [[file:../DOT_StatsHelp.org::*Usage][Usage:1]]
export err2², err1, err∞, emp_var, curr_emp_μ
# Usage:1 ends here

# [[file:../DOT_StatsHelp.org::*Usage][Usage:2]]
err2²(  s ::MeanProc{𝐑,V}; run ::Int, step ::Int) where{𝐑,V} = ( @assert (1,1)≤(run,step)≤(s.𝐫[],s.𝐬[]); s.err2²[step,run] )
err1(   s ::MeanProc{𝐑,V}; run ::Int, step ::Int) where{𝐑,V} = ( @assert (1,1)≤(run,step)≤(s.𝐫[],s.𝐬[]); s.err1[ step,run] )
err∞(   s ::MeanProc{𝐑,V}; run ::Int, step ::Int) where{𝐑,V} = ( @assert (1,1)≤(run,step)≤(s.𝐫[],s.𝐬[]); s.err∞[ step,run] )
emp_var(s ::MeanProc{𝐑,V}; run ::Int)             where{𝐑,V} = ( @assert 1    ≤run ≤ s.𝐫[]             ; s.emp_var[run]    )

curr_emp_μ(s ::MeanProc{𝐑,V})                     where{𝐑,V} = ( @assert 1 ≤ s.𝐫[]                     ; s.curr_emp_μ      )
# Usage:2 ends here

# [[file:../DOT_StatsHelp.org::*User-facing constructor for ~MeanProc~ <<mp-constructor>>][User-facing constructor for ~MeanProc~  <<mp-constructor>>:1]]
function MeanProc(dimension ::NTuple{V,Int}
                  ;
                  steps :: Int,
                  runs  :: Int,
                  𝐑     :: Type{<:Real} = ℝ)  ::MeanProc     where{V}
# User-facing constructor for ~MeanProc~  <<mp-constructor>>:1 ends here

# [[file:../DOT_StatsHelp.org::*User-facing constructor for ~MeanProc~ <<mp-constructor>>][User-facing constructor for ~MeanProc~  <<mp-constructor>>:2]]
curr_true_μ   = Array{ℝ,V}(undef, dimension )
    curr_emp_μ    = Array{𝐑,V}(undef, dimension )   ; curr_emp_μ   .= 𝐑(0)
    ␣ws           = Array{𝐑,V}(undef, dimension )

    err2²         = Array{ℝ,2}(undef, steps,runs)
    err1          = Array{ℝ,2}(undef, steps,runs)
    err∞          = Array{ℝ,2}(undef, steps,runs)
    emp_var       = Array{𝐑,1}(undef, runs)         ; emp_var .= 𝐑(0)

    s = MeanProc{𝐑,V}( ; curr_true_μ, curr_emp_μ,
                         err2², err1, err∞, emp_var,  ␣ws)
    ␣integrity_check(s)
    return s
end
# User-facing constructor for ~MeanProc~  <<mp-constructor>>:2 ends here

# [[file:../DOT_StatsHelp.org::*Helper functions and integrity check][Helper functions and integrity check:1]]
valency(        s ::MeanProc{𝐑,V} ) where{𝐑,V}    = V
dimension(      s ::MeanProc{𝐑,V} ) where{𝐑,V}    = size( s.curr_true_μ )
numo_stepsruns( s ::MeanProc{𝐑,V} ) where{𝐑,V}    = size( s.err2²       )
numo_steps(     s ::MeanProc{𝐑,V} ) where{𝐑,V}    = numo_stepsruns(s) |> first
numo_runs(      s ::MeanProc{𝐑,V} ) where{𝐑,V}    = numo_stepsruns(s) |> last
# Helper functions and integrity check:1 ends here

# [[file:../DOT_StatsHelp.org::*Helper functions and integrity check][Helper functions and integrity check:2]]
function ␣integrity_check(s ::MeanProc{𝐑,V}) ::Nothing  where{𝐑,V}
# Helper functions and integrity check:2 ends here

# [[file:../DOT_StatsHelp.org::*Implementation][Implementation:1]]
@assert size( s.curr_true_μ ) == dimension(s) == size( s.curr_emp_μ  )

    let steps  = numo_steps(s),
        runs   = numo_runs(s),
        dim    = dimension(s)

        @assert steps > 1
        @assert runs  ≥ 1

        @assert 0 ≤ s.𝐫[] ≤ runs
        @assert 0 ≤ s.𝐬[] ≤ steps
        @assert s.𝐫[] ≥ 1 || s.𝐬[] == 0

        @assert size(     s.err2²       ) == (steps,runs)
        @assert size(     s.err1        ) == (steps,runs)
        @assert size(     s.err∞        ) == (steps,runs)
        @assert size(     s.emp_var     ) == (runs,)

        @assert size(     s.␣ws         ) == dim
    end #^ let
    return nothing
end
# Implementation:1 ends here

# [[file:../DOT_StatsHelp.org::*Starting a new run: ~start_run!()~ <<mp-start>>][Starting a new run: ~start_run!()~ <<mp-start>>:1]]
function start_run!(s      :: MeanProc{𝐑,V}
                    ;
                    true_μ :: Array{ℝ,V} ) ::Nothing  where{𝐑,V}
# Starting a new run: ~start_run!()~ <<mp-start>>:1 ends here

# [[file:../DOT_StatsHelp.org::*Implementation of ~start_run!()~][Implementation of ~start_run!()~:1]]
␣integrity_check(s)


    if    s.𝐫[] > 0         @assert s.𝐬[] == numo_steps(s)
    else                    @assert s.𝐬[] == 0               end

    s.𝐫[] += 1            ; @assert s.𝐫[] ≤ numo_runs(s)
    s.𝐬[]  = 0

    @assert size(true_μ) == dimension(s)

    let 𝐫 = s.𝐫[],
        𝐬 = s.𝐬[]

        s.curr_true_μ .= true_μ
        s.curr_emp_μ  .= 𝐑(0)
        s.emp_var[𝐫]   = 𝐑(0)

    end
    nothing;
end #^ start_run!()
# Implementation of ~start_run!()~:1 ends here

# [[file:../DOT_StatsHelp.org::*Adding data of a step: ~record_step!()~ <<mp-record>>][Adding data of a step: ~record_step!()~ <<mp-record>>:1]]
function record_step!(s ::MeanProc{𝐑,V}
                      ;
                      𝐸 ::Array{ℝ,V} ) ::Nothing  where{𝐑,V}
# Adding data of a step: ~record_step!()~ <<mp-record>>:1 ends here

# [[file:../DOT_StatsHelp.org::*Implementation][Implementation:1]]
␣integrity_check(s)

(;curr_true_μ, curr_emp_μ, err2², err1, err∞, emp_var, ␣ws) = s


s.𝐬[] += 1            ; @assert s.𝐬[] ≤ numo_steps(s)

let 𝐫     = s.𝐫[],
    𝐬     = s.𝐬[],
    steps = numo_steps(s)

    #
    # Note order between emp var and emp μ
    #
    # emp_var[𝐫]   = (𝐬-1) ⋅ emp_var[𝐫]  / 𝐬    +   (𝐬-1) ⋅ norm2²( curr_emp_μ - 𝐸 ) / 𝐬²
    # curr_emp_μ  .= (𝐬-1) ⋅ curr_emp_μ / 𝐬   +   𝐸 / 𝐬

    ␣ws         .= curr_emp_μ
    axpby!(-1/𝐬, 𝐸,  1/𝐬, ␣ws)
    emp_var[𝐫]   = (𝐬-1) ⋅ (   emp_var[𝐫]  / 𝐬    +   norm2²( ␣ws )   )
                  # will be corrected for bias in finalize_run!()

    axpby!( 1/𝐬, 𝐸, (𝐬-1)/𝐬, curr_emp_μ)

    #
    # Errors
    #
    ␣ws         .= curr_emp_μ - curr_true_μ

    err2²[𝐬,𝐫]   = norm2²(␣ws)
    err1[ 𝐬,𝐫]   = norm1(␣ws)
    err∞[ 𝐬,𝐫]   = norm∞(␣ws)
end #^ let
nothing;
end #^ record_step!()
# Implementation:1 ends here

# [[file:../DOT_StatsHelp.org::*Finalizing a run: ~finalize_run!()~ <<mp-finalize>>][Finalizing a run: ~finalize_run!()~ <<mp-finalize>>:1]]
function finalize_run!(s ::MeanProc{𝐑,V}) ::Nothing                  where{𝐑,V}
# Finalizing a run: ~finalize_run!()~ <<mp-finalize>>:1 ends here

# [[file:../DOT_StatsHelp.org::*Implementation][Implementation:1]]
␣integrity_check(s)

    @assert s.𝐬[] == numo_steps(s)

    #
    # Un-bias empirical variance:
    #
    let 𝐫     = s.𝐫[],
        𝐬     = s.𝐬[]

        s.emp_var[ 𝐫 ] *= 𝐬 / 𝐑(𝐬-1)
    end
    nothing;
end #^ finalize_run!()
# Implementation:1 ends here

# [[file:../DOT_StatsHelp.org::␣xtiles_make()][␣xtiles_make()]]
function ␣xtiles_make(_𝝅) ::Tuple
    𝝅 = collect(_𝝅)
    sort!(𝝅)

    @assert allunique( 𝝅 )
    @assert 0.0 < 𝝅[1] ≤ 𝝅[end] == 1.0

    L = length(𝝅) # just saying...
    return (𝝅...,)
end
# ␣xtiles_make() ends here

# [[file:../DOT_StatsHelp.org::␣xtiles_count!()][␣xtiles_count!()]]
function ␣xtiles_count!(freqs ::AbstractArray{ℝ},
                        𝝅     ::NTuple{L,ℝ}
                        ;
                        p     ::ℝ,
                        Δ     ::ℝ                 )::NamedTuple    where{L}
    @assert 0-1e-50 ≤ p
    @assert           p ≤ 1+1e-30
    @assert L == length(freqs)

    ℓ = 1
    while ℓ ≤ L   &&   𝝅[ℓ] < p
        ℓ += 1
    end
    ℓ = min(ℓ,L)                  # in case of rounding errors near 1.0

    freqs[ ℓ ] += Δ

    return ( ℓ=ℓ,  lo=get(𝝅,ℓ-1,0.0), hi=𝝅[ℓ] )
end
# ␣xtiles_count!() ends here

# [[file:../DOT_StatsHelp.org::*The max-approx process type: ~MaxProc{L}~][The max-approx process type: ~MaxProc{L}~:1]]
export MaxProc
# The max-approx process type: ~MaxProc{L}~:1 ends here

# [[file:../DOT_StatsHelp.org::*The max-approx process type: ~MaxProc{L}~][The max-approx process type: ~MaxProc{L}~:2]]
mutable struct MaxProc{L}
    # consts
    const 𝝅         ::NTuple{L,ℝ}   # percentile numbers, sorted increasingly (last one must be 1.0)
    const freqs     ::Array{ℝ,2}    #
    const steps     ::Int
    const runs      ::Int

    # mutables
    true_max  ::ℝ
    curr_max  ::ℝ
    𝐫         ::Int    # index of current run (i.e., 0 ⪮ before first run)
    𝐬         ::Int    # index of current step (i.e., 0 ⪮ before first step)
end
# The max-approx process type: ~MaxProc{L}~:2 ends here

# [[file:../DOT_StatsHelp.org::*User-facing constructor for ~MaxApprox~ <<max-constructor>>][User-facing constructor for ~MaxApprox~ <<max-constructor>>:1]]
function MaxProc(_𝝅
                 ;
                 steps :: Int,
                 runs  :: Int )  ::MaxProc
# User-facing constructor for ~MaxApprox~ <<max-constructor>>:1 ends here

# [[file:../DOT_StatsHelp.org::*Implementation][Implementation:1]]
𝝅     = ␣xtiles_make(_𝝅)
    L     = length(𝝅)
    freqs = Array{ℝ,2}(undef,steps,L)
    s     = MaxProc{L}(𝝅, freqs, steps, runs, Inf, Inf, 0,0)
    ␣integrity_check(s)
    return s
end
# Implementation:1 ends here

# [[file:../DOT_StatsHelp.org::*Helper functions and integrity check][Helper functions and integrity check:1]]
numo_stepsruns( s ::MaxProc{L} ) where{L}    = ( numo_steps(s) , numo_runs(s) )
numo_steps(     s ::MaxProc{L} ) where{L}    = s.steps
numo_runs(      s ::MaxProc{L} ) where{L}    = s.runs
# Helper functions and integrity check:1 ends here

# [[file:../DOT_StatsHelp.org::*Helper functions and integrity check][Helper functions and integrity check:2]]
function ␣integrity_check(s ::MaxProc{L}) ::Nothing where{L}
    @assert L           == length(s.𝝅)  "Crazy bug!!"
    @assert 0 < s.𝝅[1] < s.𝝅[end] == 1.0
    @assert (L,s.steps) == size(s.freqs)
    @assert s.steps     == numo_steps(s)
    @assert s.runs      == numo_runs(s)
    @assert s.steps ≥ 1
    @assert s.runs  ≥ 1

    @assert 0 ≤ s.𝐬 ≤ s.steps
    @assert 0 ≤ s.𝐫 ≤ s.runs
    @assert s.𝐫 ≥ 1 || s.𝐬 == 0

    @assert s.curr_max ≤ s.true_max

    nothing;
end
# Helper functions and integrity check:2 ends here

# [[file:../DOT_StatsHelp.org::*Starting a new run: ~start_run!()~ <<max-start>>][Starting a new run: ~start_run!()~ <<max-start>>:1]]
function start_run!(s        :: MaxProc{L}
                    ;
                    true_max :: ℝ            ) ::Nothing  where{L}
    ␣integrity_check(s)

    if    s.𝐫 > 0           @assert s.𝐬 == numo_steps(s)
    else                    @assert s.𝐬 == 0               end

    s.𝐫 += 1              ; @assert s.𝐫 ≤ numo_runs(s)
    s.𝐬  = 0

    s.true_max = true_max
    s.curr_max = -Inf

    nothing;
end
# Starting a new run: ~start_run!()~ <<max-start>>:1 ends here

# [[file:../DOT_StatsHelp.org::*Adding data of a step: ~record_step!()~ <<max-record>>][Adding data of a step: ~record_step!()~ <<max-record>>:1]]
function record_step!(s ::MaxProc{L}
                      ;
                      𝐸 ::ℝ            ) ::Union{ℝ,Nothing}     where{L}
    ␣integrity_check(s)

    @assert 0 ≤ 𝐸 ≤ s.true_max

    (;runs,true_max,𝝅,freqs) = s

    new_max ::Bool = false
    if 𝐸 > s.curr_max
        s.curr_max = 𝐸
        new_max    = true
    end

    s.𝐬        += 1            ; @assert s.𝐬 ≤ numo_steps(s)
    freqsₛ    =  @view freqs[:,s.𝐬]
    (;ℓ,lo,hi) =  ␣xtiles_count!(freqsₛ, 𝝅
                                ; p = s.curr_max / true_max,  Δ=1/runs)

    if new_max
        @info "New max: $𝐸; ℓ=$ℓ, lo=$lo, hi=$hi"
        return lo
    end
    nothing;
end #^ record_step!()
# Adding data of a step: ~record_step!()~ <<max-record>>:1 ends here

# [[file:../DOT_StatsHelp.org::*Finalizing a run: ~finalize_run!()~ <<max-finalize>>][Finalizing a run: ~finalize_run!()~ <<max-finalize>>:1]]
function finalize_run!(s ::MaxProc{L}) ::Nothing         where{L}
    ␣integrity_check(s)

    @assert s.𝐬 == numo_steps(s)
    @assert 0 ≤ s.curr_max

    nothing; # ... else needs to be done
end #^ finalize_run!()
# Finalizing a run: ~finalize_run!()~ <<max-finalize>>:1 ends here

# [[file:../DOT_StatsHelp.org::*End of module][End of module:1]]
end #^ module SPSA_Shift
# End of module:1 ends here
