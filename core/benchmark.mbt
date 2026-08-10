///|
/// One reproducible validation case for a benchmark or acceptance fixture.
pub(all) struct BenchmarkCase {
  name : String
  contract : Contract
  rows : Array[DataRow]
  expected_passed : Bool
} derive(Eq, Debug)

///|
/// The observed result of one benchmark case.
pub(all) struct BenchmarkCaseResult {
  name : String
  expected_passed : Bool
  actual_passed : Bool
  consistent : Bool
  row_count : Int
  failure_count : Int
  warning_count : Int
  quality : QualityScore
} derive(Eq, Debug)

///|
/// Aggregated benchmark results. `passed` means every expectation matched.
pub(all) struct BenchmarkSuite {
  passed : Bool
  case_count : Int
  cases : Array[BenchmarkCaseResult]
  failed_cases : Array[String]
} derive(Eq, Debug)

///|
/// Run a deterministic suite without wall-clock timing or platform noise.
pub fn run_benchmark_suite(cases : Array[BenchmarkCase]) -> BenchmarkSuite {
  let results = []
  let failed_cases = []
  for case in cases {
    let report = validate_rows_with_schema(case.contract, case.rows)
    let quality = quality_score(profile_rows(case.rows), report)
    let consistent = report.passed == case.expected_passed
    if !consistent {
      failed_cases.push(case.name)
    }
    results.push({
      name: case.name,
      expected_passed: case.expected_passed,
      actual_passed: report.passed,
      consistent,
      row_count: report.row_count,
      failure_count: report.failure_count,
      warning_count: report.warning_count,
      quality,
    })
  }
  {
    passed: failed_cases.is_empty(),
    case_count: results.length(),
    cases: results,
    failed_cases,
  }
}
