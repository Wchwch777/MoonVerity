///|
test "validate command renders readable summary" {
  let contract =
    #|{
    #|  "name": "retail_orders",
    #|  "version": "1.0.0",
    #|  "fields": [],
    #|  "rules": [
    #|    {
    #|      "kind": "unique",
    #|      "fields": ["order_id"],
    #|      "severity": "error",
    #|      "message": "order_id must be unique"
    #|    }
    #|  ]
    #|}
  let data =
    #|order_id,customer_id
    #|ORD-001,C001
    #|ORD-001,C002
    #|

  let output = run_validate_text(contract, data, "csv")

  assert_true(output.contains("dataset: retail_orders"))
  assert_true(output.contains("passed: false"))
  assert_true(output.contains("order_id must be unique"))
}

///|
test "validate entry point exposes a failing process outcome" {
  let contract =
    #|{
    #|  "name": "orders",
    #|  "version": "1.0.0",
    #|  "fields": [],
    #|  "rules": [
    #|    {
    #|      "kind": "row_count",
    #|      "min": 2,
    #|      "severity": "error",
    #|      "message": "at least two rows are required"
    #|    }
    #|  ]
    #|}
  let outcome = validate_text(contract, "id\n1\n", "csv")

  assert_true(outcome.passed is false)
  assert_true(outcome.output.contains("passed: false"))
}

///|
test "contract check entry point reports invalid configuration" {
  let contract =
    #|{
    #|  "name": "",
    #|  "version": "1.0.0",
    #|  "fields": [],
    #|  "rules": [
    #|    {
    #|      "kind": "row_count"
    #|    }
    #|  ]
    #|}
  let outcome = run_contract_check_text(contract)

  assert_true(outcome.passed is false)
  assert_true(outcome.output.contains("missing_name"))
}
