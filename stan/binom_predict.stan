data {
  int<lower=0> N;
  int<lower=0, upper=N> n;
  int<lower=0> N_test;
}
parameters {
  real<lower=0, upper=1> theta;
}
model {
  theta ~ beta(2, 2);
  n ~ binomial(N, theta);
}
generated quantities {
  int<lower=0, upper=N_test> n_test = binomial_rng(N_test, theta);
}
