import gleam/list
import gleam/string
import glurp6
import glurp6/utils
import simplifile

pub fn b_values_test() {
  let filepath = "test/data/client_session_key_values.txt"
  let assert Ok(test_data) = simplifile.read(from: filepath)
  let lines = test_data |> string.split(on: "\n")

  list.each(lines, fn(line) {
    let parts = string.split(line, on: " ")
    case parts {
      [spk_str, cpk_str, x_str, u_str, expected_sk_str] -> {
        let spk = spk_str |> utils.le_bits_from_be_hex
        let cpk = cpk_str |> utils.le_bits_from_be_hex
        let x = x_str |> utils.le_bits_from_be_hex
        let u = u_str |> utils.le_bits_from_be_hex
        let expected_sk = expected_sk_str |> utils.le_bits_from_be_hex
        let sk = glurp6.calculate_client_session_key(cpk, spk, x, u)

        assert sk == expected_sk
      }

      _ -> panic as "malformed test data in x_values.txt"
    }
  })
}
