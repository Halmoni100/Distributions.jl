using Distributions
using Base.Test

# Set location vector mu and scale matrix Sigma as in
# Hofert M. On Sampling from the Multivariate t Distribution. The R Journal
mu = [1., 2]
Sigma = [4. 2; 2 3]

# LogPDF evaluation for varying degrees of freedom df
# Julia's output is compared to R's corresponding values obtained via R's mvtnorm package
# R code exemplifying how the R values (rvalues) were obtained:
# options(digits=20)
# library("mvtnorm")
# mu <- 1:2
# Sigma <- matrix(c(4, 2, 2, 3), ncol=2)
# dmvt(c(-2., 3.), delta=mu, sigma=Sigma, df=1)
rvalues = [-5.6561739738159975133,
  -5.4874952805811396672,
  -5.4441948098568158088,
  -5.432461875138580254,
  -5.4585441614404803801]
df = [1., 2, 3, 5, 10]
for i = 1:length(df)
  d = MvTDist(df[i], mu, Sigma)
  @test_approx_eq_eps logpdf(d, [-2., 3]) rvalues[i] 1.0e-8
  dd = typeof(d)(params(d)...)
  @test d.df == dd.df
  @test full(d.μ) == full(dd.μ)
  @test full(d.Σ) == full(dd.Σ)
end
