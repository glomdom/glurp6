import gleam/list
import gleam/string
import glurp6
import glurp6/utils
import simplifile

pub fn b_values_test() {
  let filepath = "test/data/b_values.txt"
  let assert Ok(test_data) = simplifile.read(from: filepath)
  let lines = test_data |> string.split(on: "\n")

  list.each(lines, fn(line) {
    let parts = string.split(line, on: " ")
    case parts {
      [verifier_str, private_key_str, expected_key_str] -> {
        let verifier = verifier_str |> utils.le_bits_from_be_hex
        let private_key = private_key_str |> utils.le_bits_from_be_hex
        let expected_key_str = expected_key_str |> utils.le_bits_from_be_hex
        let key = glurp6.calculate_server_public_key(verifier, private_key)

        assert key == expected_key_str
      }

      _ -> panic as "malformed test data in x_values.txt"
    }
  })
}
