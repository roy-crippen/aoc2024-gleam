import bool_bit_vector_ata as bbv
import gleam/list
import gleam/set
import gleam/string
import grid_gle.{type Dir, type Grid, E, N, S, W}
import utils.{Solution, read_file}

const hash = 35

const carat = 94

type State {
  State(pos: Int, dir: Dir)
}

type Status {
  Guard
  OutOfBounds
  Running
}

fn parse(s: String) -> #(Grid(Int), State) {
  let g =
    string.trim(s)
    |> string.split("\n")
    |> list.map(fn(s) {
      string.to_utf_codepoints(s)
      |> list.map(string.utf_codepoint_to_int)
    })
    |> grid_gle.from_lists
    |> utils.unwrap
  let pos =
    grid_gle.find_positions(g, fn(ch) { ch == carat })
    |> list.first
    |> utils.unwrap
  #(g, State(pos, dir: grid_gle.N))
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

fn traverse_part1(g: Grid(Int), st: State, xs: List(State)) -> List(State) {
  traverse_part1_loop(g, st, xs, Running)
}

fn traverse_part1_loop(
  g: Grid(Int),
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

fn to_next(g: Grid(Int), st: State) -> #(State, Status) {
  case grid_gle.move_pos(st.dir, st.pos, g.rows, g.cols) {
    Error(_) -> #(st, OutOfBounds)
    Ok(new_pos) -> {
      let is_guard = { grid_gle.get(g, new_pos) |> utils.unwrap } == hash
      case is_guard {
        True -> #(st, Guard)
        False -> #(State(..st, pos: new_pos), Running)
      }
    }
  }
}

// fn to_next(g: Grid(Int), st: State) -> #(State, Status) {
//   let new_pos = grid_gle.move_pos_unsafe(st.dir, st.pos, g.cols)
//   let is_inside = grid_gle.is_inside(new_pos, g.rows, g.cols)
//   let is_guard =
//     is_inside && { grid_gle.get(g, new_pos) |> utils.unwrap } == hash
//   case is_inside, is_guard {
//     True, True -> #(st, Guard)
//     False, _ -> #(st, OutOfBounds)
//     True, False -> #(State(..st, pos: new_pos), Running)
//   }
// }

fn pos_dir_to_index(cols: Int, pos: Int, dir: Dir) {
  let dir_int = case dir {
    N -> 0
    E -> 1
    S -> 2
    W -> 3
    _ -> panic as "invalid direction"
  }

  let #(r, c) = grid_gle.pos_to_rc_unsafe(pos, cols)
  { r * cols + c } * 4 + dir_int
}

fn is_cycle(
  g: Grid(Int),
  state: State,
  cols: Int,
  visits: bbv.BoolBitVect,
) -> Bool {
  let #(init_state, init_status) = to_next(g, state)
  is_cycle_loop(g, visits, cols, init_state, init_status)
}

fn is_cycle_loop(
  g: Grid(Int),
  visits: bbv.BoolBitVect,
  cols: Int,
  state: State,
  status: Status,
) -> Bool {
  let key = pos_dir_to_index(cols, state.pos, state.dir)
  let visited = bbv.get_bool_bit(visits, key)
  // let tag = case visited {
  //   Ok(True) -> "aaaaaaaaaaaaaaaaaaaaaaaaaaa"
  //   _ -> ""
  // }
  // io.debug(#(visited, state, status, tag))
  case visited {
    Ok(True) -> True
    Ok(False) ->
      case status {
        OutOfBounds -> {
          // io.debug("out of bounds")
          // io.debug("")
          False
        }
        Guard -> {
          let new_state = State(..state, dir: next_dir(state.dir))
          is_cycle_loop(g, visits, cols, new_state, Running)
        }
        Running -> {
          let #(next_state, next_status) = to_next(g, state)
          let next_visits = case next_status {
            Running -> {
              let assert Ok(Nil) = bbv.toggle_bool_bit(visits, key)
              // let _ = io.debug(bbv.get_bool_bit(visits, key))
              visits
            }
            _ -> visits
          }
          // let next_visits = case next_status {
          //   Running -> bbv.toggle_bool_bit(visits, key) |> utils.unwrap
          //   _ -> visits
          // }
          is_cycle_loop(g, next_visits, cols, next_state, next_status)
        }
      }
    _ -> panic as "invalid key sent to bool_bit_vector"
  }
}

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
  // io.debug(grid_gle.show_str(g) |> list.each(io.debug))

  traverse_part1(g, st, [st])
  |> list.map(fn(state) { state.pos })
  |> set.from_list
  |> set.size
}

fn part2(s: String) -> Int {
  let #(g, st) = parse(s)
  let route = traverse_part1(g, st, [st]) |> list.reverse
  // io.debug("")

  // setup initial fold accumulator
  let init_state = list.first(route) |> utils.unwrap
  let init_cycle_set = set.new()
  let init_pos_used_set = set.new()
  let init_acc = #(init_state, init_cycle_set, init_pos_used_set)

  // initialize bool bit vector to all false
  let total_states = g.rows * g.cols * 4
  let num_buckets = { total_states + 63 } / 64
  // let init_visited = list.repeat(0, num_buckets) |> bbv.from_list
  // let init_visited = bbv.new_unsigned(num_buckets)

  let #(_final_state, cycle_positions, _used_positions) =
    list.fold(route, init_acc, fn(acc, next_st) {
      let #(prev_state, cycle_set, pos_used_set) = acc
      let grid = grid_gle.set(g, next_st.pos, hash) |> utils.unwrap
      let has_pos_been_used = set.contains(pos_used_set, next_st.pos)
      let init_visited = bbv.new_unsigned(num_buckets)
      let has_cycle = is_cycle(grid, prev_state, g.cols, init_visited)
      let updated_cycle_set = case !has_pos_been_used && has_cycle {
        True -> set.insert(cycle_set, next_st.pos)
        False -> cycle_set
      }
      #(next_st, updated_cycle_set, set.insert(pos_used_set, next_st.pos))
    })

  // io.debug({ cycle_positions |> set.to_list |> list.sort(int.compare) })
  // io.debug(final_state)
  // io.debug({ used_positions |> set.to_list |> list.sort(int.compare) })

  set.size(cycle_positions)
  // 2162
}

pub const example_string = ""
