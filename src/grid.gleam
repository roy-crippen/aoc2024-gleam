import gleam/io
import gleam/list
import gleam/result
import glearray

pub type Grid(a) =
  glearray.Array(glearray.Array(a))

pub type Pos =
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

pub fn get_rows(g: Grid(a)) -> Int {
  glearray.length(g)
}

pub fn get_cols(g: Grid(a)) -> Result(Int, Nil) {
  use vs <- result.try(glearray.get(g, 0))
  Ok(glearray.length(vs))
}

// returns #(rows, cols)
pub fn size(g: Grid(a)) -> Result(#(Int, Int), Nil) {
  use cols_len <- result.try(get_cols(g))
  Ok(#(get_rows(g), cols_len))
}

// returns a Grid of rows by cols all with values v
pub fn make(rows: Int, cols: Int, v: a) -> Grid(a) {
  let col_array = list.repeat(v, cols) |> glearray.from_list
  list.repeat(col_array, rows) |> glearray.from_list
}

// returns a Grid from a List(List(a))
pub fn from_lists(xss: List(List(a))) -> Grid(a) {
  list.map(xss, fn(xs) { glearray.from_list(xs) }) |> glearray.from_list
}

// returns a Grid from a List(List(a))
pub fn to_lists(g: Grid(a)) -> List(List(a)) {
  glearray.to_list(g) |> list.map(fn(ar) { glearray.to_list(ar) })
}

// returns true if a row/col pair are inside the grid boundary
pub fn is_inside(g: Grid(a), r: Int, c: Int) -> Bool {
  let cols_ok = case get_cols(g) {
    Ok(cols) if c < cols -> True
    _ -> False
  }
  r >= 0 && r < get_rows(g) && c >= 0 && cols_ok
}

// returns the value in the grid at (r, c) or Nil if out of bounds
// should be very fast compared to List(a)
pub fn get(g: Grid(a), r: Int, c: Int) -> Result(a, Nil) {
  use vs <- result.try(glearray.get(g, r))
  use v <- result.try(glearray.get(vs, c))
  Ok(v)
}

// returns the value in the grid at (r, c) or Nil if out of bounds
// very expensive and probably slow
pub fn set(g: Grid(a), r: Int, c: Int, v: a) -> Result(Grid(a), Nil) {
  use vs <- result.try(glearray.get(g, r))
  use new_row <- result.try(glearray.copy_set(vs, c, v))
  glearray.copy_set(g, r, new_row)
}

pub fn map(g: Grid(a), f: fn(a) -> b) -> Grid(b) {
  let xss = to_lists(g)
  let yss = list.map(xss, fn(xs) { list.map(xs, fn(x) { f(x) }) })
  from_lists(yss)
}

pub fn apply8(g: Grid(a), pos: Pos, f: fn(Grid(a), Pos) -> b) -> List(b) {
  [
    f(g, north(pos)),
    f(g, north_west(pos)),
    f(g, west(pos)),
    f(g, south_west(pos)),
    f(g, south(pos)),
    f(g, south_east(pos)),
    f(g, east(pos)),
  ]
}

pub fn show(g: Grid(a)) {
  io.debug("")
  to_lists(g)
  |> list.each(fn(vs) { io.debug(vs) })
}

pub fn move(dir: Dir, pos: Pos) -> Pos {
  let #(r, c) = pos
  case dir {
    N -> #(r - 1, c)
    NW -> #(r - 1, c - 1)
    W -> #(r, c - 1)
    SW -> #(r + 1, c - 1)
    S -> #(r + 1, c)
    SE -> #(r + 1, c + 1)
    E -> #(r, c + 1)
    NE -> #(r - 1, c + 1)
  }
}

pub fn north(pos: Pos) -> Pos {
  move(N, pos)
}

pub fn north_west(pos: Pos) -> Pos {
  move(NW, pos)
}

pub fn west(pos: Pos) -> Pos {
  move(W, pos)
}

pub fn south_west(pos: Pos) -> Pos {
  move(SW, pos)
}

pub fn south(pos: Pos) -> Pos {
  move(S, pos)
}

pub fn south_east(pos: Pos) -> Pos {
  move(SE, pos)
}

pub fn east(pos: Pos) -> Pos {
  move(E, pos)
}

pub fn north_east(pos: Pos) -> Pos {
  move(NE, pos)
}
