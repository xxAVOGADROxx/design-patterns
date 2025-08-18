use aiken/builtin

/// Borrowed from MicroProof's Bullet:
/// https://github.com/utxo-company/bullet/blob/92d0b4aea1296407fff58cd129705ce67b407dd9/lib/macros.ak#L137-L157
fn optimized_drop_n_helper(xs: List<a>, n: Int) -> List<a> {
  if n == 0 {
    xs
  } else {
    let n = n - 1
    let xs = builtin.tail_list(xs)
    if n == 0 {
      xs
    } else {
      let n = n - 1
      let xs = builtin.tail_list(xs)
      if n == 0 {
        xs
      } else {
        builtin.tail_list(xs)
      }
    }
  }
}

/// Borrowed from MicroProof's Bullet:
/// https://github.com/utxo-company/bullet/blob/92d0b4aea1296407fff58cd129705ce67b407dd9/lib/macros.ak#L124-L135
pub fn optimized_drop_n(xs: List<a>, n: Int) -> List<a> {
  if n < 4 {
    optimized_drop_n_helper(xs, n)
  } else {
    xs
      |> builtin.tail_list
      |> builtin.tail_list
      |> builtin.tail_list
      |> builtin.tail_list
      |> optimized_drop_n(n - 4)
  }
}

test success__optimized_drop_n() {
  let x = ["a", "b", "c", "d", "e", "f", "g", "h", "i"]

  let y = optimized_drop_n(x, 8)

  let g = optimized_drop_n(x, 8) |> builtin.head_list

  y == ["i"] && g == "i"
}

test success__manual_tail_lists() {
  let x = ["a", "b", "c", "d", "e", "f", "g", "h", "i"]

  let y =
    x
      |> builtin.tail_list
      |> builtin.tail_list
      |> builtin.tail_list
      |> builtin.tail_list
      |> builtin.tail_list
      |> builtin.tail_list
      |> builtin.tail_list
      |> builtin.tail_list

  let g =
    x
      |> builtin.tail_list
      |> builtin.tail_list
      |> builtin.tail_list
      |> builtin.tail_list
      |> builtin.tail_list
      |> builtin.tail_list
      |> builtin.tail_list
      |> builtin.tail_list
      |> builtin.head_list

  y == ["i"] && g == "i"
}
