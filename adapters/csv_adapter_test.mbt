///|
test "parse csv text into normalized rows" {
  let source =
    #|order_id,customer_id,status,amount
    #|ORD-001,C001,paid,199
    #|ORD-002,C002,shipped,88
    #|
  let rows = parse_csv_text(source)

  assert_eq(rows.length(), 2)
  assert_eq(rows[0]["order_id"], "ORD-001")
  assert_eq(rows[1]["status"], "shipped")
}
