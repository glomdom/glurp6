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
  case modulus {
    1 -> 0

    _ -> {
      let base = pos_mod(base, modulus)
      loop(base, exp, modulus, 1)
    }
  }
}

fn pos_mod(n: Int, m: Int) -> Int {
  let r = n % m
  case r < 0 {
    True -> r + m
    False -> r
  }
}

fn loop(base: Int, exp: Int, modulus: Int, acc: Int) -> Int {
  case exp {
    0 -> acc

    _ if exp % 2 != 0 -> loop(base, exp - 1, modulus, { acc * base } % modulus)
    _ -> {
      let assert Ok(div) = int.divide(exp, 2)

      loop({ base * base } % modulus, div, modulus, acc)
    }
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

pub fn bits_to_int(bits: BitArray, little: Bool) -> Int {
  let size = bit_array.bit_size(bits)

  case little {
    True -> {
      let assert <<int:little-int-size(size)>> = bits
      int
    }

    False -> {
      let assert <<int:little-int-size(size)>> = bits
      int
    }
  }
}
