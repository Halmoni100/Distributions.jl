doc"""
    Logistic(μ,θ)

The *Logistic distribution* with location `μ` and scale `θ` has probability density function

$f(x; \mu, \theta) = \frac{1}{4 \theta} \mathrm{sech}^2
\left( \frac{x - \mu}{\theta} \right)$

```julia
Logistic()       # Logistic distribution with zero location and unit scale, i.e. Logistic(0.0, 1.0)
Logistic(u)      # Logistic distribution with location u and unit scale, i.e. Logistic(u, 1.0)
Logistic(u, b)   # Logistic distribution with location u ans scale b

params(d)       # Get the parameters, i.e. (u, b)
location(d)     # Get the location parameter, i.e. u
scale(d)        # Get the scale parameter, i.e. b
```

External links

* [Logistic distribution on Wikipedia](http://en.wikipedia.org/wiki/Logistic_distribution)

"""
immutable Logistic{T <: Real} <: ContinuousUnivariateDistribution
    μ::T
    θ::T

    Logistic(μ::T, θ::T) = (@check_args(Logistic, θ > zero(θ)); new(μ, θ))
end

Logistic{T <: Real}(μ::T, Θ::T) = Logistic{T}(μ, Θ)
Logistic(μ::Real, Θ::Real) = Logistic(promote(μ, ϴ)...)
Logistic(μ::Real) = Logistic(μ, 1.0)
Logistic() = Logistic(0.0, 1.0)

@distr_support Logistic -Inf Inf

#### Conversions
function convert{T <: Real, S <: Real}(::Type{Logistic{T}}, μ::S, Θ::S)
    Logistic(T(μ), T(Θ))
end
function convert{T <: Real, S <: Real}(::Type{Logistic{T}}, d::Logistic{S})
    Logistic(T(d.μ), T(d.Θ))
end

#### Parameters

location(d::Logistic) = d.μ
scale(d::Logistic) = d.θ

params(d::Logistic) = (d.μ, d.θ)


#### Statistics

mean(d::Logistic) = d.μ
median(d::Logistic) = d.μ
mode(d::Logistic) = d.μ

std(d::Logistic) = π * d.θ / sqrt3
var(d::Logistic) = (π * d.θ)^2 / 3.0
skewness(d::Logistic) = 0.0
kurtosis(d::Logistic) = 1.2

entropy(d::Logistic) = log(d.θ) + 2.0


#### Evaluation

zval(d::Logistic, x::Float64) = (x - d.μ) / d.θ
xval(d::Logistic, z::Float64) = d.μ + z * d.θ

pdf(d::Logistic, x::Float64) = (e = exp(-zval(d, x)); e / (d.θ * (1.0 + e)^2))
logpdf(d::Logistic, x::Float64) = (u = -abs(zval(d, x)); u - 2.0 * log1pexp(u) - log(d.θ))

cdf(d::Logistic, x::Float64) = logistic(zval(d, x))
ccdf(d::Logistic, x::Float64) = logistic(-zval(d, x))
logcdf(d::Logistic, x::Float64) = -log1pexp(-zval(d, x))
logccdf(d::Logistic, x::Float64) = -log1pexp(zval(d, x))

quantile(d::Logistic, p::Float64) = xval(d, logit(p))
cquantile(d::Logistic, p::Float64) = xval(d, -logit(p))
invlogcdf(d::Logistic, lp::Float64) = xval(d, -logexpm1(-lp))
invlogccdf(d::Logistic, lp::Float64) = xval(d, logexpm1(-lp))

function gradlogpdf(d::Logistic, x::Float64)
    e = exp(-zval(d, x))
    ((2.0 * e) / (1.0 + e) - 1.0) / d.θ
end

mgf(d::Logistic, t::Real) = exp(t * d.μ) / sinc(d.θ * t)

function cf(d::Logistic, t::Real)
    a = (π * t) * d.θ
    a == zero(a) ? complex(one(a)) : cis(t * d.μ) * (a / sinh(a))
end


#### Sampling

rand(d::Logistic) = quantile(d, rand())
