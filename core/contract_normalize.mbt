///|
/// Normalize user-authored contract metadata without changing its intent.
pub fn normalize_contract(contract : Contract) -> Contract {
  {
    name: contract.name.trim().to_owned(),
    version: contract.version.trim().to_owned(),
    fields: contract.fields.map(normalize_field),
    rules: contract.rules.map(normalize_rule),
  }
}

///|
fn normalize_field(field : FieldSpec) -> FieldSpec {
  {
    name: field.name.trim().to_owned(),
    kind: field.kind,
    required: field.required,
    nullable: field.nullable,
    allowed_values: unique_strings(
      field.allowed_values.map(fn(value) { value.trim().to_owned() }),
    ),
    min_int: field.min_int,
    max_int: field.max_int,
    pattern: field.pattern.map(fn(value) { value.trim().to_owned() }),
    description: field.description.trim().to_owned(),
  }
}

///|
fn normalize_rule(rule : Rule) -> Rule {
  match rule {
    Unique(fields~, severity~, message~) =>
      Unique(
        fields=fields.map(fn(field) { field.trim().to_owned() }),
        severity~,
        message=message.trim().to_owned(),
      )
    Completeness(field~, min_percent~, severity~, message~) =>
      Completeness(
        field=field.trim().to_owned(),
        min_percent~,
        severity~,
        message=message.trim().to_owned(),
      )
    Enum(field~, allowed_values~, severity~, message~) =>
      Enum(
        field=field.trim().to_owned(),
        allowed_values=unique_strings(
          allowed_values.map(fn(value) { value.trim().to_owned() }),
        ),
        severity~,
        message=message.trim().to_owned(),
      )
    IntRange(field~, min~, max~, severity~, message~) =>
      IntRange(
        field=field.trim().to_owned(),
        min~,
        max~,
        severity~,
        message=message.trim().to_owned(),
      )
    CompareInts(left~, op~, right~, severity~, message~) =>
      CompareInts(
        left=left.trim().to_owned(),
        op~,
        right=right.trim().to_owned(),
        severity~,
        message=message.trim().to_owned(),
      )
    PatternMatch(field~, pattern~, severity~, message~) =>
      PatternMatch(
        field=field.trim().to_owned(),
        pattern=pattern.trim().to_owned(),
        severity~,
        message=message.trim().to_owned(),
      )
    StringLength(field~, min~, max~, severity~, message~) =>
      StringLength(
        field=field.trim().to_owned(),
        min~,
        max~,
        severity~,
        message=message.trim().to_owned(),
      )
    DistinctCount(field~, min~, max~, severity~, message~) =>
      DistinctCount(
        field=field.trim().to_owned(),
        min~,
        max~,
        severity~,
        message=message.trim().to_owned(),
      )
    RequiredIf(condition_field~, condition_value~, field~, severity~, message~) =>
      RequiredIf(
        condition_field=condition_field.trim().to_owned(),
        condition_value=condition_value.trim().to_owned(),
        field=field.trim().to_owned(),
        severity~,
        message=message.trim().to_owned(),
      )
    RowCount(min~, max~, severity~, message~) =>
      RowCount(min~, max~, severity~, message=message.trim().to_owned())
  }
}
