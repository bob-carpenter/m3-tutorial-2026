generated quantities {
  real<lower=-1, upper=1> x = uniform_rng(-1, 1);
  real<lower=-1, upper=1> y = uniform_rng(-1, 1);
  int<lower=0, upper=1> in_circle = hypot(x, y) <= 1;
  int<lower=0, upper=4> pi = 4 * in_circle;
}
