import gleam/list
import gleam/string
import glurp6
import glurp6/utils
import simplifile

pub fn values_test() {
  let filepath = "test/data/u_values.txt"
  let assert Ok(test_data) = simplifile.read(from: filepath)
  let lines = test_data |> string.split(on: "\n")

  list.each(lines, fn(line) {
    let parts = string.split(line, on: " ")
    case parts {
      [cpk_str, spk_str, expected_u_str] -> {
        let cpk = cpk_str |> utils.le_bits_from_be_hex
        let spk = spk_str |> utils.le_bits_from_be_hex
        let expected_u = expected_u_str |> utils.le_bits_from_be_hex
        let u = glurp6.calculate_u(cpk, spk)

        assert u == expected_u
      }

      _ -> panic as "malformed test data"
    }
  })
}
