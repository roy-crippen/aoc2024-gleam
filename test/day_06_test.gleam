import day_06.{solution_day_06}
import gleeunit/should

pub const example_string = "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
"

pub fn part1_test() {
  let sol = solution_day_06()
  example_string |> sol.part1 |> should.equal(41)
  sol.input_str |> sol.part1 |> should.equal(sol.expected_part1)
}

pub fn part2_test() {
  let sol = solution_day_06()
  example_string |> sol.part2 |> should.equal(6)
  // sol.input_str |> sol.part2 |> should.equal(sol.expected_part2)
}
