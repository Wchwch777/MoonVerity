///|
fn main {
  let args = @env.args()
  if args.length() < 2 {
    print_usage_and_exit(1)
  }

  let output = match args[1] {
    "validate" => handle_validate(args)
    "profile" => handle_profile(args)
    "diff-contract" => handle_diff_contract(args)
    _ => {
      print_usage_and_exit(1)
      ""
    }
  }
  println(output)
}

///|
fn handle_validate(args : Array[String]) -> String {
  if args.length() < 4 {
    print_usage_and_exit(1)
  }
  let contract_text = read_text(args[2])
  let data_path = args[3]
  let data_text = read_text(data_path)
  let format = detect_data_format(data_path)
  let as_json = args.length() > 4 && args[4] == "--json"
  if as_json {
    @cli.run_validate_json(contract_text, data_text, format)
  } else {
    @cli.run_validate_text(contract_text, data_text, format)
  }
}

///|
fn handle_profile(args : Array[String]) -> String {
  if args.length() < 3 {
    print_usage_and_exit(1)
  }
  let data_path = args[2]
  @cli.run_profile_text(read_text(data_path), detect_data_format(data_path))
}

///|
fn handle_diff_contract(args : Array[String]) -> String {
  if args.length() < 4 {
    print_usage_and_exit(1)
  }
  @cli.run_diff_contract_text(read_text(args[2]), read_text(args[3]))
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
  println("  diff-contract <before.json> <after.json>")
  @sys.exit(code)
}
