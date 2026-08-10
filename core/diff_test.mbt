///|
test "diff contracts highlights added removed and changed fields" {
  let before : Contract = {
    name: "retail_orders",
    version: "1.0.0",
    fields: [
      field_spec("order_id", required=true),
      field_spec("status", required=true),
    ],
    rules: [
      Unique(
        fields=["order_id"],
        severity=Error,
        message="order id must be unique",
      ),
    ],
  }
  let after : Contract = {
    name: "retail_orders",
    version: "1.1.0",
    fields: [
      field_spec("order_id", required=true),
      field_spec("status", required=true, allowed_values=["paid", "shipped"]),
      field_spec("amount", kind=Int, required=true),
    ],
    rules: [
      Unique(
        fields=["order_id"],
        severity=Error,
        message="order id remains unique",
      ),
      PatternMatch(
        field="status",
        pattern="prefix:ok",
        severity=Warning,
        message="status should start with ok",
      ),
    ],
  }

  let diff = diff_contracts(before, after)

  assert_true(diff.added_fields == ["amount"])
  assert_eq(diff.removed_fields.length(), 0)
  assert_true(diff.changed_fields == ["status"])
  assert_true(diff.added_rules == ["pattern_match(status)"])
  assert_true(diff.removed_rules.is_empty())
  assert_true(diff.changed_rules == ["unique(order_id)"])
}
