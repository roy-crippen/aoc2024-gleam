import day_07.{solution_day_07}
import gleeunit/should

pub const example_string = "190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
"

pub fn part1_test() {
  let sol = solution_day_07()
  example_string |> sol.part1 |> should.equal(3749)
  // sol.input_str |> sol.part1 |> should.equal(sol.expected_part1)
}

pub fn part2_test() {
  let sol = solution_day_07()
  example_string |> sol.part2 |> should.equal(11_387)
  // sol.input_str |> sol.part2 |> should.equal(sol.expected_part2)
}
