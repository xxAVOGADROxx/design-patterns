use aiken/builtin
use aiken/collection/list
use utils.{optimized_drop_n}

/// Note that with lists smaller than 4 elements the overhead thwarts the
/// benefits.
pub fn validate_list_length(xs: List<Data>, expected_length: Int) -> Bool {
  optimized_drop_n(xs, expected_length) == []
}

const x =
  [
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o",
    "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
  ]

const x_data: Data = x

const x_list_data: List<Data> = builtin.un_list_data(x_data)

const y = x |> list.take(3)

const y_data: Data = y

const y_list_data: List<Data> = builtin.un_list_data(y_data)

test success__stdlib__26() {
  list.length(x) == 26
}

test success__validate_list_length__26() {
  validate_list_length(x_list_data, 26)
}

test success__stdlib__3() {
  list.length(y) == 3
}

test success__validate_list_length__3() {
  validate_list_length(y_list_data, 3)
}
