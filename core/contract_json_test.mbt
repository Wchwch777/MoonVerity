///|
test "parse contract json text into contract model" {
  let source =
    #|{
    #|  "name": "retail_orders",
    #|  "version": "1.0.0",
    #|  "fields": [
    #|    {
    #|      "name": "order_id",
    #|      "required": true,
    #|      "description": "Order identifier"
    #|    },
    #|    {
    #|      "name": "amount",
    #|      "kind": "int",
    #|      "required": true,
    #|      "min_int": 1,
    #|      "max_int": 10000,
    #|      "description": "Order amount"
    #|    }
    #|  ],
    #|  "rules": [
    #|    {
    #|      "kind": "unique",
    #|      "fields": ["order_id"],
    #|      "severity": "error",
    #|      "message": "order_id must be unique"
    #|    },
    #|    {
    #|      "kind": "int_range",
    #|      "field": "amount",
    #|      "min": 1,
    #|      "max": 10000,
    #|      "severity": "error",
    #|      "message": "amount out of range"
    #|    }
    #|  ]
    #|}

  let contract = parse_contract_json(source)

  assert_eq(contract.name, "retail_orders")
  assert_eq(contract.version, "1.0.0")
  assert_eq(contract.fields.length(), 2)
  assert_true(contract.fields[1].kind == Int)
  assert_eq(contract.rules.length(), 2)
}

///|
test "parse advanced rule configuration" {
  let source =
    #|{
    #|  "name": "advanced",
    #|  "version": "1.0.0",
    #|  "fields": [],
    #|  "rules": [
    #|    {
    #|      "kind": "string_length",
    #|      "field": "sku",
    #|      "min_length": 3,
    #|      "max_length": 8
    #|    },
    #|    {
    #|      "kind": "distinct_count",
    #|      "field": "region",
    #|      "min": 2,
    #|      "max": 4
    #|    },
    #|    {
    #|      "kind": "required_if",
    #|      "condition_field": "status",
    #|      "condition_value": "shipped",
    #|      "field": "tracking"
    #|    }
    #|  ]
    #|}

  let contract = parse_contract_json(source)

  assert_eq(contract.rules.length(), 3)
  assert_true(contract.rules[0] is StringLength(..))
  assert_true(contract.rules[1] is DistinctCount(..))
  assert_true(contract.rules[2] is RequiredIf(..))
}
