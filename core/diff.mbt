///|
pub fn diff_contracts(before : Contract, after : Contract) -> ContractDiff {
  let before_map = field_map(before)
  let after_map = field_map(after)
  let added = []
  let removed = []
  let changed = []

  for field in after.fields {
    if !before_map.contains(field.name) {
      added.push(field.name)
    } else if before_map[field.name] != field {
      changed.push(field.name)
    }
  }

  for field in before.fields {
    if !after_map.contains(field.name) {
      removed.push(field.name)
    }
  }

  { added_fields: added, removed_fields: removed, changed_fields: changed }
}

///|
fn field_map(contract : Contract) -> Map[String, FieldSpec] {
  let result : Map[String, FieldSpec] = {}
  for field in contract.fields {
    result[field.name] = field
  }
  result
}
