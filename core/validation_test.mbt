///|
test "validate rows with uniqueness completeness enum range and compare rules" {
  let contract : Contract = {
    name: "retail_orders",
    version: "1.0.0",
    fields: [
      field_spec("order_id", required=true, description="Order identifier"),
      field_spec(
        "customer_id",
        required=true,
        description="Customer identifier",
      ),
      field_spec(
        "status",
        required=true,
        allowed_values=["paid", "shipped", "cancelled"],
        description="Order status",
      ),
      field_spec(
        "amount",
        kind=Int,
        required=true,
        min_int=1,
        max_int=10000,
        description="Order amount",
      ),
      field_spec(
        "discount",
        kind=Int,
        required=false,
        min_int=0,
        max_int=5000,
        description="Discount amount",
      ),
    ],
    rules: [
      Unique(
        fields=["order_id"],
        severity=Error,
        message="order_id must be unique",
      ),
      Completeness(
        field="customer_id",
        min_percent=80,
        severity=Error,
        message="customer_id completeness too low",
      ),
      Enum(
        field="status",
        allowed_values=["paid", "shipped", "cancelled"],
        severity=Error,
        message="status must be allowed",
      ),
      IntRange(
        field="amount",
        min=1,
        max=10000,
        severity=Error,
        message="amount out of range",
      ),
      CompareInts(
        left="amount",
        op=GreaterOrEqual,
        right="discount",
        severity=Warning,
        message="amount should cover discount",
      ),
    ],
  }
  let rows = [
    row_of([
      ("order_id", "ORD-001"),
      ("customer_id", "C001"),
      ("status", "paid"),
      ("amount", "199"),
      ("discount", "10"),
    ]),
    row_of([
      ("order_id", "ORD-001"),
      ("customer_id", ""),
      ("status", "hold"),
      ("amount", "0"),
      ("discount", "5"),
    ]),
    row_of([
      ("order_id", "ORD-003"),
      ("customer_id", "C003"),
      ("status", "shipped"),
      ("amount", "5"),
      ("discount", "10"),
    ]),
  ]

  let report = validate_rows(contract, rows)

  assert_eq(report.row_count, 3)
  assert_eq(report.failure_count, 5)
  assert_eq(report.warning_count, 1)
  assert_true(report.passed is false)
  assert_eq(report.rule_results.length(), 5)
  assert_true(report.rule_results[0].failure_rows == [1])
  assert_true(report.rule_results[1].failure_rows == [1])
  assert_true(report.rule_results[2].failure_rows == [1])
  assert_true(report.rule_results[3].failure_rows == [1])
  assert_true(report.rule_results[4].failure_rows == [2])
}
