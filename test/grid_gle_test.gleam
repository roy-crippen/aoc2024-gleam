import gleam/result
import gleam/string
import glearray
import gleeunit/should
import grid_gle.{type Grid, is_inside, rc_to_pos}
import utils

const grid_str = ".......#.#...#...^..#.#.."

fn from_list_grid() -> Grid(String) {
  grid_str |> string.to_graphemes |> grid_gle.from_list(5, 5) |> utils.unwrap
}

pub fn get_and_set_test() {
  let g = from_list_grid()
  // io.debug("")
  // io.debug("")
  // grid_gle.show_str(g) |> list.each(io.debug)
  // io.debug("")

  let assert Ok("^") = grid_gle.get(g, 17)
  let assert Ok(g1) = grid_gle.set(g, 17, "$")
  grid_gle.get(g1, 17) |> should.equal(Ok("$"))
}

pub fn map_test() {
  let g = from_list_grid()
  let f = fn(s: String) { s <> "aaa" }
  let g1 = grid_gle.map(g, f)
  grid_gle.get(g1, 17) |> should.equal(Ok("^aaa"))
}

pub fn make_test() {
  let g = grid_gle.make(5, 3, 0)
  // io.debug("")
  // grid_gle.show(g)
  g.rows |> should.equal(5)
  g.cols |> should.equal(3)
  g.data
  |> glearray.to_list
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
  let ps = grid_gle.find_positions(g, fn(s) { s == "^" })
  should.equal(ps, [17])
}
