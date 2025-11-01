import gleam/list
import gleam/result
import gleam/string
import grid_gle.{type Dir, type Grid, type Pos}
import utils.{Solution, read_file}

fn parse(s: String) -> Grid(String) {
  string.split(s, "\n")
  |> list.map(string.to_graphemes)
  |> grid_gle.from_lists
  |> utils.unwrap
}

fn xmas_count(g: Grid(String), pos: Pos) -> Int {
  [
    check_xmas_in_dir(g, pos, grid_gle.N),
    check_xmas_in_dir(g, pos, grid_gle.NW),
    check_xmas_in_dir(g, pos, grid_gle.W),
    check_xmas_in_dir(g, pos, grid_gle.SW),
    check_xmas_in_dir(g, pos, grid_gle.S),
    check_xmas_in_dir(g, pos, grid_gle.SE),
    check_xmas_in_dir(g, pos, grid_gle.E),
    check_xmas_in_dir(g, pos, grid_gle.NE),
  ]
  |> list.filter_map(fn(v) { v })
  |> list.length
}

fn check_xmas_in_dir(g: Grid(String), pos: Pos, dir: Dir) -> Result(Nil, Nil) {
  use pos1 <- result.try(grid_gle.move_pos(dir, pos, g.rows, g.cols))
  use m <- result.try(grid_gle.get(g, pos1))

  use pos2 <- result.try(grid_gle.move_pos(dir, pos1, g.rows, g.cols))
  use a <- result.try(grid_gle.get(g, pos2))

  use pos3 <- result.try(grid_gle.move_pos(dir, pos2, g.rows, g.cols))
  use s <- result.try(grid_gle.get(g, pos3))

  case m, a, s {
    "M", "A", "S" -> Ok(Nil)
    _, _, _ -> Error(Nil)
  }
}

fn cross_xmas(g: Grid(String), pos: Pos) -> Result(Nil, Nil) {
  // nw and se
  use pos1 <- result.try(grid_gle.north_west(pos, g.rows, g.cols))
  use nw <- result.try(grid_gle.get(g, pos1))
  use pos2 <- result.try(grid_gle.south_east(pos, g.rows, g.cols))
  use se <- result.try(grid_gle.get(g, pos2))

  // ne and sw
  use pos3 <- result.try(grid_gle.north_east(pos, g.rows, g.cols))
  use ne <- result.try(grid_gle.get(g, pos3))
  use pos4 <- result.try(grid_gle.south_west(pos, g.rows, g.cols))
  use sw <- result.try(grid_gle.get(g, pos4))

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

pub fn solution_day_04_gle() -> utils.Solution {
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
  grid_gle.find_positions(g, fn(v) { v == "X" })
  |> list.fold(0, fn(acc, pos) { xmas_count(g, pos) + acc })
}

fn part2(s: String) -> Int {
  let g = parse(s)
  grid_gle.find_positions(g, fn(v) { v == "A" })
  |> list.fold(0, fn(acc, pos) {
    case cross_xmas(g, pos) {
      Ok(_) -> acc + 1
      _ -> acc
    }
  })
}
