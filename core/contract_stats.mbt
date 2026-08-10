///|
pub(all) struct ContractStats {
  field_count : Int
  required_field_count : Int
  typed_field_count : Int
  rule_count : Int
  error_rule_count : Int
  warning_rule_count : Int
} derive(Eq, Debug)

///|
/// Return stable complexity indicators for documentation and review tooling.
pub fn contract_stats(contract : Contract) -> ContractStats {
  let mut required_field_count = 0
  let mut typed_field_count = 0
  for field in contract.fields {
    if field.required {
      required_field_count += 1
    }
    if field.kind != String {
      typed_field_count += 1
    }
  }
  let mut error_rule_count = 0
  let mut warning_rule_count = 0
  for rule in contract.rules {
    match severity_of(rule) {
      Error => error_rule_count += 1
      Warning => warning_rule_count += 1
    }
  }
  {
    field_count: contract.fields.length(),
    required_field_count,
    typed_field_count,
    rule_count: contract.rules.length(),
    error_rule_count,
    warning_rule_count,
  }
}
