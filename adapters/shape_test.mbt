///|
test "shape inspection reports union columns and row width boundaries" {
  let rows : Array[Map[String, String]] = [
    Map([("id", "1"), ("status", "paid")]),
    Map([("id", "2")]),
    Map([]),
  ]
  let shape = inspect_shape(rows)

  assert_eq(shape.row_count, 3)
  assert_true(shape.column_names == ["id", "status"])
  assert_eq(shape.min_columns_per_row, 0)
  assert_eq(shape.max_columns_per_row, 2)
  assert_eq(shape.empty_row_count, 1)
}

///|
test "shape inspection handles no rows" {
  let shape = inspect_shape([])

  assert_eq(shape.row_count, 0)
  assert_true(shape.column_names.is_empty())
  assert_eq(shape.min_columns_per_row, 0)
  assert_eq(shape.max_columns_per_row, 0)
  assert_eq(shape.empty_row_count, 0)
}
