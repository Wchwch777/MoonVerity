///|
fn main {
  let args = @env.args()
  if args.length() < 2 {
    print_usage_and_exit(1)
  }

  match args[1] {
    "validate" => handle_validate(args)
    "profile" => println(handle_profile(args))
    "diff-contract" => println(handle_diff_contract(args))
    "check-contract" => handle_contract_check(args)
    _ => print_usage_and_exit(1)
  }
}

///|
fn handle_validate(args : Array[String]) -> Unit {
  if args.length() < 4 {
    print_usage_and_exit(1)
  }
  let contract_text = read_text(args[2])
  let data_path = args[3]
  let data_text = read_text(data_path)
  let format = detect_data_format(data_path)
  let as_json = args.length() > 4 && args[4] == "--json"
  let outcome = if as_json {
    @cli.validate_json(contract_text, data_text, format)
  } else {
    @cli.validate_text(contract_text, data_text, format)
  }
  println(outcome.output)
  @sys.exit(if outcome.passed { 0 } else { 1 })
}

///|
fn handle_profile(args : Array[String]) -> String {
  if args.length() < 3 {
    print_usage_and_exit(1)
  }
  let data_path = args[2]
  let data_text = read_text(data_path)
  let data_format = detect_data_format(data_path)
  if args.length() > 3 && args[3] == "--json" {
    @cli.run_profile_json(data_text, data_format)
  } else {
    @cli.run_profile_text(data_text, data_format)
  }
}

///|
fn handle_diff_contract(args : Array[String]) -> String {
  if args.length() < 4 {
    print_usage_and_exit(1)
  }
  let before = read_text(args[2])
  let after = read_text(args[3])
  if args.length() > 4 && args[4] == "--json" {
    @cli.run_diff_contract_json(before, after)
  } else {
    @cli.run_diff_contract_text(before, after)
  }
}

///|
fn handle_contract_check(args : Array[String]) -> Unit {
  if args.length() < 3 {
    print_usage_and_exit(1)
  }
  let contract_text = read_text(args[2])
  let outcome = if args.length() > 3 && args[3] == "--json" {
    @cli.run_contract_check_json(contract_text)
  } else {
    @cli.run_contract_check_text(contract_text)
  }
  println(outcome.output)
  @sys.exit(if outcome.passed { 0 } else { 1 })
}

///|
fn read_text(path : String) -> String {
  @fs.read_file_to_string(path) catch {
    _ => abort("failed to read file: \{path}")
  }
}

///|
fn detect_data_format(path : String) -> String {
  if path.has_suffix(".csv") {
    "csv"
  } else if path.has_suffix(".jsonl") {
    "jsonl"
  } else {
    abort("unsupported data file: \{path}")
  }
}

///|
fn print_usage_and_exit(code : Int) -> Unit {
  println("MoonVerity CLI")
  println("  validate <contract.json> <data.csv|data.jsonl> [--json]")
  println("  profile <data.csv|data.jsonl>")
  println("  diff-contract <before.json> <after.json> [--json]")
  println("  check-contract <contract.json> [--json]")
  @sys.exit(code)
}
