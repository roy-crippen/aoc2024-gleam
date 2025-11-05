// src/profile.gleam
import argv
import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode.{type DecodeError, type Decoder}
import gleam/erlang/atom
import gleam/erlang/process
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import utils.{type Solution, Solution}

// ---------------------------------------------------------------------
//  Import every day module you have
// ---------------------------------------------------------------------
import day_01
import day_02
import day_03
import day_04
import day_05
import day_06

// ---------------------------------------------------------------------
//  FFI for eprof – CORRECT API
// ---------------------------------------------------------------------
@external(erlang, "eprof", "start")
fn eprof_start() -> dynamic.Dynamic

@external(erlang, "eprof", "start_profiling")
fn eprof_start_profiling(pids: List(process.Pid)) -> dynamic.Dynamic

@external(erlang, "eprof", "stop_profiling")
fn eprof_stop_profiling() -> atom.Atom

@external(erlang, "eprof", "analyze")
fn eprof_analyze() -> atom.Atom

@external(erlang, "eprof", "stop")
fn eprof_stop() -> atom.Atom

// ---------------------------------------------------------------------
//  ETS access for raw eprof data
// ---------------------------------------------------------------------
@external(erlang, "ets", "whereis")
fn ets_whereis(name: atom.Atom) -> dynamic.Dynamic

@external(erlang, "ets", "tab2list")
fn ets_tab2list(tid: dynamic.Dynamic) -> List(dynamic.Dynamic)

// ---------------------------------------------------------------------
//  code:ensure_loaded – side-effect only
// ---------------------------------------------------------------------
@external(erlang, "code", "ensure_loaded")
fn code_ensure_loaded(mod: atom.Atom) -> #(atom.Atom, atom.Atom)

// ---------------------------------------------------------------------
//  Types for eprof data
// ---------------------------------------------------------------------
type Mfa {
  Mfa(module: String, func: String, arity: Int)
}

type Stats {
  Stats(calls: Int, own_us: Int, acc_us: Int, own_gct_us: Int, acc_gct_us: Int)
}

type Entry {
  Entry(mfa: Mfa, stats: Stats)
}

// ---------------------------------------------------------------------
//  Decoder for eprof ETS rows: {{Module, {Func, Arity}}, {Calls, Own, Acc, OwnGct, AccGct}}
// ---------------------------------------------------------------------
fn entry_decoder() -> Decoder(Entry) {
  decode.at([0, 0], decode.string)
  // Module
  |> decode.then(fn(module) {
    decode.at([0, 1, 0], decode.string)
    // Func
    |> decode.then(fn(func) {
      decode.at([0, 1, 1], decode.int)
      // Arity
      |> decode.map(fn(arity) { Mfa(module: module, func: func, arity: arity) })
    })
  })
  |> decode.then(fn(mfa) {
    decode.at([1, 0], decode.int)
    // Calls
    |> decode.then(fn(calls) {
      decode.at([1, 1], decode.int)
      // Own µs
      |> decode.then(fn(own_us) {
        decode.at([1, 2], decode.int)
        // Acc µs
        |> decode.then(fn(acc_us) {
          decode.at([1, 3], decode.int)
          // Own GC µs
          |> decode.then(fn(own_gct_us) {
            decode.at([1, 4], decode.int)
            // Acc GC µs
            |> decode.map(fn(acc_gct_us) {
              Entry(
                mfa: mfa,
                stats: Stats(
                  calls: calls,
                  own_us: own_us,
                  acc_us: acc_us,
                  own_gct_us: own_gct_us,
                  acc_gct_us: acc_gct_us,
                ),
              )
            })
          })
        })
      })
    })
  })
}

fn decode_entry(raw: dynamic.Dynamic) -> Result(Entry, List(DecodeError)) {
  decode.run(raw, entry_decoder())
}

// ---------------------------------------------------------------------
//  Main entry point
// ---------------------------------------------------------------------
pub fn main() {
  let args = argv.load().arguments
  case args {
    [day_str, part_str] -> run_profile(day_str, part_str)
    _ -> io.println("Usage: gleam run -m profile <day> <part>")
  }
}

// ---------------------------------------------------------------------
//  Parse arguments
// ---------------------------------------------------------------------
fn run_profile(day_str: String, part_str: String) -> Nil {
  case int.parse(day_str), int.parse(part_str) {
    Ok(day), Ok(part) if day > 0 && day <= 25 && part >= 1 && part <= 2 -> {
      profile_day(day, part)
      io.println("\nProfiling complete")
    }
    _, _ -> io.println("Usage: gleam run -m profile <day> <part>")
  }
}

