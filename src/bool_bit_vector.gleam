import atomic_array as ata
import gleam/int

pub type BoolBitVect {
  BBVect(data: ata.AtomicArray, size: Int)
}

pub fn new_unsigned(size size: Int) -> BoolBitVect {
  BBVect(data: ata.new_unsigned(size), size: size)
}

pub fn length(vect: BoolBitVect) -> Int {
  vect.size
}

pub fn get_bool_bit(vect: BoolBitVect, key: Int) -> Result(Bool, Nil) {
  let bucket = key / 64
  let bit = key % 64
  let assert Ok(val) = ata.get(vect.data, bucket)
  let shifted = int.bitwise_shift_right(val, bit)
  let masked = int.bitwise_and(shifted, 1)

  // true if masked==1
  Ok(masked == 1)
}

pub fn toggle_bool_bit(vect: BoolBitVect, key: Int) -> Result(Nil, Nil) {
  let bucket = key / 64
  let bit = key % 64
  let assert Ok(val) = ata.get(vect.data, bucket)
  let bit_mask = int.bitwise_shift_left(1, bit)
  let new_val = int.bitwise_exclusive_or(val, bit_mask)
  ata.set(vect.data, bucket, new_val)
}
