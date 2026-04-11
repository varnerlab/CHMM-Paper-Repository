# ========================================================================================= #
# run_baselines_and_cross_asset.jl
#
# Generates:
#   1. Table 2 baselines: Bootstrap, Gaussian i.i.d., Laplace i.i.d. for SPY
#   2. Table T2: Cross-asset generalization for NVDA, JNJ, JPM at K=13
# ========================================================================================= #

using Pkg; Pkg.activate(".");
include("Include.jl");

const TICKER = "SPY";
const RISK_FREE_RATE = 0.0;
const ΔT = 1/252;
const N_PATHS = 1000;
const L = 252;
const K = 13;
const MAX_ITER = 60;
const RESULTS_DIR = joinpath(@__DIR__, "results");

# ========================================================================================= #
# LOAD DATA
# ========================================================================================= #
println("Loading data...")
train_dataset = MyPortfolioDataSet() |> x -> x["dataset"];
max_days = nrow(train_dataset["AAPL"]);
dataset = Dict{String,DataFrame}();
for (t, data) ∈ train_dataset
    if nrow(data) == max_days; dataset[t] = data; end
end
list_of_all_tickers = keys(dataset) |> collect |> sort;
all_R = log_growth_matrix(dataset, list_of_all_tickers; Δt=ΔT, risk_free_rate=RISK_FREE_RATE);
idx_spy = findfirst(x -> x == TICKER, list_of_all_tickers);
R_is = all_R[:, idx_spy];
n_is = length(R_is);

oos_dataset = MyOutOfSamplePortfolioDataSet() |> x -> x["dataset"];
R_oos = log_growth_matrix(oos_dataset, TICKER; Δt=ΔT, risk_free_rate=RISK_FREE_RATE);
n_oos = length(R_oos);

# Observed stats
μ_obs = mean(R_is); σ_obs = std(R_is);
kurt_obs_is = sum(((R_is .- μ_obs) ./ σ_obs).^4) / n_is - 3.0;
acf_obs_is = autocor(abs.(R_is), 1:L);
μ_oos = mean(R_oos); σ_oos = std(R_oos);
kurt_obs_oos = sum(((R_oos .- μ_oos) ./ σ_oos).^4) / n_oos - 3.0;

println("IS: $n_is obs, OoS: $n_oos obs")

# ========================================================================================= #
# METRICS FUNCTION
# ========================================================================================= #
function eval_full(observed, sim_archive; L_val=252)
    np = size(sim_archive, 2); n_o = length(observed);
    μ_o = mean(observed); σ_o = std(observed);
    kurt_o = sum(((observed .- μ_o) ./ σ_o).^4) / n_o - 3.0;
    L_use = min(L_val, n_o - 1);
    acf_o = autocor(abs.(observed), 1:L_use);

    ks_pass = 0; kurt_s = 0.0; acf_mae_s = 0.0; w1_s = 0.0; hell_s = 0.0;
    for i in 1:np
        sim = sim_archive[:, i];
        pval = pvalue(ApproximateTwoSampleKSTest(observed, sim));
        if pval > 0.05; ks_pass += 1; end

        μ_s = mean(sim); σ_s = std(sim);
        kurt_s += sum(((sim .- μ_s) ./ σ_s).^4) / length(sim) - 3.0;
        acf_sim = autocor(abs.(sim), 1:L_use);
        acf_mae_s += mean(abs.(acf_o .- acf_sim));

        obs_sorted = sort(observed); sim_sorted = sort(sim);
        n_min = min(length(obs_sorted), length(sim_sorted));
        obs_q = [obs_sorted[max(1, round(Int, k*length(obs_sorted)/n_min))] for k in 1:n_min];
        sim_q = [sim_sorted[max(1, round(Int, k*length(sim_sorted)/n_min))] for k in 1:n_min];
        w1_s += mean(abs.(obs_q .- sim_q));

        lo = min(minimum(observed), minimum(sim)) - 10;
        hi = max(maximum(observed), maximum(sim)) + 10;
        edges = range(lo, hi, length=101);
        h_o = fit(Histogram, observed, edges).weights ./ n_o;
        h_s = fit(Histogram, sim, edges).weights ./ length(sim);
        hell_s += sqrt(sum((sqrt.(h_o) .- sqrt.(h_s)).^2)) / sqrt(2);
    end

    return (ks=round(100*ks_pass/np, digits=1),
            kurt=round(kurt_s/np, digits=2), kurt_obs=round(kurt_o, digits=2),
            acf_mae=round(acf_mae_s/np, digits=4),
            w1=round(w1_s/np, digits=3), hell=round(hell_s/np, digits=4))
end

# ========================================================================================= #
# PART 1: BASELINE COMPARISONS (Table 2)
# ========================================================================================= #
println("\n" * "="^70)
println("PART 1: Baseline Comparisons for $TICKER")
println("="^70)

