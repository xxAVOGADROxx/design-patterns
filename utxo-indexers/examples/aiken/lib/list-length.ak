use aiken/collection/list
use utils.{optimized_drop_n}

/// Note that with lists smaller than 4 elements the overhead thwarts the
/// benefits.
pub fn validate_list_length(xs: List<a>, expected_length: Int) -> Bool {
  optimized_drop_n(xs, expected_length) == []
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

test success__validate_list_length__26() {
  validate_list_length(x, 26)
}

test success__stdlib__3() {
  list.length(y) == 3
}

test success__validate_list_length__3() {
  validate_list_length(y, 3)
}
