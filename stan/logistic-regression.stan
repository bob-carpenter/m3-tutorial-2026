data {
  int<lower=0> N;                       // # obs
  vector[N] x;                          // covariates
  array[N] int<lower=0, upper=1> y;     // outcomes
}
parameters {
  real alpha;                           // intercept
  real beta;                            // slope
}
model {
  alpha ~ normal(0, 5);                 // prior
  beta ~ normal(0, 5);                  // prior
  y ~ bernoulli_logit(alpha + beta * x);    // likelihod
}  
