transformed data {
  // number of trials
  array[4] int N = {10, 100, 1000, 10000};

  // task accuracy
  real<lower=0, upper=1> theta = 0.46;
}
generated quantities {
  // simulate n[i] ~ binomial(N[i], theta)
  array[4] int n = binomial_rng(N, theta);
  
  // max likelihood estimate theta_hat[i] = n[i] / N[i]
  vector[4] theta_hat = to_vector(n) ./ to_vector(N);
}
