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
  should.equal(1, 1)
  // let sol = solution_day_04()
  // example_string |> sol.part2 |> should.equal(9)
  // sol.input_str |> sol.part2 |> should.equal(sol.expected_part2)
}
// pub fn int
