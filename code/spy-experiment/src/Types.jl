# --- ABSTRACT TYPES ---------------------------------------------------------- #
abstract type AbstractMarkovModel end
abstract type AbstractDistributionModel end
# ----------------------------------------------------------------------------- #


# --- DISCRETE MODELS (Baseline Comparison) ----------------------------------- #

"""
    mutable struct MyHiddenMarkovModel <: AbstractMarkovModel

Discrete HMM with categorical transition and emission distributions.
Used as the base for the discrete jump model (baseline comparison).

### Required fields
- `states::Array{Int64,1}`: The states of the model
- `transition::Dict{Int64, Categorical}`: Transition distributions per state
- `emission::Dict{Int64, Categorical}`: Emission distributions per state
"""
mutable struct MyHiddenMarkovModel <: AbstractMarkovModel

    # data -
    states::Array{Int64,1}
    transition::Dict{Int64, Categorical}
    emission::Dict{Int64, Categorical}

    # constructor -
    MyHiddenMarkovModel() = new();
end


"""
    mutable struct MyHiddenMarkovModelWithJumps <: AbstractMarkovModel

Discrete HMM augmented with Poisson jump process (regime teleportation).
This is the baseline model from the discrete paper for comparison.

### Required fields
- `states::Array{Int64,1}`: The states of the model
- `transition::Dict{Int64, Categorical}`: Transition distributions per state
- `inverse_transition::Dict{Int64, Categorical}`: Inverse transition (high-low reversed)
- `emission::Dict{Int64, Categorical}`: Emission distributions per state
- `ϵ::Float64`: Jump probability
- `λ::Float64`: Jump duration parameter (Poisson rate)
- `jump_distribution::Poisson`: Jump duration distribution
"""
mutable struct MyHiddenMarkovModelWithJumps <: AbstractMarkovModel

    # data -
    states::Array{Int64,1}
    transition::Dict{Int64, Categorical}
    inverse_transition::Dict{Int64, Categorical}; # high-low probability states reversed
    emission::Dict{Int64, Categorical}
    ϵ::Float64; # jump probability
    λ::Float64; # jump distribution parameter
    jump_distribution::Poisson; # jump distribution

    # constructor -
    MyHiddenMarkovModelWithJumps() = new();
end


# --- CONTINUOUS MODELS ------------------------------------------------------- #

"""
    mutable struct MyContinuousHiddenMarkovModel <: AbstractMarkovModel

The `MyContinuousHiddenMarkovModel` mutable struct represents a hidden Markov model (HMM) with continuous states and Gaussian emissions.

### Required fields
- `states::Array{Int64,1}`: The states of the model
- `transition::Dict{Int64, Categorical}`: The transition matrix of the model encoded as a dictionary where the `key` is the state and the `value` is a `Categorical` distribution
- `emission::Dict{Int64, Normal}`: The emission matrix of the model encoded as a dictionary where the `key` is the state and the `value` is a `Normal` distribution
- `log_likelihood_history::Array{Float64,1}`: The log likelihood history of the model
### Constructor
- `MyContinuousHiddenMarkovModel()`: Creates a new instance of the `MyContinuousHiddenMarkovModel` struct.
"""
mutable struct MyContinuousHiddenMarkovModel <: AbstractMarkovModel
    
    # data
    states::Array{Int64,1}
    transition::Dict{Int64, Categorical}
    # Emission here is a Normal distribution, not Categorical
    emission::Dict{Int64, Normal} 
    
    # We can store the EM history if we want
    log_likelihood_history::Array{Float64,1}

    # constructor
    MyContinuousHiddenMarkovModel() = new();
end


# --- GARCH MODEL ------------------------------------------------------------- #

"""
    mutable struct MyGARCHModel

GARCH(1,1) model for conditional variance modeling.
σ²_t = ω + α * r²_{t-1} + β * σ²_{t-1}

### Required fields
- `ω::Float64`: Constant (intercept), must be > 0
- `α::Float64`: ARCH coefficient (shock impact), must be ≥ 0
- `β::Float64`: GARCH coefficient (persistence), must be ≥ 0
- `μ::Float64`: Mean of the return process
- `σ2_history::Array{Float64,1}`: Fitted conditional variance series
- `log_likelihood::Float64`: Log-likelihood at MLE solution
"""
mutable struct MyGARCHModel

    ω::Float64;
    α::Float64;
    β::Float64;
    μ::Float64;
    σ2_history::Array{Float64,1};
    log_likelihood::Float64;

    MyGARCHModel() = new();
end
# ----------------------------------------------------------------------------- #


# --- DISTRIBUTION MODELS (Bayesian Inference) -------------------------------- #

"""
    struct StudentTModel <: AbstractDistributionModel

Dispatch tag for Bayesian Student's t-distribution fitting via Turing.jl.
Used with `build_turing_model` and `learn_distribution_mcmc`.
"""
struct StudentTModel <: AbstractDistributionModel end

"""
    struct LaplaceModel <: AbstractDistributionModel

Dispatch tag for Bayesian Laplace distribution fitting via Turing.jl.
Used with `build_turing_model` and `learn_distribution_mcmc`.
"""
struct LaplaceModel <: AbstractDistributionModel end
# ----------------------------------------------------------------------------- #


