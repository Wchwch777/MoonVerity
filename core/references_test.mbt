///|
test "contract references are sorted, deduplicated, and expose missing fields" {
  let contract : Contract = {
    name: "references",
    version: "1.0.0",
    fields: [field_spec("status"), field_spec("id"), field_spec("amount")],
    rules: [
      Unique(fields=["id", "missing", "id"], severity=Error, message="unique"),
      CompareInts(
        left="amount",
        op=GreaterOrEqual,
        right="discount",
        severity=Warning,
        message="amount",
      ),
      RequiredIf(
        condition_field="status",
        condition_value="paid",
        field="receipt",
        severity=Error,
        message="receipt",
      ),
    ],
  }

  let references = analyze_contract_references(contract)
  assert_true(
    references.referenced_fields ==
    ["id", "amount", "status", "missing", "receipt", "discount"],
  )
  assert_true(references.missing_fields == ["missing", "receipt", "discount"])
  assert_true(references.unused_fields == [])
  assert_true(rule_field_references(contract.rules[0]) == ["id", "missing"])

  let codes = inspect_contract(contract).map(fn(issue) { issue.code })
  let missing_count = codes.fold(init=0, fn(count, code) {
    if code == "missing_field_reference" {
      count + 1
    } else {
      count
    }
  })
  assert_eq(missing_count, 3)
}

///|
test "row count rules do not create field references" {
  let contract : Contract = {
    name: "row_count",
    version: "1.0.0",
    fields: [field_spec("unused")],
    rules: [RowCount(min=Some(1), max=Some(4), severity=Error, message="rows")],
  }

  let references = analyze_contract_references(contract)

  assert_true(references.referenced_fields.is_empty())
  assert_true(references.missing_fields.is_empty())
  assert_true(references.unused_fields == ["unused"])
}
