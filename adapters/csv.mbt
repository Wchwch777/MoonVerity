///|
pub fn parse_csv_text(source : String) -> Array[Map[String, String]] {
  let lines = normalized_lines(source)
  if lines.is_empty() {
    []
  } else {
    let headers = parse_csv_line(lines[0])
    let rows = []
    for line in lines[1:] {
      if line.trim().to_owned() != "" {
        let cells = parse_csv_line(line)
        rows.push(row_from_headers(headers, cells))
      }
    }
    rows
  }
}

///|
pub fn read_csv_file(path : String) -> Array[Map[String, String]] {
  let source = @fs.read_file_to_string(path) catch {
    _ => abort("failed to read csv file: \{path}")
  }
  parse_csv_text(source)
}

///|
fn parse_csv_line(line : String) -> Array[String] {
  let cells = []
  let mut current = ""
  let mut in_quotes = false
  for ch in line {
    if ch == '"' {
      in_quotes = !in_quotes
    } else if ch == ',' && !in_quotes {
      cells.push(current)
      current = ""
    } else {
      current = current + "\{ch}"
    }
  }
  cells.push(current)
  cells.map(fn(cell) { cell.trim().to_owned() })
}

///|
fn row_from_headers(
  headers : Array[String],
  cells : Array[String],
) -> Map[String, String] {
  let row : Map[String, String] = {}
  for index, header in headers {
    row[header] = if index < cells.length() { cells[index] } else { "" }
  }
  row
}

///|
fn normalized_lines(source : String) -> Array[String] {
  source
  .split("\r\n")
  .to_array()
  .join("\n")
  .split("\n")
  .to_array()
  .filter(fn(line) { line.trim().to_owned() != "" })
  .map(fn(line) { line.to_owned() })
}
