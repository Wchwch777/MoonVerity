///|
/// Validate field declarations in addition to the explicit contract rules.
///
/// This opt-in entry point keeps `validate_rows` compatible with the original
/// rule-only API while making the field metadata executable for applications
/// that want a complete data-contract gate.
pub fn validate_rows_with_schema(
  contract : Contract,
  rows : Array[DataRow],
) -> ValidationReport {
  let base = validate_rows(contract, rows)
  let field_results = contract.fields.map(fn(field) {
    validate_field(field, rows)
  })
  let mut schema_failure_count = 0
  for result in field_results {
    if !result.passed {
      schema_failure_count += result.failure_rows.length()
    }
  }
  let results = field_results
  for result in base.rule_results {
    results.push(result)
  }
  {
    dataset_name: base.dataset_name,
    row_count: base.row_count,
    passed: base.passed && schema_failure_count == 0,
    failure_count: base.failure_count + schema_failure_count,
    warning_count: base.warning_count,
    rule_results: results,
  }
}

///|
fn validate_field(field : FieldSpec, rows : Array[DataRow]) -> RuleResult {
  let failures = []
  for index, row in rows {
    if field_fails(field, row) {
      failures.push(index)
    }
  }
  {
    name: "field(\{field.name})",
    severity: Error,
    passed: failures.is_empty(),
    failure_rows: failures,
    message: field_message(field),
  }
}

///|
fn field_fails(field : FieldSpec, row : DataRow) -> Bool {
  match row.get(field.name) {
    None => field.required
    Some(raw) => {
      let value = raw.trim().to_owned()
      if value == "" {
        !field.nullable
      } else {
        !field_value_matches(field, value)
      }
    }
  }
}

///|
fn field_value_matches(field : FieldSpec, value : String) -> Bool {
  let kind_matches = match field.kind {
    String => true
    Int => parse_int_option(Some(value)) is Some(_)
    Bool => value.to_lower() == "true" || value.to_lower() == "false"
    Date => valid_date(value)
  }
  let allowed_matches = field.allowed_values.is_empty() ||
    field.allowed_values.contains(value)
  let min_matches = match field.min_int {
    Some(min) =>
      match parse_int_option(Some(value)) {
        Some(number) => number >= min
        None => false
      }
    None => true
  }
  let max_matches = match field.max_int {
    Some(max) =>
      match parse_int_option(Some(value)) {
        Some(number) => number <= max
        None => false
      }
    None => true
  }
  let pattern_matches = match field.pattern {
    Some(pattern) => match_pattern(value, pattern)
    None => true
  }
  kind_matches &&
  allowed_matches &&
  min_matches &&
  max_matches &&
  pattern_matches
}

///|
fn field_message(field : FieldSpec) -> String {
  if field.description == "" {
    "field does not match its declared schema"
  } else {
    field.description
  }
}

///|
fn valid_date(value : String) -> Bool {
  let parts = value.split("-").to_array()
  if parts.length() != 3 {
    false
  } else {
    let year_text = parts[0].to_owned()
    let month_text = parts[1].to_owned()
    let day_text = parts[2].to_owned()
    if year_text.length() != 4 ||
      month_text.length() != 2 ||
      day_text.length() != 2 {
      false
    } else if !digits_only(year_text) ||
      !digits_only(month_text) ||
      !digits_only(day_text) {
      false
    } else {
      match
        (
          parse_int_option(Some(year_text)),
          parse_int_option(Some(month_text)),
          parse_int_option(Some(day_text)),
        ) {
        (Some(year), Some(month), Some(day)) =>
          year > 0 &&
          month >= 1 &&
          month <= 12 &&
          day >= 1 &&
          day <= days_in_month(year, month)
        _ => false
      }
    }
  }
}

///|
fn digits_only(value : String) -> Bool {
  if value == "" {
    false
  } else {
    for ch in value {
      if ch < '0' || ch > '9' {
        return false
      }
    }
    true
  }
}

///|
fn days_in_month(year : Int, month : Int) -> Int {
  match month {
    2 => if is_leap_year(year) { 29 } else { 28 }
    4 | 6 | 9 | 11 => 30
    _ => 31
  }
}

///|
fn is_leap_year(year : Int) -> Bool {
  year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)
}
