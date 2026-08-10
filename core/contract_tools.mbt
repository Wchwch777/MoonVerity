///|
pub(all) struct ContractIssue {
  code : String
  message : String
} derive(Eq, Debug)

///|
/// Inspect a contract before running it so configuration errors are explicit.
pub fn inspect_contract(contract : Contract) -> Array[ContractIssue] {
  let issues = []
  if contract.name.trim().to_owned() == "" {
    add_issue(issues, "missing_name", "contract name must not be empty")
  }
  if contract.version.trim().to_owned() == "" {
    add_issue(issues, "missing_version", "contract version must not be empty")
  }

  let seen_fields = Map([])
  for field in contract.fields {
    if field.name.trim().to_owned() == "" {
      add_issue(issues, "empty_field_name", "field name must not be empty")
    }
    if seen_fields.contains(field.name) {
      add_issue(
        issues,
        "duplicate_field",
        "field name is declared more than once: " + field.name,
      )
    } else {
      seen_fields[field.name] = ()
    }
    inspect_field(field, issues)
  }

  for rule in contract.rules {
    inspect_rule(rule, issues)
  }
  let references = analyze_contract_references(contract)
  for field in references.missing_fields {
    add_issue(
      issues,
      "missing_field_reference",
      "rule references an undeclared field: " + field,
    )
  }
  issues
}

///|
pub fn contract_field_names(contract : Contract) -> Array[String] {
  let names = contract.fields.map(fn(field) { field.name })
  names.sort()
  names
}

///|
pub fn contract_rule_names(contract : Contract) -> Array[String] {
  contract.rules.map(rule_name)
}

///|
pub fn has_field(contract : Contract, name : String) -> Bool {
  contract.fields.any(fn(field) { field.name == name })
}

///|
fn inspect_field(field : FieldSpec, issues : Array[ContractIssue]) -> Unit {
  match (field.min_int, field.max_int) {
    (Some(min), Some(max)) =>
      if min > max {
        add_issue(
          issues,
          "invalid_field_range",
          "field has min_int greater than max_int: " + field.name,
        )
      }
    _ => ()
  }
  if field.kind != Int && (field.min_int is Some(_) || field.max_int is Some(_)) {
    add_issue(
      issues,
      "numeric_bounds_on_non_int",
      "field has integer bounds but is not an Int field: " + field.name,
    )
  }
  for index, value in field.allowed_values {
    if field.allowed_values[index + 1:].contains(value) {
      add_issue(
        issues,
        "duplicate_allowed_value",
        "field repeats an allowed value: " + field.name + "=" + value,
      )
    }
  }
}

///|
fn inspect_rule(rule : Rule, issues : Array[ContractIssue]) -> Unit {
  match rule {
    Unique(fields~, ..) =>
      if fields.is_empty() {
        add_issue(issues, "empty_unique_fields", "unique rule needs a field")
      }
    Completeness(field~, min_percent~, ..) =>
      if field == "" || min_percent < 0 || min_percent > 100 {
        add_issue(
          issues, "invalid_completeness", "completeness must use a field and a percentage from 0 to 100",
        )
      }
    Enum(field~, allowed_values~, ..) =>
      if field == "" || allowed_values.is_empty() {
        add_issue(
          issues, "invalid_enum", "enum rule needs a field and at least one allowed value",
        )
      }
    IntRange(field~, min~, max~, ..) =>
      if field == "" || min > max {
        add_issue(
          issues, "invalid_int_range", "int_range needs a field and min <= max",
        )
      }
    CompareInts(left~, right~, ..) =>
      if left == "" || right == "" || left == right {
        add_issue(
          issues, "invalid_compare", "compare_ints needs two different fields",
        )
      }
    PatternMatch(field~, pattern~, ..) =>
      if field == "" || pattern == "" {
        add_issue(
          issues, "invalid_pattern", "pattern_match needs a field and pattern",
        )
      }
    StringLength(field~, min~, max~, ..) =>
      if field == "" || min < 0 || min > max {
        add_issue(
          issues, "invalid_string_length", "string_length needs a field and 0 <= min <= max",
        )
      }
    DistinctCount(field~, min~, max~, ..) =>
      if field == "" || min < 0 || min > max {
        add_issue(
          issues, "invalid_distinct_count", "distinct_count needs a field and 0 <= min <= max",
        )
      }
    RequiredIf(condition_field~, condition_value~, field~, ..) =>
      if condition_field == "" ||
        condition_value == "" ||
        field == "" ||
        condition_field == field {
        add_issue(
          issues, "invalid_required_if", "required_if needs two different fields and a condition value",
        )
      }
    RowCount(min~, max~, ..) =>
      match (min, max) {
        (Some(minimum), Some(maximum)) =>
          if minimum < 0 || minimum > maximum {
            add_issue(
              issues, "invalid_row_count", "row_count needs 0 <= min <= max",
            )
          }
        (Some(minimum), None) =>
          if minimum < 0 {
            add_issue(
              issues, "invalid_row_count", "row_count minimum must not be negative",
            )
          }
        (None, Some(maximum)) =>
          if maximum < 0 {
            add_issue(
              issues, "invalid_row_count", "row_count maximum must not be negative",
            )
          }
        (None, None) =>
          add_issue(
            issues, "unbounded_row_count", "row_count needs a minimum or maximum",
          )
      }
  }
}

///|
fn add_issue(
  issues : Array[ContractIssue],
  code : String,
  message : String,
) -> Unit {
  issues.push({ code, message })
}
