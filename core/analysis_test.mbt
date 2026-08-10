///|
test "summarize report separates errors warnings and affected rows" {
  let contract : Contract = {
    name: "summary",
    version: "1.0.0",
    fields: [],
    rules: [
      Unique(fields=["id"], severity=Error, message="id must be unique"),
      Enum(
        field="status",
        allowed_values=["ok"],
        severity=Warning,
        message="status should be ok",
      ),
    ],
  }
  let rows = [
    row_of([("id", "A"), ("status", "bad")]),
    row_of([("id", "A"), ("status", "ok")]),
  ]

  let summary = summarize_report(validate_rows(contract, rows))

  assert_eq(summary.status, "failed")
  assert_eq(summary.error_rule_count, 1)
  assert_eq(summary.warning_rule_count, 1)
  assert_eq(summary.failed_rule_count, 2)
  assert_true(summary.affected_rows == [0, 1])
}

///|
test "summarize warning-only report as passed with warnings" {
  let report = validate_rows(
    {
      name: "warning_summary",
      version: "1.0.0",
      fields: [],
      rules: [
        RowCount(
          min=Some(2),
          max=None,
          severity=Warning,
          message="more rows are recommended",
        ),
      ],
    },
    [row_of([])],
  )

  let summary = summarize_report(report)

  assert_eq(summary.status, "passed_with_warnings")
  assert_eq(summary.error_rule_count, 0)
  assert_eq(summary.warning_rule_count, 1)
  assert_eq(summary.failed_rule_count, 1)
  assert_true(summary.affected_rows == [0])
}

///|
test "rule summaries preserve rule order and counts" {
  let report = validate_rows(
    {
      name: "ordered_summary",
      version: "1.0.0",
      fields: [],
      rules: [
        RowCount(
          min=Some(1),
          max=Some(1),
          severity=Error,
          message="exactly one row",
        ),
        StringLength(
          field="id",
          min=2,
          max=4,
          severity=Warning,
          message="id length",
        ),
      ],
    },
    [row_of([("id", "A")]), row_of([("id", "AB")])],
  )
  let summaries = rule_summaries(report)

  assert_eq(summaries.length(), 2)
  assert_eq(summaries[0].name, "row_count")
  assert_eq(summaries[0].failure_count, 1)
  assert_eq(summaries[1].name, "string_length(id)")
  assert_eq(summaries[1].failure_count, 1)
}
