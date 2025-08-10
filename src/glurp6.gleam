import gleam/bit_array
import gleam/crypto.{Sha1}
import gleam/string
import glurp6/utils.{le_bits_from_be_hex}

/// x = H( salt || H( username ":" password ) )
/// 
/// Returned x is little endian
pub fn srp6_x(user: String, pass: String, salt: BitArray) -> BitArray {
  let up =
    string.concat([string.uppercase(user), ":", string.uppercase(pass)])
    |> bit_array.from_string

  // H(U ":" P)
  let up_hash = crypto.hash(Sha1, up)
  let x_hash = crypto.hash(Sha1, bit_array.concat([salt, up_hash]))

  x_hash
}

pub fn main() -> Nil {
  let salt =
    le_bits_from_be_hex(
      "CAC94AF32D817BA64B13F18FDEDEF92AD4ED7EF7AB0E19E9F2AE13C828AEAF57",
    )

  let x = srp6_x("USERNAME123", "PASSWORD123", salt)
  let expected = le_bits_from_be_hex("D927E98BE3E9AF84FDC99DE9034F8E70ED7E90D6")

  assert x == expected

  Nil
}
