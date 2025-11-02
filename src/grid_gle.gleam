import gleam/list
import gleam/result
import glearray

pub type Grid(a) {
  Grid(data: glearray.Array(a), rows: Int, cols: Int)
}

pub type Pos =
  Int

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

/// Returns a Grid(a) of rows by cols all with value v
pub fn make(rows: Int, cols: Int, v: a) -> Grid(a) {
  let data = list.repeat(v, rows * cols) |> glearray.from_list
  Grid(data, rows, cols)
}

/// Returns a Grid(a) of rows by cols from some List(a)
pub fn from_lists(xss: List(List(a))) -> Result(Grid(a), Nil) {
  let rows = list.length(xss)
  use first_row <- result.try(list.first(xss))
  let cols = list.length(first_row)
  let data = list.flatten(xss) |> glearray.from_list
  Ok(Grid(data, rows, cols))
}

/// Returns a Grid(a) of rows by cols from some List(a)
pub fn from_list(data: List(a), rows: Int, cols: Int) -> Result(Grid(a), Nil) {
  let data = data |> glearray.from_list
  Ok(Grid(data, rows, cols))
}

pub fn pos_to_rc(pos: Pos, rows: Int, cols: Int) -> Result(RC, Nil) {
  case is_inside(pos, rows, cols) {
    True -> Ok(#(pos / cols, pos % cols))
    False -> Error(Nil)
  }
}

pub fn pos_to_rc_unsafe(pos: Pos, cols: Int) -> RC {
  #(pos / cols, pos % cols)
}

pub fn rc_to_pos(rc: RC, cols: Int) -> Result(Pos, Nil) {
  let #(r, c) = rc
  case r >= 0 && c >= 0 {
    True -> Ok(r * cols + c)
    False -> Error(Nil)
  }
}

pub fn rc_to_pos_unsafe(rc: RC, cols: Int) -> Pos {
  let #(r, c) = rc
  r * cols + c
}

/// Returns true if position pos is inside the grid boundary
pub fn is_inside(pos: Pos, rows: Int, cols: Int) -> Bool {
  pos >= 0 && pos < rows * cols
}

/// Returns the value in the grid at pos or Nil if out of bounds
pub fn get(g: Grid(a), pos: Pos) -> Result(a, Nil) {
  use v <- result.try(glearray.get(g.data, pos))
  Ok(v)
}

/// Sets the value in g at pos or Nil if out of bounds, returns the modified grid
/// Expensive because set make a new copy of the data
pub fn set(g: Grid(a), pos: Pos, v: a) -> Result(Grid(a), Nil) {
  use data <- result.try(glearray.copy_set(g.data, pos, v))
  Ok(Grid(..g, data: data))
}

pub fn map(g: Grid(a), f: fn(a) -> b) -> Grid(b) {
  let data = g.data |> glearray.to_list |> list.map(f) |> glearray.from_list
  Grid(rows: g.rows, cols: g.cols, data: data)
}

pub fn find_positions(g: Grid(a), f: fn(a) -> Bool) -> List(Pos) {
  g.data
  |> glearray.to_list
  |> list.index_fold([], fn(acc, v, idx) {
    case f(v) {
      True -> [idx, ..acc]
      False -> acc
    }
  })
}

// pub fn apply8(g: Grid(a), pos: Pos, f: fn(Grid(a), Pos) -> b) -> List(b) {
//   [
//     f(g, north(pos)),
//     f(g, north_west(pos)),
//     f(g, west(pos)),
//     f(g, south_west(pos)),
//     f(g, south(pos)),
//     f(g, south_east(pos)),
//     f(g, east(pos)),
//   ]
// }

// pub fn show(g: Grid(a)) {
//   io.debug("")
//   to_lists(g)
//   |> list.each(fn(vs) { io.debug(vs) })
// }

pub fn move_pos(
  direction dir: Dir,
  position pos: Pos,
  row_cnt rows: Int,
  col_cnt cols: Int,
) -> Result(Pos, Nil) {
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

pub fn move_pos_unsafe(
  direction dir: Dir,
  position pos: Pos,
  col_cnt cols: Int,
) -> Pos {
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

// pub fn move_pos_unsafe1(
//   direction dir: Dir,
//   position pos: Pos,
//   col_cnt cols: Int,
// ) -> Pos {
//   let #(r, c) = pos_to_rc_unsafe(pos, cols)
//   case dir {
//     N -> #(r - 1, c) |> rc_to_pos_unsafe(cols)
//     NW -> #(r - 1, c - 1) |> rc_to_pos_unsafe(cols)
//     W -> #(r, c - 1) |> rc_to_pos_unsafe(cols)
//     SW -> #(r + 1, c - 1) |> rc_to_pos_unsafe(cols)
//     S -> #(r + 1, c) |> rc_to_pos_unsafe(cols)
//     SE -> #(r + 1, c + 1) |> rc_to_pos_unsafe(cols)
//     E -> #(r, c + 1) |> rc_to_pos_unsafe(cols)
//     NE -> #(r - 1, c + 1) |> rc_to_pos_unsafe(cols)
//   }
// }

pub fn north(pos: Pos, rows: Int, cols: Int) -> Result(Pos, Nil) {
  move_pos(N, pos, rows, cols)
}

pub fn north_west(pos: Pos, rows: Int, cols: Int) -> Result(Pos, Nil) {
  move_pos(NW, pos, rows, cols)
}

pub fn west(pos: Pos, rows: Int, cols: Int) -> Result(Pos, Nil) {
  move_pos(W, pos, rows, cols)
}

pub fn south_west(pos: Pos, rows: Int, cols: Int) -> Result(Pos, Nil) {
  move_pos(SW, pos, rows, cols)
}

pub fn south(pos: Pos, rows: Int, cols: Int) -> Result(Pos, Nil) {
  move_pos(S, pos, rows, cols)
}

pub fn south_east(pos: Pos, rows: Int, cols: Int) -> Result(Pos, Nil) {
  move_pos(SE, pos, rows, cols)
}

pub fn east(pos: Pos, rows: Int, cols: Int) -> Result(Pos, Nil) {
  move_pos(E, pos, rows, cols)
}

pub fn north_east(pos: Pos, rows: Int, cols: Int) -> Result(Pos, Nil) {
  move_pos(NE, pos, rows, cols)
}
