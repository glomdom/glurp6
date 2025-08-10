import gleam/list
import gleam/string
import glurp6
import glurp6/utils
import simplifile

pub fn v_values_test() {
  let filepath = "test/data/v_values.txt"
  let assert Ok(test_data) = simplifile.read(from: filepath)
  let lines = test_data |> string.split(on: "\n")

  list.each(lines, fn(line) {
    let parts = string.split(line, on: " ")
    case parts {
      [user_str, pass_str, salt_str, expected_v_str] -> {
        let salt = salt_str |> utils.le_bits_from_be_hex
        let expected_v = expected_v_str |> utils.le_bits_from_be_hex
        let v = glurp6.calculate_password_verifier(user_str, pass_str, salt)

        assert v == expected_v
      }

      _ -> panic as "malformed test data in x_values.txt"
    }
  })
}
