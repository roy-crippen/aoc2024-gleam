import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import grid_gle.{type Dir, type Grid, type Pos}
import utils.{Solution, read_file}

const hash = 35

const carat = 94

type State {
  State(pos: Pos, dir: Dir)
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
    grid_gle.N -> grid_gle.E
    grid_gle.E -> grid_gle.S
    grid_gle.S -> grid_gle.W
    grid_gle.W -> grid_gle.N
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
  let new_pos = grid_gle.move_pos_unsafe(st.dir, st.pos, g.cols)
  let is_inside = grid_gle.is_inside(new_pos, g.rows, g.cols)
  let is_guard =
    is_inside && { grid_gle.get(g, new_pos) |> utils.unwrap } == hash
  case is_inside, is_guard {
    True, True -> #(st, Guard)
    False, _ -> #(st, OutOfBounds)
    True, False -> #(State(..st, pos: new_pos), Running)
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

fn part2(_s: String) -> Int {
  42
}

pub const example_string = ""
