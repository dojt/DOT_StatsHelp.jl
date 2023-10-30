# [[file:../DOT_StatsHelp.org::*File headers][File headers:2]]
###########################################################################
#                                                                         #
#  THIS IS A MACHINE-GENERATED FILE.  DO NOT EDIT IT.                     #
#                                                                         #
#  (The actual source code is in the Org file.)                           #
#                                                                         #
###########################################################################
# File headers:2 ends here

# [[file:../DOT_StatsHelp.org::*Importing things][Importing things:1]]
using  DOT_StatsHelp

using  Test


using  DoubleFloats: Double64

using  LinearAlgebra: norm_sqr as norm2², norm2, norm1, normInf as norm∞

using  Statistics: mean, var, quantile

using  DOT_NiceMath
using  DOT_StatsHelp.Numbers64     # === DOT_NiceMath.Numbers64 -- just making sure we get the same!
# Importing things:1 ends here

# [[file:../DOT_StatsHelp.org::*Generic test based on ~JET.jl~][Generic test based on ~JET.jl~:1]]
using JET
using JSON        # Only for ignoring by JET
using JSON3
using Polynomials # Only for ignoring by JET

@testset verbose=true "DOT_StatsHelp.jl testing:  via JET.jl" begin
    test_package(DOT_StatsHelp,
                 ignored_modules=(AnyFrameModule(JSON.Parser),
                                  AnyFrameModule(Polynomials),
                                  AnyFrameModule(JSON3),
                                  AnyFrameModule(Base) # Hahaha.
                                  )
                 )
end
# Generic test based on ~JET.jl~:1 ends here

# [[file:../DOT_StatsHelp.org::*Set up testset][Set up testset:1]]
@testset verbose=true "DOT_StatsHelp.jl testing: Test MeanProc_Full{}" begin
# Set up testset:1 ends here

# [[file:../DOT_StatsHelp.org::*Test with valency 0][Test with valency 0:1]]
function test__meanestim_0(;runs=1:10,steps=2:4:20)
    for 𝐑 ∈ (Double64,Float64)
        for (curr_runs,curr_steps) in Iterators.product(runs,steps)

            data = 100*randn(curr_steps,curr_runs)

            mp = MeanProc_Full( () ; steps=curr_steps, runs=curr_runs, 𝐑)

            for run = 1:curr_runs

                start_run!(mp ; true_μ = fill(0.0) )

                for step = 1:curr_steps
                    record_step!(mp ; 𝐸 = fill(data[step,run]) )
                    @test curr_emp_μ(mp)[]  ≈ mean( @view data[1:step,run] )
                end
                finalize_run!(mp)

                @test emp_var(mp;run)         ≈ var(  @view data[:,run] )

                for step=1:curr_steps
                    @test  err2²(mp;run,step) ≈ mean( data[1:step,run] ) |> abs²
                end
                @test all(
                    err1(mp;run,step)         ≈ mean( data[1:step,run] ) |> abs
                    for step=1:curr_steps
                        )
                @test all(
                    err∞(mp;run,step)         ≈ mean( data[1:step,run] ) |> abs
                for step=1:curr_steps
                    )

            end #^ for run

            if 𝐑 == Float64
                jsonstr = write_JSON(mp)
                mp2     = read_JSON_full(jsonstr;V=0)

                @test mp.curr_true_μ  == mp2.curr_true_μ
                @test mp.curr_emp_μ   == mp2.curr_emp_μ
                @test mp.err2²        == mp2.err2²
                @test mp.err1         == mp2.err1
                @test mp.err∞         == mp2.err∞
                @test mp.emp_var      == mp2.emp_var
            end

        end #^ for curr_...
    end #^ for 𝐑
end #^ test__meanestim_0()
# Test with valency 0:1 ends here

# [[file:../DOT_StatsHelp.org::*Test with valency 0][Test with valency 0:2]]
@testset "Valency-0 tests" begin
    test__meanestim_0()
end
# Test with valency 0:2 ends here

