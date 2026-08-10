///|
pub fn parse_jsonl_text(source : String) -> Array[Map[String, String]] {
  let rows = []
  for line in source.split("\n") {
    let text = line.trim().to_owned()
    if text != "" {
      rows.push(parse_jsonl_row(text))
    }
  }
  rows
}

///|
pub fn read_jsonl_file(path : String) -> Array[Map[String, String]] {
  let source = @fs.read_file_to_string(path) catch {
    _ => abort("failed to read jsonl file: \{path}")
  }
  parse_jsonl_text(source)
}

///|
fn parse_jsonl_row(line : String) -> Map[String, String] {
  let parsed : Json = @json.parse(line) catch {
    _ => abort("invalid jsonl line")
  }
  let object : Map[String, Json] = @json.from_json(parsed) catch {
    _ => abort("jsonl line must be an object")
  }
  let row : Map[String, String] = Map([])
  for key, value in object {
    row[key] = json_value_to_cell(value)
  }
  row
}

///|
fn json_value_to_cell(value : Json) -> String {
  if value == Json::null() {
    ""
  } else {
    match json_as_string(value) {
      Some(text) => text
      None =>
        match json_as_int(value) {
          Some(number) => "\{number}"
          None =>
            match json_as_bool(value) {
              Some(flag) => "\{flag}"
              None => value.stringify()
            }
        }
    }
  }
}

///|
fn json_as_string(value : Json) -> String? {
  try @json.from_json(value) catch {
    _ => None
  } noraise {
    text => Some(text)
  }
}

///|
fn json_as_int(value : Json) -> Int? {
  try @json.from_json(value) catch {
    _ => None
  } noraise {
    number => Some(number)
  }
}

///|
fn json_as_bool(value : Json) -> Bool? {
  try @json.from_json(value) catch {
    _ => None
  } noraise {
    flag => Some(flag)
  }
}
