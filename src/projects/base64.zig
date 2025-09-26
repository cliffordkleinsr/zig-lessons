const std = @import("std");
/// # Introduction
/// Base64 is an encoding system which translates binary data to text.
/// A big chunk of the web uses base64 to deliver binary data to systems that can only read text data.
///
/// ## Checklist
/// But how exactly does the algorithm behind the base64 encoding work?
/// Let’s discuss that.
/// 1. First, we will explain the base64 scale, which is the 64-character scale that is the basis for the base64 encoding system.
/// 2. After that, we explain the algorithm behind a base64 encoder, which is the part of the algorithm that is responsible for encoding messages into the base64 encoding system.
/// 3. We then explain the algorithm behind a base64 decoder,
///    which is the part of the algorithm that is responsible for translating base64 messages back into their original meaning.
///
/// ### The base64 scale
/// The base64 encoding system is based on a scale that goes from **0 to 63** (hence the name).
/// Each index in this scale is represented by a character (it’s a scale of 64 characters).
/// Therefore, in order to convert some binary data, to the base64 encoding,
/// we need to convert each binary number to the corresponding character in this “scale of 64 characters”.
///
/// - The base64 scale starts with all ASCII uppercase letters **(A to Z)** which represents the first 25 indexes in this scale **(0 to 25)**.
/// - After that, we have all ASCII lowercase letters **(a to z)**, which represents the range **26 to 51** in the scale.
/// - After that, we have the one digit numbers **(0 to 9)**, which represents the indexes from **52 to 61** in the scale.
/// - Finally, the last two indexes in the scale **(62 and 63)** are represented by the characters **+ and /**, respectively.
/// - The character `=` represents the end of meaningful characters in the sequence
///
/// These are the 64 characters that compose the base64 scale.
///
/// ### Creating the scale as a lookup table
/// The best way to represent this scale in code, is to represent it as a lookup table.
/// The basic idea is to replace a runtime calculation **(which can take a long time to be done)** with a basic array indexing operation.
///
/// Instead of calculating the results everytime you need them, you calculate all possible results at once,
/// and then, you store them in an array (which behaves like a “table”).
/// Then, every time you need to use one of the characters in the base64 scale,
/// instead of using many resources to calculate the exact character to be used,
/// you simply retrieve this character from the array where you stored all the possible characters in the base64 scale.
/// We retrieve the character that we need directly from memory.
///
/// We can start building a Zig struct to store our base64 decoder/encoder logic. We start with the `Base64` struct below.
/// For now, we only have one single data member in this struct, i.e., the member `_table`, which represents our lookup table.
/// We also have an `init()` method, to create a new instance of a `Base64` object, and, a `_char_at()` method, which is a “get character at index `𝑥`” type of function.
///
/// In other words, the `_char_at()` method is responsible for getting the character in the lookup table (i.e., the _table struct data member)
/// that corresponds to a particular index in the “base64 scale”.
/// So, in the example below, we know that the character that corresponds to the index 28 in the “base64 scale” is the character “c”.
///
/// ### A base64 encoder
/// https://www.sunshine2k.de/articles/coding/base64/understanding_base64.html
///
/// The encoding algorithm is pretty simple:
/// The algorithm behind a base64 encoder usually works on a window of 3 bytes.
/// Since each byte has 8 bits, so, 3 bytes forms a set of `8 x 3 = 24bits`
/// Take three character bytes from the input stream `(24bits)`, divide them into four `6bit` parts and convert each `6bit` value according to the table we creted in the struct.
/// Repeat this until no more input character bytes are left.
/// What to do if the number of input character bytes is not divisible by three?In this case, the input buffer is filled up with zeros until it is divisable by three.
/// Then each 6bit part which was filled up with zero is encoded with the special padding character '='.
///
/// Example encoding for the input string "Sun":
/// ```rs
/// Input character bytes: S          u           n
/// ASCII Hex value:       0x53       0x75        0x6E //not actually used
/// Binary                 01010011   01110101    01101110
/// 6bit parts:            010100     110111      010101       101110
/// Decimal (index)values: 20         55          21           46
/// Base64 characters:     U          3           V            u
///```
///So the string "Sun" has encoded in Base64 the value "U3Vu".
///
/// So actually there are three cases that could happen:
///
/// 1. If There is only one input character byte left in the last triple:
/// The most significant 6 bits are normally encoded, the other 2 bits are expanded with zeros and also encoded.
/// To fill up the based64 encoded quadruple, two padding '=' characters are appended.
///
/// 2. If There are two input character bytes left in the last triple:
/// From those 16 bits, the most significant 2 x 6 bits are encoded to two base64 output characters.
/// The remaining 4 bits are expanded with zeros and also encoded. Then a single padding character is appended to fill up the base64 quadruple.
///
/// 3. If The number of input character bytes is divisable by three:
/// No padding, thus no special handling necessary.
///
/// Let's see an example for case 1:
///```rs
/// Input character bytes: S
/// Hex value:             0x53
/// Binary                 01010011
/// 6bit parts:            010100   110000 xxxxxx xxxxxx
/// Decimal (index)values: 20       48     N/A    N/A
/// Base64 characters:     U        w      =      =
/// ```
/// *After encoding the first 6 bits (010100) of 'S', the lower two bits (11) are expanded with zeros.
/// Two padding characters are inserted. So the string "S" has base64-encoded the value "`Uw==`"
/// The remaining two 6-bit groups become “padding groups”. That is why the last two characters in the output sequence (Uw==) are ==.*
///
/// Let's see an example for case 2:
/// https://pedropark99.github.io/zig-book/Figures/base64-encoder-flow.png
///
/// Taking the string “Hi” as an example, we have 2 bytes, or, 16 bits in total.
/// Therefore, we lack a full byte (8 bits) to complete the window of 24 bits that the base64 algorithm likes to work on.
/// The first thing that the algorithm does, is to check how to divide the input bytes into groups of 6 bits.
///
/// If the algorithm notices that there is a group of 6 bits that it’s not complete,
/// the algorithm simply adds extra zeros in this group to fill the space that it needs.
/// That is why in the third group after the 6-bit transformation, 2 extra zeros were added to fill the gap.
/// Example encoding with two padding characters: Encoding of "S"
///
/// ### A base64 decoder
/// The algorithm behind a base64 decoder is essentially the inverse process of a base64 encoder.
/// A base64 decoder needs to translate base64 messages back into their original meaning, i.e., into the original sequence of binary data.
///
/// Due to the padding during encoding, the number of characters of a Base64 string is always divisable by four.
/// Thus we can process four characters of the string in one step to retrieve three decoded bytes.
///
/// This means: Extract the next four characters, get the index value from the lookup table (reverse lookup),
/// merge the four 6bit values to three 8bit values - those are the three decoded character bytes.
/// Example decoding for the Base64 string "U3Vu":
/// ```rs
/// Base64 characters      : U          3          V          u
/// Decimal (index) values : 20         55         21         46
/// 6bit parts             : 010100     110111     010101     101110
/// Binary                 : 01010011   01110101   01101110
/// Hex value              : 0x53       0x75       0x6E
/// Character bytes        : S          u          n
/// ```
/// *So the Base64-encoded string "U3Vu" has decoded the value "Sun"*
///
/// Only special care has to taken for the last quadruple if it contains padding characters.
///
/// Therefore, there are three cases that could happen:
/// 1. The third and fourth byte of the quadruple equal the padding byte '`=`'. (Two padding characters).
/// 2. The fourth byte of the quadruple is the padding byte '`=`', but not the third byte. (One padding character)
/// 3. The third and fourth byte of the quadruple do not equal the padding byte '`=`'. This is the standard case from above.
///
/// Let's see an example for case 1:
/// Example decoding with two padding characters: Decoding of "Uw==":
/// ```rs
/// Base64 characters      : U          w          =          =
/// Decimal (index) values : 20         48         N/A        N/A
/// 6bit parts:              010100     110000     N/A        N/A
/// Binary                   01010011   0111xxxx
/// Hex value:               0x53       N/A        N/A
/// Character bytes        : S
/// ```
/// *So the Base64-encoded string "Uw==" has decoded the value "S".*
///
/// Let's see an example for case 2:
/// Example decoding with one padding character: Decoding of "`U3U=`":
/// ```rs
/// Base64 characters      : U          3          U          =
/// Decimal (index) values : 20         55         21         N/A
/// 6bit parts:              010100     110111     010100     N/A
/// Binary                   01010011   01110101   00xxxx
/// Hex value:               0x53       0x75       N/A
/// Character bytes:         S          u
/// ```
/// *So the Base64-encoded string "`U3U`" has decoded the value "Su"*
///
/// ### Calculating the size of the output
/// One task that we need to do is to calculate how much space we need to reserve for the output, both of the encoder and decoder.
/// This can be done easily in Zig because every array has its length (its number of elements) easily accesible by consulting the `.len` property of the array.
///
/// For the encoder, the logic is the following:
/// - for each 3 bytes that we find in the input, 4 new bytes are created in the output.
///
/// So, we take the number of bytes in the input, divide it by 3, use a ceiling function, then, we multiply the result by 4.
/// That way, we get the total number of bytes that will be produced by the encoder in its output.
/// The` _calc_encode_length()` function below encapsulates this logic.
/// Inside this function, we take the length of the input array, we divide it by 3,
/// and apply a ceil operation over the result by using the `divCeil()` function from the Zig Standard Library.
/// Also, you might have notice that, if the input length is less than 3 bytes, then, the output length of the encoder is always 4 bytes.
/// This is the case for every input with less than 3 bytes, because the algorithm always produces enough “padding-groups” in the end result, to complete the 4 bytes window.
///
/// Now, the logic to calculate the length of the output from the decoder is a little bit more complicated.
/// But, it is basically just the inverse logic that we’ve used for the encoder: for each 4 bytes in the input, 3 bytes will be produced in the output of the decoder.
/// However, this time we need to take the `=` character into account, which is always ignored by the decoder
///
/// In essence, we take the length of the input and divide it by 4, then we apply a floor function on the result,
/// then we multiply the result by 3, and then, we subtract from the result how much times the character `=` is found in the input.
///
/// The function `_calc_decode_length()` exposed below summarizes this logic that we described.
/// It’s similar to the function `_calc_encode_length()`.
/// Notice that this time, we apply a floor operation over the output of the division, by using the `divFloor()` function (instead of a ceiling operation with `divCeil()`).
const Base64 = struct {
    _table: *const [64]u8,

    fn init() Base64 {
        const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const lower = "abcdefghijklmnopqrstuvwxyz";
        const digits = "0123456789+/";

        return Base64{ ._table = upper ++ lower ++ digits };
    }

    fn _char_at(self: Base64, index: usize) u8 {
        return self._table[index];
    }
    // Base64 encodes data in chunks of 3 bytes → 4 chars.
    fn _calc_encode_length(input: []const u8) !usize {
        // If input is less than 3 bytes, you still need 4 chars (with padding).
        if (input.len < 0x3) {
            return 0x4;
        }
        // Otherwise, it calculates how many groups of 3 fit into the input (divCeil ensures any leftover <3 bytes still counts as a full group).
        const n_groups = try std.math.divCeil(usize, input.len, 3);
        // Final encoded length
        return n_groups * 4;
    }
    // Base64 input is valid in groups of 4 characters.
    fn _calc_decode_length(input: []const u8) !usize {
        // If fewer than 4 chars, it just assumes 3 bytes (smallest non-padded decode).
        if (input.len < 0x4) {
            return 0x3;
        }
        // Otherwise:
        // Finds how many full 4-char groups exist `(divFloor)`.
        const n_groups = try std.math.divFloor(usize, input.len, 4);
        // Starts with `n_groups * 4` as a working length.
        var multi_groups = n_groups * 4;
        var i = input.len - 1;
        // Walks backwards over the string, checking for padding '='. (Each `=` means one less decoded byte.)
        //(Base64 padding can be 1 or 2 = at the end.)
        while (i > 0) : (i -= 1) {
            if (input[i] == '=') {
                multi_groups -= 1;
            } else {
                break;
            }
        }

        return multi_groups;
    }
};
pub fn main() !void {
    const base64 = Base64.init();
    std.debug.print("{c}\n", .{base64._char_at(28)});
}
