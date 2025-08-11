import gleam/bit_array
import gleam/crypto.{Sha1}
import gleam/string
import glurp6/constants
import glurp6/utils

/// Returned x is little endian bitarray of size `160 bits / 20 bytes`
pub fn calculate_x(user: String, pass: String, salt: BitArray) -> BitArray {
  let up =
    string.concat([string.uppercase(user), ":", string.uppercase(pass)])
    |> bit_array.from_string

  let up_hash = crypto.hash(Sha1, up)
  let x_hash = crypto.hash(Sha1, bit_array.concat([salt, up_hash]))

  utils.pad(x_hash, 160)
}

/// Returned verifier is little endian bitarray of size `256 bits / 32 bytes`
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

/// Returned server public key is little endian bitarray of size `256 bits / 32 bytes`
pub fn calculate_server_public_key(
  pass_verifier: BitArray,
  server_private_key: BitArray,
) -> BitArray {
  let x_int = utils.bits_to_int(pass_verifier, True)
  let b_int = utils.bits_to_int(server_private_key, True)

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

pub fn calculate_client_session_key(
  client_private_key: BitArray,
  server_public_key: BitArray,
  x: BitArray,
  u: BitArray,
) -> BitArray {
  let cpk_int = utils.bits_to_int(client_private_key, True)
  let spk_int = utils.bits_to_int(server_public_key, True)
  let x_int = utils.bits_to_int(x, True)
  let u_int = utils.bits_to_int(u, True)

  let session_key_int =
    utils.mod_pow(
      {
        spk_int
        - constants.k
        * utils.mod_pow(constants.generator, x_int, constants.prime)
      },
      { cpk_int + u_int * x_int },
      constants.prime,
    )

  let session_key = <<session_key_int:little-size(256)>>

  utils.pad(session_key, 256)
}

pub fn calculate_server_session_key(
  client_public_key: BitArray,
  verifier: BitArray,
  u: BitArray,
  server_private_key: BitArray,
) -> BitArray {
  let cpk_int = utils.bits_to_int(client_public_key, True)
  let verifier_int = utils.bits_to_int(verifier, True)
  let u_int = utils.bits_to_int(u, True)
  let spk_int = utils.bits_to_int(server_private_key, True)

  let session_key_int =
    utils.mod_pow(
      cpk_int * utils.mod_pow(verifier_int, u_int, constants.prime),
      spk_int,
      constants.prime,
    )

  let session_key = <<session_key_int:little-size(256)>>

  utils.pad(session_key, 256)
}
