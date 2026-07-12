///|
pub type DataRow = Map[String, String]

///|
pub(all) enum FieldType {
  String
  Int
  Bool
  Date
} derive(Eq, Debug)

///|
pub(all) enum Severity {
  Error
  Warning
} derive(Eq, Debug)

///|
pub(all) enum ComparisonOp {
  GreaterOrEqual
  GreaterThan
  LessOrEqual
  LessThan
  Equal
} derive(Eq, Debug)

///|
pub(all) struct FieldSpec {
  name : String
  kind : FieldType
  required : Bool
  nullable : Bool
  allowed_values : Array[String]
  min_int : Int?
  max_int : Int?
  pattern : String?
  description : String
} derive(Eq, Debug)

///|
pub(all) enum Rule {
  Unique(fields~ : Array[String], severity~ : Severity, message~ : String)
  Completeness(
    field~ : String,
    min_percent~ : Int,
    severity~ : Severity,
    message~ : String
  )
  Enum(
    field~ : String,
    allowed_values~ : Array[String],
    severity~ : Severity,
    message~ : String
  )
  IntRange(
    field~ : String,
    min~ : Int,
    max~ : Int,
    severity~ : Severity,
    message~ : String
  )
  CompareInts(
    left~ : String,
    op~ : ComparisonOp,
    right~ : String,
    severity~ : Severity,
    message~ : String
  )
  PatternMatch(
    field~ : String,
    pattern~ : String,
    severity~ : Severity,
    message~ : String
  )
  RowCount(min~ : Int?, max~ : Int?, severity~ : Severity, message~ : String)
} derive(Eq, Debug)

///|
pub(all) struct Contract {
  name : String
  version : String
  fields : Array[FieldSpec]
  rules : Array[Rule]
} derive(Eq, Debug)

///|
pub(all) struct RuleResult {
  name : String
  severity : Severity
  passed : Bool
  failure_rows : Array[Int]
  message : String
} derive(Eq, Debug)

///|
pub(all) struct ValidationReport {
  dataset_name : String
  row_count : Int
  passed : Bool
  failure_count : Int
  warning_count : Int
  rule_results : Array[RuleResult]
} derive(Eq, Debug)

///|
pub(all) struct ColumnProfile {
  name : String
  non_empty_count : Int
  empty_count : Int
  distinct_values : Array[String]
} derive(Eq, Debug)

///|
pub(all) struct DatasetProfile {
  row_count : Int
  columns : Array[ColumnProfile]
} derive(Eq, Debug)

///|
pub(all) struct ContractDiff {
  added_fields : Array[String]
  removed_fields : Array[String]
  changed_fields : Array[String]
} derive(Eq, Debug)
