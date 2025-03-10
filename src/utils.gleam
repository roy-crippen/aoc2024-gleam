import gleam/string.{split, trim}
import simplifile

pub fn read_lines(filepath: String) {
  let contents = read_file(filepath)
  split(trim(contents), "\n")
}

pub fn read_file(filepath: String) {
  let assert Ok(contents) = simplifile.read(filepath)
  contents
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
