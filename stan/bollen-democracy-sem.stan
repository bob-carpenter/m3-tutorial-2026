// Model translated from: Bollen, K. A. (1989). Structural Equations
// with Latent Variables. New York: Wiley.

// original paper: Bollen, K. A. (1979). "Political Democracy and the
// Timing of Development."  American Sociological Review, 44(4),
// 572–587.

// AI assist from: Claude Opus 4.8 (hard thinking)

// CSV data from: Fox, J., Nie, Z., & Byrnes, J. (2024). sem:
// Structural Equation Models. R
// package. https://CRAN.R-project.org/package=sem

// Repackaged data from: Arel-Bundock, V. (2024). Rdatasets: A
// collection of datasets originally distributed in R
// packages. https://github.com/vincentarelbundock/Rdatasets

functions {
  // Cholesky factor of a 2x2 residual covariance from two SDs and a correlation.
  matrix chol_cov2(real sigma_a, real sigma_b, real rho) {
    matrix[2, 2] L = rep_matrix(0, 2, 2);
    L[1, 1] = sigma_a;
    L[2, 1] = sigma_b * rho;
    L[2, 2] = sigma_b * sqrt(1 - square(rho));
    return L;
  }

  // Per-case means for a 2-indicator block:
  //   indicator 1 = l_a * f_a ,  indicator 2 = l_b * f_b
  array[] vector mu2(vector f_a, vector f_b, real l_a, real l_b) {
    int N = num_elements(f_a);
    array[N] vector[2] mu;
    for (n in 1 : N)
      mu[n] = [l_a * f_a[n], l_b * f_b[n]]';
    return mu;
  }

  // Per-case means for the 4-indicator box block:
  //   ind 1,2 load on eta_a ; ind 3,4 load on eta_b
  array[] vector mu4(vector eta_a, vector eta_b,
                     real l1, real l2, real l3, real l4) {
    int N = num_elements(eta_a);
    array[N] vector[4] mu;
    for (n in 1 : N)
      mu[n] = [l1 * eta_a[n], l2 * eta_a[n],
               l3 * eta_b[n], l4 * eta_b[n]]';
    return mu;
  }
}
data {
  int<lower=1> N;
  matrix[N, 3] x;  // centered
  matrix[N, 8] y;  // centered
}
transformed data {
  // x with independent errors -> keep as columns
  vector[N] x1 = x[ , 1];
  vector[N] x2 = x[ , 2];
  vector[N] x3 = x[ , 3];

  // y regrouped into its correlated-error blocks
  array[N] vector[2] y_15;     // (y1, y5)
  array[N] vector[2] y_37;     // (y3, y7)
  array[N] vector[4] y_2468;   // (y2, y4, y6, y8)

  for (n in 1 : N) {
    y_15[n] = [y[n, 1], y[n, 5]]';
    y_37[n] = [y[n, 3], y[n, 7]]';
    y_2468[n] = [y[n, 2], y[n, 4], y[n, 6], y[n, 8]]';
  }
}
parameters {
  // latent variables (per case)
  vector[N] xi;
  vector[N] eta1;
  vector[N] eta2;

  // structural coefficients
  vector[2] gamma;   // gamma[1]: xi->eta1 , gamma[2]: xi->eta2
  real beta;         // eta1 -> eta2

  // free loadings (anchors x1, y1, y5 fixed at 1)
  vector[2] lambda_x;   // x2, x3
  vector[6] lambda_y;   // y2,y3,y4 (on eta1) ; y6,y7,y8 (on eta2)

  // latent scales / disturbances
  real<lower=0> sigma_xi;          // sqrt(phi)
  vector<lower=0>[2] sigma_zeta;   // disturbances of eta1, eta2

  // measurement-error SDs
  vector<lower=0>[3] sigma_delta;     // delta (x errors)
  vector<lower=0>[8] sigma_epsilon;   // epsilon (y errors)

  // residual correlations
  real<lower=-1, upper=1> rho_15;
  real<lower=-1, upper=1> rho_37;
  cholesky_factor_corr[4] L_2468;     // correlation Cholesky for the box
}
transformed parameters {
  // correlation matrix of the box block, needed for the soft zeros
  matrix[4, 4] Omega_2468 = multiply_lower_tri_self_transpose(L_2468);
}
model {
  sigma_xi ~ exponential(1);
  sigma_zeta ~ exponential(1);
  sigma_delta ~ exponential(1);
  sigma_epsilon ~ exponential(1);

  gamma ~ normal(0, 5);
  beta ~ normal(0, 5);
  lambda_x ~ normal(1, 1);
  lambda_y ~ normal(1, 1);

  L_2468 ~ lkj_corr_cholesky(2);
  // rho_15, rho_37 ~ uniform(-1, 1) implicitly from bounds

  // soft structural zeros on absent correlations
  Omega_2468[1, 4] ~ normal(0, 0.02);   // corr(eps2, eps8)
  Omega_2468[2, 3] ~ normal(0, 0.02);   // corr(eps4, eps6)

  // ---------- structural model (regressions in the latents) ----------
  xi ~ normal(0, sigma_xi);
  eta1 ~ normal(gamma[1] * xi, sigma_zeta[1]);
  eta2 ~ normal(gamma[2] * xi + beta * eta1, sigma_zeta[2]);

  // ---------- measurement model: x (independent errors) ----------
  x1 ~ normal(xi, sigma_delta[1]);
  x2 ~ normal(lambda_x[1] * xi, sigma_delta[2]);
  x3 ~ normal(lambda_x[2] * xi, sigma_delta[3]);

  // ---------- measurement model: y (correlated-error blocks) ----------
  // (y1, y5): anchors, loadings fixed at 1
  y_15 ~ multi_normal_cholesky(
           mu2(eta1, eta2, 1.0, 1.0),
           chol_cov2(sigma_epsilon[1], sigma_epsilon[5], rho_15));

  // (y3, y7)
  y_37 ~ multi_normal_cholesky(
           mu2(eta1, eta2, lambda_y[2], lambda_y[5]),
           chol_cov2(sigma_epsilon[3], sigma_epsilon[7], rho_37));

  // (y2, y4, y6, y8): box block, covariance = diag(sigma) * Omega * diag(sigma)
  // offset by 1 is because of 0-loading offset
  y_2468 ~ multi_normal_cholesky(
             mu4(eta1, eta2,
                 lambda_y[1], lambda_y[3],   // y2, y4 on eta1
                 lambda_y[4], lambda_y[6]),  // y6, y8 on eta2
             diag_pre_multiply(
               [sigma_epsilon[2], sigma_epsilon[4],
                sigma_epsilon[6], sigma_epsilon[8]]',
               L_2468));
}
generated quantities {
  real<lower=0> phi = square(sigma_xi);          // variance of xi
  real<lower=-1, upper=1> corr_eps_28 = Omega_2468[1, 4];  // should pin near 0
  real<lower=-1, upper=1> corr_eps_46 = Omega_2468[2, 3];  // should pin near 0
}
