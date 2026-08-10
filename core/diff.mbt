///|
pub fn diff_contracts(before : Contract, after : Contract) -> ContractDiff {
  let before_map = field_map(before)
  let after_map = field_map(after)
  let added = []
  let removed = []
  let changed = []
  let before_rules = rule_map(before)
  let after_rules = rule_map(after)
  let added_rules = []
  let removed_rules = []
  let changed_rules = []

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

  for rule in after.rules {
    let name = rule_name(rule)
    if !before_rules.contains(name) {
      added_rules.push(name)
    } else if before_rules[name] != rule {
      changed_rules.push(name)
    }
  }

  for rule in before.rules {
    let name = rule_name(rule)
    if !after_rules.contains(name) {
      removed_rules.push(name)
    }
  }

  {
    added_fields: added,
    removed_fields: removed,
    changed_fields: changed,
    added_rules,
    removed_rules,
    changed_rules,
  }
}

///|
fn field_map(contract : Contract) -> Map[String, FieldSpec] {
  let result : Map[String, FieldSpec] = Map([])
  for field in contract.fields {
    result[field.name] = field
  }
  result
}

///|
fn rule_map(contract : Contract) -> Map[String, Rule] {
  let result : Map[String, Rule] = Map([])
  for rule in contract.rules {
    result[rule_name(rule)] = rule
  }
  result
}
