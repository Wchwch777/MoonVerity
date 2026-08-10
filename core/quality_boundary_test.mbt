///|
test "quality score keeps completeness and penalties integer deterministic" {
  let rows = [
    row_of([("id", "A"), ("status", "ok")]),
    row_of([("id", "B"), ("status", "ok")]),
    row_of([("id", "C"), ("status", "")]),
    row_of([("id", "D"), ("status", "ok")]),
    row_of([("id", "E"), ("status", "ok")]),
    row_of([("id", "F"), ("status", "ok")]),
    row_of([("id", "G"), ("status", "ok")]),
    row_of([("id", "H"), ("status", "ok")]),
    row_of([("id", "I"), ("status", "ok")]),
    row_of([("id", "J"), ("status", "ok")]),
  ]
  let report = validate_rows(
    { name: "boundary", version: "1.0.0", fields: [], rules: [] },
    rows,
  )
  let score = quality_score(profile_rows(rows), report)

  assert_eq(score.total_cells, 20)
  assert_eq(score.non_empty_cells, 19)
  assert_eq(score.completeness_percent, 95)
  assert_eq(score.score_percent, 95)
  assert_eq(score.grade, "A")
}

///|
test "quality score caps severe failures at zero" {
  let rows = [
    row_of([("id", "A")]),
    row_of([("id", "A")]),
    row_of([("id", "A")]),
    row_of([("id", "A")]),
  ]
  let report = validate_rows(
    {
      name: "severe",
      version: "1.0.0",
      fields: [],
      rules: [
        Unique(fields=["id"], severity=Error, message="unique"),
        StringLength(
          field="missing",
          min=4,
          max=4,
          severity=Warning,
          message="length",
        ),
      ],
    },
    rows,
  )
  let score = quality_score(profile_rows(rows), report)

  assert_eq(score.error_row_count, 3)
  assert_eq(score.warning_row_count, 4)
  assert_eq(score.score_percent, 0)
  assert_eq(score.grade, "F")
}

///|
test "rule references cover every field-bearing rule" {
  let severity : Severity = Error
  let message = ""
  let expected = [
    ["id"],
    ["status"],
    ["kind"],
    ["amount"],
    ["left", "right"],
    ["email"],
    ["name"],
    ["category"],
    ["state", "target"],
    [],
  ]
  let rules : Array[Rule] = [
    Unique(fields=["id"], severity~, message~),
    Completeness(field="status", min_percent=80, severity~, message~),
    Enum(field="kind", allowed_values=["a"], severity~, message~),
    IntRange(field="amount", min=0, max=10, severity~, message~),
    CompareInts(left="left", op=Equal, right="right", severity~, message~),
    PatternMatch(field="email", pattern="contains:@", severity~, message~),
    StringLength(field="name", min=1, max=8, severity~, message~),
    DistinctCount(field="category", min=1, max=2, severity~, message~),
    RequiredIf(
      condition_field="state",
      condition_value="active",
      field="target",
      severity~,
      message~,
    ),
    RowCount(min=Some(1), max=None, severity~, message~),
  ]

  for index, rule in rules {
    assert_true(rule_field_references(rule) == expected[index])
  }
}
