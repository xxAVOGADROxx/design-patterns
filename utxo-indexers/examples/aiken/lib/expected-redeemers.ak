use aiken/builtin
use cardano/transaction.{Mint, OutputReference, Redeemer, ScriptPurpose, Spend}
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

/// We know the `Spend` constructor of `ScriptPurpose` has a tag of `1` based
/// on its definition:
/// ```aiken
/// pub type ScriptPurpose {
///   Mint(PolicyId)         // --> 0
///   Spend(OutputReference) // --> 1
///   Withdraw(Credential)   // --> 2
///   Publish { at: Index, certificate: Certificate }
///   Vote(Voter)
///   Propose { at: Index, proposal_procedure: ProposalProcedure }
/// }
/// ```
fn is_non_spend(script_purpose: Data<ScriptPurpose>) -> Bool {
  builtin.unconstr_index(script_purpose) != 1
}

/// Useful approach when working inside the `else` branch of a validator where
/// `redeemers` field is accessed as a `Data` (the `Pairs` phantom type is only
/// included for better readability and has no impact on the logic/performance).
///
/// While the test below shows this function as more costly, it is of note that
/// Aiken does perform implicit coercions in other branches of validators, which
/// are not reflected here.
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

const mock_out_ref: OutputReference =
  OutputReference { transaction_id: #"", output_index: 0 }

const x: Pairs<ScriptPurpose, Redeemer> =
  [
    Pair(Spend(mock_out_ref), builtin.i_data(0)),
    Pair(Spend(mock_out_ref), builtin.i_data(0)),
    Pair(Spend(mock_out_ref), builtin.i_data(0)),
    Pair(Spend(mock_out_ref), builtin.i_data(0)),
    Pair(Mint(#""), builtin.i_data(0)),
    Pair(Mint(#""), builtin.i_data(0)),
  ]

const x_data: Data = x

test success__enforce_n_spend_redeemers() {
  enforce_n_spend_redeemers(x, 4)
}

test success__enforce_n_spend_redeemers_data() {
  enforce_n_spend_redeemers_from_data(x_data, 4)
}
