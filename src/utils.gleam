import gleam/string.{split, trim}
import simplifile

pub fn read_lines(filepath: String) -> List(String) {
  let contents = read_file(filepath)
  split(trim(contents), "\n")
}

pub fn read_file(filepath: String) -> String {
  let assert Ok(contents) = simplifile.read(filepath)
  contents
}

pub fn unwrap(r: Result(a, e)) -> a {
  case r {
    Ok(value) -> value
    Error(e) -> {
      let e_str = "unwrap failed, error = " <> string.inspect(e)
      panic as e_str
    }
  }
}

pub type Solution {
  Solution(
    day: Int,
    input_str: String,
    part1: fn(String) -> Int,
    part2: fn(String) -> Int,
    expected_part1: Int,
    expected_part2: Int,
  )
}
