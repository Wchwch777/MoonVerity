///|
test "compare operators handle zero and negative values" {
  let rows = [
    row_of([("left", "-2"), ("right", "-2")]),
    row_of([("left", "0"), ("right", "1")]),
    row_of([("left", "3"), ("right", "2")]),
  ]
  let cases : Array[(ComparisonOp, Array[Int])] = [
    (GreaterOrEqual, [1]),
    (GreaterThan, [0, 1]),
    (LessOrEqual, [2]),
    (LessThan, [0, 2]),
    (Equal, [1, 2]),
  ]

  for _, item in cases {
    let (op, expected) = item
    let report = validate_rows(
      {
        name: "operators",
        version: "1.0.0",
        fields: [],
        rules: [
          CompareInts(
            left="left",
            op~,
            right="right",
            severity=Error,
            message="comparison",
          ),
        ],
      },
      rows,
    )
    assert_true(report.rule_results[0].failure_rows == expected)
  }
}

///|
test "row count includes exact boundaries" {
  let rows = [row_of([]), row_of([])]
  let at_min = validate_rows(
    {
      name: "row_count_min",
      version: "1.0.0",
      fields: [],
      rules: [
        RowCount(min=Some(2), max=None, severity=Error, message="minimum"),
      ],
    },
    rows,
  )
  let at_max = validate_rows(
    {
      name: "row_count_max",
      version: "1.0.0",
      fields: [],
      rules: [
        RowCount(min=None, max=Some(2), severity=Error, message="maximum"),
      ],
    },
    rows,
  )

  assert_true(at_min.passed)
  assert_true(at_max.passed)
}

///|
test "completeness percentage reports the first missing boundary row" {
  let rows = [
    row_of([("value", "a")]),
    row_of([("value", "b")]),
    row_of([("value", "c")]),
    row_of([("value", "")]),
  ]
  let exact = validate_rows(
    {
      name: "completeness_exact",
      version: "1.0.0",
      fields: [],
      rules: [
        Completeness(
          field="value",
          min_percent=75,
          severity=Error,
          message="75 percent",
        ),
      ],
    },
    rows,
  )
  let above = validate_rows(
    {
      name: "completeness_above",
      version: "1.0.0",
      fields: [],
      rules: [
        Completeness(
          field="value",
          min_percent=76,
          severity=Error,
          message="76 percent",
        ),
      ],
    },
    rows,
  )

  assert_true(exact.passed)
  assert_true(above.rule_results[0].failure_rows == [3])
}

///|
test "unique rule supports composite keys and missing cells" {
  let report = validate_rows(
    {
      name: "composite_unique",
      version: "1.0.0",
      fields: [],
      rules: [
        Unique(
          fields=["tenant", "id"],
          severity=Error,
          message="tenant and id must be unique",
        ),
      ],
    },
    [
      row_of([("tenant", "a"), ("id", "1")]),
      row_of([("tenant", "a"), ("id", "2")]),
      row_of([("tenant", "a"), ("id", "1")]),
      row_of([("tenant", "b")]),
      row_of([("tenant", "b")]),
    ],
  )

  assert_true(report.rule_results[0].failure_rows == [2, 4])
}

///|
test "pattern rules support exact prefix suffix and contains forms" {
  let report = validate_rows(
    {
      name: "patterns",
      version: "1.0.0",
      fields: [],
      rules: [
        PatternMatch(
          field="exact",
          pattern="OK",
          severity=Error,
          message="exact",
        ),
        PatternMatch(
          field="prefix",
          pattern="prefix:MB",
          severity=Error,
          message="prefix",
        ),
        PatternMatch(
          field="suffix",
          pattern="suffix:.csv",
          severity=Error,
          message="suffix",
        ),
        PatternMatch(
          field="contains",
          pattern="contains:bit",
          severity=Error,
          message="contains",
        ),
      ],
    },
    [
      row_of([
        ("exact", "OK"),
        ("prefix", "MB-1"),
        ("suffix", "data.csv"),
        ("contains", "moonbit"),
      ]),
      row_of([
        ("exact", "bad"),
        ("prefix", "1-MB"),
        ("suffix", "data.jsonl"),
        ("contains", "moon"),
      ]),
    ],
  )

  assert_true(report.rule_results[0].failure_rows == [1])
  assert_true(report.rule_results[1].failure_rows == [1])
  assert_true(report.rule_results[2].failure_rows == [1])
  assert_true(report.rule_results[3].failure_rows == [1])
}
