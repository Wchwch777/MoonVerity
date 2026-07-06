///|
test "parse jsonl text into normalized rows" {
  let source =
    #|{"order_id":"ORD-001","customer_id":"C001","status":"paid","amount":199}
    #|{"order_id":"ORD-002","customer_id":"C002","status":"shipped","amount":88}
    #|
  let rows = parse_jsonl_text(source)

  assert_eq(rows.length(), 2)
  assert_eq(rows[0]["amount"], "199")
  assert_eq(rows[1]["customer_id"], "C002")
}
