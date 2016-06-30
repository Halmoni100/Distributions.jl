immutable NoncentralBeta{T <: Real} <: ContinuousUnivariateDistribution
    α::T
    β::T
    λ::T

    function NoncentralBeta(α::T, β::T, λ::T)
    	@check_args(NoncentralBeta, α > zero(α) && β > zero(β))
        @check_args(NoncentralBeta, λ >= zero(λ))
    	new(α, β, λ)
    end
end

NoncentralBeta{T <: Real}(α::T, β::T, λ::T) = NoncentralBeta{T}(α, β, λ)
NoncentralBeta(α::Real, β::Real, λ::Real) = NoncentralBeta(promote(α, β, λ)...)

@distr_support NoncentralBeta 0.0 1.0


### Parameters

params(d::NoncentralBeta) = (d.α, d.β, d.λ)


### Evaluation & Sampling

# TODO: add mean and var

@_delegate_statsfuns NoncentralBeta nbeta α β λ

function rand(d::NoncentralBeta)
    a = rand(NoncentralChisq(2.0 * d.α, d.β))
    b = rand(Chisq(2.0 * d.β))
    a / (a + b)
end
