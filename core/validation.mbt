///|
pub fn validate_rows(
  contract : Contract,
  rows : Array[DataRow],
) -> ValidationReport {
  let results = []
  let mut failure_count = 0
  let mut warning_count = 0

  for rule in contract.rules {
    let failure_rows = evaluate_rule(rule, rows)
    let passed = failure_rows.is_empty()
    if !passed {
      failure_count += failure_rows.length()
      if severity_of(rule) == Error {
        ()
      } else {
        warning_count += failure_rows.length()
      }
    }
    results.push({
      name: rule_name(rule),
      severity: severity_of(rule),
      passed,
      failure_rows,
      message: message_of(rule),
    })
  }

  {
    dataset_name: contract.name,
    row_count: rows.length(),
    passed: failure_count == 0,
    failure_count,
    warning_count,
    rule_results: results,
  }
}

///|
fn evaluate_rule(rule : Rule, rows : Array[DataRow]) -> Array[Int] {
  match rule {
    Unique(fields~, ..) => evaluate_unique(fields, rows)
    Completeness(field~, min_percent~, ..) =>
      evaluate_completeness(field, min_percent, rows)
    Enum(field~, allowed_values~, ..) =>
      evaluate_enum(field, allowed_values, rows)
    IntRange(field~, min~, max~, ..) =>
      evaluate_int_range(field, min, max, rows)
    CompareInts(left~, op~, right~, ..) =>
      evaluate_compare_ints(left, op, right, rows)
    RowCount(min~, max~, ..) => evaluate_row_count(rows.length(), min, max)
  }
}

///|
fn evaluate_unique(fields : Array[String], rows : Array[DataRow]) -> Array[Int] {
  let seen : Map[String, Int] = {}
  let failures = []
  for index, row in rows {
    let key = fields.map(fn(name) { option_or_empty(row.get(name)) }).join("||")
    if seen.contains(key) {
      failures.push(index)
    } else {
      seen[key] = index
    }
  }
  failures
}

///|
fn evaluate_completeness(
  field : String,
  min_percent : Int,
  rows : Array[DataRow],
) -> Array[Int] {
  if rows.is_empty() {
    []
  } else {
    let non_empty_rows = rows.fold(init=0, fn(acc, row) {
      if non_empty(row.get(field)) {
        acc + 1
      } else {
        acc
      }
    })
    let percent = non_empty_rows * 100 / rows.length()
    if percent >= min_percent {
      []
    } else {
      let failures = []
      for index, row in rows {
        if !non_empty(row.get(field)) {
          failures.push(index)
        }
      }
      failures
    }
  }
}

///|
fn evaluate_enum(
  field : String,
  allowed_values : Array[String],
  rows : Array[DataRow],
) -> Array[Int] {
  let failures = []
  for index, row in rows {
    let value = option_or_empty(row.get(field))
    if value != "" && !allowed_values.contains(value) {
      failures.push(index)
    }
  }
  failures
}

///|
fn evaluate_int_range(
  field : String,
  min : Int,
  max : Int,
  rows : Array[DataRow],
) -> Array[Int] {
  let failures = []
  for index, row in rows {
    match parse_int_option(row.get(field)) {
      Some(number) => if number < min || number > max { failures.push(index) }
      None => failures.push(index)
    }
  }
  failures
}

///|
fn evaluate_compare_ints(
  left : String,
  op : ComparisonOp,
  right : String,
  rows : Array[DataRow],
) -> Array[Int] {
  let failures = []
  for index, row in rows {
    match (parse_int_option(row.get(left)), parse_int_option(row.get(right))) {
      (Some(l), Some(r)) =>
        if l > 0 && r >= 0 && !compare_ints(l, op, r) {
          failures.push(index)
        }
      _ => failures.push(index)
    }
  }
  failures
}

///|
fn evaluate_row_count(length : Int, min : Int?, max : Int?) -> Array[Int] {
  let too_small = match min {
    Some(value) => length < value
    None => false
  }
  let too_large = match max {
    Some(value) => length > value
    None => false
  }
  if too_small || too_large {
    [0]
  } else {
    []
  }
}
