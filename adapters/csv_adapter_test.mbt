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

///|
test "parse csv quoted commas escaped quotes and missing cells" {
  let source = "id,note,tail\r\n1,\"a,b\",\"say \"\"hello\"\"\"\r\n2,,\r\n"
  let rows = parse_csv_text(source)

  assert_eq(rows.length(), 2)
  assert_eq(rows[0]["note"], "a,b")
  assert_eq(rows[0]["tail"], "say \"hello\"")
  assert_eq(rows[1]["note"], "")
  assert_eq(rows[1]["tail"], "")
}
