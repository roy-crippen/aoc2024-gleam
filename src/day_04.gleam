import gleam/list
import gleam/result
import gleam/string
import grid.{type Dir, type Grid, type Pos}
import utils.{Solution, read_file}

fn parse(s: String) -> Grid(String) {
  string.split(s, "\n")
  |> list.map(string.to_graphemes)
  |> grid.from_lists
  |> utils.unwrap
}

fn xmas_count(g: Grid(String), pos: Pos) -> Int {
  [
    check_xmas_in_dir(g, pos, grid.N),
    check_xmas_in_dir(g, pos, grid.NW),
    check_xmas_in_dir(g, pos, grid.W),
    check_xmas_in_dir(g, pos, grid.SW),
    check_xmas_in_dir(g, pos, grid.S),
    check_xmas_in_dir(g, pos, grid.SE),
    check_xmas_in_dir(g, pos, grid.E),
    check_xmas_in_dir(g, pos, grid.NE),
  ]
  |> list.filter_map(fn(v) { v })
  |> list.length
}

fn check_xmas_in_dir(g: Grid(String), pos: Pos, dir: Dir) -> Result(Nil, Nil) {
  use pos1 <- result.try(grid.move_pos(dir, pos, g.rows, g.cols))
  use m <- result.try(grid.get(g, pos1))

  use pos2 <- result.try(grid.move_pos(dir, pos1, g.rows, g.cols))
  use a <- result.try(grid.get(g, pos2))

  use pos3 <- result.try(grid.move_pos(dir, pos2, g.rows, g.cols))
  use s <- result.try(grid.get(g, pos3))

  case m, a, s {
    "M", "A", "S" -> Ok(Nil)
    _, _, _ -> Error(Nil)
  }
}

fn cross_xmas(g: Grid(String), pos: Pos) -> Result(Nil, Nil) {
  // nw and se
  use pos1 <- result.try(grid.north_west(pos, g.rows, g.cols))
  use nw <- result.try(grid.get(g, pos1))
  use pos2 <- result.try(grid.south_east(pos, g.rows, g.cols))
  use se <- result.try(grid.get(g, pos2))

  // ne and sw
  use pos3 <- result.try(grid.north_east(pos, g.rows, g.cols))
  use ne <- result.try(grid.get(g, pos3))
  use pos4 <- result.try(grid.south_west(pos, g.rows, g.cols))
  use sw <- result.try(grid.get(g, pos4))

  case nw, se, ne, sw {
    "M", "S", "S", "M" -> Ok(Nil)
    "M", "S", "M", "S" -> Ok(Nil)
    "S", "M", "S", "M" -> Ok(Nil)
    "S", "M", "M", "S" -> Ok(Nil)
    _, _, _, _ -> Error(Nil)
  }
}

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
  grid.find_positions(g, fn(v) { v == "X" })
  |> list.fold(0, fn(acc, pos) { xmas_count(g, pos) + acc })
}

fn part2(s: String) -> Int {
  let g = parse(s)
  grid.find_positions(g, fn(v) { v == "A" })
  |> list.fold(0, fn(acc, pos) {
    case cross_xmas(g, pos) {
      Ok(_) -> acc + 1
      _ -> acc
    }
  })
  // 1850
}
