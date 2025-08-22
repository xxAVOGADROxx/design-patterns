use aiken/collection/list
use utils.{optimized_drop_n}

/// Note that with lists smaller than 4 elements the overhead thwarts the
/// benefits.
pub fn list_length_fast(xs: List<a>, expected_length: Int) -> Int {
  expect optimized_drop_n(xs, expected_length) == []
  expected_length
}

const x =
  [
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o",
    "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
  ]

const y = x |> list.take(3)

test success__stdlib__26() {
  list.length(x) == 26
}

test success__list_length_fast__26() {
  list_length_fast(x, 26) == 26
}

test success__stdlib__3() {
  list.length(y) == 3
}

test success__list_length_fast__3() {
  list_length_fast(y, 3) == 3
}
