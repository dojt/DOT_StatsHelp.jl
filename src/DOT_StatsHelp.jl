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
export MeanProc_Full_Storage, write_JSON, read_JSON
# Module definition, import, and recurrent exports:3 ends here

# [[file:../DOT_StatsHelp.org::*The mean process type: ~MeanProc_Full{𝐑,V}~ <<¤MP-full--struct>>][The mean process type: ~MeanProc_Full{𝐑,V}~                   <<¤MP-full--struct>>:1]]
export MeanProc_Full
# The mean process type: ~MeanProc_Full{𝐑,V}~                   <<¤MP-full--struct>>:1 ends here

# [[file:../DOT_StatsHelp.org::*The mean process type: ~MeanProc_Full{𝐑,V}~ <<¤MP-full--struct>>][The mean process type: ~MeanProc_Full{𝐑,V}~                   <<¤MP-full--struct>>:2]]
struct MeanProc_Full{𝐑 <: Real, V}              # `V` is an integer: the valency of the tensor
# The mean process type: ~MeanProc_Full{𝐑,V}~                   <<¤MP-full--struct>>:2 ends here

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
MeanProc_Full{𝐑,V}(;
           curr_true_μ ::Array{ℝ,V}, curr_emp_μ ::Array{𝐑,V}, emp_var ::Vector{𝐑},
           err2² ::Array{ℝ,2}, err1 ::Array{ℝ,2}, err∞ ::Array{ℝ,2}, ␣ws ::Array{𝐑,V}) where{𝐑,V}
    new(curr_true_μ, curr_emp_μ, err2², err1, err∞, emp_var, ␣ws,
        0,0)
end
# Fields and inner constructor:1 ends here

# [[file:../DOT_StatsHelp.org::*Fields and inner constructor][Fields and inner constructor:2]]
end
# Fields and inner constructor:2 ends here

# [[file:../DOT_StatsHelp.org::*Usage][Usage:1]]
export err2², err1, err∞, emp_var, curr_emp_μ
# Usage:1 ends here

# [[file:../DOT_StatsHelp.org::*Usage][Usage:2]]
err2²(  s ::MeanProc_Full{𝐑,V}; run ::Int, step ::Int) where{𝐑,V} = ( @assert (1,1)≤(run,step)≤(s.𝐫[],s.𝐬[]); s.err2²[step,run] )
err1(   s ::MeanProc_Full{𝐑,V}; run ::Int, step ::Int) where{𝐑,V} = ( @assert (1,1)≤(run,step)≤(s.𝐫[],s.𝐬[]); s.err1[ step,run] )
err∞(   s ::MeanProc_Full{𝐑,V}; run ::Int, step ::Int) where{𝐑,V} = ( @assert (1,1)≤(run,step)≤(s.𝐫[],s.𝐬[]); s.err∞[ step,run] )
emp_var(s ::MeanProc_Full{𝐑,V}; run ::Int)             where{𝐑,V} = ( @assert 1    ≤run ≤ s.𝐫[]             ; s.emp_var[run]    )

curr_emp_μ(s ::MeanProc_Full{𝐑,V})                     where{𝐑,V} = ( @assert 1 ≤ s.𝐫[]                     ; s.curr_emp_μ      )
# Usage:2 ends here

# [[file:../DOT_StatsHelp.org::*User-facing constructor for ~MeanProc_Full~][User-facing constructor for ~MeanProc_Full~:1]]
function MeanProc_Full(dimension ::NTuple{V,Int}
                       ;
                       steps :: Int,
                       runs  :: Int,
                       𝐑     :: Type{<:Real} = ℝ)  ::MeanProc_Full     where{V}
# User-facing constructor for ~MeanProc_Full~:1 ends here

# [[file:../DOT_StatsHelp.org::*Implementation][Implementation:1]]
curr_true_μ   = Array{ℝ,V}(undef, dimension )
curr_emp_μ    = Array{𝐑,V}(undef, dimension )   ; curr_emp_μ   .= 𝐑(0)
␣ws           = Array{𝐑,V}(undef, dimension )

err2²         = Array{ℝ,2}(undef, steps,runs)
err1          = Array{ℝ,2}(undef, steps,runs)
err∞          = Array{ℝ,2}(undef, steps,runs)
emp_var       = Array{𝐑,1}(undef, runs)         ; emp_var .= 𝐑(0)

