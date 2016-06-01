doc"""
    Exponential(θ)

The *Exponential distribution* with scale parameter `θ` has probability density function

$f(x; \theta) = \frac{1}{\theta} e^{-\frac{x}{\theta}}, \quad x > 0$

```julia
Exponential()      # Exponential distribution with unit scale, i.e. Exponential(1.0)
Exponential(b)     # Exponential distribution with scale b

params(d)          # Get the parameters, i.e. (b,)
scale(d)           # Get the scale parameter, i.e. b
rate(d)            # Get the rate parameter, i.e. 1 / b
```

External links

* [Exponential distribution on Wikipedia](http://en.wikipedia.org/wiki/Exponential_distribution)

"""
immutable Exponential{T <: Real} <: ContinuousUnivariateDistribution
    θ::T		# note: scale not rate

    Exponential(θ::Real) = (@check_args(Exponential, θ > zero(θ)); new(θ))
end

Exponential{T <: Real}(Θ::T) = Exponential{T}(Θ)
Exponential(Θ::Int) = Exponential(Float64(Θ))
Exponential() = Exponential(1.0)

@distr_support Exponential 0.0 Inf

### Conversions
convert{T <: Real, S <: Real}(::Type{Exponential{T}}, Θ::S) = Exponential(T(Θ))
convert{T <: Real, S <: Real}(::Type{Exponential{T}}, d::Exponential{S}) = Exponential(T(d.Θ))


#### Parameters

scale(d::Exponential) = d.θ
rate(d::Exponential) = 1.0 / d.θ

params(d::Exponential) = (d.θ,)


#### Statistics

mean(d::Exponential) = d.θ
median(d::Exponential) = logtwo * d.θ
mode(d::Exponential) = 0.0

var(d::Exponential) = d.θ^2
skewness(d::Exponential) = 2.0
kurtosis(d::Exponential) = 6.0

entropy(d::Exponential) = 1.0 + log(d.θ)


#### Evaluation

zval(d::Exponential, x::Real) = x / d.θ
xval(d::Exponential, z::Real) = z * d.θ

pdf(d::Exponential, x::Real) = (λ = rate(d); x < 0.0 ? zero(λ) : λ * exp(-λ * x))
logpdf(d::Exponential, x::Real) =  (λ = rate(d); x < 0.0 ? -Inf : log(λ) - λ * x)

cdf(d::Exponential, x::Real) = x > 0.0 ? -expm1(-zval(d, x)) : 0.0
ccdf(d::Exponential, x::Real) = x > 0.0 ? exp(-zval(d, x)) : 0.0
logcdf(d::Exponential, x::Real) = x > 0.0 ? log1mexp(-zval(d, x)) : -Inf
logccdf(d::Exponential, x::Real) = x > 0.0 ? -zval(d, x) : 0.0

quantile(d::Exponential, p::Real) = -xval(d, log1p(-p))
cquantile(d::Exponential, p::Real) = -xval(d, log(p))
invlogcdf(d::Exponential, lp::Real) = -xval(d, log1mexp(lp))
invlogccdf(d::Exponential, lp::Real) = -xval(d, lp)

gradlogpdf(d::Exponential, x::Real) = x > 0.0 ? -rate(d) : 0.0

mgf(d::Exponential, t::Real) = 1.0/(1.0 - t * scale(d))
cf(d::Exponential, t::Real) = 1.0/(1.0 - t * im * scale(d))


#### Sampling

rand(d::Exponential) = xval(d, randexp())


#### Fit model

immutable ExponentialStats <: SufficientStats
    sx::Float64   # (weighted) sum of x
    sw::Float64   # sum of sample weights

    ExponentialStats(sx::Real, sw::Real) = new(sx, sw)
end

suffstats{T<:Real}(::Type{Exponential}, x::AbstractArray{T}) = ExponentialStats(sum(x), length(x))
suffstats{T<:Real}(::Type{Exponential}, x::AbstractArray{T}, w::AbstractArray{Float64}) = ExponentialStats(dot(x, w), sum(w))

fit_mle(::Type{Exponential}, ss::ExponentialStats) = Exponential(ss.sx / ss.sw)
