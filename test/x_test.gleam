import gleam/list
import gleam/string
import glurp6
import glurp6/utils
import simplifile

pub fn x_salt_values_test() {
  let filepath = "test/data/x_salt_values.txt"
  let assert Ok(test_data) = simplifile.read(from: filepath)
  let lines = test_data |> string.split(on: "\n")

  list.each(lines, fn(line) {
    let assert Ok(parts) = string.split_once(line, on: " ")
    case parts {
      #(salt_str, expected_x_str) -> {
        let salt = salt_str |> utils.le_bits_from_be_hex
        let expected_x = expected_x_str |> utils.le_bits_from_be_hex
        let x = glurp6.calculate_x("USERNAME123", "PASSWORD123", salt)

        assert x == expected_x
      }
    }
  })
}

pub fn x_values_test() {
  let filepath = "test/data/x_values.txt"
  let assert Ok(test_data) = simplifile.read(from: filepath)
  let lines = test_data |> string.split(on: "\n")
  let salt =
    "CAC94AF32D817BA64B13F18FDEDEF92AD4ED7EF7AB0E19E9F2AE13C828AEAF57"
    |> utils.le_bits_from_be_hex

  list.each(lines, fn(line) {
    let parts = string.split(line, on: " ")
    case parts {
      [user_str, pass_str, expected_x_str] -> {
        let expected_x = expected_x_str |> utils.le_bits_from_be_hex
        let x = glurp6.calculate_x(user_str, pass_str, salt)

        assert x == expected_x
      }

      _ -> panic as "malformed test data in x_values.txt"
    }
  })
}
