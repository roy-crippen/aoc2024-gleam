import day_03.{example_string1, example_string2, solution_day_03}
import gleam/io.{debug}
import gleeunit/should

pub fn part1_test() {
  let sol = solution_day_03()
  example_string1 |> sol.part1 |> debug |> should.equal(161)
  sol.input_str |> sol.part1 |> should.equal(sol.expected_part1)
}

pub fn part2_test() {
  let sol = solution_day_03()
  example_string2 |> sol.part2 |> should.equal(48)
  sol.input_str |> sol.part2 |> debug |> should.equal(sol.expected_part2)
}
