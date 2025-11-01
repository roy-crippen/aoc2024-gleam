import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import utils.{Solution, read_file}

fn parse(s: String) -> #(List(Int), List(Int)) {
  string.trim(s)
  |> string.split("\n")
  |> parse_loop([], [])
}

fn parse_loop(
  lines: List(String),
  lefts: List(Int),
  rights: List(Int),
) -> #(List(Int), List(Int)) {
  case lines {
    [] -> #(lefts, rights)
    [line, ..rest] -> {
      let assert Ok(#(l, r)) = string.split_once(line, "   ")
      let assert Ok(left) = int.parse(l)
      let assert Ok(right) = int.parse(r)
      parse_loop(rest, [left, ..lefts], [right, ..rights])
    }
  }
}

fn sort_then_zip(pair: #(List(Int), List(Int))) -> List(#(Int, Int)) {
  let l_sorted = list.sort(pair.0, int.compare)
  let r_sorted = list.sort(pair.1, int.compare)
  list.zip(l_sorted, r_sorted)
}

fn solve_part2(pair: #(List(Int), List(Int))) -> Int {
  let #(lefts, rights) = pair
  let r_dict = build_dict(rights)
  lefts
  |> list.fold(0, fn(acc, left) {
    acc + left * { dict.get(r_dict, left) |> result.unwrap(0) }
  })
}

fn build_dict(xs: List(Int)) -> Dict(Int, Int) {
  let increment = fn(x) {
    case x {
      Some(i) -> i + 1
      None -> 1
    }
  }
  list.fold(xs, dict.new(), fn(acc, x) { dict.upsert(acc, x, increment) })
}

const expected_part1 = 2_086_478

const expected_part2 = 24_941_624

pub fn solution_day_01() -> utils.Solution {
  Solution(
    part1,
    part2,
    expected_part1,
    expected_part2,
    day: 1,
    input_str: read_file("data/day_01.txt"),
  )
}

fn part1(s: String) -> Int {
  s
  |> parse
  |> sort_then_zip
  |> list.fold(0, fn(acc, pair) { acc + int.absolute_value(pair.0 - pair.1) })
}

fn part2(s: String) -> Int {
  s |> parse |> solve_part2
}
