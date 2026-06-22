data {
  int<lower=1> N;
  int<lower=1> G;
  vector[N] x;
  vector[N] y;
  array[N] int<lower=1, upper=G> group_id;
}
transformed data {
  real x_mean = mean(x);
  vector[N] x_c = x - x_mean;
}
parameters {
  real alpha;
  real beta;
  real<lower=0> sigma;
  vector[G] group_slope;
  real<lower=0> tau_slope;
}
transformed parameters {
  vector[N] mu;

  mu = alpha + (beta + group_slope[group_id]) .* x_c;
}
model {
  alpha ~ normal(mean(y), 2.5);
  beta ~ normal(0, 2.5);
  sigma ~ exponential(1);

  tau_slope ~ exponential(1);
  group_slope ~ normal(0, tau_slope);

  y ~ normal(mu, sigma);
}
generated quantities {
  vector[N] log_lik;
  real alpha_at_x0 = alpha - beta * x_mean;

  for (n in 1:N) {
    log_lik[n] = normal_lpdf(y[n] | mu[n], sigma);
  }
}
