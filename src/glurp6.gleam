import gleam/bit_array
import gleam/crypto.{Sha1}
import gleam/string
import glurp6/constants
import glurp6/utils

/// x = H( salt || H( username ":" password ) )
/// 
/// Returned x is little endian
pub fn calculate_x(user: String, pass: String, salt: BitArray) -> BitArray {
  let up =
    string.concat([string.uppercase(user), ":", string.uppercase(pass)])
    |> bit_array.from_string

  // H(U ":" P)
  let up_hash = crypto.hash(Sha1, up)
  let x_hash = crypto.hash(Sha1, bit_array.concat([salt, up_hash]))

  x_hash
}

/// Returned verifier is little endian of size (32 * 8)
pub fn calculate_password_verifier(
  user: String,
  pass: String,
  salt: BitArray,
) -> BitArray {
  let x = calculate_x(user, pass, salt)
  let assert <<x_int:little-int-size(20 * 8)>> = x

  let v_int = utils.mod_pow(constants.generator, x_int, constants.prime)
  let v = <<v_int:little-int-size(256)>>

  v
}
