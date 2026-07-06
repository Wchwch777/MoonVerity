///|
pub fn run_validate_text(
  contract_text : String,
  data_text : String,
  data_format : String,
) -> String {
  let contract = @core.parse_contract_json(contract_text)
  let rows = parse_rows(data_text, data_format)
  let report = @core.validate_rows(contract, rows)
  format_validation_report(report)
}

///|
pub fn run_profile_text(data_text : String, data_format : String) -> String {
  let rows = parse_rows(data_text, data_format)
  let profile = @core.profile_rows(rows)
  format_profile(profile)
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
pub fn run_validate_json(
  contract_text : String,
  data_text : String,
  data_format : String,
) -> String {
  let contract = @core.parse_contract_json(contract_text)
  let rows = parse_rows(data_text, data_format)
  let report = @core.validate_rows(contract, rows)
  validation_report_json(report)
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
fn format_validation_report(report : @core.ValidationReport) -> String {
  let lines = [
    "dataset: \{report.dataset_name}",
    "rows: \{report.row_count}",
    "passed: \{report.passed}",
    "failures: \{report.failure_count}",
    "warnings: \{report.warning_count}",
  ]
  for result in report.rule_results {
    let status = if result.passed { "ok" } else { "fail" }
    lines.push(
      "[\{status}] \{result.name} rows=\{result.failure_rows.length()} message=\{result.message}",
    )
  }
  lines.join("\n")
}

///|
fn format_profile(profile : @core.DatasetProfile) -> String {
  let lines = ["rows: \{profile.row_count}"]
  for column in profile.columns {
    lines.push(
      "column: \{column.name} non_empty: \{column.non_empty_count} empty: \{column.empty_count} distinct: \{column.distinct_values.length()}",
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
  ].join("\n")
}

///|
fn validation_report_json(report : @core.ValidationReport) -> String {
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
