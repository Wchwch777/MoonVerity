///|
pub(all) struct RuleSummary {
  name : String
  severity : Severity
  passed : Bool
  failure_count : Int
} derive(Eq, Debug)

///|
pub(all) struct ValidationSummary {
  status : String
  error_rule_count : Int
  warning_rule_count : Int
  failed_rule_count : Int
  affected_rows : Array[Int]
} derive(Eq, Debug)

///|
/// Return one compact summary item for each validation rule.
pub fn rule_summaries(report : ValidationReport) -> Array[RuleSummary] {
  report.rule_results.map(fn(result) {
    {
      name: result.name,
      severity: result.severity,
      passed: result.passed,
      failure_count: result.failure_rows.length(),
    }
  })
}

///|
/// Summarize a report for dashboards and CI annotations.
pub fn summarize_report(report : ValidationReport) -> ValidationSummary {
  let mut error_rule_count = 0
  let mut warning_rule_count = 0
  let mut failed_rule_count = 0
  let affected_rows = []
  for result in report.rule_results {
    match result.severity {
      Error => error_rule_count += 1
      Warning => warning_rule_count += 1
    }
    if !result.passed {
      failed_rule_count += 1
      for row in result.failure_rows {
        if !affected_rows.contains(row) {
          affected_rows.push(row)
        }
      }
    }
  }
  affected_rows.sort()
  let status = if report.passed {
    if failed_rule_count > 0 {
      "passed_with_warnings"
    } else {
      "passed"
    }
  } else {
    "failed"
  }
  {
    status,
    error_rule_count,
    warning_rule_count,
    failed_rule_count,
    affected_rows,
  }
}
