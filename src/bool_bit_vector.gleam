import gleam/int
import iv

pub fn get_bool_bit(xs: iv.Array(Int), key: Int) -> Result(Bool, Nil) {
  let buckets = iv.length(xs)
  let bucket = case key / 64 {
    v if v >= 0 && v < buckets -> Ok(v)
    _ -> Error(Nil)
  }
  let assert Ok(bucket) = bucket
  let bit = key % 64
  let assert Ok(val) = iv.get(xs, bucket)
  let shifted = int.bitwise_shift_right(val, bit)
  let masked = int.bitwise_and(shifted, 1)
  Ok(masked == 1)
  // True if bit=1 (set/true)
}

pub fn toggle_bool_bit(
  xs: iv.Array(Int),
  key: Int,
) -> Result(iv.Array(Int), Nil) {
  let buckets = iv.length(xs)
  let bucket = case key / 64 {
    v if v >= 0 && v < buckets -> Ok(v)
    _ -> Error(Nil)
  }
  let assert Ok(bucket) = bucket
  let bit = key % 64
  let assert Ok(val) = iv.get(xs, bucket)
  let bit_mask = int.bitwise_shift_left(1, bit)
  let new_val = int.bitwise_exclusive_or(val, bit_mask)
  // Flip: 0↔1
  iv.set(xs, bucket, new_val)
}
