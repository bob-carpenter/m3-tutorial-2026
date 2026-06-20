data {
  int<lower=0> N;                       // # matchups
  int<lower-0> J;                       // # items
  array[N] int<lower=1, upper=J> ii;    // first item
  array[N] int<lower=1, upper=J> jj;    // second item
  array[N] int<lower=0, upper=1> y;     // outcomes
}
parameters {
  vector[J] alpha;                      // abilities (log odds scale)
}
model {
  alpha ~ normal(0, 5);                        // prior
  y ~ bernoulli_logit(alpha[ii] - alpha[jj]);  // likelihood

  // equiv for (n in 1:N) y[n] ~ bernoulli_logit(alpha[ii[n]] - alpha[jj[n]]);
}  
