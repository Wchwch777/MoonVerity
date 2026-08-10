///|
test "profile rows summarizes completeness and enum cardinality" {
  let rows = [
    row_of([("order_id", "ORD-001"), ("status", "paid")]),
    row_of([("order_id", "ORD-002"), ("status", "paid")]),
    row_of([("order_id", "ORD-003"), ("status", "shipped")]),
    row_of([("order_id", "ORD-004"), ("status", "")]),
  ]

  let profile = profile_rows(rows)

  assert_eq(profile.row_count, 4)
  assert_eq(profile.columns.length(), 2)
  assert_eq(profile.columns[1].name, "status")
  assert_eq(profile.columns[1].non_empty_count, 3)
  assert_eq(profile.columns[1].distinct_values.length(), 2)
  assert_eq(profile.columns[1].min_length, 4)
  assert_eq(profile.columns[1].max_length, 7)
  assert_eq(profile.columns[1].total_length, 15)
}

///|
test "profile empty dataset has no columns" {
  let profile = profile_rows([])

  assert_eq(profile.row_count, 0)
  assert_true(profile.columns.is_empty())
}
