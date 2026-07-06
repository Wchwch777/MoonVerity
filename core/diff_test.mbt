///|
test "diff contracts highlights added removed and changed fields" {
  let before : Contract = {
    name: "retail_orders",
    version: "1.0.0",
    fields: [
      field_spec("order_id", required=true),
      field_spec("status", required=true),
    ],
    rules: [],
  }
  let after : Contract = {
    name: "retail_orders",
    version: "1.1.0",
    fields: [
      field_spec("order_id", required=true),
      field_spec("status", required=true, allowed_values=["paid", "shipped"]),
      field_spec("amount", kind=Int, required=true),
    ],
    rules: [],
  }

  let diff = diff_contracts(before, after)

  assert_true(diff.added_fields == ["amount"])
  assert_eq(diff.removed_fields.length(), 0)
  assert_true(diff.changed_fields == ["status"])
}