# --- Bootstrap ---
println("  Bootstrap...")
boot_is = Array{Float64,2}(undef, n_is, N_PATHS);
boot_oos = Array{Float64,2}(undef, n_oos, N_PATHS);
for i in 1:N_PATHS
    boot_is[:, i] = R_is[rand(1:n_is, n_is)];
    boot_oos[:, i] = R_is[rand(1:n_is, n_oos)];  # resample from IS
end
m_boot_is = eval_full(R_is, boot_is);
m_boot_oos = eval_full(R_oos, boot_oos);

# --- Gaussian i.i.d. ---
println("  Gaussian i.i.d....")
gauss_is = Array{Float64,2}(undef, n_is, N_PATHS);
gauss_oos = Array{Float64,2}(undef, n_oos, N_PATHS);
d_gauss = Normal(μ_obs, σ_obs);
for i in 1:N_PATHS
    gauss_is[:, i] = rand(d_gauss, n_is);
    gauss_oos[:, i] = rand(d_gauss, n_oos);
end
m_gauss_is = eval_full(R_is, gauss_is);
m_gauss_oos = eval_full(R_oos, gauss_oos);

# --- Laplace i.i.d. ---
println("  Laplace i.i.d....")
μ_lap = median(R_is); b_lap = mean(abs.(R_is .- μ_lap));
d_lap = Laplace(μ_lap, b_lap);
lap_is = Array{Float64,2}(undef, n_is, N_PATHS);
lap_oos = Array{Float64,2}(undef, n_oos, N_PATHS);
for i in 1:N_PATHS
    lap_is[:, i] = rand(d_lap, n_is);
    lap_oos[:, i] = rand(d_lap, n_oos);
end
m_lap_is = eval_full(R_is, lap_is);
m_lap_oos = eval_full(R_oos, lap_oos);

# Print Table 2 baselines
println("\nTable 2: Baseline Results — $TICKER")
println("="^90)
println("Model         | KS IS(%) | KS OoS(%) | Kurt IS | Kurt OoS | ACF-MAE | W1 IS  | H IS")
println("-"^90)
println("Bootstrap     | $(lpad(m_boot_is.ks,7)) | $(lpad(m_boot_oos.ks,8))  | $(lpad(m_boot_is.kurt,6)) | $(lpad(m_boot_oos.kurt,7))  | $(m_boot_is.acf_mae) | $(m_boot_is.w1) | $(m_boot_is.hell)")
println("Gaussian      | $(lpad(m_gauss_is.ks,7)) | $(lpad(m_gauss_oos.ks,8))  | $(lpad(m_gauss_is.kurt,6)) | $(lpad(m_gauss_oos.kurt,7))  | $(m_gauss_is.acf_mae) | $(m_gauss_is.w1) | $(m_gauss_is.hell)")
println("Laplace       | $(lpad(m_lap_is.ks,7)) | $(lpad(m_lap_oos.ks,8))  | $(lpad(m_lap_is.kurt,6)) | $(lpad(m_lap_oos.kurt,7))  | $(m_lap_is.acf_mae) | $(m_lap_is.w1) | $(m_lap_is.hell)")
println("="^90)
println("Observed kurtosis: IS=$(round(kurt_obs_is,digits=2)), OoS=$(round(kurt_obs_oos,digits=2))")

# Save
mkpath(joinpath(RESULTS_DIR, TICKER));
open(joinpath(RESULTS_DIR, TICKER, "Table-2-Baselines.txt"), "w") do io
    println(io, "Table 2: Baseline Model Comparison — $TICKER ($N_PATHS paths, α=0.05)")
    println(io, "="^100)
    println(io, "")
    println(io, "               | KS IS (%) | KS OoS (%) | Kurt IS (sim) | Kurt OoS (sim) | ACF-MAE  | W1 IS   | Hellinger IS")
    println(io, "-"^100)
    println(io, "Observed       |           |            | $(lpad(kurt_obs_is,12)) | $(lpad(kurt_obs_oos,13))  |          |         |")
    println(io, "Bootstrap      | $(lpad(m_boot_is.ks,8)) | $(lpad(m_boot_oos.ks,9))  | $(lpad(m_boot_is.kurt,12)) | $(lpad(m_boot_oos.kurt,13))  | $(lpad(m_boot_is.acf_mae,7)) | $(lpad(m_boot_is.w1,6))  | $(m_boot_is.hell)")
    println(io, "Gaussian i.i.d.| $(lpad(m_gauss_is.ks,8)) | $(lpad(m_gauss_oos.ks,9))  | $(lpad(m_gauss_is.kurt,12)) | $(lpad(m_gauss_oos.kurt,13))  | $(lpad(m_gauss_is.acf_mae,7)) | $(lpad(m_gauss_is.w1,6))  | $(m_gauss_is.hell)")
    println(io, "Laplace i.i.d. | $(lpad(m_lap_is.ks,8)) | $(lpad(m_lap_oos.ks,9))  | $(lpad(m_lap_is.kurt,12)) | $(lpad(m_lap_oos.kurt,13))  | $(lpad(m_lap_is.acf_mae,7)) | $(lpad(m_lap_is.w1,6))  | $(m_lap_is.hell)")
    println(io, "="^100)
