import bool_bit_vector as bbv
import gleam/list
import gleam/set
import gleam/string
import grid.{type Dir, type Grid, E, N, S, W}
import utils.{Solution, read_file}

type State {
  State(pos: Int, dir: Dir)
}

type Status {
  Guard
  OutOfBounds
  Running
}

fn parse(s: String) -> #(Grid(String), State) {
  let g =
    string.trim(s)
    |> string.split("\n")
    |> list.map(fn(s) { string.to_graphemes(s) })
    |> grid.from_lists
    |> utils.unwrap
  let pos =
    grid.find_positions(g, fn(ch) { ch == "^" })
    |> list.first
    |> utils.unwrap
  #(g, State(pos, dir: grid.N))
}

fn next_dir(dir: Dir) -> Dir {
  case dir {
    N -> E
    E -> S
    S -> W
    W -> N
    _ -> panic as "invalid direction"
  }
}

fn traverse_part1(g: Grid(String), st: State, xs: List(State)) -> List(State) {
  traverse_part1_loop(g, st, xs, Running)
}

fn traverse_part1_loop(
  g: Grid(String),
  state: State,
  states: List(State),
  status: Status,
) -> List(State) {
  case status {
    Guard -> traverse_part1(g, State(..state, dir: next_dir(state.dir)), states)
    OutOfBounds -> states
    Running -> {
      let #(new_state, new_status) = to_next(g, state)
      let states = [new_state, ..states]
      traverse_part1_loop(g, new_state, states, new_status)
    }
  }
}

fn to_next(g: Grid(String), st: State) -> #(State, Status) {
  case grid.move_pos(st.dir, st.pos, g.rows, g.cols) {
    Error(_) -> #(st, OutOfBounds)
    Ok(new_pos) -> {
      case { grid.get(g, new_pos) |> utils.unwrap } == "#" {
        True -> #(st, Guard)
        False -> #(State(..st, pos: new_pos), Running)
      }
    }
  }
}

fn pos_dir_to_index(cols: Int, pos: Int, dir: Dir) {
  let dir_int = case dir {
    N -> 0
    E -> 1
    S -> 2
    W -> 3
    _ -> panic as "invalid direction"
  }

  let #(r, c) = grid.pos_to_rc_unsafe(pos, cols)
  { r * cols + c } * 4 + dir_int
}

fn is_cycle(g: Grid(String), state: State, visits: bbv.BoolBitVect) -> Bool {
  let #(init_state, init_status) = to_next(g, state)
  is_cycle_loop(g, visits, init_state, init_status)
}

fn is_cycle_loop(
  g: Grid(String),
  visits: bbv.BoolBitVect,
  state: State,
  status: Status,
) -> Bool {
  let key = pos_dir_to_index(g.cols, state.pos, state.dir)
  let visited = bbv.get_bool_bit(visits, key)
  case visited {
    Ok(True) -> True
    Ok(False) ->
      case status {
        OutOfBounds -> {
          False
        }
        Guard -> {
          let new_state = State(..state, dir: next_dir(state.dir))
          is_cycle_loop(g, visits, new_state, Running)
        }
        Running -> {
          let #(next_state, next_status) = to_next(g, state)
          let next_visits = case next_status {
            Running -> {
              let assert Ok(Nil) = bbv.toggle_bool_bit(visits, key)
              visits
            }
            _ -> visits
          }
          is_cycle_loop(g, next_visits, next_state, next_status)
        }
      }
    _ -> panic as "invalid key sent to bool_bit_vector"
  }
}

// fn collect_results(
//   acc: #(List(process.Subject(Bool)), Int),
// ) -> #(List(process.Subject(Bool)), Int) {
//   let #(subjects, cnt) = acc
//   case subjects {
//     [] -> acc
//     [subject, ..rest] -> {
//       case process.receive(subject, 1000) {
//         Ok(True) -> collect_results(#(rest, cnt + 1))
//         _ -> collect_results(#(rest, cnt))
//       }
//     }
//   }
// }

const expected_part1 = 5329

const expected_part2 = 2162

pub fn solution_day_06() -> utils.Solution {
  Solution(
    part1,
    part2,
    expected_part1,
    expected_part2,
    day: 06,
    input_str: read_file("data/day_06.txt"),
  )
}

fn part1(s: String) -> Int {
  // io.debug("")
  let #(g, st) = parse(s)
  // io.debug(st)
  // io.debug(grid.show_str(g) |> list.each(io.debug))

  traverse_part1(g, st, [st])
  |> list.map(fn(state) { state.pos })
  |> set.from_list
  |> set.size
}

fn part2(s: String) -> Int {
  let #(g, st) = parse(s)
  let route = traverse_part1(g, st, [st]) |> list.reverse

  // remove any elements where pos has been used
  let rest = list.drop(route, 1)
  let used_set = set.new()
  let final_acc =
    list.fold(rest, #([], used_set), fn(acc, st) {
      let #(keeps, used_set) = acc
      case set.contains(used_set, st.pos) {
        True -> acc
        False -> #([st, ..keeps], set.insert(used_set, st.pos))
      }
    })
  let new_route = final_acc.0 |> list.reverse

  // initialize bool bit vector to all false
  let total_states = g.rows * g.cols * 4
  let num_buckets = { total_states + 63 } / 64

  // let task_list =
  //   list.window_by_2(new_route)
  //   |> list.map(fn(pair) {
  //     let #(prev_st, next_st) = pair
  //     let grid = grid.set(g, next_st.pos, hash) |> utils.unwrap
  //     let visited = bbv.new_unsigned(num_buckets)
  //     #(grid, prev_st, next_st, visited)
  //   })

  // let rs =
  //   list.map(task_list, fn(tup) {
  //     let #(grid, prev_st, _next_st, visited) = tup
  //     is_cycle(grid, prev_st, visited)
  //   })
  //   |> list.filter(fn(b) { b })
  // list.each(rs, fn(pair) { io.debug(pair) })
  // list.length(rs)

  // let subjects =
  //   // List(process.Subject(Bool)) =
  //   list.map(task_list, fn(tup) {
  //     let #(grid, prev_st, _next_st, visited) = tup
  //     let subject = process.new_subject()
  //     let _pid =
  //       process.start(
  //         fn() {
  //           let b = is_cycle(grid, prev_st, visited)
  //           process.send(subject, b)
  //           subject
  //         },
  //         True,
  //       )
  //     subject
  //   })

  // let #(_, cnt) = collect_results(#(subjects, 0))
  // io.debug(cnt)
  // cnt

  // best serial solution
  let init_acc = #(list.first(route) |> utils.unwrap, 0)
  let #(_final_state, cnt) =
    list.fold(new_route, init_acc, fn(acc, next_st) {
      let #(prev_state, cnt) = acc
      let grid = grid.set(g, next_st.pos, "#") |> utils.unwrap
      let has_cycle = is_cycle(grid, prev_state, bbv.new_unsigned(num_buckets))
      let updated_cnt = case has_cycle {
        True -> cnt + 1
        False -> cnt
      }
      #(next_st, updated_cnt)
    })
  cnt
}
