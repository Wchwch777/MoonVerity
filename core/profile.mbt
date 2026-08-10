///|
pub fn profile_rows(rows : Array[DataRow]) -> DatasetProfile {
  let names = []
  let seen : Map[String, Unit] = Map([])
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
  let mut min_length = 0
  let mut max_length = 0
  let mut total_length = 0
  let values = []
  for row in rows {
    match row.get(name) {
      Some(value) =>
        if value.trim().to_owned() != "" {
          non_empty_count += 1
          let normalized = value.trim().to_owned()
          let length = normalized.length()
          if non_empty_count == 1 {
            min_length = length
            max_length = length
          } else {
            if length < min_length {
              min_length = length
            }
            if length > max_length {
              max_length = length
            }
          }
          total_length += length
          values.push(normalized)
        }
      None => ()
    }
  }
  {
    name,
    non_empty_count,
    empty_count: rows.length() - non_empty_count,
    distinct_values: unique_strings(values),
    min_length,
    max_length,
    total_length,
  }
}
