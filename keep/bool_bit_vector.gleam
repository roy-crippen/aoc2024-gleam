import gleam/int
import gleam/result
import iv

pub type BoolBitVect {
  BBVect(data: iv.Array(Int))
}

pub fn from_list(xs: List(Int)) -> BoolBitVect {
  let data = iv.from_list(xs)
  BBVect(data)
}

pub fn length(vect: BoolBitVect) -> Int {
  vect.data |> iv.length
}

pub fn get_bool_bit(vect: BoolBitVect, key: Int) -> Result(Bool, Nil) {
  let buckets = iv.length(vect.data)
  let bucket = case key / 64 {
    v if v >= 0 && v < buckets -> Ok(v)
    _ -> Error(Nil)
  }
  let assert Ok(bucket) = bucket
  let bit = key % 64
  let assert Ok(val) = iv.get(vect.data, bucket)
  let shifted = int.bitwise_shift_right(val, bit)
  let masked = int.bitwise_and(shifted, 1)
  Ok(masked == 1)
  // True if bit=1 (set/true)
}

pub fn toggle_bool_bit(vect: BoolBitVect, key: Int) -> Result(BoolBitVect, Nil) {
  let buckets = iv.length(vect.data)
  let bucket = case key / 64 {
    v if v >= 0 && v < buckets -> Ok(v)
    _ -> Error(Nil)
  }
  let assert Ok(bucket) = bucket
  let bit = key % 64
  let assert Ok(val) = iv.get(vect.data, bucket)
  let bit_mask = int.bitwise_shift_left(1, bit)
  let new_val = int.bitwise_exclusive_or(val, bit_mask)
  // Flip: 0↔1
  use data <- result.try(iv.set(vect.data, bucket, new_val))
  Ok(BBVect(data))
}
