///|
pub fn row_of(entries : Array[(String, String)]) -> DataRow {
  Map::from_iter(entries.iter())
}

///|
pub fn field_spec(
  name : String,
  kind? : FieldType = String,
  required? : Bool = false,
  nullable? : Bool = false,
  allowed_values? : Array[String] = [],
  min_int? : Int,
  max_int? : Int,
  pattern? : String,
  description? : String = "",
) -> FieldSpec {
  {
    name,
    kind,
    required,
    nullable,
    allowed_values,
    min_int,
    max_int,
    pattern,
    description,
  }
}

///|
fn non_empty(value : String?) -> Bool {
  match value {
    Some(text) => text.trim().to_owned() != ""
    None => false
  }
}

///|
fn parse_int_option(text : String?) -> Int? {
  match text {
    Some(raw) => {
      let trimmed = raw.trim().to_owned()
      if trimmed == "" {
        None
      } else {
        try @string.parse_int(trimmed) catch {
          _ => None
        } noraise {
          value => Some(value)
        }
      }
    }
    None => None
  }
}

///|
fn option_or_empty(value : String?) -> String {
  match value {
    Some(text) => text
    None => ""
  }
}

///|
fn compare_ints(left : Int, op : ComparisonOp, right : Int) -> Bool {
  match op {
    GreaterOrEqual => left >= right
    GreaterThan => left > right
    LessOrEqual => left <= right
    LessThan => left < right
    Equal => left == right
  }
}

///|
fn unique_strings(values : Array[String]) -> Array[String] {
  let seen : Map[String, Unit] = Map([])
  let result = []
  for value in values {
    if !seen.contains(value) {
      seen[value] = ()
      result.push(value)
    }
  }
  result
}

///|
fn sorted_keys(row : DataRow) -> Array[String] {
  row.keys().to_array()
}

///|
fn rule_name(rule : Rule) -> String {
  match rule {
    Unique(fields~, ..) => "unique(\{fields.join(",")})"
    Completeness(field~, ..) => "completeness(\{field})"
    Enum(field~, ..) => "enum(\{field})"
    IntRange(field~, ..) => "int_range(\{field})"
    CompareInts(left~, right~, ..) => "compare(\{left},\{right})"
    PatternMatch(field~, ..) => "pattern_match(\{field})"
    StringLength(field~, ..) => "string_length(\{field})"
    DistinctCount(field~, ..) => "distinct_count(\{field})"
    RequiredIf(condition_field~, field~, ..) =>
      "required_if(\{condition_field},\{field})"
    RowCount(..) => "row_count"
  }
}

///|
fn severity_of(rule : Rule) -> Severity {
  match rule {
    Unique(severity~, ..) => severity
    Completeness(severity~, ..) => severity
    Enum(severity~, ..) => severity
    IntRange(severity~, ..) => severity
    CompareInts(severity~, ..) => severity
    PatternMatch(severity~, ..) => severity
    StringLength(severity~, ..) => severity
    DistinctCount(severity~, ..) => severity
    RequiredIf(severity~, ..) => severity
    RowCount(severity~, ..) => severity
  }
}

///|
fn message_of(rule : Rule) -> String {
  match rule {
    Unique(message~, ..) => message
    Completeness(message~, ..) => message
    Enum(message~, ..) => message
    IntRange(message~, ..) => message
    CompareInts(message~, ..) => message
    PatternMatch(message~, ..) => message
    StringLength(message~, ..) => message
    DistinctCount(message~, ..) => message
    RequiredIf(message~, ..) => message
    RowCount(message~, ..) => message
  }
}
