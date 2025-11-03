import gleam/list
import gleam/result
import glearray

pub type Grid(a) {
  Grid(data: glearray.Array(a), rows: Int, cols: Int)
}

/// Returns a Grid(a) of rows by cols all with value v
pub fn make(rows: Int, cols: Int, v: a) -> Grid(a) {
  let data = list.repeat(v, rows * cols) |> glearray.from_list
  Grid(data, rows, cols)
}

/// Returns a Grid(a) of rows by cols from some List(List(a)), validating uniform row lengths
pub fn from_lists(xss: List(List(a))) -> Result(Grid(a), Nil) {
  let rows = list.length(xss)
  use first_row <- result.try(list.first(xss))
  let cols = list.length(first_row)
  use _ <- result.try(case list.all(xss, fn(row) { list.length(row) == cols }) {
    True -> Ok(Nil)
    False -> Error(Nil)
  })
  let data = list.flatten(xss) |> glearray.from_list
  Ok(Grid(data, rows, cols))
}

/// Returns a Grid(a) of rows by cols from some List(a), validating exact length match
pub fn from_list(data: List(a), rows: Int, cols: Int) -> Result(Grid(a), Nil) {
  case list.length(data) == rows * cols {
    True -> {
      let data_array = data |> glearray.from_list
      Ok(Grid(data_array, rows, cols))
    }
    False -> Error(Nil)
  }
}

pub type RC =
  #(Int, Int)

pub type Dir {
  N
  NW
  W
  SW
  S
  SE
  E
  NE
}

pub fn pos_to_rc(pos: Int, rows: Int, cols: Int) -> Result(RC, Nil) {
  case is_inside(pos, rows, cols) {
    True -> Ok(#(pos / cols, pos % cols))
    False -> Error(Nil)
  }
}

pub fn pos_to_rc_unsafe(pos: Int, cols: Int) -> RC {
  #(pos / cols, pos % cols)
}

pub fn rc_to_pos(rc: RC, cols: Int) -> Result(Int, Nil) {
  let #(r, c) = rc
  case r >= 0 && c >= 0 {
    True -> Ok(r * cols + c)
    False -> Error(Nil)
  }
}

pub fn rc_to_pos_unsafe(rc: RC, cols: Int) -> Int {
  let #(r, c) = rc
  r * cols + c
}

/// Returns true if position pos is inside the grid boundary
pub fn is_inside(pos: Int, rows: Int, cols: Int) -> Bool {
  pos >= 0 && pos < rows * cols
}

/// Returns the value in the grid at pos or Nil if out of bounds
pub fn get(g: Grid(a), pos: Int) -> Result(a, Nil) {
  glearray.get(g.data, pos)
}

/// Sets the value in g at pos or Nil if out of bounds, returns the modified grid
/// Expensive because set make a new copy of the data
pub fn set(g: Grid(a), pos: Int, v: a) -> Result(Grid(a), Nil) {
  use data <- result.try(glearray.copy_set(g.data, pos, v))
  Ok(Grid(..g, data: data))
}

pub fn map(g: Grid(a), f: fn(a) -> b) -> Grid(b) {
  let data_list = g.data |> glearray.to_list
  let mapped_list = list.map(data_list, f)
  let data = glearray.from_list(mapped_list)
  Grid(rows: g.rows, cols: g.cols, data: data)
}

/// Returns positions (in forward order) where f(value) is True
pub fn find_positions(g: Grid(a), f: fn(a) -> Bool) -> List(Int) {
  g.data
  |> glearray.to_list
  |> list.index_map(fn(v, idx) {
    case f(v) {
      True -> Ok(idx)
      False -> Error(Nil)
    }
  })
  |> result.values
}

/// Returns the grid data as List(List(a)) for visualization/printing
pub fn to_lists(g: Grid(a)) -> List(List(a)) {
  let chunk = fn(acc, v, i) {
    case i % g.cols == 0 {
      True -> [[v], ..acc]
      False -> {
        let assert [row, ..rest] = acc
        [[v, ..row], ..rest]
      }
    }
  }
  let chunks_rev = g.data |> glearray.to_list |> list.index_fold([], chunk)
  list.reverse(chunks_rev)
}

/// Returns valid neighbor positions in 8 directions (N, NW, W, SW, S, SE, E, NE)
pub fn neighbors(g: Grid(a), pos: Int) -> List(Int) {
  [north, north_west, west, south_west, south, south_east, east, north_east]
  |> list.map(fn(mover) { mover(pos, g.rows, g.cols) })
  |> list.filter_map(fn(v) { v })
}

pub fn move_pos(
  direction dir: Dir,
  position pos: Int,
  row_cnt rows: Int,
  col_cnt cols: Int,
) -> Result(Int, Nil) {
  let max_col = cols - 1
  let max_row = rows - 1
  use #(r, c) <- result.try(pos_to_rc(pos, rows, cols))
  case dir {
    N if r > 0 -> Ok(pos - cols)
    NW if r > 0 && c > 0 -> Ok(pos - cols - 1)
    W if c > 0 -> Ok(pos - 1)
    SW if r < max_row && c > 0 -> Ok(pos + cols - 1)
    S if r < max_row -> Ok(pos + cols)
    SE if r < max_row && c < max_col -> Ok(pos + cols + 1)
    E if c < max_col -> Ok(pos + 1)
    NE if r > 0 && c < max_col -> Ok(pos - cols + 1)
    _ -> Error(Nil)
  }
}

/// Unsafe: May return out-of-bounds positions
pub fn move_pos_unsafe(
  direction dir: Dir,
  position pos: Int,
  col_cnt cols: Int,
) -> Int {
  case dir {
    N -> pos - cols
    NW -> pos - cols - 1
    W -> pos - 1
    SW -> pos + cols - 1
    S -> pos + cols
    SE -> pos + cols + 1
    E -> pos + 1
    NE -> pos - cols + 1
  }
}

pub fn north(pos: Int, rows: Int, cols: Int) -> Result(Int, Nil) {
  move_pos(N, pos, rows, cols)
}

pub fn north_west(pos: Int, rows: Int, cols: Int) -> Result(Int, Nil) {
  move_pos(NW, pos, rows, cols)
}

pub fn west(pos: Int, rows: Int, cols: Int) -> Result(Int, Nil) {
  move_pos(W, pos, rows, cols)
}

pub fn south_west(pos: Int, rows: Int, cols: Int) -> Result(Int, Nil) {
  move_pos(SW, pos, rows, cols)
}

pub fn south(pos: Int, rows: Int, cols: Int) -> Result(Int, Nil) {
  move_pos(S, pos, rows, cols)
}

pub fn south_east(pos: Int, rows: Int, cols: Int) -> Result(Int, Nil) {
  move_pos(SE, pos, rows, cols)
}

pub fn east(pos: Int, rows: Int, cols: Int) -> Result(Int, Nil) {
  move_pos(E, pos, rows, cols)
}

pub fn north_east(pos: Int, rows: Int, cols: Int) -> Result(Int, Nil) {
  move_pos(NE, pos, rows, cols)
}