# [[file:../DOT_StatsHelp.org::*Test with valency 1][Test with valency 1:1]]
function test__meanestim_1(;runs=1:3:9,steps=2:5:12)
    for 𝐑 ∈ (Double64,Float64)
        for (curr_runs,curr_steps) in Iterators.product(runs,steps)

            dim  = 31

            data = [ randn(dim) for s=1:curr_steps, r=1:curr_runs ]

            mp = MeanProc_Full( (dim,) ; steps=curr_steps, runs=curr_runs, 𝐑)

            for run = 1:curr_runs

                start_run!(mp ; true_μ = zeros(31) )

                for step = 1:curr_steps
                    record_step!(mp ; 𝐸 = data[step,run] )
                    @test curr_emp_μ(mp)  ≈ mean( @view data[1:step,run] )
                end
                finalize_run!(mp)

                @test emp_var(mp;run)         ≈ var( @view data[:,run] ) |> norm1 # Julia `var` returns array

                for step=1:curr_steps
                    @test  err2²(mp;run,step) ≈ mean( data[1:step,run] ) |> norm2²
                end
                @test all(
                    err1(mp;run,step)         ≈ mean( data[1:step,run] ) |> norm1
                    for step=1:curr_steps
                )
                @test all(
                    err∞(mp;run,step)         ≈ mean( data[1:step,run] ) |> norm∞
                    for step=1:curr_steps
                )

            end #^ for run

            if 𝐑 == Float64
                jsonstr = write_JSON(mp)
                mp2     = read_JSON_full(jsonstr;V=1)

                @test mp.curr_true_μ  == mp2.curr_true_μ
                @test mp.curr_emp_μ   == mp2.curr_emp_μ
                @test mp.err2²        == mp2.err2²
                @test mp.err1         == mp2.err1
                @test mp.err∞         == mp2.err∞
                @test mp.emp_var      == mp2.emp_var
            end

        end #^ for curr_...
    end #^ for 𝐑
end #^ test__meanestim_1()
# Test with valency 1:1 ends here

# [[file:../DOT_StatsHelp.org::*Test with valency 1][Test with valency 1:2]]
@testset "Valency-1 tests" begin
    test__meanestim_1()
end
# Test with valency 1:2 ends here

# [[file:../DOT_StatsHelp.org::*Test with valency 2][Test with valency 2:1]]
function test__meanestim_2(;runs=1:3:9,steps=2:5:12)
    for 𝐑 ∈ (Double64,Float64)
        for (curr_runs,curr_steps) in Iterators.product(runs,steps)

            sz  = (7,13)

            data = [ randn(sz) for s=1:curr_steps, r=1:curr_runs ]

            mp = MeanProc_Full( (sz) ; steps=curr_steps, runs=curr_runs, 𝐑)

            for run = 1:curr_runs

                start_run!(mp ; true_μ = zeros(sz) )

                for step = 1:curr_steps
                    record_step!(mp ; 𝐸 = data[step,run] )
                    @test curr_emp_μ(mp)  ≈ mean( @view data[1:step,run] )
                end
                finalize_run!(mp)

                @test emp_var(mp;run)         ≈ var( @view data[:,run] ) |> norm1 # Julia `var` returns array

                for step=1:curr_steps
                    @test  err2²(mp;run,step) ≈ mean( data[1:step,run] ) |> norm2²
                end
                @test all(
                    err1(mp;run,step)         ≈ mean( data[1:step,run] ) |> norm1
                    for step=1:curr_steps
                )
                @test all(
                    err∞(mp;run,step)         ≈ mean( data[1:step,run] ) |> norm∞
                    for step=1:curr_steps
                )

            end #^ for run

            if 𝐑 == Float64
                jsonstr = write_JSON(mp)
                mp2     = read_JSON_full(jsonstr;V=2)

                @test mp.curr_true_μ  == mp2.curr_true_μ
                @test mp.curr_emp_μ   == mp2.curr_emp_μ
                @test mp.err2²        == mp2.err2²
                @test mp.err1         == mp2.err1
                @test mp.err∞         == mp2.err∞
                @test mp.emp_var      == mp2.emp_var
            end

        end #^ for curr_...
    end #^ for 𝐑
