///|
/// The field references used by a contract's rules.
pub(all) struct ContractReferences {
  referenced_fields : Array[String]
  missing_fields : Array[String]
  unused_fields : Array[String]
} derive(Eq, Debug)

///|
/// Analyze rule-to-field dependencies before executing a contract.
pub fn analyze_contract_references(contract : Contract) -> ContractReferences {
  let referenced_fields = []
  for rule in contract.rules {
    for field in rule_field_references(rule) {
      if !referenced_fields.contains(field) {
        referenced_fields.push(field)
      }
    }
  }
  referenced_fields.sort()
  let declared_fields = contract_field_names(contract)
  let missing_fields = referenced_fields.filter(fn(field) {
    !declared_fields.contains(field)
  })
  let unused_fields = declared_fields.filter(fn(field) {
    !referenced_fields.contains(field)
  })
  { referenced_fields, missing_fields, unused_fields }
}

///|
/// Return the fields a rule reads, preserving the rule's declaration order.
pub fn rule_field_references(rule : Rule) -> Array[String] {
  match rule {
    Unique(fields~, ..) => deduplicate_fields(fields)
    Completeness(field~, ..) => [field]
    Enum(field~, ..) => [field]
    IntRange(field~, ..) => [field]
    CompareInts(left~, right~, ..) => deduplicate_fields([left, right])
    PatternMatch(field~, ..) => [field]
    StringLength(field~, ..) => [field]
    DistinctCount(field~, ..) => [field]
    RequiredIf(condition_field~, field~, ..) =>
      deduplicate_fields([condition_field, field])
    RowCount(..) => []
  }
}

///|
fn deduplicate_fields(fields : Array[String]) -> Array[String] {
  let result = []
  for field in fields {
    if !result.contains(field) {
      result.push(field)
    }
  }
  result
}
