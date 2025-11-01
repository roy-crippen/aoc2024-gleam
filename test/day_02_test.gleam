import day_02.{solution_day_02}
import gleeunit/should

pub const example_string = "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9"

pub fn part1_test() {
  let sol = solution_day_02()
  example_string |> sol.part1 |> should.equal(2)
  sol.input_str |> sol.part1 |> should.equal(sol.expected_part1)
}

pub fn part2_test() {
  let sol = solution_day_02()
  example_string |> sol.part2 |> should.equal(4)
  sol.input_str |> sol.part2 |> should.equal(sol.expected_part2)
}
