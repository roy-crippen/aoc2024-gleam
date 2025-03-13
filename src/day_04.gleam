import gleam/list
import gleam/result
import gleam/string
import grid.{type Dir, type Grid, type Pos, from_lists, get, size}
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
  find_string(g, "X")
  |> list.fold(0, fn(acc, pos) { xmas_count(g, pos) + acc })
}

fn part2(s: String) -> Int {
  let g = parse(s)
  find_string(g, "A")
  |> list.fold(0, fn(acc, pos) {
    case cross_xmas(g, pos) {
      Ok(_) -> acc + 1
      _ -> acc
    }
  })
}

fn cross_xmas(g: Grid(String), pos: Pos) -> Result(Nil, Nil) {
  // nw and se
  let pos1 = grid.north_west(pos)
  use nw <- result.try(get(g, pos1))
  let pos2 = grid.south_east(pos)
  use se <- result.try(get(g, pos2))

  // ne and sw
  let pos3 = grid.north_east(pos)
  use ne <- result.try(get(g, pos3))
  let pos4 = grid.south_west(pos)
  use sw <- result.try(get(g, pos4))

  case nw, se, ne, sw {
    "M", "S", "S", "M" -> Ok(Nil)
    "M", "S", "M", "S" -> Ok(Nil)
    "S", "M", "S", "M" -> Ok(Nil)
    "S", "M", "M", "S" -> Ok(Nil)
    _, _, _, _ -> Error(Nil)
  }
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
  let pos1 = grid.move(dir, pos)
  use m <- result.try(get(g, pos1))

  let pos2 = grid.move(dir, pos1)
  use a <- result.try(get(g, pos2))

  let pos3 = grid.move(dir, pos2)
  use s <- result.try(get(g, pos3))

  case m, a, s {
    "M", "A", "S" -> Ok(Nil)
    _, _, _ -> Error(Nil)
  }
}

fn find_string(g: Grid(String), s: String) -> List(Pos) {
  let assert Ok(#(rows, cols)) = size(g)
  list.range(0, rows - 1)
  |> list.flat_map(fn(i) {
    list.range(0, cols - 1)
    |> list.map(fn(j) {
      case get(g, #(i, j)) {
        Ok(v) if v == s -> Ok(#(i, j))
        _ -> Error(Nil)
      }
    })
  })
  |> list.filter_map(fn(res) { res })
}

fn parse(s: String) -> Grid(String) {
  string.split(s, "\n")
  |> list.map(fn(s) {
    s
    |> string.to_graphemes
  })
  |> from_lists
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
