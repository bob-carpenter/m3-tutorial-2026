data {
  int<lower=0> N;                       // # training obs
  vector[N] x;                          // training covariates
  vector[N] y;                          // training outcomes
  int<lower=0> N_new;                   // # test obs
  vector[N_new] x_new;                  // test covariates
}
parameters {
  real alpha;                           // intercept
  real beta;                            // slope
  real<lower=0> sigma;                  // error scale
}
model {
  { alpha, beta } ~ normal(0, 5);       // priors
  sigma ~ lognormal(0, 1);              // prior
  y ~ normal(alpha + beta * x, sigma);  // likelihod
}  
generated quantities {
  vector[N_new] y_new                   // test predictions
    = to_vector(normal_rng(alpha + beta * x_new, sigma));
}
