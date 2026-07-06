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
