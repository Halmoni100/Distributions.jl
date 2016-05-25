doc"""
    Pareto(α,θ)

The *Pareto distribution* with shape `α` and scale `θ` has probability density function

$f(x; \alpha, \theta) = \frac{\alpha \theta^\alpha}{x^{\alpha + 1}}, \quad x \ge \theta$

```julia
Pareto()            # Pareto distribution with unit shape and unit scale, i.e. Pareto(1.0, 1.0)
Pareto(a)           # Pareto distribution with shape a and unit scale, i.e. Pareto(a, 1.0)
Pareto(a, b)        # Pareto distribution with shape a and scale b

params(d)        # Get the parameters, i.e. (a, b)
shape(d)         # Get the shape parameter, i.e. a
scale(d)         # Get the scale parameter, i.e. b
```

External links
 * [Pareto distribution on Wikipedia](http://en.wikipedia.org/wiki/Pareto_distribution)

"""
immutable Pareto <: ContinuousUnivariateDistribution
    α::Float64
    θ::Float64

    function Pareto(α::Real, θ::Real)
        @check_args(Pareto, α > zero(α) && θ > zero(θ))
        new(α, θ)
    end
    Pareto(α::Real) = Pareto(α, 1.0)
    Pareto() = new(1.0, 1.0)
end

@distr_support Pareto d.θ Inf


#### Parameters

shape(d::Pareto) = d.α
scale(d::Pareto) = d.θ

params(d::Pareto) = (d.α, d.θ)


#### Statistics

mean(d::Pareto) = ((α, θ) = params(d); α > 1.0 ? α * θ / (α - 1.0) : Inf)
median(d::Pareto) = ((α, θ) = params(d); θ * 2.0 ^ (1.0 / α))
mode(d::Pareto) = d.θ

function var(d::Pareto)
    (α, θ) = params(d)
    α > 2.0 ? (θ^2 * α) / ((α - 1.0)^2 * (α - 2.0)) : Inf
end

function skewness(d::Pareto)
    α = shape(d)
    α > 3.0 ? ((2.0 * (1.0 + α)) / (α - 3.0)) * sqrt((α - 2.0) / α) : NaN
end

function kurtosis(d::Pareto)
    α = shape(d)
    α > 4.0 ? (6.0 * (α^3 + α^2 - 6.0 * α - 2.0)) / (α * (α - 3.0) * (α - 4.0)) : NaN
end

entropy(d::Pareto) = ((α, θ) = params(d); log(θ / α) + 1.0 / α + 1.0)


#### Evaluation

function pdf(d::Pareto, x::Float64)
    (α, θ) = params(d)
    x >= θ ? α * (θ / x)^α * (1.0 / x) : 0.0
end

function logpdf(d::Pareto, x::Float64)
    (α, θ) = params(d)
    x >= θ ? log(α) + α * log(θ) - (α + 1.0) * log(x) : -Inf
end

function ccdf(d::Pareto, x::Float64)
    (α, θ) = params(d)
    x >= θ ? (θ / x)^α : 1.0
end

cdf(d::Pareto, x::Float64) = 1.0 - ccdf(d, x)

function logccdf(d::Pareto, x::Float64)
    (α, θ) = params(d)
    x >= θ ? α * log(θ / x) : 0.0
end

logcdf(d::Pareto, x::Float64) = log1p(-ccdf(d, x))

cquantile(d::Pareto, p::Float64) = d.θ / p^(1.0 / d.α)
quantile(d::Pareto, p::Float64) = cquantile(d, 1.0 - p)


#### Sampling

rand(d::Pareto) = d.θ * exp(randexp() / d.α)


## Fitting

function fit_mle{T <: Real}(::Type{Pareto}, x::AbstractArray{T})
    # Based on
    # https://en.wikipedia.org/wiki/Pareto_distribution#Parameter_estimation

    θ = minimum(x)

    n = length(x)
    lθ = log(θ)
    temp1 = zero(T)
    for i=1:n
        temp1 += log(x[i]) - lθ
    end
    α = n/temp1

    return Pareto(α, θ)
end
