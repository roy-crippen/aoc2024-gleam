import gleam/result
import gleam/string
import gleeunit/should
import grid.{type Grid, is_inside, rc_to_pos}
import iv
import utils

const grid_str = ".......#.#...#...^..#.#.."

fn from_list_grid() -> Grid(String) {
  grid_str |> string.to_graphemes |> grid.from_list(5, 5) |> utils.unwrap
}

pub fn get_and_set_test() {
  let g = from_list_grid()
  // io.debug("")
  // io.debug("")
  // grid.show_str(g) |> list.each(io.debug)
  // io.debug("")

  let assert Ok("^") = grid.get(g, 17)
  let assert Ok(g1) = grid.set(g, 17, "$")
  grid.get(g1, 17) |> should.equal(Ok("$"))
}

pub fn map_test() {
  let g = from_list_grid()
  let f = fn(s: String) { s <> "aaa" }
  let g1 = grid.map(g, f)
  grid.get(g1, 17) |> should.equal(Ok("^aaa"))
}

pub fn make_test() {
  let g = grid.make(5, 3, 0)
  // io.debug("")
  // grid.show(g)
  g.rows |> should.equal(5)
  g.cols |> should.equal(3)
  g.data
  |> iv.to_list
  |> should.equal([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
}

pub fn is_inside_test() {
  let g = from_list_grid()
  is_inside(rc_to_pos(#(0, 0), g.cols) |> result.unwrap(-1), g.rows, g.cols)
  |> should.be_true
  is_inside(rc_to_pos(#(4, 4), g.cols) |> result.unwrap(-1), g.rows, g.cols)
  |> should.be_true
  is_inside(rc_to_pos(#(-1, 0), g.cols) |> result.unwrap(-1), g.rows, g.cols)
  |> should.be_false
  is_inside(rc_to_pos(#(0, -1), g.cols) |> result.unwrap(-1), g.rows, g.cols)
  |> should.be_false
  is_inside(rc_to_pos(#(4, 5), g.cols) |> result.unwrap(-1), g.rows, g.cols)
  |> should.be_false
  is_inside(rc_to_pos(#(5, -4), g.cols) |> result.unwrap(-1), g.rows, g.cols)
  |> should.be_false
}

pub fn find_positions_test() {
  let g = from_list_grid()
  let ps = grid.find_positions(g, fn(s) { s == "^" })
  should.equal(ps, [17])
}
