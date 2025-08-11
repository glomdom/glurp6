import gleam/list
import gleam/string
import glurp6
import glurp6/utils
import simplifile

pub fn server_session_key_values_test() {
  let filepath = "test/data/server_session_key_values.txt"
  let assert Ok(test_data) = simplifile.read(from: filepath)
  let lines = test_data |> string.split(on: "\n")

  list.each(lines, fn(line) {
    let parts = string.split(line, on: " ")
    case parts {
      [cpk_str, verifier_str, u_str, spk_str, expected_sk_str] -> {
        let cpk = cpk_str |> utils.le_bits_from_be_hex
        let verifier = verifier_str |> utils.le_bits_from_be_hex
        let u = u_str |> utils.le_bits_from_be_hex
        let spk = spk_str |> utils.le_bits_from_be_hex
        let expected_sk = expected_sk_str |> utils.le_bits_from_be_hex
        let sk = glurp6.calculate_server_session_key(cpk, verifier, u, spk)

        assert sk == expected_sk
      }

      _ -> panic as "malformed test data in x_values.txt"
    }
  })
}
