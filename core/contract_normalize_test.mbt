///|
test "normalize contract trims metadata and removes duplicate values" {
  let contract : Contract = {
    name: " orders ",
    version: " 1.0.0 ",
    fields: [
      field_spec(
        " status ",
        allowed_values=[" paid ", "paid", " shipped "],
        description=" order status ",
      ),
    ],
    rules: [
      Enum(
        field=" status ",
        allowed_values=[" paid ", "paid"],
        severity=Warning,
        message=" status should be valid ",
      ),
      RequiredIf(
        condition_field=" status ",
        condition_value=" shipped ",
        field=" tracking ",
        severity=Error,
        message=" tracking is required ",
      ),
    ],
  }

  let normalized = normalize_contract(contract)

  assert_eq(normalized.name, "orders")
  assert_eq(normalized.version, "1.0.0")
  assert_eq(normalized.fields[0].name, "status")
  assert_true(normalized.fields[0].allowed_values == ["paid", "shipped"])
  assert_eq(normalized.fields[0].description, "order status")
  assert_true(normalized.rules[0] is Enum(field="status", ..))
  assert_true(normalized.rules[1] is RequiredIf(condition_field="status", ..))
}

///|
test "contract stats count schema and severity dimensions" {
  let stats = contract_stats({
    name: "orders",
    version: "1.0.0",
    fields: [field_spec("id", kind=Int, required=true), field_spec("status")],
    rules: [
      Unique(fields=["id"], severity=Error, message="unique"),
      PatternMatch(
        field="status",
        pattern="paid",
        severity=Warning,
        message="status",
      ),
    ],
  })

  assert_eq(stats.field_count, 2)
  assert_eq(stats.required_field_count, 1)
  assert_eq(stats.typed_field_count, 1)
  assert_eq(stats.rule_count, 2)
  assert_eq(stats.error_rule_count, 1)
  assert_eq(stats.warning_rule_count, 1)
}
