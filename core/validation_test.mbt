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
  assert_eq(report.failure_count, 4)
  assert_eq(report.warning_count, 2)
  assert_true(report.passed is false)
  assert_eq(report.rule_results.length(), 5)
  assert_true(report.rule_results[0].failure_rows == [1])
  assert_true(report.rule_results[1].failure_rows == [1])
  assert_true(report.rule_results[2].failure_rows == [1])
  assert_true(report.rule_results[3].failure_rows == [1])
  assert_true(report.rule_results[4].failure_rows == [1, 2])
}

///|
test "validate rows with PatternMatch rules" {
  let contract : Contract = {
    name: "pattern_test",
    version: "1.0.0",
    fields: [
      field_spec("phone", required=true, description="Phone number"),
      field_spec("email", required=true, description="Email address"),
      field_spec("code", required=true, description="System code"),
    ],
    rules: [
      PatternMatch(
        field="phone",
        pattern="prefix:+86",
        severity=Error,
        message="phone must start with +86",
      ),
      PatternMatch(
        field="email",
        pattern="suffix:@example.com",
        severity=Error,
        message="email must end with @example.com",
      ),
      PatternMatch(
        field="code",
        pattern="contains:SYS",
        severity=Warning,
        message="code should contain SYS",
      ),
    ],
  }

  let rows = [
    row_of([
      ("phone", "+861234567890"),
      ("email", "user@example.com"),
      ("code", "SYS-001"),
    ]),
    row_of([
      ("phone", "1234567890"),
      ("email", "user@gmail.com"),
      ("code", "APP-001"),
    ]),
  ]

  let report = validate_rows(contract, rows)

  assert_eq(report.row_count, 2)
  assert_eq(report.failure_count, 2)
  assert_eq(report.warning_count, 1)
  assert_true(report.passed is false)
  assert_true(report.rule_results[0].failure_rows == [1])
  assert_true(report.rule_results[1].failure_rows == [1])
  assert_true(report.rule_results[2].failure_rows == [1])
}

///|
test "warning-only rule keeps the report passing" {
  let contract : Contract = {
    name: "warning_only",
    version: "1.0.0",
    fields: [],
    rules: [
      RowCount(
        min=Some(2),
        max=None,
        severity=Warning,
        message="dataset should contain at least two rows",
      ),
    ],
  }
  let report = validate_rows(contract, [row_of([])])

  assert_true(report.passed)
  assert_eq(report.failure_count, 0)
  assert_eq(report.warning_count, 1)
  assert_true(report.rule_results[0].severity == Warning)
  assert_true(report.rule_results[0].passed is false)
}

///|
test "compare rule checks negative integers" {
  let contract : Contract = {
    name: "negative_compare",
    version: "1.0.0",
    fields: [],
    rules: [
      CompareInts(
        left="minimum",
        op=GreaterOrEqual,
        right="baseline",
        severity=Error,
        message="minimum must cover baseline",
      ),
    ],
  }
  let rows = [
    row_of([("minimum", "-5"), ("baseline", "-2")]),
    row_of([("minimum", "-2"), ("baseline", "-5")]),
  ]

  let report = validate_rows(contract, rows)

  assert_true(report.rule_results[0].failure_rows == [0])
  assert_eq(report.failure_count, 1)
  assert_true(report.passed is false)
}

///|
test "schema validation checks field metadata" {
  let contract : Contract = {
    name: "typed_rows",
    version: "1.0.0",
    fields: [
      field_spec("id", kind=Int, required=true, min_int=0, max_int=10),
      field_spec("enabled", kind=Bool, required=true),
      field_spec("created", kind=Date, required=true),
      field_spec("tag", nullable=true, allowed_values=["a", "b"]),
    ],
    rules: [],
  }
  let rows = [
    row_of([
      ("id", "0"),
      ("enabled", "true"),
      ("created", "2024-02-29"),
      ("tag", ""),
    ]),
    row_of([
      ("id", "-1"),
      ("enabled", "maybe"),
      ("created", "2023-02-29"),
      ("tag", "c"),
    ]),
    row_of([
      ("id", ""),
      ("enabled", "false"),
      ("created", "2024-01-01"),
      ("tag", "a"),
    ]),
  ]

  let report = validate_rows_with_schema(contract, rows)

  assert_true(report.passed is false)
  assert_eq(report.failure_count, 5)
  assert_true(report.rule_results[0].name == "field(id)")
  assert_true(report.rule_results[0].failure_rows == [1, 2])
  assert_true(report.rule_results[1].failure_rows == [1])
  assert_true(report.rule_results[2].failure_rows == [1])
  assert_true(report.rule_results[3].failure_rows == [1])
}

///|
test "schema validation accepts exact numeric and date boundaries" {
  let contract : Contract = {
    name: "boundary_rows",
    version: "1.0.0",
    fields: [
      field_spec("id", kind=Int, min_int=0, max_int=10),
      field_spec("enabled", kind=Bool),
      field_spec("created", kind=Date),
    ],
    rules: [],
  }
  let rows = [
    row_of([("id", "0"), ("enabled", "false"), ("created", "2000-02-29")]),
    row_of([("id", "10"), ("enabled", "true"), ("created", "2024-12-31")]),
  ]

  let report = validate_rows_with_schema(contract, rows)

  assert_true(report.passed)
  assert_eq(report.failure_count, 0)
}

///|
test "advanced quality rules cover lengths cardinality and dependencies" {
  let contract : Contract = {
    name: "advanced_rules",
    version: "1.0.0",
    fields: [],
    rules: [
      StringLength(
        field="sku",
        min=3,
        max=5,
        severity=Error,
        message="sku length is invalid",
      ),
      DistinctCount(
        field="region",
        min=2,
        max=3,
        severity=Error,
        message="region cardinality is invalid",
      ),
      RequiredIf(
        condition_field="status",
        condition_value="shipped",
        field="tracking",
        severity=Error,
        message="shipped orders need tracking",
      ),
    ],
  }
  let rows = [
    row_of([
      ("sku", "AB"),
      ("region", "east"),
      ("status", "paid"),
      ("tracking", ""),
    ]),
    row_of([
      ("sku", "ABCDE"),
      ("region", "west"),
      ("status", "shipped"),
      ("tracking", ""),
    ]),
    row_of([
      ("sku", "ABCDEF"),
      ("region", "east"),
      ("status", "shipped"),
      ("tracking", "T-1"),
    ]),
    row_of([
      ("sku", "ABCD"),
      ("region", "south"),
      ("status", "paid"),
      ("tracking", ""),
    ]),
  ]

  let report = validate_rows(contract, rows)

  assert_true(report.rule_results[0].failure_rows == [0, 2])
  assert_true(report.rule_results[1].passed)
  assert_true(report.rule_results[2].failure_rows == [1])
  assert_eq(report.failure_count, 3)
}
