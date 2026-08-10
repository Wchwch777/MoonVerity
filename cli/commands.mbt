///|
pub(all) struct ValidationOutcome {
  output : String
  passed : Bool
} derive(Eq, Debug)

///|
pub fn validate_text(
  contract_text : String,
  data_text : String,
  data_format : String,
) -> ValidationOutcome {
  let contract = @core.parse_contract_json(contract_text)
  let rows = parse_rows(data_text, data_format)
  let report = @core.validate_rows_with_schema(contract, rows)
  let quality = @core.quality_score(@core.profile_rows(rows), report)
  { output: format_validation_report(report, quality), passed: report.passed }
}

///|
pub fn run_validate_text(
  contract_text : String,
  data_text : String,
  data_format : String,
) -> String {
  validate_text(contract_text, data_text, data_format).output
}

///|
pub fn run_profile_text(data_text : String, data_format : String) -> String {
  let rows = parse_rows(data_text, data_format)
  let profile = @core.profile_rows(rows)
  format_profile(profile, @adapters.inspect_shape(rows))
}

///|
pub fn run_profile_json(data_text : String, data_format : String) -> String {
  let rows = parse_rows(data_text, data_format)
  let profile = @core.profile_rows(rows)
  let shape = @adapters.inspect_shape(rows)
  let columns = profile.columns.map(fn(column) {
    Json::object({
      "name": Json::string(column.name),
      "non_empty_count": Json::number(column.non_empty_count.to_double()),
      "empty_count": Json::number(column.empty_count.to_double()),
      "distinct_values": Json::array(
        column.distinct_values.map(fn(value) { Json::string(value) }),
      ),
      "min_length": Json::number(column.min_length.to_double()),
      "max_length": Json::number(column.max_length.to_double()),
      "total_length": Json::number(column.total_length.to_double()),
    })
  })
  Json::object({
    "row_count": Json::number(profile.row_count.to_double()),
    "shape": Json::object({
      "column_names": Json::array(
        shape.column_names.map(fn(name) { Json::string(name) }),
      ),
      "min_columns_per_row": Json::number(shape.min_columns_per_row.to_double()),
      "max_columns_per_row": Json::number(shape.max_columns_per_row.to_double()),
      "empty_row_count": Json::number(shape.empty_row_count.to_double()),
    }),
    "columns": Json::array(columns),
  }).stringify(indent=2)
}

///|
pub fn run_diff_contract_text(
  before_text : String,
  after_text : String,
) -> String {
  let before = @core.parse_contract_json(before_text)
  let after = @core.parse_contract_json(after_text)
  let diff = @core.diff_contracts(before, after)
  format_contract_diff(diff)
}

///|
pub fn run_diff_contract_json(
  before_text : String,
  after_text : String,
) -> String {
  let before = @core.parse_contract_json(before_text)
  let after = @core.parse_contract_json(after_text)
  let diff = @core.diff_contracts(before, after)
  Json::object({
    "added_fields": Json::array(
      diff.added_fields.map(fn(name) { Json::string(name) }),
    ),
    "removed_fields": Json::array(
      diff.removed_fields.map(fn(name) { Json::string(name) }),
    ),
    "changed_fields": Json::array(
      diff.changed_fields.map(fn(name) { Json::string(name) }),
    ),
    "added_rules": Json::array(
      diff.added_rules.map(fn(name) { Json::string(name) }),
    ),
    "removed_rules": Json::array(
      diff.removed_rules.map(fn(name) { Json::string(name) }),
    ),
    "changed_rules": Json::array(
      diff.changed_rules.map(fn(name) { Json::string(name) }),
    ),
  }).stringify(indent=2)
}

///|
pub fn run_validate_json(
  contract_text : String,
  data_text : String,
  data_format : String,
) -> String {
  validate_json(contract_text, data_text, data_format).output
}

///|
pub fn validate_json(
  contract_text : String,
  data_text : String,
  data_format : String,
) -> ValidationOutcome {
  let contract = @core.parse_contract_json(contract_text)
  let rows = parse_rows(data_text, data_format)
  let report = @core.validate_rows_with_schema(contract, rows)
  let quality = @core.quality_score(@core.profile_rows(rows), report)
  { output: validation_report_json(report, quality), passed: report.passed }
}

///|
pub fn run_contract_check_text(contract_text : String) -> ValidationOutcome {
  let contract = @core.parse_contract_json(contract_text)
  let issues = @core.inspect_contract(contract)
  {
    output: format_contract_issues(contract, issues),
    passed: issues.is_empty(),
  }
}

///|
pub fn run_contract_check_json(contract_text : String) -> ValidationOutcome {
  let contract = @core.parse_contract_json(contract_text)
  let issues = @core.inspect_contract(contract)
  let issue_json = issues.map(fn(issue) {
    Json::object({
      "code": Json::string(issue.code),
      "message": Json::string(issue.message),
    })
  })
  {
    output: Json::object({
      "passed": Json::boolean(issues.is_empty()),
      "issues": Json::array(issue_json),
    }).stringify(indent=2),
    passed: issues.is_empty(),
  }
}

