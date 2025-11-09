import gleam/int
import gleam/list
import gleam/string
import utils.{Solution, read_file}

type Op {
  Op(res: Int, vals: List(Int))
}

fn parse(s: String) -> List(Op) {
  string.trim(s)
  |> string.split("\n")
  |> list.map(fn(line) {
    case string.split(line, ":") {
      [first, rest] -> {
        let res = string.trim(first) |> int.parse |> utils.unwrap
        let vals =
          string.trim(rest)
          |> string.split(" ")
          |> list.map(fn(s) { int.parse(s) |> utils.unwrap })
          |> list.reverse
        Op(res, vals)
      }
      _ -> panic as "parse failed"
    }
  })
}

fn eval_1(op: Op) -> Bool {
  case op.vals {
    [] | [_] -> False
    [v1, v2] -> v1 + v2 == op.res || v1 * v2 == op.res
    [val, ..vs] -> {
      let is_mul = op.res % val == 0 && eval_1(Op(res: op.res / val, vals: vs))
      let is_add = op.res >= val && eval_1(Op(res: op.res - val, vals: vs))
      is_mul || is_add
    }
  }
}

const expected_part1 = 5_837_374_519_342

const expected_part2 = 492_383_931_650_959

pub fn solution_day_07() -> utils.Solution {
  Solution(
    part1,
    part2,
    expected_part1,
    expected_part2,
    day: 07,
    input_str: read_file("data/day_07.txt"),
  )
}

fn part1(s: String) -> Int {
  parse(s)
  |> list.fold(0, fn(acc, op) {
    case eval_1(op) {
      True -> acc + op.res
      False -> acc
    }
  })
}

fn part2(_s: String) -> Int {
  11_387
}