s = MeanProc_Full{𝐑,V}( ; curr_true_μ, curr_emp_μ,
                     err2², err1, err∞, emp_var,  ␣ws)
␣integrity_check(s)
return s
# Implementation:1 ends here

# [[file:../DOT_StatsHelp.org::*Implementation][Implementation:2]]
end #^ MeanProc_Full constructor
# Implementation:2 ends here

# [[file:../DOT_StatsHelp.org::*Helper functions and integrity check][Helper functions and integrity check:1]]
valency(        s ::MeanProc_Full{𝐑,V} ) where{𝐑,V}    = V
dimension(      s ::MeanProc_Full{𝐑,V} ) where{𝐑,V}    = size( s.curr_true_μ )
numo_stepsruns( s ::MeanProc_Full{𝐑,V} ) where{𝐑,V}    = size( s.err2²       )
numo_steps(     s ::MeanProc_Full{𝐑,V} ) where{𝐑,V}    = numo_stepsruns(s) |> first
numo_runs(      s ::MeanProc_Full{𝐑,V} ) where{𝐑,V}    = numo_stepsruns(s) |> last
# Helper functions and integrity check:1 ends here

# [[file:../DOT_StatsHelp.org::*Helper functions and integrity check][Helper functions and integrity check:2]]
function ␣integrity_check(s ::MeanProc_Full{𝐑,V}) ::Nothing  where{𝐑,V}
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

# [[file:../DOT_StatsHelp.org::*Starting a new run: ~start_run!()~ <<mp-start>>][Starting a new run: ~start_run!()~                            <<mp-start>>:1]]
function start_run!(s      :: MeanProc_Full{𝐑,V}
                    ;
                    true_μ :: Array{ℝ,V} ) ::Nothing  where{𝐑,V}
# Starting a new run: ~start_run!()~                            <<mp-start>>:1 ends here

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

# [[file:../DOT_StatsHelp.org::*Adding data of a step: ~record_step!()~][Adding data of a step: ~record_step!()~:1]]
function record_step!(s ::MeanProc_Full{𝐑,V}
                      ;
                      𝐸 ::Array{ℝ,V} ) ::Nothing  where{𝐑,V}
# Adding data of a step: ~record_step!()~:1 ends here

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

# [[file:../DOT_StatsHelp.org::*Finalizing a run: ~finalize_run!()~ <<mp-finalize>>][Finalizing a run: ~finalize_run!()~                           <<mp-finalize>>:1]]
function finalize_run!(s ::MeanProc_Full{𝐑,V}) ::Nothing                  where{𝐑,V}
# Finalizing a run: ~finalize_run!()~                           <<mp-finalize>>:1 ends here

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

# [[file:../DOT_StatsHelp.org::*Storage struct][Storage struct:1]]
@kwdef struct MeanProc_Full_Storage{V}
    dim          ::NTuple{V,Int}
    steps_runs   ::Tuple{Int,Int}

    curr_true_μ  ::Array{ℝ,1} # was: V
    curr_emp_μ   ::Array{ℝ,1} #      V
    err2²        ::Array{ℝ,1} #      2
    err1         ::Array{ℝ,1} #      2
    err∞         ::Array{ℝ,1} #      2

    emp_var      ::Vector{ℝ}
end
# Storage struct:1 ends here

# [[file:../DOT_StatsHelp.org::*Constructor: ~MeanProc_Full~ to ~MeanProc_Full_Storage~][Constructor: ~MeanProc_Full~ to ~MeanProc_Full_Storage~:1]]
function MeanProc_Full_Storage(mp ::MeanProc_Full{ℝ,V}) ::MeanProc_Full_Storage{V} where{V}
    dim                         = size( mp.curr_true_μ )
    steps_runs ::Tuple{Int,Int} = size( mp.err2²       )

    return MeanProc_Full_Storage{V}(;
                           dim         = dim,
                           steps_runs  = steps_runs,
                           curr_true_μ = reshape(mp.curr_true_μ , (length(mp.curr_true_μ),) ),
                           curr_emp_μ  = reshape(mp.curr_emp_μ  , (length(mp.curr_emp_μ ),) ),
                           err2²       = reshape(mp.err2²       , (length(mp.err2²      ),) ),
                           err1        = reshape(mp.err1        , (length(mp.err1       ),) ),
                           err∞        = reshape(mp.err∞        , (length(mp.err∞       ),) ),
                           emp_var     =         mp.emp_var
                           )
