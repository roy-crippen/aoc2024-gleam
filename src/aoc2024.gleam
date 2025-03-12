import day_01.{solution_day_01}
import day_02.{solution_day_02}
import day_03.{solution_day_03}
import gleam/erlang.{Microsecond, system_time}
import gleam/int
import gleam/io
import gleam/list
import gleam_community/ansi

import utils.{type Solution}

const sols = [solution_day_01, solution_day_02, solution_day_03]

pub fn main() {
  sols
  |> list.each(fn(solf) {
    let sol = solf()
    // erlang engine warmup
    let _ = sol.part1(sol.input_str)
    io.println(run_solution(sol))
  })
}

fn run_solution(sol: Solution) -> String {
  let day_str = int.to_string(sol.day) |> ansi.blue
  let part1_str = run_part(sol, True)
  let part2_str = run_part(sol, False)
  day_str <> "  " <> part1_str <> "  " <> part2_str
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
  let res_str = int.to_string(res)
  let expected_str = int.to_string(expected)
  case { expected } == res {
    True -> res_str <> " " <> elapased_str
    False -> "--- " <> res_str <> " != expected " <> expected_str
  }
}

fn duration_str(dur: Int) -> String {
  let dur_str = case dur {
    _ if dur > 5000 -> int.to_string(dur / 1000) <> "ms"
    _ -> int.to_string(dur) <> "us"
  }
  dur_str
}
