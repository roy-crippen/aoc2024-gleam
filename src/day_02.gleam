import gleam/int
import gleam/list
import gleam/string
import utils.{Solution, read_file}

const expected_part1 = 390

const expected_part2 = 439

type Ordered {
  Asc
  Desc
  NoOrder
}

pub fn solution_day_02() -> utils.Solution {
  Solution(
    part1,
    part2,
    expected_part1,
    expected_part2,
    day: 2,
    input_str: read_file("data/day_02.txt"),
  )
}

fn part1(s: String) -> Int {
  parse(s)
  |> list.map(fn(xs) { xs |> diffs })
  |> list.fold(0, fn(acc, xs) {
    case is_safe(xs).0 {
      True -> acc + 1
      _ -> acc
    }
  })
}

fn part2(s: String) -> Int {
  parse(s)
  |> list.fold(0, fn(acc, xs) {
    case is_safe_part2(xs) {
      True -> acc + 1
      _ -> acc
    }
  })
}

fn is_safe(xs: List(Int)) -> #(Bool, Int) {
  // determine the order
  let assert Ok(first) = list.first(xs)
  let ord = case first {
    0 -> NoOrder
    v if v < 0 -> Asc
    _ -> Desc
  }

  // find 'unsafe' index if any
  let find_bad_idx =
    list.try_fold(xs, 0, fn(acc, x) {
      let v = int.absolute_value(x)
      let levels_ok = v > 0 && v < 4
      let ok =
        { levels_ok && x < 0 && ord == Asc }
        || { levels_ok && x > 0 && ord == Desc }
      case ok {
        True -> Ok(acc + 1)
        False -> Error(acc)
      }
    })

  // report everything ok or failure index
  case find_bad_idx {
    Ok(i) -> #(True, i)
    Error(i) -> #(False, i)
  }
}

fn is_safe_part2(xs: List(Int)) -> Bool {
  let ds = diffs(xs)
  let #(b, idx) = is_safe(ds)
  case b {
    True -> True
    _ -> {
      // try removing idx and idx +/- 1
      let yss = [
        remove_1(xs, idx - 1) |> diffs,
        remove_1(xs, idx) |> diffs,
        remove_1(xs, idx + 1) |> diffs,
      ]
      list.any(yss, fn(ys) { is_safe(ys).0 })
    }
  }
}

fn remove_1(xs: List(Int), idx: Int) -> List(Int) {
  let #(lefts, rights) = list.split(xs, idx)
  let assert Ok(rest) = list.rest(rights)
  list.append(lefts, rest)
}

fn diffs(xs: List(Int)) -> List(Int) {
  diffs_loop(xs, [])
}

fn diffs_loop(ys: List(Int), rs: List(Int)) -> List(Int) {
  case ys {
    [] -> list.reverse(rs)
    [first, second] -> list.reverse([{ first - second }, ..rs])
    [first, second, ..rest] ->
      diffs_loop([second, ..rest], [{ first - second }, ..rs])
    [_] -> panic
  }
}

fn parse(s: String) -> List(List(Int)) {
  string.split(s, "\n")
  |> list.map(fn(s) {
    s
    |> string.split(" ")
    |> list.map(fn(s) {
      let assert Ok(v) = int.parse(s)
      v
    })
  })
}

pub const example_string = "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9"
