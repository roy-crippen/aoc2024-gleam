import gleam/list
import gleam/string
import grid
import utils.{Solution, read_file}

const expected_part1 = 2573

const expected_part2 = 1850

pub fn solution_day_04() -> utils.Solution {
  Solution(
    part1,
    part2,
    expected_part1,
    expected_part2,
    day: 04,
    input_str: read_file("data/day_04.txt"),
  )
}

fn part1(s: String) -> Int {
  let g = parse(s)
  grid.show(g)
  42
}

fn part2(_s: String) -> Int {
  42
}

fn parse(s: String) -> grid.Grid(String) {
  string.split(s, "\n")
  |> list.map(fn(s) {
    s
    |> string.to_graphemes
  })
  |> grid.from_lists
}

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
