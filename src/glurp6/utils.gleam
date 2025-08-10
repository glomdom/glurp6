import gleam/bit_array
import gleam/int

pub fn be_to_le(bits: BitArray) -> BitArray {
  reverse_byte_order(bits)
}

pub fn le_to_be(bits: BitArray) -> BitArray {
  reverse_byte_order(bits)
}

pub fn le_bits_from_be_hex(hex: String) -> BitArray {
  let assert Ok(bits) = bit_array.base16_decode(hex)

  be_to_le(bits)
}

pub fn reverse_byte_order(bits: BitArray) -> BitArray {
  case bit_array.bit_size(bits) % 8 {
    0 -> reverse(bits, <<>>)
    _ -> panic as "expected a whole number of bytes"
  }
}

fn reverse(bits: BitArray, acc: BitArray) -> BitArray {
  case bits {
    <<b:8, rest:bytes>> -> reverse(rest, <<b:8, acc:bits>>)
    <<>> -> acc
    _ -> acc
  }
}

pub fn mod_pow(base: Int, exp: Int, modulus: Int) -> Int {
  case exp {
    0 -> 1
    _ if exp % 2 == 0 -> {
      let assert Ok(div) = int.divide(exp, 2)
      let half = mod_pow(base, div, modulus)

      { half * half } % modulus
    }

    _ -> { base * mod_pow(base, exp - 1, modulus) } % modulus
  }
}

pub fn pad(bits: BitArray, to: Int) -> BitArray {
  let to_pad = bit_array.bit_size(bits) - to

  case to_pad {
    0 -> bits
    _ if to_pad > 0 -> <<bits:bits, 0:size(to_pad)>>
    _ if to_pad < 0 -> <<bits:bits-256>>
    _ -> panic as "failed to pad bitarray"
  }
}
