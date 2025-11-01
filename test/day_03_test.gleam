import day_03.{solution_day_03}
import gleeunit/should

pub const example_string1 = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

pub const example_string2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

pub fn part1_test() {
  let sol = solution_day_03()
  example_string1 |> sol.part1 |> should.equal(161)
  sol.input_str |> sol.part1 |> should.equal(sol.expected_part1)
}

pub fn part2_test() {
  let sol = solution_day_03()
  example_string2 |> sol.part2 |> should.equal(48)
  sol.input_str |> sol.part2 |> should.equal(sol.expected_part2)
}