end

# ========================================================================================= #
# PART 2: CROSS-ASSET GENERALIZATION (Table T2)
# ========================================================================================= #
println("\n" * "="^70)
println("PART 2: Cross-Asset Generalization (K=$K)")
println("="^70)

cross_tickers = ["NVDA", "JNJ", "JPM"];

open(joinpath(RESULTS_DIR, TICKER, "Table-T2-Cross-Asset.txt"), "w") do io
    println(io, "Table T2: Cross-Asset Generalization (K=$K, $N_PATHS paths, α=0.05)")
    println(io, "="^100)
    println(io, "Ticker | Model   | KS IS (%) | KS OoS (%) | Kurt Obs | Kurt Sim | ACF-MAE  | W1 IS")
    println(io, "-"^100)

    for t in cross_tickers
        println("  Processing $t...")

        # Get returns
        t_idx = findfirst(x -> x == t, list_of_all_tickers);
        if isnothing(t_idx); println("  $t not found, skipping."); continue; end
        R_t_is = all_R[:, t_idx];

        if !haskey(oos_dataset, t); println("  $t OoS not available, skipping."); continue; end
        R_t_oos = log_growth_matrix(oos_dataset, t; Δt=ΔT, risk_free_rate=RISK_FREE_RATE);

        n_t_is = length(R_t_is); n_t_oos = length(R_t_oos);
        μ_t = mean(R_t_is); σ_t = std(R_t_is);
        kurt_t_obs = sum(((R_t_is .- μ_t) ./ σ_t).^4) / n_t_is - 3.0;

        # Train base model
        base = build(MyContinuousHiddenMarkovModel, (
            observations=R_t_is, number_of_states=K, max_iter=MAX_ITER));

        # Stationary distribution
        T_mat = zeros(K, K);
        for i in 1:K; T_mat[i, :] = probs(base.transition[i]); end
        π_stat = (T_mat^1000)[1, :];
        start_dist = Categorical(π_stat);

        # Grid search (small grid for speed)
        best_ε = 1e-4; best_λ = 100.0; best_J = Inf;
        acf_t_obs = autocor(abs.(R_t_is), 1:L);
        for ε in [1e-4, 1e-3, 1e-2]
            for λ in [30, 70, 100, 130]
                jm_test = build(MyContinuousHiddenMarkovModelWithJumps, (
                    base_model=base, epsilon=ε, lambda=Float64(λ)));
                acf_sum = zeros(L);
                for p in 1:100
                    s0 = rand(start_dist);
                    states = jm_test(s0, n_t_is);
                    returns = [rand(jm_test.emission[s]) for s in states];
                    acf_sum .+= autocor(abs.(returns), 1:L);
                end
                acf_sim = acf_sum ./ 100;
                J = sum((acf_t_obs .- acf_sim).^2);
                if J < best_J; best_J = J; best_ε = ε; best_λ = λ; end
            end
        end

        # Build models
        jm = build(MyContinuousHiddenMarkovModelWithJumps, (
            base_model=base, epsilon=best_ε, lambda=Float64(best_λ)));

        # Simulate and evaluate
        for (name, m) in [("CHMM-NJ", base), ("CHMM-WJ", jm)]
            sim_is = Array{Float64,2}(undef, n_t_is, N_PATHS);
            sim_oos = Array{Float64,2}(undef, n_t_oos, N_PATHS);
            for i in 1:N_PATHS
                s0 = rand(start_dist);
                states_is = m(s0, n_t_is);
                for j in 1:n_t_is; sim_is[j,i] = rand(m.emission[states_is[j]]); end
                s0 = rand(start_dist);
                states_oos = m(s0, n_t_oos);
                for j in 1:n_t_oos; sim_oos[j,i] = rand(m.emission[states_oos[j]]); end
            end
            m_is = eval_full(R_t_is, sim_is);
            m_oos = eval_full(R_t_oos, sim_oos);

            line = "$(rpad(t,6)) | $(rpad(name,7)) | $(lpad(m_is.ks,8)) | $(lpad(m_oos.ks,9))  | $(lpad(round(kurt_t_obs,digits=1),7))  | $(lpad(m_is.kurt,7))  | $(lpad(m_is.acf_mae,7)) | $(m_is.w1)"
            println("    $line")
            println(io, line)
        end
    end
    println(io, "="^100)
end

println("\nDone. Results saved to $(joinpath(RESULTS_DIR, TICKER))")
