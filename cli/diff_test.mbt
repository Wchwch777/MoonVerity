///|
test "diff-contract command renders field changes" {
  let before =
    #|{
    #|  "name": "retail_orders",
    #|  "version": "1.0.0",
    #|  "fields": [
    #|    { "name": "order_id", "required": true }
    #|  ],
    #|  "rules": []
    #|}
  let after =
    #|{
    #|  "name": "retail_orders",
    #|  "version": "1.1.0",
    #|  "fields": [
    #|    { "name": "order_id", "required": true },
    #|    { "name": "status", "required": true }
    #|  ],
    #|  "rules": []
    #|}

  let output = run_diff_contract_text(before, after)

  assert_true(output.contains("added fields: status"))
}

///|
test "diff-contract command renders machine-readable changes" {
  let before =
    #|{
    #|  "name": "orders",
    #|  "version": "1.0.0",
    #|  "fields": [],
    #|  "rules": []
    #|}
  let after =
    #|{
    #|  "name": "orders",
    #|  "version": "1.1.0",
    #|  "fields": [
    #|    { "name": "status" }
    #|  ],
    #|  "rules": []
    #|}
  let output = run_diff_contract_json(before, after)

  assert_true(output.contains("\"added_fields\""))
  assert_true(output.contains("status"))
}
