import gleam/io
import gleeunit/should
import grid

const grid_list = [
  [".", ".", "#", ".", "#"],
  [".", ".", ".", ".", "."],
  [".", ".", ".", "#", "."],
  [".", ".", "^", ".", "."],
  ["#", ".", "#", ".", "."],
]

pub fn from_list_and_set_test() {
  let g = grid.from_lists(grid_list)
  // grid.show(g)
  let assert Ok(g1) = grid.set(g, 3, 2, "$")
  grid.get(g1, 3, 2) |> should.equal(Ok("$"))
}

pub fn map_test() {
  let g = grid.from_lists(grid_list)
  let f = fn(s: String) { s <> "aaa" }
  let g1 = grid.map(g, f)
  // grid.show(g1)
  grid.get(g1, 3, 2) |> io.debug |> should.equal(Ok("^aaa"))
}

pub fn make_test() {
  let g = grid.make(10, 10, 0)
  grid.size(g) |> should.equal(Ok(#(10, 10)))
  // grid.show(g)
}

pub fn get_test() {
  let g = grid.from_lists(grid_list)
  grid.size(g) |> should.equal(Ok(#(5, 5)))
  grid.get(g, 3, 2) |> should.equal(Ok("^"))
}

pub fn is_inside_test() {
  let g = grid.from_lists(grid_list)
  grid.is_inside(g, 0, 0) |> should.be_true
  grid.is_inside(g, 4, 4) |> should.be_true
  grid.is_inside(g, -1, 0) |> should.be_false
  grid.is_inside(g, 0, -1) |> should.be_false
  grid.is_inside(g, 4, 5) |> should.be_false
  grid.is_inside(g, 5, -4) |> should.be_false
}

pub fn move_test() {
  let pos1 = #(3, 2)
  let pos2 = pos1 |> grid.north |> grid.east |> grid.south |> grid.west
  should.equal(pos1, pos2)
  let pos3 =
    pos1
    |> grid.north_east
    |> grid.north_west
    |> grid.south_west
    |> grid.south_east
  should.equal(pos1, pos3)
}
