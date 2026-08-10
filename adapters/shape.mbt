///|
/// Structural facts about a normalized row collection.
pub(all) struct DatasetShape {
  row_count : Int
  column_names : Array[String]
  min_columns_per_row : Int
  max_columns_per_row : Int
  empty_row_count : Int
} derive(Eq, Debug)

///|
/// Inspect row shape without interpreting field values.
pub fn inspect_shape(rows : Array[Map[String, String]]) -> DatasetShape {
  let column_names = []
  let mut min_columns = -1
  let mut max_columns = 0
  let mut empty_row_count = 0
  for row in rows {
    let column_count = row.length()
    if column_count == 0 {
      empty_row_count += 1
    }
    if min_columns < 0 || column_count < min_columns {
      min_columns = column_count
    }
    if column_count > max_columns {
      max_columns = column_count
    }
    for name, _ in row {
      if !column_names.contains(name) {
        column_names.push(name)
      }
    }
  }
  column_names.sort()
  {
    row_count: rows.length(),
    column_names,
    min_columns_per_row: if min_columns < 0 {
      0
    } else {
      min_columns
    },
    max_columns_per_row: max_columns,
    empty_row_count,
  }
}
