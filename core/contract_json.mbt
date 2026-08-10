///|
struct ContractConfig {
  name : String
  version : String
  fields : Array[FieldConfig]
  rules : Array[RuleConfig]
} derive(FromJson, Debug)

///|
struct FieldConfig {
  name : String
  kind : String?
  required : Bool?
  nullable : Bool?
  allowed_values : Array[String]?
  min_int : Int?
  max_int : Int?
  pattern : String?
  description : String?
} derive(FromJson, Debug)

///|
struct RuleConfig {
  kind : String
  fields : Array[String]?
  field : String?
  allowed_values : Array[String]?
  min_percent : Int?
  min : Int?
  max : Int?
  left : String?
  op : String?
  right : String?
  pattern : String?
  min_length : Int?
  max_length : Int?
  condition_field : String?
  condition_value : String?
  severity : String?
  message : String?
} derive(FromJson, Debug)

///|
pub fn parse_contract_json(source : String) -> Contract {
  let parsed : Json = @json.parse(source) catch {
    _ => abort("invalid contract json")
  }
  let config : ContractConfig = @json.from_json(parsed) catch {
    _ => abort("contract json does not match expected schema")
  }
  {
    name: config.name,
    version: config.version,
    fields: config.fields.map(field_config_to_spec),
    rules: config.rules.map(rule_config_to_rule),
  }
}

///|
fn field_config_to_spec(config : FieldConfig) -> FieldSpec {
  {
    name: config.name,
    kind: parse_field_type(option_or(config.kind, "string")),
    required: option_or_bool(config.required, false),
    nullable: option_or_bool(config.nullable, false),
    allowed_values: option_or_array(config.allowed_values),
    min_int: config.min_int,
    max_int: config.max_int,
    pattern: config.pattern,
    description: option_or(config.description, ""),
  }
}

///|
fn rule_config_to_rule(config : RuleConfig) -> Rule {
  let severity = parse_severity(option_or(config.severity, "error"))
  let message = option_or(config.message, config.kind)
  match config.kind {
    "unique" =>
      Unique(
        fields=expect_string_array(config.fields, "fields"),
        severity~,
        message~,
      )
    "completeness" =>
      Completeness(
        field=expect_string(config.field, "field"),
        min_percent=expect_int(config.min_percent, "min_percent"),
        severity~,
        message~,
      )
    "enum" =>
      Enum(
        field=expect_string(config.field, "field"),
        allowed_values=expect_string_array(
          config.allowed_values,
          "allowed_values",
        ),
        severity~,
        message~,
      )
    "int_range" =>
      IntRange(
        field=expect_string(config.field, "field"),
        min=expect_int(config.min, "min"),
        max=expect_int(config.max, "max"),
        severity~,
        message~,
      )
    "compare_ints" =>
      CompareInts(
        left=expect_string(config.left, "left"),
        op=parse_comparison_op(expect_string(config.op, "op")),
        right=expect_string(config.right, "right"),
        severity~,
        message~,
      )
    "pattern_match" =>
      PatternMatch(
        field=expect_string(config.field, "field"),
        pattern=expect_string(config.pattern, "pattern"),
        severity~,
        message~,
      )
    "string_length" =>
      StringLength(
        field=expect_string(config.field, "field"),
        min=expect_int(config.min_length, "min_length"),
        max=expect_int(config.max_length, "max_length"),
        severity~,
        message~,
      )
    "distinct_count" =>
      DistinctCount(
        field=expect_string(config.field, "field"),
        min=expect_int(config.min, "min"),
        max=expect_int(config.max, "max"),
        severity~,
        message~,
      )
    "required_if" =>
      RequiredIf(
        condition_field=expect_string(config.condition_field, "condition_field"),
        condition_value=expect_string(config.condition_value, "condition_value"),
        field=expect_string(config.field, "field"),
        severity~,
        message~,
      )
    "row_count" => RowCount(min=config.min, max=config.max, severity~, message~)
    _ => abort("unsupported rule kind: \{config.kind}")
  }
}

///|
fn option_or(value : String?, fallback : String) -> String {
  match value {
    Some(text) => text
    None => fallback
  }
}

///|
fn option_or_bool(value : Bool?, fallback : Bool) -> Bool {
  match value {
    Some(flag) => flag
    None => fallback
  }
}

///|
fn option_or_array(value : Array[String]?) -> Array[String] {
  match value {
    Some(values) => values
    None => []
  }
}

///|
fn expect_string(value : String?, label : String) -> String {
  match value {
    Some(text) => text
    None => abort("missing rule property: \{label}")
  }
}

///|
fn expect_string_array(value : Array[String]?, label : String) -> Array[String] {
  match value {
    Some(values) => values
    None => abort("missing rule property: \{label}")
  }
}

///|
fn expect_int(value : Int?, label : String) -> Int {
  match value {
    Some(number) => number
    None => abort("missing rule property: \{label}")
  }
}

///|
fn parse_field_type(value : String) -> FieldType {
  match value.to_lower() {
    "string" => String
    "int" => Int
    "bool" => Bool
    "date" => Date
    _ => abort("unsupported field type: \{value}")
  }
}

///|
fn parse_severity(value : String) -> Severity {
  match value.to_lower() {
    "error" => Error
    "warning" => Warning
    _ => abort("unsupported severity: \{value}")
  }
}

///|
fn parse_comparison_op(value : String) -> ComparisonOp {
  match value {
    ">=" => GreaterOrEqual
    ">" => GreaterThan
    "<=" => LessOrEqual
    "<" => LessThan
    "==" => Equal
    _ => abort("unsupported comparison op: \{value}")
  }
}
