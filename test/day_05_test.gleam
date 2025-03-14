import day_05.{example_string, solution_day_05}
import gleeunit/should

pub fn part1_test() {
  let sol = solution_day_05()
  example_string |> sol.part1 |> should.equal(143)
  sol.input_str |> sol.part1 |> should.equal(sol.expected_part1)
}

pub fn part2_test() {
  let sol = solution_day_05()
  example_string |> sol.part2 |> should.equal(123)
  sol.input_str |> sol.part2 |> should.equal(sol.expected_part2)
}
