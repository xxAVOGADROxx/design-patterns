use aiken/builtin
use cardano/transaction.{Redeemer, ScriptPurpose}

/// We know the `Spend` constructor of `ScriptPurpose` has a tag of `1` based on
/// its definition:
/// ```aiken
/// pub type ScriptPurpose {
///   Mint(PolicyId)         // -> 0
///   Spend(OutputReference) // -> 1
///   Withdraw(Credential)   // -> 2
///   Publish { at: Index, certificate: Certificate }
///   Vote(Voter)
///   Propose { at: Index, proposal_procedure: ProposalProcedure }
/// }
fn is_non_spend(script_purpose: Data<ScriptPurpose>) -> Bool {
  builtin.unconstr_index(script_purpose) != 0
}

fn drop_n_maker(n: Int) -> fn(List<a>) -> List<a> {
  if n == 0 {
    identity
  } else {
    fn(list: List<a>) { drop_n_maker(n - 1)(list) |> builtin.tail_list }
  }
}

pub fn enforce_n_spend_redeemers(
  redeemers: Pairs<ScriptPurpose, Redeemer>,
  n: Int,
) -> Bool {
  // Since we expect `n` 
  let last_spend_at_head = redeemers |> drop_n_maker(n - 1)
  let last_spend = last_spend_at_head |> builtin.head_list
  let no_spends = last_spend_at_head |> builtin.tail_list
  let first_non_spend = no_spends |> builtin.head_list
  and {
    !is_non_spend(last_spend),
    is_non_spend(first_non_spend),
  }
}
