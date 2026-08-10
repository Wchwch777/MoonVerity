///|
test "profile command renders column summary" {
  let data =
    #|order_id,status
    #|ORD-001,paid
    #|ORD-002,shipped
    #|ORD-003,paid
    #|

  let output = run_profile_text(data, "csv")

  assert_true(output.contains("rows: 3"))
  assert_true(output.contains("column: status"))
  assert_true(output.contains("distinct: 2"))
}

///|
test "profile command renders machine-readable metrics" {
  let data =
    #|id,status
    #|1,paid
    #|2,shipped
  let output = run_profile_json(data, "csv")

  assert_true(output.contains("\"row_count\": 2"))
  assert_true(output.contains("\"min_length\": 4"))
  assert_true(output.contains("\"max_length\": 7"))
}
