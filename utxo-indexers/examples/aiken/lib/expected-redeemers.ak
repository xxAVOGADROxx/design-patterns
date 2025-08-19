use aiken/builtin
use cardano/transaction.{Redeemer, ScriptPurpose, Spend}
use utils.{optimized_drop_n}

pub fn enforce_n_spend_redeemers(
  redeemers: Pairs<ScriptPurpose, Redeemer>,
  n: Int,
) -> Bool {
  // We know all `Spend` purposes are at the start of the `redeemers` list (as
  // it's ordered by the redeemer tags, and `Spend` has the smallest), so by
  // dropping `n - 1` first elements of it, we can validate that the head of the
  // remaining list **is** a `Spend`, and the head of its tail **is not** a
  // `Spend`.
  let last_spend_at_head = redeemers |> optimized_drop_n(n - 1)

  // The redeemer pair that we expect to be the last `Spend`.
  let last_spend = last_spend_at_head |> builtin.head_list

  // The list tail which we expect its head not to be a `Spend`.
  let no_spends = last_spend_at_head |> builtin.tail_list

  let first_non_spend = no_spends |> builtin.head_list

  and {
    when last_spend.1st is {
      Spend(_) -> True
      _ -> False
    },
    when first_non_spend.1st is {
      Spend(_) -> False
      _ -> True
    },
  }
}

/// We know the `Spend` constructor of `ScriptPurpose` has a tag of `0` based
/// on:
/// https://github.com/IntersectMBO/cardano-ledger/blob/693218df6cd90263da24e6c2118bac420ceea3a1/eras/conway/impl/cddl-files/conway.cddl#L693-L699
fn is_non_spend(script_purpose: Data<ScriptPurpose>) -> Bool {
  builtin.unconstr_index(script_purpose) != 0
}

/// Useful approach when working inside the `else` branch of a validator where
/// `redeemers` field is accessed as a `Data` (the `Pairs` phantom type is only
/// included for better readability and has no impact on the logic/performance).
pub fn enforce_n_spend_redeemers_from_data(
  redeemers_data: Data<Pairs<ScriptPurpose, Redeemer>>,
  n: Int,
) -> Bool {
  let redeemers_pairs: Pairs<Data, Data> = builtin.un_map_data(redeemers_data)

  let last_spend_at_head = redeemers_pairs |> optimized_drop_n(n - 1)

  let last_spend = last_spend_at_head |> builtin.head_list

  let no_spends = last_spend_at_head |> builtin.tail_list

  let first_non_spend = no_spends |> builtin.head_list

  and {
    !is_non_spend(last_spend.1st),
    is_non_spend(first_non_spend.1st),
  }
}
