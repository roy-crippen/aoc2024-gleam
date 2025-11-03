import bool_bit_vector as bbv
import gleam/list
import gleeunit/should
import iv

pub fn get_and_set_test() {
  let rows = 130
  let cols = 130
  let total_states = rows * cols * 4
  let num_buckets = { total_states + 63 } / 64

  // all false (0s)
  let xs = list.repeat(0, num_buckets) |> iv.from_list

  let idx = 60_000
  let is_value_set = bbv.get_bool_bit(xs, idx)
  #("a", iv.length(xs), idx, is_value_set)
  |> should.equal(#("a", 1057, 60_000, Ok(False)))

  let assert Ok(xs) = bbv.toggle_bool_bit(xs, idx)
  let is_value_set = bbv.get_bool_bit(xs, idx)
  #("b", iv.length(xs), idx, is_value_set)
  |> should.equal(#("b", 1057, 60_000, Ok(True)))

  let assert Ok(xs) = bbv.toggle_bool_bit(xs, idx)
  let is_value_set = bbv.get_bool_bit(xs, idx)
  #("c", iv.length(xs), idx, is_value_set)
  |> should.equal(#("c", 1057, 60_000, Ok(False)))
}
