///|
pub fn profile_rows(rows : Array[DataRow]) -> DatasetProfile {
  let names = []
  let seen : Map[String, Unit] = {}
  for row in rows {
    for name in sorted_keys(row) {
      if !seen.contains(name) {
        seen[name] = ()
        names.push(name)
      }
    }
  }
  {
    row_count: rows.length(),
    columns: names.map(fn(name) { build_column_profile(name, rows) }),
  }
}

///|
fn build_column_profile(name : String, rows : Array[DataRow]) -> ColumnProfile {
  let mut non_empty_count = 0
  let values = []
  for row in rows {
    match row.get(name) {
      Some(value) =>
        if value.trim().to_owned() != "" {
          non_empty_count += 1
          values.push(value)
        }
      None => ()
    }
  }
  {
    name,
    non_empty_count,
    empty_count: rows.length() - non_empty_count,
    distinct_values: unique_strings(values),
  }
}
