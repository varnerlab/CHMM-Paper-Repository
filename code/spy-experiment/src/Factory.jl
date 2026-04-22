# --- DISCRETE MODEL BUILDERS (Baseline Comparison) --------------------------- #

"""
    build(model::Type{MyHiddenMarkovModel}, data::NamedTuple) -> MyHiddenMarkovModel

Builds a discrete HMM from provided transition and emission matrices.

### NamedTuple keys
- `states::Array{Int64,1}`: State indices
- `T::Array{Float64,2}`: Transition matrix [K x K]
- `E::Array{Float64,2}`: Emission matrix [K x M]
"""
function build(model::Type{MyHiddenMarkovModel}, data::NamedTuple)::MyHiddenMarkovModel

    m = model();
    transition = Dict{Int64, Categorical}();
    emission = Dict{Int64, Categorical}();

    states = data.states;
    T = data.T;
    E = data.E;

    for s ∈ states
        transition[s] = Categorical(T[s,:]);
        emission[s] = Categorical(E[s,:]);
    end

    m.transition = transition;
    m.emission = emission;
    m.states = states;

    return m;
end


"""
    build(model::Type{MyHiddenMarkovModelWithJumps}, data::NamedTuple) -> MyHiddenMarkovModelWithJumps

Builds a discrete HMM with Poisson jump process (baseline from discrete paper).

### NamedTuple keys
- `states::Array{Int64,1}`: State indices
- `T::Array{Float64,2}`: Transition matrix [K x K]
- `E::Array{Float64,2}`: Emission matrix [K x M]
- `ϵ::Float64`: Jump probability
- `λ::Float64`: Jump duration rate (Poisson parameter)
"""
function build(model::Type{MyHiddenMarkovModelWithJumps}, data::NamedTuple)::MyHiddenMarkovModelWithJumps

    m = model();
    transition = Dict{Int64, Categorical}();
    inverse_transition = Dict{Int64, Categorical}();
    emission = Dict{Int64, Categorical}();
    ϵ = data.ϵ;
    λ = data.λ;

    states = data.states;
    T = data.T;
    E = data.E;

    for s ∈ states
        transition[s] = Categorical(T[s,:]);
        emission[s] = Categorical(E[s,:]);
    end

    for s ∈ states
        F = sum(1 .- T[s,:]);
        d = (1/F)*(1 .- T[s,:]);
        inverse_transition[s] = Categorical(d);
    end

    m.transition = transition;
    m.inverse_transition = inverse_transition;
    m.emission = emission;
    m.states = states;
    m.ϵ = ϵ;
    m.λ = λ;
    m.jump_distribution = Poisson(λ);

    return m;
end


# --- CONTINUOUS MODEL BUILDERS ----------------------------------------------- #

"""
    build(model::Type{MyContinuousHiddenMarkovModel}, data::NamedTuple) -> MyContinuousHiddenMarkovModel

This `build` method constructs and trains a `MyContinuousHiddenMarkovModel` instance using the Baum-Welch algorithm. The model's emission probabilities are modeled by Normal distributions.

### Arguments
- `model::Type{MyContinuousHiddenMarkovModel}`: The type of model to build.
- `data::NamedTuple`: The data for training the model.

The `data` NamedTuple must contain the following keys:
- `observations::Vector{Float64}`: A vector of floating-point observations.
- `number_of_states::Int`: The number of hidden states in the model.

### Returns
- A fully trained `MyContinuousHiddenMarkovModel` instance with transition and emission distributions learned from the data.
"""
function build(model::Type{MyContinuousHiddenMarkovModel}, data::NamedTuple)::MyContinuousHiddenMarkovModel
    
    # Extract training data
    obs = data.observations
    n_states = data.number_of_states
    
    # Check if max_iter is provided in the data, otherwise default to 30
    max_iterations = haskey(data, :max_iter) ? data.max_iter : 30
    
    # Pass max_iterations to the baum_welch function
    T_matrix, μ_vec, σ_vec, π_vec, ll_hist, γ = baum_welch(obs, n_states, max_iter=max_iterations)
    
    # Initialize an empty model instance
    m = model()

    # ... (rest of the function remains exactly the same) ...
    m.states = collect(1:n_states)
    m.log_likelihood_history = ll_hist
    
    transition = Dict{Int64, Categorical}()
    emission = Dict{Int64, Normal}()
    
    for s in 1:n_states
        transition[s] = Categorical(T_matrix[s, :])
        emission[s] = Normal(μ_vec[s], σ_vec[s])
    end
    
    m.transition = transition
    m.emission = emission
    
    return m
