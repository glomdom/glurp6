import gleam/bit_array

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