// ---------------------------------------------------------------------
//  Core profiling routine – using start_profiling (correct ETS data)
// ---------------------------------------------------------------------
fn profile_day(day: Int, part: Int) -> Nil {
  io.debug(
    "DEBUG: Starting profile_day for day "
    <> int.to_string(day)
    <> " part "
    <> int.to_string(part),
  )

  // 1. Force-load the day module
  let mod_name = atom.create_from_string("day_" <> int.to_string(day))
  let _ = code_ensure_loaded(mod_name)
  io.debug("DEBUG: Loaded module " <> atom.to_string(mod_name))

  // 2. Start eprof server
  let _ = eprof_start()
  io.debug("DEBUG: eprof_start called")

  // 3. Start profiling on current process
  let pid = process.self()
  io.debug(
    "DEBUG: Starting eprof_start_profiling on PID " <> string.inspect(pid),
  )
  let _ = eprof_start_profiling([pid])

  // 4. Run the actual solution
  let sol = get_solution_for_day(day)()
  let _ = case part {
    1 -> sol.part1(sol.input_str)
    2 -> sol.part2(sol.input_str)
    _ -> 0
  }

  // 5. Stop profiling
  let _ = eprof_stop_profiling()
  io.debug("DEBUG: eprof_stop_profiling called")

  // 6. Fetch raw ETS data
  let table_name = atom.create_from_string("eprof")
  let tid_result = ets_whereis(table_name)
  io.debug("DEBUG: ETS whereis returned " <> string.inspect(tid_result))

  let raw_data = case decode.run(tid_result, decode.int) {
    Ok(_) -> {
      let data = ets_tab2list(tid_result)
      io.debug("DEBUG: Raw data length: " <> int.to_string(list.length(data)))
      case list.first(data) {
        Ok(first) ->
          io.debug("DEBUG: First raw entry: " <> string.inspect(first))
        Error(_) -> io.debug("DEBUG: No first entry")
      }
      case list.drop(data, 1) |> list.first {
        Ok(second) ->
          io.debug("DEBUG: Second raw entry: " <> string.inspect(second))
        Error(_) -> io.debug("DEBUG: No second entry")
      }
      data
    }
    Error(_) -> {
      io.debug("DEBUG: TID decode failed, raw_data = []")
      []
    }
  }

  // 7. Decode entries
  io.debug(
    "DEBUG: Attempting to decode "
    <> int.to_string(list.length(raw_data))
    <> " entries",
  )
  let decoded_entries =
    raw_data
    |> list.map(decode_entry)
    |> list.filter_map(fn(r) {
      case r {
        Ok(entry) -> {
          io.debug(
            "DEBUG: Decoded: "
            <> entry.mfa.module
            <> ":"
            <> entry.mfa.func
            <> "/"
            <> int.to_string(entry.mfa.arity)
            <> " calls="
            <> int.to_string(entry.stats.calls)
            <> " own_us="
            <> int.to_string(entry.stats.own_us)
            <> " acc_us="
            <> int.to_string(entry.stats.acc_us),
          )
          Ok(entry)
        }
        Error(_) -> Error(Nil)
      }
    })
  io.debug(
    "DEBUG: Successfully decoded "
    <> int.to_string(list.length(decoded_entries))
    <> " entries",
  )

  // 8. Print default eprof analysis
  let _ = eprof_analyze()
  io.debug("DEBUG: eprof_analyze called")

  // 9. Custom: Module-level exclusive time (own_us)
  let day_prefix = "day_" <> int.to_string(day)
  io.debug("DEBUG: Filtering for day_prefix: " <> day_prefix)

  let module_own_us =
    decoded_entries
    |> list.fold(dict.new(), fn(acc, entry) {
      let mod_str = entry.mfa.module
      case string.starts_with(mod_str, day_prefix) {
        True -> {
          let current = dict.get(acc, mod_str) |> result.unwrap(0)
          dict.insert(acc, mod_str, current + entry.stats.own_us)
        }
        False -> acc
      }
    })

  io.println(
    "\n--- Module Summary (Exclusive Time: own_us summed per module) ---",
  )
  module_own_us
  |> dict.to_list
  |> list.map(fn(e) {
    let #(m, us) = e
    #(m, us, int.to_float(us) *. 0.001)
  })
  |> list.sort(fn(a, b) { int.compare(b.1, a.1) })
  |> list.map(fn(e) {
    let #(m, us, ms) = e
    string.pad_end(m, 30, " ")
    <> string.pad_start(int.to_string(us), 12, " ")
    <> string.pad_start(float.to_string(ms) <> " ms", 12, " ")
  })
  |> list.each(io.println)

  // 10. Custom: Per-function inclusive time (acc_us)
  io.println(
    "\n--- Day Module Functions (Inclusive Time: acc_us per function) ---",
  )
  let day_functions =
    decoded_entries
    |> list.filter(fn(e) { string.starts_with(e.mfa.module, day_prefix) })
    |> list.map(fn(e) {
      let f = e.mfa.func <> "/" <> int.to_string(e.mfa.arity)
      #(f, e.stats.calls, e.stats.acc_us, int.to_float(e.stats.acc_us) *. 0.001)
    })
    |> list.sort(fn(a, b) { int.compare(b.2, a.2) })
    |> list.map(fn(e) {
      let #(f, c, us, ms) = e
      string.pad_end(f, 35, " ")
      <> string.pad_start(int.to_string(c), 8, " ")
      <> string.pad_start(int.to_string(us), 10, " ")
      <> string.pad_start(float.to_string(ms), 10, " ")
      <> " us/ms"
    })

  case day_functions {
    [] -> io.println("No day-specific functions found.")
    _ -> day_functions |> list.each(io.println)
  }

  // 11. Final cleanup
  let _ = eprof_stop()
  io.debug("DEBUG: eprof_stop called")

  Nil
}

// ---------------------------------------------------------------------
//  Resolve solution function for a given day
// ---------------------------------------------------------------------
fn get_solution_for_day(day: Int) -> fn() -> Solution {
  case day {
    1 -> day_01.solution_day_01
    2 -> day_02.solution_day_02
    3 -> day_03.solution_day_03
    4 -> day_04.solution_day_04
    5 -> day_05.solution_day_05
    6 -> day_06.solution_day_06
    // Add more days here
    _ -> fn() {
      Solution(
        day: day,
        input_str: "",
        part1: fn(_) { 0 },
        part2: fn(_) { 0 },
        expected_part1: 0,
        expected_part2: 0,
      )
    }
  }
}