///|
fn parse_rows(
  data_text : String,
  data_format : String,
) -> Array[Map[String, String]] {
  match data_format.to_lower() {
    "csv" => @adapters.parse_csv_text(data_text)
    "jsonl" => @adapters.parse_jsonl_text(data_text)
    _ => abort("unsupported data format: \{data_format}")
  }
}

///|
fn format_validation_report(
  report : @core.ValidationReport,
  quality : @core.QualityScore,
) -> String {
  let lines = [
    "dataset: \{report.dataset_name}",
    "rows: \{report.row_count}",
    "passed: \{report.passed}",
    "failures: \{report.failure_count}",
    "warnings: \{report.warning_count}",
    "quality: \{quality.score_percent}% grade=\{quality.grade} completeness=\{quality.completeness_percent}%",
  ]
  for result in report.rule_results {
    let status = if result.passed {
      "ok"
    } else if result.severity == @core.Warning {
      "warn"
    } else {
      "fail"
    }
    lines.push(
      "[\{status}] \{result.name} rows=\{result.failure_rows.length()} message=\{result.message}",
    )
  }
  lines.join("\n")
}

///|
fn format_contract_issues(
  contract : @core.Contract,
  issues : Array[@core.ContractIssue],
) -> String {
  let lines = [
    "contract: \{contract.name} version=\{contract.version}",
    "passed: \{issues.is_empty()}",
  ]
  for issue in issues {
    lines.push("[\{issue.code}] \{issue.message}")
  }
  lines.join("\n")
}

///|
fn format_profile(
  profile : @core.DatasetProfile,
  shape : @adapters.DatasetShape,
) -> String {
  let lines = [
    "rows: \{profile.row_count}",
    "shape: min_columns=\{shape.min_columns_per_row} max_columns=\{shape.max_columns_per_row} empty_rows=\{shape.empty_row_count}",
  ]
  for column in profile.columns {
    lines.push(
      "column: \{column.name} non_empty: \{column.non_empty_count} empty: \{column.empty_count} distinct: \{column.distinct_values.length()}",
    )
    lines.push(
      "  length: min=\{column.min_length} max=\{column.max_length} total=\{column.total_length}",
    )
  }
  lines.join("\n")
}

///|
fn format_contract_diff(diff : @core.ContractDiff) -> String {
  let added = if diff.added_fields.is_empty() {
    "-"
  } else {
    diff.added_fields.join(", ")
  }
  let removed = if diff.removed_fields.is_empty() {
    "-"
  } else {
    diff.removed_fields.join(", ")
  }
  let changed = if diff.changed_fields.is_empty() {
    "-"
  } else {
    diff.changed_fields.join(", ")
  }
  [
    "added fields: \{added}",
    "removed fields: \{removed}",
    "changed fields: \{changed}",
    "added rules: \{format_names(diff.added_rules)}",
    "removed rules: \{format_names(diff.removed_rules)}",
    "changed rules: \{format_names(diff.changed_rules)}",
  ].join("\n")
}

///|
fn format_names(names : Array[String]) -> String {
  if names.is_empty() {
    "-"
  } else {
    names.join(", ")
  }
}

///|
fn validation_report_json(
  report : @core.ValidationReport,
  quality : @core.QualityScore,
) -> String {
  let results = report.rule_results.map(fn(result) {
    Json::object({
      "name": Json::string(result.name),
      "severity": Json::string(severity_text(result.severity)),
      "passed": Json::boolean(result.passed),
      "failure_rows": Json::array(
        result.failure_rows.map(fn(index) { Json::number(index.to_double()) }),
      ),
      "message": Json::string(result.message),
    })
  })
  Json::object({
    "dataset_name": Json::string(report.dataset_name),
    "row_count": Json::number(report.row_count.to_double()),
    "passed": Json::boolean(report.passed),
    "failure_count": Json::number(report.failure_count.to_double()),
    "warning_count": Json::number(report.warning_count.to_double()),
    "quality": Json::object({
      "total_cells": Json::number(quality.total_cells.to_double()),
      "non_empty_cells": Json::number(quality.non_empty_cells.to_double()),
      "completeness_percent": Json::number(
        quality.completeness_percent.to_double(),
      ),
      "error_row_count": Json::number(quality.error_row_count.to_double()),
      "warning_row_count": Json::number(quality.warning_row_count.to_double()),
      "score_percent": Json::number(quality.score_percent.to_double()),
      "grade": Json::string(quality.grade),
    }),
    "rule_results": Json::array(results),
  }).stringify(indent=2)
}

///|
fn severity_text(severity : @core.Severity) -> String {
  match severity {
    Error => "error"
    Warning => "warning"
  }
}
