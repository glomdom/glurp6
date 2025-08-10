import gleam/bit_array
import gleam/crypto.{Sha1}
import gleam/string
import glurp6/constants
import glurp6/utils

/// Returned x is little endian bitarray of size (20 * 8)
pub fn calculate_x(user: String, pass: String, salt: BitArray) -> BitArray {
  let up =
    string.concat([string.uppercase(user), ":", string.uppercase(pass)])
    |> bit_array.from_string

  let up_hash = crypto.hash(Sha1, up)
  let x_hash = crypto.hash(Sha1, bit_array.concat([salt, up_hash]))

  utils.pad(x_hash, 160)
}

/// Returned verifier is little endian bitarray of size (32 * 8)
pub fn calculate_password_verifier(
  user: String,
  pass: String,
  salt: BitArray,
) -> BitArray {
  let x = calculate_x(user, pass, salt)
  let assert <<x_int:little-int-size(160)>> = x

  let v_int = utils.mod_pow(constants.generator, x_int, constants.prime)
  let v = <<v_int:little-int-size(256)>>

  utils.pad(v, 256)
}

pub fn calculate_server_public_key(
  pass_verifier: BitArray,
  server_private_key: BitArray,
) -> BitArray {
  let verifier_size = bit_array.bit_size(pass_verifier)
  let assert <<x_int:little-int-size(verifier_size)>> = pass_verifier

  let key_size = bit_array.bit_size(server_private_key)
  let assert <<b_int:little-int-size(key_size)>> = server_private_key

  let key_int =
    {
      constants.k
      * x_int
      + utils.mod_pow(constants.generator, b_int, constants.prime)
    }
    % constants.prime

  let key = <<key_int:little-size(256)>>

  utils.pad(key, 256)
}
