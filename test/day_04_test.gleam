import day_04.{example_string, solution_day_04}
import gleam/io.{debug}
import gleeunit/should

pub fn part1_test() {
  let sol = solution_day_04()
  example_string |> sol.part1 |> debug |> should.equal(18)
  sol.input_str |> sol.part1 |> should.equal(sol.expected_part1)
}

pub fn part2_test() {
  let sol = solution_day_04()
  example_string |> sol.part2 |> should.equal(9)
  sol.input_str |> sol.part2 |> debug |> should.equal(sol.expected_part2)
}
