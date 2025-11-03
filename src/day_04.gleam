import gleam/list
import gleam/result
import gleam/string
import grid_gle.{type Dir, type Grid}
import utils.{Solution, read_file}

const ch_x = 88

const ch_m = 77

const ch_a = 65

const ch_s = 83

fn parse(s: String) -> Grid(Int) {
  string.trim(s)
  |> string.split("\n")
  |> list.map(fn(s) {
    string.to_utf_codepoints(s)
    |> list.map(string.utf_codepoint_to_int)
  })
  |> grid_gle.from_lists
  |> utils.unwrap
}

fn xmas_count(g: Grid(Int), pos: Int) -> Int {
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

fn check_xmas_in_dir(g: Grid(Int), pos: Int, dir: Dir) -> Result(Nil, Nil) {
  use pos1 <- result.try(grid_gle.move_pos(dir, pos, g.rows, g.cols))
  use m <- result.try(grid_gle.get(g, pos1))

  use pos2 <- result.try(grid_gle.move_pos(dir, pos1, g.rows, g.cols))
  use a <- result.try(grid_gle.get(g, pos2))

  use pos3 <- result.try(grid_gle.move_pos(dir, pos2, g.rows, g.cols))
  use s <- result.try(grid_gle.get(g, pos3))

  let ls = [m, a, s]
  case ls {
    ys if ys == [ch_m, ch_a, ch_s] -> Ok(Nil)
    // 77, 65, 83 -> Ok(Nil)
    _ -> Error(Nil)
  }
}

fn cross_xmas(g: Grid(Int), pos: Int) -> Result(Nil, Nil) {
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

  let ls = [nw, se, ne, sw]
  case ls {
    // m=77, s=83
    // "M", "S", "S", "M" -> Ok(Nil)
    // "M", "S", "M", "S" -> Ok(Nil)
    // "S", "M", "S", "M" -> Ok(Nil)
    // "S", "M", "M", "S" -> Ok(Nil)
    xs if xs == [ch_m, ch_s, ch_s, ch_m] -> Ok(Nil)
    xs if xs == [ch_m, ch_s, ch_m, ch_s] -> Ok(Nil)
    xs if xs == [ch_s, ch_m, ch_s, ch_m] -> Ok(Nil)
    xs if xs == [ch_s, ch_m, ch_m, ch_s] -> Ok(Nil)
    _ -> Error(Nil)
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
  grid_gle.find_positions(g, fn(v) { v == ch_x })
  |> list.fold(0, fn(acc, pos) { xmas_count(g, pos) + acc })
}

fn part2(s: String) -> Int {
  let g = parse(s)
  grid_gle.find_positions(g, fn(v) { v == ch_a })
  |> list.fold(0, fn(acc, pos) {
    case cross_xmas(g, pos) {
      Ok(_) -> acc + 1
      _ -> acc
    }
  })
  // 1850
}
