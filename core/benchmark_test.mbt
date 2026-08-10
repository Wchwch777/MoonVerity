///|
test "benchmark suite records expected and actual outcomes" {
  let valid_contract : Contract = {
    name: "valid",
    version: "1.0.0",
    fields: [],
    rules: [RowCount(min=Some(2), max=Some(3), severity=Error, message="rows")],
  }
  let cases : Array[BenchmarkCase] = [
    {
      name: "valid-two-rows",
      contract: valid_contract,
      rows: [row_of([]), row_of([])],
      expected_passed: true,
    },
    {
      name: "invalid-one-row",
      contract: valid_contract,
      rows: [row_of([])],
      expected_passed: false,
    },
    {
      name: "intentionally-wrong-expectation",
      contract: valid_contract,
      rows: [row_of([]), row_of([])],
      expected_passed: false,
    },
  ]

  let suite = run_benchmark_suite(cases)

  assert_eq(suite.case_count, 3)
  assert_true(!suite.passed)
  assert_eq(suite.failed_cases, ["intentionally-wrong-expectation"])
  assert_true(suite.cases[0].consistent)
  assert_true(suite.cases[1].consistent)
  assert_true(!suite.cases[2].consistent)
  assert_eq(suite.cases[0].row_count, 2)
  assert_eq(suite.cases[1].failure_count, 1)
}

///|
test "empty benchmark suite is a successful no-op" {
  let suite = run_benchmark_suite([])

  assert_true(suite.passed)
  assert_eq(suite.case_count, 0)
  assert_true(suite.failed_cases.is_empty())
}
