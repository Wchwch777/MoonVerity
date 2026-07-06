///|
pub using @core {
  type ColumnProfile,
  type ComparisonOp,
  type Contract,
  type ContractDiff,
  type DatasetProfile,
  type FieldSpec,
  type FieldType,
  type Rule,
  type RuleResult,
  type Severity,
  type ValidationReport,
  diff_contracts,
  field_spec,
  parse_contract_json,
  profile_rows,
  row_of,
  validate_rows,
}

///|
pub using @adapters {
  parse_csv_text,
  parse_jsonl_text,
  read_csv_file,
  read_jsonl_file,
}

///|
pub using @cli {
  run_diff_contract_text,
  run_profile_text,
  run_validate_json,
  run_validate_text,
}