end
# Constructor: ~MeanProc_Full~ to ~MeanProc_Full_Storage~:1 ends here

# [[file:../DOT_StatsHelp.org::*Constructor: ~MeanProc_Full_Storage~ to ~MeanProc_Full~][Constructor: ~MeanProc_Full_Storage~ to ~MeanProc_Full~:1]]
function MeanProc_Full(mpio ::MeanProc_Full_Storage{V}) ::MeanProc_Full{ℝ,V}    where{V}
    return MeanProc_Full{ℝ,V}(;
                         curr_true_μ = reshape(mpio.curr_true_μ , mpio.dim       ),
                         curr_emp_μ  = reshape(mpio.curr_emp_μ  , mpio.dim       ),
                         err2²       = reshape(mpio.err2²       , mpio.steps_runs),
                         err1        = reshape(mpio.err1        , mpio.steps_runs),
                         err∞        = reshape(mpio.err∞        , mpio.steps_runs),
                         emp_var     =         mpio.emp_var,
                         ␣ws         = Array{ℝ,V}( undef,  ((0 for j=1:V)...,)  )
                         )
end
# Constructor: ~MeanProc_Full_Storage~ to ~MeanProc_Full~:1 ends here

# [[file:../DOT_StatsHelp.org::*JSON-IO functions][JSON-IO functions:1]]
using JSON3
# JSON-IO functions:1 ends here

# [[file:../DOT_StatsHelp.org::*JSON-IO functions][JSON-IO functions:2]]
function write_JSON(mp ::MeanProc_Full{ℝ,V}) ::String      where{V}
    return JSON3.write( MeanProc_Full_Storage( mp ) )
end
# JSON-IO functions:2 ends here

# [[file:../DOT_StatsHelp.org::*JSON-IO functions][JSON-IO functions:3]]
function read_JSON(json ::AbstractString; V ::Int) ::MeanProc_Full
    return MeanProc_Full( JSON3.read(json, MeanProc_Full_Storage{V}) )
end
# JSON-IO functions:3 ends here

# [[file:../DOT_StatsHelp.org::*The type ~MeanProc_Qtl{𝐑}~][The type ~MeanProc_Qtl{𝐑}~:1]]
export MeanProc_Qtl
struct MeanProc_Qtl{𝐑 <: Real}
# The type ~MeanProc_Qtl{𝐑}~:1 ends here

# [[file:../DOT_StatsHelp.org::*Fields and inner constructor][Fields and inner constructor:1]]
numo_steps      ::Int         #                      no need-to-know, just pest control

#               Input for run
δ               ::ℝ           #                      the quantile
true_μ          ::ℝ           #                      constant over runs!
ε₀              ::ℝ           # correction for `true_μ` close to 0

#               Result of step
curr_emp_μ      ::Vector{𝐑}   #                      length: `runs`
err             ::Vector{ℝ}   # relative error       length: `runs`
emp_var         ::Vector{𝐑}   #                      length: `runs`

#               Overall output
err_quants      ::Vector{ℝ}   # the quantiles        length: `steps`
err_minmax      ::Vector{ℝ}   #                      length: `steps`
emp_var_minmax  ::Vector{ℝ}   #                      length: `steps`

#               Work space over steps
␣π              ::Vector{Int} # permutation          length: `runs`

#               Counters
𝐫               ::Ref{Int}    # index of current run (i.e., 0 ⪮ before first run)
𝐬               ::Ref{Int}    # index of current step (i.e., 0 ⪮ before first step)

function
    MeanProc_Full{𝐑}(  δ ::ℝ
                       ;
                       numo_steps ::Int, true_μ ::ℝ, ε₀ ::ℝ,
                       curr_emp_μ ::Vector{𝐑}, emp_var ::Vector{𝐑}, err ::Vector{ℝ}, ␣π ::Vector{Int},
                       err_quants ::Vector{ℝ}, err_minmax ::Vector{ℝ}, emp_var_minmax ::Vector{ℝ}
                    ) where{𝐑}

    new{𝐑}(numo_steps,
           δ, true_μ, ε₀,
           curr_emp_μ, err, emp_var,
           err_quants, err_minmax, emp_var_minmax,
           ␣π,
           0,0)
end ;
# Fields and inner constructor:1 ends here

