data {
  int<lower=0> N;                       
  int<lower=1> K;                 // # covariates per outcome
  matrix[N, K] x;                 // data matrix, incl intercept column
  array[N] int<lower=0> y;              
}
parameters {
  vector[K] beta;                 // K slopes
}
model {
  beta ~ normal(0, 5);            // vectorized prior
  y ~ poisson_log(x * beta);      // vectorized likelihood
}  
