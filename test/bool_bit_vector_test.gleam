import bool_bit_vector as bbv
import gleeunit/should

pub fn get_and_set_test() {
  let rows = 130
  let cols = 130
  let total_states = rows * cols * 4
  let num_buckets = { total_states + 63 } / 64

  // all false (0s)
  let xs = bbv.new_unsigned(num_buckets)

  let idx = 60_000
  let is_value_set = bbv.get_bool_bit(xs, idx)
  #("a", bbv.length(xs), idx, is_value_set)
  |> should.equal(#("a", 1057, 60_000, Ok(False)))

  let assert Ok(_) = bbv.toggle_bool_bit(xs, idx)
  let is_value_set = bbv.get_bool_bit(xs, idx)
  #("b", bbv.length(xs), idx, is_value_set)
  |> should.equal(#("b", 1057, 60_000, Ok(True)))

  let assert Ok(_) = bbv.toggle_bool_bit(xs, idx)
  let is_value_set = bbv.get_bool_bit(xs, idx)
  #("c", bbv.length(xs), idx, is_value_set)
  |> should.equal(#("c", 1057, 60_000, Ok(False)))
}
