import day_04.{solution_day_04}
import gleeunit/should

pub const example_string = "MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX"

pub fn part1_test() {
  let sol = solution_day_04()
  example_string |> sol.part1 |> should.equal(18)
  // sol.input_str |> sol.part1 |> should.equal(sol.expected_part1)
}

pub fn part2_test() {
  let sol = solution_day_04()
  example_string |> sol.part2 |> should.equal(9)
  // sol.input_str |> sol.part2 |> should.equal(sol.expected_part2)
}
