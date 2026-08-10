///|
test "csv parser handles header-only and trailing empty cells" {
  let header_only = parse_csv_text("id,status\r\n")
  let trailing = parse_csv_text("id,status,amount\n1,paid,\n")

  assert_true(header_only.is_empty())
  assert_eq(trailing.length(), 1)
  assert_eq(trailing[0]["amount"], "")
}

///|
test "csv parser keeps spaces inside quoted cells" {
  let rows = parse_csv_text("id,note\n1,\"  keep spaces  \"\n")

  assert_eq(rows[0]["note"], "keep spaces")
}

///|
test "jsonl parser normalizes primitive values" {
  let rows = parse_jsonl_text(
    "\n{\"enabled\":true,\"score\":-2,\"note\":null}\n\n",
  )

  assert_eq(rows.length(), 1)
  assert_eq(rows[0]["enabled"], "true")
  assert_eq(rows[0]["score"], "-2")
  assert_eq(rows[0]["note"], "")
}

///|
test "jsonl parser preserves nested values as canonical json" {
  let rows = parse_jsonl_text("{\"meta\":{\"source\":\"test\"}}\n")

  assert_true(rows[0]["meta"].contains("source"))
  assert_true(rows[0]["meta"].contains("test"))
}
