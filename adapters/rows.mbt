///|
/// Trim keys and values so records from different input sources share one
/// normalization policy before validation or serialization.
pub fn normalize_rows(
  rows : Array[Map[String, String]],
) -> Array[Map[String, String]] {
  rows.map(fn(row) {
    let normalized = Map([])
    for key, value in row {
      normalized[key.trim().to_owned()] = value.trim().to_owned()
    }
    normalized
  })
}

///|
/// Project records to a stable set of columns, filling missing cells with "".
pub fn project_rows(
  rows : Array[Map[String, String]],
  columns : Array[String],
) -> Array[Map[String, String]] {
  rows.map(fn(row) {
    let projected = Map([])
    for column in columns {
      projected[column] = match row.get(column) {
        Some(value) => value
        None => ""
      }
    }
    projected
  })
}

///|
/// Return all column names in sorted order without duplicates.
pub fn row_columns(rows : Array[Map[String, String]]) -> Array[String] {
  let seen = Map([])
  for row in rows {
    for key in row.keys() {
      seen[key] = ()
    }
  }
  let columns = seen.keys().to_array()
  columns.sort()
  columns
}

///|
/// Serialize rows as RFC 4180-compatible single-line CSV records.
pub fn render_csv(
  rows : Array[Map[String, String]],
  columns : Array[String],
) -> String {
  let lines = [columns.map(escape_csv).join(",")]
  for row in rows {
    lines.push(
      columns
      .map(fn(column) {
        escape_csv(
          match row.get(column) {
            Some(value) => value
            None => ""
          },
        )
      })
      .join(","),
    )
  }
  lines.join("\n") + "\n"
}

///|
/// Serialize rows as JSONL with every cell represented as a JSON string.
pub fn render_jsonl(rows : Array[Map[String, String]]) -> String {
  let lines = rows.map(fn(row) {
    let object = Map([])
    for key, value in row {
      object[key] = Json::string(value)
    }
    Json::object(object).stringify()
  })
  if lines.is_empty() {
    ""
  } else {
    lines.join("\n") + "\n"
  }
}

///|
fn escape_csv(value : String) -> String {
  let mut escaped = ""
  for ch in value {
    if ch == '"' {
      escaped = escaped + "\"\""
    } else {
      escaped = escaped + "\{ch}"
    }
  }
  if value.contains(",") || value.contains("\"") || value.contains("\n") {
    "\"\{escaped}\""
  } else {
    escaped
  }
}
