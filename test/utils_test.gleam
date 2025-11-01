import gleeunit/should
import utils

pub fn unwrap_test() {
  Ok(25) |> utils.unwrap |> should.equal(25)
}