end


# --- GARCH MODEL BUILDER ----------------------------------------------------- #

"""
    build(model::Type{MyGARCHModel}, data::NamedTuple) -> MyGARCHModel

Fits a GARCH(1,1) model via maximum likelihood estimation.
σ²_t = ω + α * r²_{t-1} + β * σ²_{t-1}

### NamedTuple keys
- `observations::Vector{Float64}`: Return series (same scale as HMM data)
"""
function build(model::Type{MyGARCHModel}, data::NamedTuple)::MyGARCHModel

    obs = data.observations;
    ω, α, β, μ, σ2_hist, ll = _fit_garch11(obs);

    m = model();
    m.ω = ω;
    m.α = α;
    m.β = β;
    m.μ = μ;
    m.σ2_history = σ2_hist;
    m.log_likelihood = ll;

    return m;
end

# ----------------------------------------------------------------------------- #


# --- BAYESIAN MODEL BUILDERS ------------------------------------------------- #

"""
    build_turing_model(::StudentTModel, data::Vector{Float64})

Builds a Turing.jl probabilistic model for data assumed to follow a Student's t-distribution. This is useful for Bayesian inference of the distribution's parameters.

### Arguments
- `::StudentTModel`: A type instance to dispatch to this method.
- `data::Vector{Float64}`: A vector of observations.

### Returns
- A Turing model instance, ready for sampling/inference.

### Model Priors
- `σ`: Scale parameter (standard deviation), drawn from a truncated Cauchy distribution. This is a weakly informative prior.
- `μ`: Location parameter (mean), drawn from a Normal distribution centered at 0.
- `ν`: Degrees of freedom, drawn from an Exponential distribution. This prior favors smaller values of `ν`, accommodating heavy tails.
"""
function build_turing_model(::StudentTModel, data)
    @model function student_t_model(obs)
        # Priors for the distribution parameters
        σ ~ Distributions.Truncated(Distributions.Cauchy(0, 1), 0, Inf) # Scale parameter
        μ ~ Distributions.Normal(0, 0.1)      # Location parameter
        ν ~ Distributions.Exponential(1/30.0) # Degrees of freedom

        # Likelihood: The observations are modeled as a scaled and shifted Student's t-distribution
        obs .~ Distributions.TDist(ν) * σ .+ μ
    end
    return student_t_model(data)
end


"""
    build_turing_model(::LaplaceModel, data::Vector{Float64})

Builds a Turing.jl probabilistic model for data assumed to follow a Laplace (double exponential) distribution.

### Arguments
- `::LaplaceModel`: A type instance to dispatch to this method.
- `data::Vector{Float64}`: A vector of observations.

### Returns
- A Turing model instance, ready for sampling/inference.

### Model Priors
- `μ`: Location parameter (mean), drawn from a Normal distribution centered at 0.
- `b`: Scale parameter, drawn from an Exponential distribution.
"""
function build_turing_model(::LaplaceModel, data)
    @model function laplace_model(obs)
        # Priors for the distribution parameters
        μ ~ Distributions.Normal(0, 0.1)  # Location parameter
        b ~ Distributions.Exponential(1.0) # Scale parameter

        # Likelihood: The observations are modeled as a Laplace distribution
        obs .~ Distributions.Laplace(μ, b)
    end
    return laplace_model(data)
end

# --------------------------------------------------------------------------------------------- #