# [[file:../DOT_StatsHelp.org::*Fields and inner constructor][Fields and inner constructor:2]]
end #^ struct MeanProc_Qtl
# Fields and inner constructor:2 ends here

# [[file:../DOT_StatsHelp.org::*User-facing constructor][User-facing constructor:1]]
function MeanProc_Qtl(δ      :: ℝ
                      ;
                      true_μ :: ℝ,
                      runs   :: Int,
                      steps  :: Int,
                      𝐑      :: Type{<:Real} = ℝ,
                      ε₀     :: ℝ            = 1e-6)
# User-facing constructor:1 ends here

# [[file:../DOT_StatsHelp.org::*Implementation][Implementation:1]]
@assert 0 < δ < 1
@assert isfinite(true_μ)
@assert runs ≥ 2
@assert 0 ≤ ε₀ < 0.1

curr_emp_μ     = zeros( 𝐑,          runs)
emp_var        = zeros( 𝐑,          runs)
err            = Vector{ℝ  }(undef, runs)
␣π             = collect(1:runs)


err_quants     = ℝ[] ; sizehint!(err_quants    ,steps)
err_minmax     = ℝ[] ; sizehint!(err_minmax    ,steps)
emp_var_minmax = ℝ[] ; sizehint!(emp_var_minmax,steps)

s = MeanProc_Qtl{𝐑}(δ ; ε₀, numo_steps=steps, true_μ,
                    curr_emp_μ, emp_var, err, ␣π,
                    err_quants, err_minmax, emp_var_minmax)
␣integrity_check(s)
return s
# Implementation:1 ends here

# [[file:../DOT_StatsHelp.org::*Implementation][Implementation:2]]
end #^ MeanProc_Qtl constructor
# Implementation:2 ends here

# [[file:../DOT_StatsHelp.org::*Helper functions and integrity check][Helper functions and integrity check:1]]
numo_runs(s ::MeanProc_Qtl{𝐑} ) where{𝐑}     = length(s.curr_emp_μ)
numo_steps(s ::MeanProc_Qtl{𝐑} ) where{𝐑}    = s.numo_steps
# Helper functions and integrity check:1 ends here

# [[file:../DOT_StatsHelp.org::*Helper functions and integrity check][Helper functions and integrity check:2]]
function ␣integrity_check(s ::MeanProc_Qtl{𝐑}) ::Nothing  where{𝐑}
# Helper functions and integrity check:2 ends here

# [[file:../DOT_StatsHelp.org::*Implementation][Implementation:1]]
@assert isfinite( s.true_μ )
@assert 0 < s.δ  < 1
@assert 0 ≤ s.ε₀ < 0.1

let runs   = numo_runs(s)
    steps  = numo_steps(s)

    @assert runs  ≥ 2

    @assert 0 ≤ s.𝐫[] ≤ runs
    @assert 0 ≤ s.𝐬[] ≤ steps
    @assert s.𝐬[] ≥ 1 || s.𝐫[] == 0

    @assert size( s.curr_emp_μ     ) == (runs,)
    @assert size( s.err            ) == (runs,)
    @assert size( s.emp_var        ) == (runs,)
    @assert size( s.␣π             ) == (runs,)

    @assert size( s.err_quants     ) ==
            size( s.err_minmax     ) ==
            size( s.emp_var_minmax )

    @assert (s.𝐬[]-1,) ≤ size(s.err_quants) ≤ (s.𝐬[],) # ??????????????????????????

end #^ let
return nothing
# Implementation:1 ends here

# [[file:../DOT_StatsHelp.org::*Implementation][Implementation:2]]
end #^ ␣integrity_check(::MeanProc_Qtl)
# Implementation:2 ends here

# [[file:../DOT_StatsHelp.org::*Starting a new step: ~start_step!()~][Starting a new step: ~start_step!()~:1]]
function start_step!(s ::MeanProc_Qtl{𝐑}) ::Nothing        where{𝐑}

    ␣integrity_check(s)


    if    s.𝐬[] > 0         @assert s.𝐫[] == numo_runs(s)
    else                    @assert s.𝐫[] == 0               end

    s.𝐬[] += 1            ; @assert s.𝐬[] ≤ numo_steps(s)
    s.𝐫[]  = 0

    nothing;
end #^ start_run!()
# Starting a new step: ~start_step!()~:1 ends here

