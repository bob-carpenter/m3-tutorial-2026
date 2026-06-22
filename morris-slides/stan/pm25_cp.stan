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
  matrix[2, G] group_coef;
  vector<lower=0>[2] tau;
  cholesky_factor_corr[2] L_Omega;
}
transformed parameters {
  matrix[2, 2] L_Sigma = diag_pre_multiply(tau, L_Omega);
  vector[N] mu;

  mu = alpha
    + to_vector(group_coef[1, group_id])
    + (beta + to_vector(group_coef[2, group_id])) .* x_c;
}
model {
  alpha ~ normal(mean(y), 2.5);
  beta ~ normal(0, 2.5);
  sigma ~ exponential(1);

  tau ~ exponential(1);
  L_Omega ~ lkj_corr_cholesky(2);

  for (g in 1:G) {
    group_coef[, g] ~ multi_normal_cholesky(rep_vector(0, 2), L_Sigma);
  }

  y ~ normal(mu, sigma);
}
generated quantities {
  vector[N] log_lik;
  corr_matrix[2] Omega = multiply_lower_tri_self_transpose(L_Omega);
  real alpha_at_x0 = alpha - beta * x_mean;

  for (n in 1:N) {
    log_lik[n] = normal_lpdf(y[n] | mu[n], sigma);
  }
}