end #^ test__meanestim_1()
# Test with valency 2:1 ends here

# [[file:../DOT_StatsHelp.org::*Test with valency 2][Test with valency 2:2]]
@testset "Valency-2 tests" begin
    test__meanestim_2()
end
# Test with valency 2:2 ends here

# [[file:../DOT_StatsHelp.org::*End of testset][End of testset:1]]
end #^ testset
# End of testset:1 ends here

# [[file:../DOT_StatsHelp.org::*Set up testset][Set up testset:1]]
@testset verbose=true "DOT_StatsHelp.jl testing: Test MeanProc_Qtl{}" begin
# Set up testset:1 ends here

# [[file:../DOT_StatsHelp.org::*The test][The test:1]]
function test__meanestim_qtl(;runs=10:71:400,steps=4:4:20)

    δ  = 0.123

    for ε₀ ∈ (1e-3, 1e-7)
        for true_μ ∈ (1.0, 1e-10)
            for 𝐑 ∈ (Double64,Float64)
                for (curr_runs,curr_steps) in Iterators.product(runs,steps)

                    data = ones(curr_steps,curr_runs)/true_μ + 100*randn(curr_steps,curr_runs)
                    μ    = [ mean( @view data[1:step,run]   )  for step=1:curr_steps, run=1:curr_runs ]
                    vari = [ var(  @view data[1:step,run]   )  for step=1:curr_steps, run=1:curr_runs ]
                    Δ    = abs.( μ .− true_μ )
                    rerr = Δ ./( true_μ + ε₀ )

                    pcnt = [ quantile((@view rerr[step,:]),δ)  for step=1:curr_steps ]
                    erex = [ extrema(  @view rerr[step,:]   )  for step=1:curr_steps ]
                    varex= [ extrema(  @view vari[step,:]   )  for step=1:curr_steps ]

                    mp = MeanProc_Qtl(δ
                                      ;
                                      true_μ, ε₀,
                                      runs   = curr_runs,
                                      steps  = curr_steps,
                                      𝐑)
                    for step = 1:curr_steps

                        start_step!(mp)

                        for run = 1:curr_runs

                            record_run!(mp ; 𝐸 = data[step,run] )

                            @test mp.curr_emp_μ[ mp.𝐫[]] ≈ μ[   step,run]
                            @test mp.err[        mp.𝐫[]] ≈ rerr[step,run]
                            if step ≥ 2
                                @test mp.emp_var[mp.𝐫[]] ≈ vari[step,run]    rtol=1e-4
                            end
                        end #^ for (runs)

                        finalize_step!(mp)

                        @test mp.err_quants[step] ≈ pcnt[step]
                        @test all( a≈b
                                   for (a,b) ∈ zip(mp.err_minmax[step],erex[step])
                                 )
                        if step ≥ 2
                            @test first(mp.emp_var_minmax[step]) ≈ first(varex[step])    rtol=1e-3
                            @test last( mp.emp_var_minmax[step]) ≈ last( varex[step])    rtol=1e-3
                        end
                    end #^ for (steps)

                    @test mp.numo_steps == curr_steps
                    @test mp.𝐬[]        == curr_steps
                    @test mp.𝐫[]        == curr_runs


                    if 𝐑 == Float64
                        let
                            jsonstr  = write_JSON(mp)
                            mpio     = read_JSON_qtl(jsonstr)

                            @test mp.numo_steps     == first( mpio.steps_runs )
                            @test length(mp.err)    == last(  mpio.steps_runs )
                            @test mp.δ              == mpio.δ
                            @test mp.ε₀             == mpio.ε₀
                            @test mp.true_μ         == mpio.true_μ
                            @test mp.curr_emp_μ     == mpio.curr_emp_μ
                            @test mp.err            == mpio.err
                            @test mp.emp_var        == mpio.emp_var
                            @test mp.err_quants     == mpio.err_quants
                            @test mp.err_minmax     == mpio.err_minmax
                            @test mp.emp_var_minmax == mpio.emp_var_minmax
                        end
                        let
                            empty!(mp.err_quants)
                            empty!(mp.err_minmax)
                            empty!(mp.emp_var_minmax)

                            jsonstr  = write_JSON(mp)
                            mpio = @test_logs (
                                :error,
                                r"JSON-reading MeanProc_Qtl_Storage with acutal numo steps == 0 <"
                            )  read_JSON_qtl(jsonstr)

                            @test mp.numo_steps     == first( mpio.steps_runs )
                            @test length(mp.err)    == last(  mpio.steps_runs )
                            @test mp.δ              == mpio.δ
                            @test mp.ε₀             == mpio.ε₀
                            @test mp.true_μ         == mpio.true_μ
                            @test mp.curr_emp_μ     == mpio.curr_emp_μ
                            @test mp.err            == mpio.err
                            @test mp.emp_var        == mpio.emp_var
                            @test mp.err_quants     == mpio.err_quants
                            @test mp.err_minmax     == mpio.err_minmax
                            @test mp.emp_var_minmax == mpio.emp_var_minmax
                        end
                    end
                end #^ for curr_...
            end #^ for 𝐑
        end #^ for true_μ
    end #^ for ε₀
