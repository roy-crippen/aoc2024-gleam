import day_01.{solution_day_01}

import day_02.{solution_day_02}

// import day_03.{solution_day_03}
// import day_04.{solution_day_04}
// import day_05.{solution_day_05}
// import day_99.{solution_day_99}
import gleam/erlang.{Microsecond, system_time}
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam_community/ansi

import utils.{type Solution}

const sols = [
  solution_day_01,
  solution_day_02,
  // solution_day_03,
// solution_day_04,
// solution_day_05,
// solution_day_99,
]

pub fn main() {
  sols
  |> list.each(fn(solf) {
    let sol = solf()
    let _ = sol.part1(sol.input_str)
    io.println(run_solution(sol))
  })
}

fn run_solution(sol: Solution) -> String {
  let day_str =
    "day" <> int.to_string(sol.day) |> string.pad_start(3, " ") |> ansi.blue
  let part1_str = "  part 1" <> run_part(sol, True)
  let part2_str = "  part 2" <> run_part(sol, False)
  day_str <> part1_str <> "\n" <> day_str <> part2_str
}

fn run_part(sol: Solution, is_part1: Bool) -> String {
  let #(f, expected) = case is_part1 {
    True -> #(sol.part1, sol.expected_part1)
    _ -> #(sol.part2, sol.expected_part2)
  }

  let start_time = system_time(Microsecond)
  let res = f(sol.input_str)
  let end_time = system_time(Microsecond)
  let elapsed_us = end_time - start_time
  let elapased_str = duration_str(elapsed_us)
  let res_str = int.to_string(res) |> string.pad_start(15, " ")
  let expected_str = int.to_string(expected) |> string.pad_start(15, " ")
  case { expected } == res {
    True -> res_str <> " " <> elapased_str
    False -> "--- " <> res_str <> " != expected " <> expected_str
  }
}

fn duration_str(dur: Int) -> String {
  let dur_float = int.to_float(dur) /. 1000.0
  float.to_string(dur_float) |> string.pad_start(10, " ") <> " ms"
}
