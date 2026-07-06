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
