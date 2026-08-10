///|
test "quality score reports completeness and clean data as grade A" {
  let rows = [
    row_of([("id", "A"), ("status", "paid")]),
    row_of([("id", "B"), ("status", "shipped")]),
  ]
  let report = validate_rows(
    { name: "quality", version: "1.0.0", fields: [], rules: [] },
    rows,
  )

  let score = quality_score(profile_rows(rows), report)

  assert_eq(score.total_cells, 4)
  assert_eq(score.non_empty_cells, 4)
  assert_eq(score.completeness_percent, 100)
  assert_eq(score.error_row_count, 0)
  assert_eq(score.warning_row_count, 0)
  assert_eq(score.score_percent, 100)
  assert_eq(score.grade, "A")
}

///|
test "quality score separates warning and error affected rows" {
  let rows = [
    row_of([("id", "A"), ("status", "bad")]),
    row_of([("id", "A"), ("status", "ok")]),
    row_of([("id", "C"), ("status", "")]),
  ]
  let report = validate_rows(
    {
      name: "quality",
      version: "1.0.0",
      fields: [],
      rules: [
        Unique(fields=["id"], severity=Error, message="id"),
        Enum(
          field="status",
          allowed_values=["ok"],
          severity=Warning,
          message="status",
        ),
      ],
    },
    rows,
  )

  let score = quality_score(profile_rows(rows), report)

  assert_eq(score.error_row_count, 1)
  assert_eq(score.warning_row_count, 1)
  assert_true(score.score_percent < 100)
  assert_eq(score.grade, "F")
}

///|
test "quality score handles an empty profile without division by zero" {
  let report = validate_rows(
    { name: "empty", version: "1.0.0", fields: [], rules: [] },
    [],
  )
  let score = quality_score(profile_rows([]), report)

  assert_eq(score.total_cells, 0)
  assert_eq(score.completeness_percent, 100)
  assert_eq(score.score_percent, 100)
  assert_eq(score.grade, "A")
}
