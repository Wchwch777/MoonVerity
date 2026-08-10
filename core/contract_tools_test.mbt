///|
test "inspect contract reports structural and rule configuration issues" {
  let contract : Contract = {
    name: "",
    version: "",
    fields: [
      field_spec("id", kind=Int, min_int=10, max_int=1),
      field_spec("id", allowed_values=["paid", "paid"]),
    ],
    rules: [
      Unique(fields=[], severity=Error, message="id"),
      Completeness(
        field="id",
        min_percent=101,
        severity=Error,
        message="complete",
      ),
      StringLength(field="id", min=5, max=2, severity=Error, message="length"),
      RowCount(min=Some(-1), max=Some(0), severity=Error, message="rows"),
    ],
  }
  let issues = inspect_contract(contract)
  let codes = issues.map(fn(issue) { issue.code })

  assert_true(codes.contains("missing_name"))
  assert_true(codes.contains("missing_version"))
  assert_true(codes.contains("duplicate_field"))
  assert_true(codes.contains("invalid_field_range"))
  assert_true(codes.contains("duplicate_allowed_value"))
  assert_true(codes.contains("empty_unique_fields"))
  assert_true(codes.contains("invalid_completeness"))
  assert_true(codes.contains("invalid_string_length"))
  assert_true(codes.contains("invalid_row_count"))
}

///|
test "contract tools expose sorted names and valid contracts have no issues" {
  let contract : Contract = {
    name: "orders",
    version: "1.0.0",
    fields: [field_spec("status"), field_spec("id")],
    rules: [
      Unique(fields=["id"], severity=Error, message="unique"),
      Enum(
        field="status",
        allowed_values=["paid"],
        severity=Error,
        message="enum",
      ),
    ],
  }

  assert_true(inspect_contract(contract).is_empty())
  assert_true(contract_field_names(contract) == ["id", "status"])
  assert_true(contract_rule_names(contract) == ["unique(id)", "enum(status)"])
  assert_true(has_field(contract, "id"))
  assert_true(!has_field(contract, "missing"))
}