# [[file:../DOT_StatsHelp.org::*Adding a data point: ~record_run!()~][Adding a data point: ~record_run!()~:1]]
function record_run!( s ::MeanProc_Qtl{𝐑}
                      ;
                      𝐸 ::ℝ              ) ::Nothing  where{𝐑}

    ␣integrity_check(s)

    @assert isfinite(𝐸)
    @assert s.𝐬[] ≥ 1
    @assert s.𝐫[] < numo_runs(s)

    let
        ( ;
          δ, true_μ,
          curr_emp_μ,
          err,
          emp_var,
          𝐫, 𝐬          ) = s

        𝐫[] += 1

        𝑟 = 𝐫[]
        𝑠 = 𝐬[]


        let old_μ = curr_emp_μ[𝑟]

            emp_var[𝑟] =
                if      𝑠 == 1      𝐑(0)
                elseif  𝑠 == 2      (old_μ − (old_μ+𝐸)/2)^2 + (𝐸 − (old_μ+𝐸)/2)^2
                else
                    old_emp_var = emp_var[𝑟] ⋅ (𝑠-1)/𝐑(𝑠-2)
                    old_emp_var +  abs²(old_μ − 𝐸)/𝑠
                end
        end #^ let


        curr_emp_μ[𝑟] = ( (𝑠-1)⋅curr_emp_μ[𝑟] + 𝐸 ) / 𝑠


        let 𝛥 = abs( curr_emp_μ[𝑟] − true_μ )

            err[𝑟] = 𝛥 / ( abs(true_μ) + s.ε₀ )

        end
    end #^ let
end #^ record_run!()
# Adding a data point: ~record_run!()~:1 ends here

# [[file:../DOT_StatsHelp.org::*Finalizing a step: ~finalize_step!()~][Finalizing a step: ~finalize_step!()~:1]]
function finalize_step!(s ::MeanProc_Qtl{𝐑}) ::ℝ     where{𝐑}

    ␣integrity_check(s)


    let
        runs              = numo_runs(s)
        ( ;
          δ, true_μ,
          curr_emp_μ,
          err,
          emp_var,
          ␣π,
          𝐫, 𝐬          ) = s


        push!(s.err_quants    ,
              let lo = floor(Int, (δ   )⋅runs ),
                  hi = ceil( Int, (δ +1)⋅runs )

                  sortperm!( ␣π, err  ;  alg = PartialQuickSort( lo:hi ) )
              end
              )

        push!(          s.err_minmax               ,
                  extrema(err)                      )

        push!(          s.emp_var_minmax           ,
                  extrema(emp_var) |> Tuple{ℝ,ℝ}    )

    end #^ let

    ␣integrity_check(s)

    return s.err_quants[end]
end #^ finalize_step!()
# Finalizing a step: ~finalize_step!()~:1 ends here

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
    const 𝝅         ::NTuple{L,ℝ}   # tiles numbers, sorted increasingly (last one must be 1.0)
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

# [[file:../DOT_StatsHelp.org::*User-facing constructor for ~MaxApprox~][User-facing constructor for ~MaxApprox~:1]]
function MaxProc(_𝝅
                 ;
                 steps :: Int,
                 runs  :: Int )  ::MaxProc
# User-facing constructor for ~MaxApprox~:1 ends here

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

# [[file:../DOT_StatsHelp.org::*Starting a new run: ~start_run!()~][Starting a new run: ~start_run!()~:1]]
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
# Starting a new run: ~start_run!()~:1 ends here

# [[file:../DOT_StatsHelp.org::*Adding data of a step: ~record_step!()~][Adding data of a step: ~record_step!()~:1]]
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
# Adding data of a step: ~record_step!()~:1 ends here

# [[file:../DOT_StatsHelp.org::*Finalizing a run: ~finalize_run!()~ <<max-finalize>>][Finalizing a run: ~finalize_run!()~                  <<max-finalize>>:1]]
function finalize_run!(s ::MaxProc{L}) ::ℝ         where{L}
    ␣integrity_check(s)

    @assert s.𝐬 == numo_steps(s)
    @assert 0 ≤ s.curr_max

    return s.curr_max
end #^ finalize_run!()
# Finalizing a run: ~finalize_run!()~                  <<max-finalize>>:1 ends here

# [[file:../DOT_StatsHelp.org::*End of module][End of module:1]]
end #^ module SPSA_Shift
# End of module:1 ends here
