use aiken/builtin
use aiken/collection/list
use utils.{optimized_drop_n}

fn drop_n_maker(n: Int) -> fn(List<a>) -> List<a> {
  if n == 0 {
    identity
  } else {
    fn(list: List<a>) { drop_n_maker(n - 1)(list) |> builtin.tail_list }
  }
}

const drop_30: fn(List<Data>) -> List<Data> = drop_n_maker(30)

const drop_20: fn(List<Data>) -> List<Data> = drop_n_maker(20)

const drop_10: fn(List<Data>) -> List<Data> = drop_n_maker(10)

pub fn do_list_length_fast(
  xs: List<Data>,
  remaining_expected: Int,
  count_so_far: Int,
) -> Int {
  if remaining_expected >= 30 {
    do_list_length_fast(
      xs |> drop_30,
      remaining_expected - 30,
      count_so_far + 30,
    )
  } else if remaining_expected >= 20 {
    do_list_length_fast(
      xs |> drop_20,
      remaining_expected - 20,
      count_so_far + 20,
    )
  } else if remaining_expected >= 10 {
    do_list_length_fast(
      xs |> drop_10,
      remaining_expected - 10,
      count_so_far + 10,
    )
  } else {
    expect list.is_empty(optimized_drop_n(xs, remaining_expected))
    remaining_expected + count_so_far
  }
}

pub fn list_length_fast(xs: List<Data>, expected_length: Int) -> Int {
  do_list_length_fast(xs, expected_length, 0)
}

const x = ["a", "b", "c", "d", "e", "f", "g", "h", "i"]

const x_data: Data = x

const x_list_data: List<Data> = builtin.un_list_data(x_data)

test success__stdlib() {
  list.length(x) == 9
}

test success__list_length_fast() {
  list_length_fast(x_list_data, 9) == 9
}
