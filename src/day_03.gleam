import gleam/int
import gleam/list
import gleam/regexp
import gleam/string.{replace, slice, split_once}
import utils.{Solution, read_file}

fn eval_mul(s: String) -> Int {
  let assert Ok(#(s1, s2)) =
    s |> replace("mul(", "") |> replace(")", "") |> split_once(",")
  let assert Ok(v1) = int.parse(s1)
  let assert Ok(v2) = int.parse(s2)
  v1 * v2
}

fn remove_donts(ss: List(String)) -> List(String) {
  list.fold(ss, #(True, []), fn(acc, s) {
    let start = slice(s, 0, 3)
    let #(is_do, vs) = acc
    case start, is_do {
      "don", _ -> #(False, vs)
      "do(", _ -> #(True, vs)
      "mul", True -> #(True, [s, ..vs])
      _, _ -> #(is_do, vs)
    }
  }).1
}

const expected_part1 = 169_021_493

const expected_part2 = 111_762_583

pub fn solution_day_03() -> utils.Solution {
  Solution(
    part1,
    part2,
    expected_part1,
    expected_part2,
    day: 03,
    input_str: read_file("data/day_03.txt"),
  )
}

fn part1(s: String) -> Int {
  let assert Ok(re) = regexp.from_string("mul\\(\\d{1,3},\\d{1,3}\\)")
  regexp.scan(re, s)
  |> list.map(fn(match) { match.content })
  |> list.fold(0, fn(acc, v) { acc + eval_mul(v) })
}

fn part2(s: String) -> Int {
  let assert Ok(re) =
    regexp.from_string("do\\(\\)|don't\\(\\)|mul\\(\\d{1,3},\\d{1,3}\\)")
  regexp.scan(re, s)
  |> list.map(fn(match) { match.content })
  |> remove_donts
  |> list.fold(0, fn(acc, v) { acc + eval_mul(v) })
}
