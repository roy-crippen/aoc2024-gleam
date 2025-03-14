import gleam/dict
import gleam/int
import gleam/list
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/set
import gleam/string
import utils.{Solution, read_file}

type Rules =
  dict.Dict(Int, set.Set(Int))

const expected_part1 = 6034

const expected_part2 = 6305

pub fn solution_day_05() -> utils.Solution {
  Solution(
    part1,
    part2,
    expected_part1,
    expected_part2,
    day: 05,
    input_str: read_file("data/day_05.txt"),
  )
}

fn part1(s: String) -> Int {
  let #(rules, updates) = parse(s)
  let goods = updates |> list.filter(fn(xs) { is_in_order(rules, xs) })
  let middle = fn(xs) { xs |> list.drop(list.length(xs) / 2) |> list.take(1) }
  let centers = goods |> list.flat_map(middle)

  // sum up the centers
  centers |> list.fold(0, fn(acc, v) { acc + v })
}

fn part2(s: String) -> Int {
  let #(rules, updates) = parse(s)

  let bads = updates |> list.filter(fn(xs) { !is_in_order(rules, xs) })
  let sort = fn(xs) { list.sort(xs, fn(a, b) { cmp_by_rule(rules, a, b) }) }
  let goods = bads |> list.map(sort)
  let middle = fn(xs) { xs |> list.drop(list.length(xs) / 2) |> list.take(1) }
  let centers = goods |> list.flat_map(middle)

  // sum up the centers
  centers |> list.fold(0, fn(acc, v) { acc + v })
}

fn cmp_by_rule(rules: Rules, a: Int, b: Int) -> Order {
  let a_sucs = dict.get(rules, a)
  let b_sucs = dict.get(rules, b)
  case a_sucs, b_sucs {
    Error(Nil), _ -> Gt
    _, Error(Nil) -> Lt
    Ok(a_set), Ok(b_set) -> {
      case set.contains(a_set, b), set.contains(b_set, a) {
        True, False -> Lt
        False, True -> Gt
        // Eq will never happen
        _, _ -> Eq
      }
    }
  }
}

fn is_in_order(rules: Rules, xs: List(Int)) -> Bool {
  list.window_by_2(xs)
  |> list.fold_until(True, fn(acc, pair) {
    let #(curr, next) = pair
    case dict.has_key(rules, curr) {
      True -> {
        let assert Ok(set0) = dict.get(rules, curr)
        case set.contains(set0, next) {
          True -> list.Continue(acc)
          False -> list.Stop(False)
        }
      }
      False -> list.Stop(False)
    }
  })
}

fn parse(s: String) -> #(Rules, List(List(Int))) {
  let #(s_rules, s_updates) =
    string.split(s, "\n") |> list.split_while(fn(s) { !string.is_empty(s) })

  let rules =
    s_rules
    |> list.map(fn(s) {
      let assert Ok(#(s1, s2)) = string.split_once(s, "|")
      let assert Ok(v1) = int.parse(s1)
      let assert Ok(v2) = int.parse(s2)
      #(v1, v2)
    })
    |> list.fold(dict.new(), fn(acc_dict, pair) {
      let #(k, v) = pair
      case dict.has_key(acc_dict, k) {
        True -> {
          let assert Ok(set0) = dict.get(acc_dict, k)
          let set1 = set.insert(set0, v)
          dict.insert(acc_dict, k, set1)
        }
        _ -> {
          let set0 = set.new() |> set.insert(v)
          dict.insert(acc_dict, k, set0)
        }
      }
    })

  let updates =
    s_updates
    |> list.drop(1)
    |> list.map(fn(s) {
      string.split(s, ",")
      |> list.map(fn(s) {
        let assert Ok(v) = int.parse(s)
        v
      })
    })

  #(rules, updates)
}

pub const example_string = "47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47"
