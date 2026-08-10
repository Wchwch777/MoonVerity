///|
/// A diagnostic quality score derived from profile completeness and validation rows.
/// The score is a dashboard signal, not a replacement for the contract gate.
pub(all) struct QualityScore {
  total_cells : Int
  non_empty_cells : Int
  completeness_percent : Int
  error_row_count : Int
  warning_row_count : Int
  score_percent : Int
  grade : String
} derive(Eq, Debug)

///|
/// Calculate a deterministic score for dashboards and benchmark reports.
pub fn quality_score(
  profile : DatasetProfile,
  report : ValidationReport,
) -> QualityScore {
  let total_cells = profile.row_count * profile.columns.length()
  let non_empty_cells = profile.columns.fold(init=0, fn(total, column) {
    total + column.non_empty_count
  })
  let completeness_percent = if total_cells == 0 {
    100
  } else {
    non_empty_cells * 100 / total_cells
  }
  let error_rows = affected_rows(report, Error)
  let warning_rows = affected_rows(report, Warning)
  let error_penalty = row_penalty(error_rows.length(), report.row_count, 100)
  let warning_penalty = row_penalty(warning_rows.length(), report.row_count, 50)
  let score_percent = clamp_score(
    completeness_percent - error_penalty - warning_penalty,
  )
  {
    total_cells,
    non_empty_cells,
    completeness_percent,
    error_row_count: error_rows.length(),
    warning_row_count: warning_rows.length(),
    score_percent,
    grade: quality_grade(score_percent),
  }
}

///|
fn affected_rows(report : ValidationReport, severity : Severity) -> Array[Int] {
  let rows = []
  for result in report.rule_results {
    if result.severity == severity {
      for row in result.failure_rows {
        if !rows.contains(row) {
          rows.push(row)
        }
      }
    }
  }
  rows.sort()
  rows
}

///|
fn row_penalty(row_count : Int, total_rows : Int, weight : Int) -> Int {
  if total_rows == 0 {
    0
  } else {
    row_count * weight / total_rows
  }
}

///|
fn clamp_score(value : Int) -> Int {
  if value < 0 {
    0
  } else if value > 100 {
    100
  } else {
    value
  }
}

///|
fn quality_grade(score : Int) -> String {
  if score >= 95 {
    "A"
  } else if score >= 85 {
    "B"
  } else if score >= 70 {
    "C"
  } else if score >= 60 {
    "D"
  } else {
    "F"
  }
}
