///|
test "normalize rows trims column names and values" {
  let rows = normalize_rows([
    Map::from_array([(" id ", " 1 "), ("status", " paid ")]),
  ])

  assert_eq(rows[0].get("id"), Some("1"))
  assert_eq(rows[0].get("status"), Some("paid"))
  assert_true(rows[0].get(" id ") is None)
}

///|
test "project rows fills missing columns deterministically" {
  let rows = project_rows(
    [Map::from_array([("id", "1"), ("status", "paid")])],
    ["status", "amount", "id"],
  )

  assert_eq(rows[0].keys().to_array(), ["status", "amount", "id"])
  assert_eq(rows[0]["status"], "paid")
  assert_eq(rows[0]["amount"], "")
  assert_eq(rows[0]["id"], "1")
}

///|
test "row columns are sorted and deduplicated" {
  let columns = row_columns([
    Map::from_array([("z", "1"), ("a", "2")]),
    Map::from_array([("m", "3"), ("a", "4")]),
  ])

  assert_true(columns == ["a", "m", "z"])
}

///|
test "render csv quotes values and round trips through parser" {
  let rows = [
    Map::from_array([("id", "1"), ("note", "a,b"), ("quote", "say \"hi\"")]),
  ]
  let csv = render_csv(rows, ["id", "note", "quote"])
  let parsed = parse_csv_text(csv)

  assert_true(csv.contains("\"a,b\""))
  assert_true(csv.contains("\"say \"\"hi\"\"\""))
  assert_eq(parsed[0]["note"], "a,b")
  assert_eq(parsed[0]["quote"], "say \"hi\"")
}

///|
test "render jsonl round trips normalized string cells" {
  let rows = [Map::from_array([("id", "1"), ("status", "paid")])]
  let jsonl = render_jsonl(rows)
  let parsed = parse_jsonl_text(jsonl)

  assert_eq(parsed.length(), 1)
  assert_eq(parsed[0]["id"], "1")
  assert_eq(parsed[0]["status"], "paid")
}
