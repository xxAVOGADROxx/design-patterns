use aiken/builtin
use cardano/transaction.{Mint, OutputReference, Redeemer, ScriptPurpose, Spend}
use utils.{optimized_drop_n}

pub fn enforce_n_spend_redeemers(
  redeemers: Pairs<ScriptPurpose, Redeemer>,
  n: Int,
) -> Bool {
  // We know all `Spend` purposes are at the start of the `redeemers` list (as
  // it's ordered by the **ledger** redeemer tags, and `Spend` has the smallest,
  // defined [here](https://github.com/IntersectMBO/cardano-ledger/blob/02212d86ac2ba6300a2ed53989140bb8f54b7fc9/eras/conway/impl/cddl-files/conway.cddl#L693-L699])),
  // so by dropping `n - 1` first elements of it, we can validate that the head
  // of the remaining list **is** a `Spend`, and the head of its tail **is not**
  // a `Spend`.
  let last_spend_at_head = redeemers |> optimized_drop_n(n - 1)

  // The redeemer pair that we expect to be the last `Spend`.
  let last_spend = last_spend_at_head |> builtin.head_list

  // The list tail which we expect to be either empty, or its head be any script
  // purpose other than `Spend`.
  let no_spends = last_spend_at_head |> builtin.tail_list

  when last_spend.1st is {
    Spend(_) ->
      when no_spends is {
        [] -> True
        [first_non_spend, ..] ->
          when first_non_spend.1st is {
            Spend(_) -> False
            _ -> True
          }
      }
    _ -> False
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
/// While the tests show this function as more costly, it is of note that Aiken
/// does perform implicit coercions in other branches of validators, which are
/// not reflected in the test.
pub fn enforce_n_spend_redeemers_from_data(
  redeemers_data: Data<Pairs<ScriptPurpose, Redeemer>>,
  n: Int,
) -> Bool {
  let redeemers_pairs: Pairs<Data, Data> = builtin.un_map_data(redeemers_data)

  let last_spend_at_head = redeemers_pairs |> optimized_drop_n(n - 1)

  let last_spend = last_spend_at_head |> builtin.head_list

  let no_spends = last_spend_at_head |> builtin.tail_list

  if !is_non_spend(last_spend.1st) {
    when no_spends is {
      [] -> True
      [first_non_spend, ..] -> is_non_spend(first_non_spend.1st)
    }
  } else {
    False
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