end #^ test__meanestim_0()
# The test:1 ends here

# [[file:../DOT_StatsHelp.org::*The test][The test:2]]
test__meanestim_qtl()
# The test:2 ends here

# [[file:../DOT_StatsHelp.org::*End of testset][End of testset:1]]
end #^ testset
# End of testset:1 ends here

# [[file:../DOT_StatsHelp.org::*Main testing function][Main testing function:1]]
function test__xtiles()

    function some_tests__interior(_𝝅)
        L     = length(_𝝅)
        m     = 16
        N     = m⋅L
        𝝅     = DOT_StatsHelp.␣xtiles_make(_𝝅)
        freqs = zeros(ℝ,L)

        for ℓ = 1 : L
            lo = get(𝝅,ℓ-1,   0.0)
            hi =     𝝅[ℓ  ]
            @test lo < hi || (lo==hi && ℓ==L)
            for j = 1:m
                p =  lo + (hi-lo)⋅rand()
                iv = DOT_StatsHelp.␣xtiles_count!(freqs,𝝅 ; p, Δ=1/N)
                @test iv.lo < p ≤ iv.hi
            end
        end

        @test sum(freqs) ≈ 1
        for ℓ = 1:L
            @test freqs[ℓ] ≈ m/N
        end
    end

    function some_tests__boundary(_𝝅)
        L     = length(_𝝅)
        m     = 16
        N     = m⋅L
        𝝅     = DOT_StatsHelp.␣xtiles_make(_𝝅)
        freqs = zeros(ℝ,L)

        for j = 1:m
            for ℓ = 1:L
                lo = get(𝝅,ℓ-1,   0.0)
                hi =     𝝅[ℓ  ]
                @test lo < hi || (lo==hi && ℓ==L)
                DOT_StatsHelp.␣xtiles_count!(freqs,𝝅 ; p=hi, Δ=1/N)
            end
        end

        @test sum(freqs) ≈ 1
        for ℓ = 1:L
            @test freqs[ℓ] ≈ m/N
        end
    end

    for L = 1:10
        𝝅 = [ rand(L-1)
              1.0       ]
        some_tests__interior(𝝅)
        some_tests__boundary(𝝅)
    end
end #^ test__Xtiles()
# Main testing function:1 ends here

# [[file:../DOT_StatsHelp.org::*Call the testing function][Call the testing function:1]]
@testset verbose=true "DOT_StatsHelp.jl testing: Test Xtiles helper" begin
    test__xtiles()
end
# Call the testing function:1 ends here
