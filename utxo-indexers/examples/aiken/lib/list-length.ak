use aiken/builtin
use aiken/collection/list
use utils.{optimized_drop_n}

/// Note that with lists smaller than 4 elements the overhead thwarts the
/// benefits.
pub fn list_length_fast_easy(xs: List<a>, expected_length: Int) -> Int {
  expect optimized_drop_n(xs, expected_length) == []
  expected_length
}

fn drop_30_hard(xs: List<a>) -> List<a> {
  xs
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
}

fn drop_20_hard(xs: List<a>) -> List<a> {
  xs
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
}

fn drop_10_hard(xs: List<a>) -> List<a> {
  xs
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
    |> builtin.tail_list
}

pub fn do_list_length_faster_hard(
  xs: List<a>,
  remaining_expected: Int,
  count_so_far: Int,
) -> Int {
  if remaining_expected >= 30 {
    do_list_length_faster_hard(
      xs |> drop_30_hard,
      remaining_expected - 30,
      count_so_far + 30,
    )
  } else if remaining_expected >= 20 {
    do_list_length_faster_hard(
      xs |> drop_20_hard,
      remaining_expected - 20,
      count_so_far + 20,
    )
  } else if remaining_expected >= 10 {
    do_list_length_faster_hard(
      xs |> drop_10_hard,
      remaining_expected - 10,
      count_so_far + 10,
    )
  } else {
    expect optimized_drop_n(xs, remaining_expected) == []
    remaining_expected + count_so_far
  }
}

/// Another implementations that is slightly faster than `list_length_fast_easy`
/// for long lists. It has more overhead, so compared to stdlib's `list.length`
/// it'll be effective for lists longer than 8 elements (and 20 elements
/// compared to `list_length_fast_easy`).
pub fn list_length_faster_hard(xs: List<a>, expected_length: Int) -> Int {
  do_list_length_faster_hard(xs, expected_length, 0)
}

fn drop_n_maker(n: Int) -> fn(List<a>) -> List<a> {
  if n == 0 {
    identity
  } else {
    fn(list: List<a>) { drop_n_maker(n - 1)(list) |> builtin.tail_list }
  }
}

const drop_30_easy: fn(List<Data>) -> List<Data> = drop_n_maker(30)

const drop_20_easy: fn(List<Data>) -> List<Data> = drop_n_maker(20)

const drop_10_easy: fn(List<Data>) -> List<Data> = drop_n_maker(10)

pub fn do_list_length_not_fast_easy(
  xs: List<Data>,
  remaining_expected: Int,
  count_so_far: Int,
) -> Int {
  if remaining_expected >= 30 {
    do_list_length_not_fast_easy(
      xs |> drop_30_easy,
      remaining_expected - 30,
      count_so_far + 30,
    )
  } else if remaining_expected >= 20 {
    do_list_length_not_fast_easy(
      xs |> drop_20_easy,
      remaining_expected - 20,
      count_so_far + 20,
    )
  } else if remaining_expected >= 10 {
    do_list_length_not_fast_easy(
      xs |> drop_10_easy,
      remaining_expected - 10,
      count_so_far + 10,
    )
  } else {
    expect optimized_drop_n(xs, remaining_expected) == []
    remaining_expected + count_so_far
  }
}

/// Another implementation to showcase how with Aiken's `const` optimizations
/// we won't get better results compared to handwriting `drop_n` helpers.
pub fn list_length_not_fast_easy(xs: List<Data>, expected_length: Int) -> Int {
  do_list_length_not_fast_easy(xs, expected_length, 0)
}

const x =
  [
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o",
    "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
  ]

const y = x |> list.take(4)

const z = x |> list.take(8)

const r = x |> list.take(20)

test success__stdlib__4() {
  list.length(y) == 4
}

test success__list_length_fast_easy__4() {
  list_length_fast_easy(y, 4) == 4
}

test success__stdlib__8() {
  list.length(z) == 8
}

test success__list_length_fast_easy__8() {
  list_length_fast_easy(z, 8) == 8
}

test success__list_length_faster_hard__8() {
  list_length_faster_hard(z, 8) == 8
}

test success__list_length_fast_easy__20() {
  list_length_fast_easy(r, 20) == 20
}

test success__list_length_faster_hard__20() {
  list_length_faster_hard(r, 20) == 20
}

test success__stdlib__26() {
  list.length(x) == 26
}

test success__list_length_fast_easy__26() {
  list_length_fast_easy(x, 26) == 26
}

test success__list_length_faster_hard__26() {
  list_length_faster_hard(x, 26) == 26
}

const x_as_data: Data = x

const x_data: List<Data> = builtin.un_list_data(x_as_data)

test success__list_length_not_fast_easy__26() {
  list_length_not_fast_easy(x_data, 26) == 26
}
