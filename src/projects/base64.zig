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
///
/// ## Building the encoder logic
/// In this section, we can start building the logic behind the `encode()` function, which will be responsible for encoding messages into the base64 encoding system.
///
/// ### The 6-bit transformation
/// In essence, this 6-bit transformation is made with the help of bitwise operators.
/// Bitwise operators are essential to any type of low-level operation that is done at the bit-level. For the specific case of the base64 algorithm,
/// the operators bit shift to the left `(<<)`, bit shift to the right `(>>)`and the bitwise and `(&)` are used. They are the core solution for the 6-bit transformation.
///
/// There are 3 different scenarios that we need to take into account in this transformation.
/// - First, is the perfect scenario, where we have the perfect window of 3 bytes to work on.
/// - Second, we have the scenario where we have a window of only two bytes to work with.
/// - And last, we have the scenario where we have a window of one single byte.
///
/// In each of these 3 scenarios, the 6-bit transformation works a bit differently.
/// To put it simply, I will use the variable `output` to refer to the bytes in the output of the base64 encoder,
/// and the variable `input` to refer to the bytes in the input of the encoder.
///
/// Taking into consideration the first scenario where you have the perfect window of 3 bytes, these are steps for the 6-bit transformation:
/// 1. `output[0]` is produced by moving the bits from `input[0]` two positions to the right.
/// 2. `output[1]` is produced by summing two components.
///     First, take the last two bits from `input[0]`, then, move them four positions to the left.
///     Second, move the bits from `input[1]` four positions to the right. Sum these two components.
/// 3. `output[2]` is produced by summing two components.
///     First, take the last four bits from `input[1]`, then, move them two positions to the left.
///     Second, move the bits from `input[2]` six positions to the right. Sum these two components.
/// 4. `output[3]` is produced by taking the last six bits from `input[2]`.
///
/// *See the example for "Sun".*
///
/// https://pedropark99.github.io/zig-book/Figures/base64-encoder-bit-shift.png
///
/// On the other hand, we must be prepared for the instances where we do not have the perfect window of 3 bytes.
/// If you have a window of 2 bytes, then, the steps 3 and 4, which produces the bytes output[2] and output[3], change a little bit, and they become:
/// 1. Same as above.
/// 2. Same as above.
/// 3. `output[2]` is produced by taking the last 4 bits from `input[1]`, then, move them two positions to the left.
/// 4. `output[3]` is the character '`=`'.
///
/// *See the example for "Hi".*
///
/// Finally, if you have a window of a single byte, then, the steps 2 to 4, which produces the bytes output[1], output[2] and output[3] change, becoming:
/// 1. Same as above in the perfect scenario.
/// 2. `output[1]` is produced by taking the last two bits from input[0], then, move them four positions to the left.
/// 3. Same as above in the perfect scenario.
/// 4. `output[2]` and `output[3]` are the character `=`.
///
/// *See the example for "S".*
///
/// ### Bit-shifting in Zig
/// Bit-shifting in Zig works similarly to bit-shifting in C.
/// All bitwise operators that exist in C are available in Zig.
/// Here, in the base64 encoder algorithm, they are essential to produce the result we want.
///
/// These operators operates at the bit-level of your values. This means that these operators takes the bits that form the value you have, and change them in some way.
/// This ultimately also changes the value itself, because the binary representation of this value changes.
/// We have already seen in this [Figure](https://pedropark99.github.io/zig-book/Figures/base64-encoder-flow.png) the effect produced by a bit-shift.
///
/// If you recall in the "Hi" example, the first byte present in the output should be equivalent to the 6-bit group 010010.
/// Although being visually different, the sequences 010010 and 00010010 are semantically equal.
/// They mean the same thing. They both represent the number 18 in decimal, and the value 0x12 in hexadecimal.
///
/// *See `zig_bit_shifting()` example*
///
/// ### Selecting specific bits with the `&` operator
/// If you comeback to the chapter *"The 6-bit transformation"*, you will see that, in order to produce the second and third bytes in the output,
/// we need to select specific bits from the first and second bytes in the input string.
/// But how can we do that? The answer relies on the bitwise and `(&)` operator.
///
/// This [Figure]( https://pedropark99.github.io/zig-book/Figures/base64-encoder-bit-shift.png) already showed you what effect this `&` operator produces
/// in the bits of its operands.
///
/// In summary, the `&` operator performs a logical conjunction operation between the bits of its operands.
/// In more details, the operator `&` compares each bit of the first operand to the corresponding bit of the second operand.
/// If both bits are 1, the corresponding result bit is set to 1. Otherwise, the corresponding result bit is set to 0.
/// [Microsoft](https://learn.microsoft.com/en-us/cpp/cpp/bitwise-and-operator-amp?view=msvc-170)
///
/// Both operands to the bitwise AND operator must have integral types.
/// The usual arithmetic conversions covered in [Standard conversions](https://learn.microsoft.com/en-us/cpp/cpp/standard-conversions?view=msvc-170) are applied to the operands.
///
/// So, if we apply this operator to the binary sequences `1000100` and `00001101` the result of this operation is the binary sequence `00000100`.
/// Because only at the sixth position in both binary sequences we had a 1 value.
/// So any position where we do not have both binary sequences setted to `1`, we get a `0` bit in the resulting binary sequence.
///
/// We lose information about the original bit values from both sequences in this case.
/// Because we no longer know if this `0` bit in the resulting binary sequence was produced by combining `0` with `0`, or `1` with `0`, or `0` with `1`.
///
/// ### Allocating space for the output
/// As explained in the stack section of `chap_three.zig`, to store an object in the stack, this object needs to have a known and fixed length at compile-time.
/// This is an important limitation for our base64 encoder/decoder"s case.
/// Because the size of the output (from both the encoder and decoder) depends directly on the size of the input.
///
/// Having this in mind, we cannot know at compile time which is the size of the output for both the encoder and decoder.
/// So, if we can’t know the size of the output at compile time, this means that we cannot store the output for both the encoder and decoder in the stack.
///
/// Consequently, we need to store this output on the heap, and, as outlined in the heap section of `chap_three.zig`,
/// we can only store objects in the heap by using allocator objects. So, one of the arguments to both the `encode()` and `decode()` functions, needs to be an allocator object,
/// because we know for sure that, at some point inside the body of these functions, we need to allocate space on the heap to store the output of these functions.
///
/// ### Writing the encode() function
/// The `encode()` function has two arguments:
/// 1. `input` is the input sequence of characters that you want to encode in `base64`.
/// 2. `allocator` is an allocator object to use in the necessary memory allocations.
///
/// The main for loop in the function is responsible for iterating through the entire input string.
/// In every iteration, we use a count variable to count how many iterations we had at the moment.
/// When count reaches 3, then, we try to encode the 3 characters (or bytes) that we have accumulated in the temporary buffer object (buf).
///
/// After encoding these 3 characters and storing the result in the output variable,
/// we reset the count variable to zero, and start to count again on the next iteration of the loop.
///
/// If the loop hits the end of the string, and, the count variable is less than 3, then, it means that the temporary buffer contains the last 1 or 2 bytes from the input.
/// That is why we have two if statements after the for loop. To deal which each possible case.
///
/// ## Building the decoder logic
/// The decoder `decode()` function performs the inverse process of the `encode()` function.
///
/// ### Mapping base64 characters to their indexes
/// One thing that we need to do, in order to decode a base64-encoded message,
/// is to calculate the index in the base64 scale of every base64 character that we encounter in the decoder input.
///
/// In other words, the decoder receives as input a sequence of characters from the Base64 alphabet.
/// Each character is mapped to its corresponding 6-bit index value (0–63).
/// Once we have this sequence of 6-bit values, we concatenate their bits and regroup them into 8-bit bytes to reconstruct the original binary data.
/// In practice, this mapping can be optimized by using a lookup table, allowing constant-time translation instead of performing character searches for each symbol.
///
/// The `_char_index()` function below contains this strategy.
/// We are essentially looping through the lookup table with the base64 scale, and comparing the character we got with each character in the base64 scale.
/// If these characters match, then, we return the index of this character in the base64 scale as the result.
///
/// if the input character is '=', the function returns the index 64, which is “out of range” in the scale.
/// But, as described in the "Base64 Scale Chapter", the character '=' does not belong to the base64 scale itself.
/// It’s a special and meaningless character in base64.
///
/// ### The 6-bit transformation
/// This is the core of the Base64 decoding algorithm.
/// Once you understand how this 6-bit transformation works, the rest of the decoder becomes straightforward.
///
/// Before performing the transformation, the input Base64 characters must first be converted
/// into their corresponding numeric indexes using `_char_index()`.
/// The result of this conversion is stored in a temporary buffer of 6-bit values.
/// These indexes (not the original characters) are then used to reconstruct the original bytes.
///
/// In the encoding process, every group of 3 bytes is transformed into 4 Base64 characters.
/// The decoding process is the inverse — it takes 4 Base64 characters and reconstructs the 3 original bytes.
///
/// The steps for reconstructing each output byte are as follows:
///
/// 1. **output[0]**
///    - Take the first 6 bits from `buf[0]` and shift them left by 2 positions.
///    - Take the top 2 bits from `buf[1]` (by shifting it right by 4).
///    - Add these two components together to form the first byte.
///
/// 2. **output[1]**
///    - Take the remaining 4 bits from `buf[1]` and shift them left by 4 positions.
///    - Take the top 4 bits from `buf[2]` (by shifting it right by 2).
///    - Add these components together to form the second byte.
///
/// 3. **output[2]**
///    - Take the remaining 2 bits from `buf[2]` and shift them left by 6 positions.
///    - Add all 6 bits from `buf[3]` to complete the third byte.
///
/// This process reverses the Base64 encoding step, merging the 6-bit groups back into
/// their original sequence of 8-bit bytes.
///
/// ### Writing the `decode()` function
/// The `decode()` function below contains the entire decoding process.
/// We first calculate the size of the output, with `_calc_decode_length()`, then, we allocate enough memory for this output with the allocator object.
///
/// Three temporary variables are created:
/// 1. `count`, to hold the window count in each iteration of the for loop.
/// 2. `iout`, to hold the current index in the output.
/// 3. `buf`, which is the temporary buffer that holds the base64 indexes to be converted through the 6-bit transformation.
///
/// Then, in each iteration of the for loop we fill the temporary buffer with the current window of bytes.
/// When `count` hits the number 4, then, we have a full window of indexes in `buf` to be converted, and then, we apply the 6-bit transformation over the temporary buffer.
///
/// Notice that we check if the indexes 2 and 3 in the temporary buffer are the number 64, which,
/// if you recall from section mapping base64 characters to their indexes, is when the `_calc_index()` function receives a '=' character as input.
///
/// So, if these indexes are equal to the number `64`, the `decode()` function knows that it can simply ignore these indexes.
const Base64 = struct {
    _table: *const [0x40]u8,

    fn init() Base64 {
        const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const lower = "abcdefghijklmnopqrstuvwxyz";
        const digits = "0123456789+/";

        return Base64{ ._table = upper ++ lower ++ digits };
    }

    /// Gets the base64 char at from table's index
    fn _char_at(self: Base64, index: usize) u8 {
        return self._table[index];
    }
    /// Gets the index from the base64 char in the table
    fn _char_at_index(self: Base64, char: u8) u8 {
        if (char == '=') {
            return 0x40;
        }

        var index: u8 = 0;
        for (self._table, 0..) |_, i| {
            if (self._char_at(i) == char) {
                break;
            }
            index += 1;
        }

        return index;
    }
    /// Base64 encodes data in chunks of 3 bytes → 4 chars.
    ///
    /// *Examples*:
    /// ```zig
    /// "A".len = 1 → ceil(1 / 3) = 1 → 1 × 4 = 4
    /// "AB".len = 2 → ceil(2 / 3) = 1 → 1 × 4 = 4
    /// "ABC".len = 3 → ceil(3 / 3) = 1 → 1 × 4 = 4
    /// "ABCD".len = 4 → ceil(4 / 3) = 2 → 2 x 4 = 8
    /// "ABCDEFG".len = 7 → ceil(7 / 3) = 3 → 3 x 4 = 12
    /// ```
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
    /// Base64 input is valid in groups of 4 characters.
    ///
    /// *Example `TWFu`*:
    /// ```zig
    /// "TWFu".len = 4 → divFloor(4, 4) = 1 → 1 × 4 = 4 → multi_groups = 4
    /// "TWFu".len - 1 = 3
    /// input[3] is 'u' breaks and returns 4
    ///```
    /// *Example `TWE=`*:
    /// ```zig
    /// "TWE=".len = 4 → divFloor(4, 4) = 1 → 1 × 4 = 4 → multi_groups = 4
    /// "TWE=".len - 1 = 3
    /// input[3] == '=' → multi_groups -= 1 → 3
    /// input[2] == 'E' breaks and returns 3
    /// ```
    /// *Example: `TQ==`*
    /// ```zig
    /// "TQ==".len = 4 → divFloor(4, 4) = 1 → 1 × 4 = 4 → multi_groups = 4
    /// "TQ==".len - 1 = 3
    /// input[3] == '=' → multi_groups -= 1 → 3
    /// input[2] == '=' → multi_groups -= 1 → 2
    /// input[1] == 'E' breaks and returns 2
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

    fn encode(self: Base64, allocator: std.mem.Allocator, input: []const u8) ![]u8 {
        // If input is empty, return empty string.
        if (input.len == 0) {
            return "";
        }
        // Calculates how long the encoded output should be based on the input.
        const n_out = try _calc_encode_length(input);
        // allocates a buffer big enough to hold it.
        var out = try allocator.alloc(u8, n_out);
        // buf is a small buffer of up to 3 bytes (what we’ll encode).
        var buf = [3]u8{ 0, 0, 0 };
        // count tracks how many bytes are in `buf`.
        var count: u8 = 0;
        // iout is the current index in the output.
        var iout: usize = 0;

        // for (input, 0..) |_, i| {
        for (input) |ch| {
            buf[count] = ch; //input[i];
            count += 1;
            //lets take an example: kay
            //buf[0] = 0b01001011   (K)
            //buf[1] = 0b01100001   (a)
            //buf[2] = 0b01111001   (y)
            if (count == 3) {
                // Group 1 (first 6 bits
                // `buf[0] >> 2`
                // buf[0] has 8 bits.
                // Shifting right by 2 drops the last 2 bits, leaving the top 6.
                // `0b01001011 >> 2` = `0b00010010`
                //      →↑                 |↑↑ moves it further left by 2
                // this gives the first 6-bit value.
                // ____________
                // Group1: 0b00010010
                out[iout] = self._char_at(buf[0] >> 2);
                // Group 2 (crosses buf[0] and buf[1])
                // buf[0] & 3 keeps the last 2 bits of buf[0].
                // mask `0b01001011 & 0b00000011` → `0b00000011`.
                //   0b01001011
                // & 0b00000011
                // ____________
                // = 0b00000011
                // why 0x3? because `0x3 = 00000011` → keep 2 bits (for when we only want buf[0]’s 2 lowest bits).
                // `<< 4` moves those 2 bits into the top of a 6-bit group.
                // `0b00000011 << 4` = `0b00110000`
                //     |↑↑|←|←             |↑↑ moves it to the start of the 6bit group
                // buf[1] >> 4 takes the top 4 bits of buf[1].
                // `0b01100001 >> 4` = `0b00000110`
                //     →|→|↑↑|             |↑↑↑↑ moves it further left by 4
                // Adding them combines to form the next 6-bit chunk.
                //         0b00110000
                //       + 0b00000110
                //       ____________
                // Group2: 0b00110110
                out[iout + 1] = self._char_at(((buf[0] & 0x3) << 4) + (buf[1] >> 4));
                // Group 3 (crosses buf[1] and buf[2])
                // buf[1] & 15 keeps the last 4 bits (15 = 0b00001111).
                // mask `0b01100001 & 0b00001111` → `0b00000001`.
                //   0b01100001
                // & 0b00001111
                // ____________
                // = 0b00000001
                // why 0xF? because `0xF = 00001111` → keep 4 bits.
                // `<< 2` shifts them into the top of a 6-bit group.
                // `0b00000001 << 2` = `0b00000100`
                //         ↑|←                 |↑ moves it to the start of the 6bit group
                // buf[2] >> 6 keeps the top 2 bits of buf[2].
                // `0b01111001 >> 6` = 0b00000001
                //     →|→|↑↑|                 |↑
                // Together that’s 4 bits from buf[1] + 2 bits from buf[2].
                //         0b00000100
                //       + 0b00000001
                //        ____________
                // Group3: 0b00000101
                out[iout + 2] = self._char_at(((buf[1] & 0xF) << 2) + (buf[2] >> 6));
                // Group 4 (last 6 bits of buf[2])
                // 0x3f = binary 0b00111111 = 63.
                // `buf[2] & 0x3F` keeps the last 6 bits of buf[2].
                // mask `0b01111001 & 0b00111111` → `0b00111001`.
                //  0b01111001
                // & 0b00111111
                // ____________
                // = 0b00111001
                // Why 0x3F? because `0x3F = 00111111` → keep 6 bits (max base64 chunk).
                // This keeps the last 6 bits of buf[2].
                // ____________
                // Group4: 0b00111001
                out[iout + 3] = self._char_at(buf[2] & 0x3F);
                iout += 4;
                count = 0;

                // results = 0b00010010 0b00110110 0b00000101 0b00111001
            }
        }
        // Lets take an example of S
        // buf[0] = 0b01010011  (S)
        if (count == 1) {
            // Group 1 (first 6 bits)
            // `buf[0] >> 2`
            // buf[0] has 8 bits.
            // Shifting right by 2 drops the last 2 bits, leaving the top 6.
            // `0b01010011 >> 2 = 0b00010100`
            //      →↑                |↑↑ moves it further left by 2
            // this gives the first 6-bit value.
            // ____________
            // Group1: 0b00010100
            out[iout] = self._char_at(buf[0] >> 2);
            // Group 2 (masks the last 2 bits of buf[0] and moves the bits to the start of the 6bit group)
            // buf[0] & 0x3 keeps the last 2 bits of buf[0].
            // mask `0b01010011 & 0b00000011` → `0b00000011`.
            //   0b01010011
            // & 0b00000011
            // ____________
            // = 0b00000011
            // `<< 4 moves those 2 bits into the top of a 6-bit group.`
            // `0b00000011 << 4` = `0b00110000`
            //     |↑↑|←|←             |↑↑ moves it to the start of the 6bit group
            // This mask forms the next 6-bit chunk.
            // ____________
            // Group2: 0b00110000
            out[iout + 1] = self._char_at((buf[0] & 0x3) << 4);
            // Group3: (padds the next 6bit group since we have no bits to encode)
            // ____________
            // Group3: =
            out[iout + 2] = '=';
            // Group4: (padds the last 6bit group since we have no bits to encode)
            // ____________
            // Group4: =
            out[iout + 3] = '=';

            // results = 0b00010100 0b00110000 = =
        }

        // Lets take an example of Su
        // buf[0] = 0b01010011  (S)
        // buf[1] = 0b01110101  (u)
        if (count == 2) {
            // Group 1 (first 6 bits)
            // Shifting right by 2 drops the last 2 bits, leaving the top 6.
            // `0b01010011 >> 2 = 0b00010100`
            //      →↑                |↑↑ moves it further left by 2
            // this gives the first 6-bit value.
            // ____________
            // Group1: 0b00010100
            out[iout] = self._char_at(buf[0] >> 2);
            // Group 2 (crosses buf[0] and buf[1])
            // buf[0] & 0x3 keeps the last 2 bits of buf[0].
            // mask `0b01010011 & 0b00000011` → `0b00000011`.
            //   0b01010011
            // & 0b00000011
            // ____________
            // = 0b00000011
            // `<< 4 moves those 2 bits into the top of a 6-bit group.`
            // `0b00000011 << 4` = `0b00110000`
            //     |↑↑|←|←             |↑↑ moves it to the start of the 6bit group
            //
            // `buf[1] >> 4` takes the top 4 bits of buf[1].
            // `0b01110101 >> 4 = 0b00000111`
            //     →|→|↑↑|             |↑↑↑↑ moves it further left by 4
            // Adding them combines to form the next 6-bit chunk.
            //         0b00110000
            //       + 0b00000111
            //       ____________
            // Group2: 0b00110111
            out[iout + 1] = self._char_at(((buf[0] & 0x3) << 4) + (buf[1] >> 4));
            // Group 3 (masks the last 4 bits of buf[1] and moves the bits to the start of the 6bit group)
            // mask `0b01110101 & 0b00001111` → `0b00000101`.
            //   0b01110101
            // & 0b00001111
            // ____________
            // = 0b00000101
            // `<< 2` shifts them into the top of a 6-bit group.
            // `0b00000101 << 2 = 0b00010100`
            //        |↑|←            |↑↑↑ moves it further right by 2
            // This gives the next 6-bit value.
            // ____________
            // Group3: 0b00010100
            out[iout + 2] = self._char_at((buf[1] & 0xF) << 2);
            // Group4: (padds the last 6bit group since we have no bits to encode)
            // ____________
            // Group4: =
            out[iout + 3] = '=';
            iout += 4;

            // results = 0b00010100 0b00110111 0b00010100 =
        }

        return out;
    }

    fn decode(self: Base64, allocator: std.mem.Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) {
            return "";
        }
        // computes how many bytes the decoded output will have accounting for any '=' padding at the end
        const n_out = try _calc_decode_length(input);
        // allocates a buffer big enough to hold it.
        var output = try allocator.alloc(u8, n_out);

        var count: u8 = 0;
        var iout: usize = 0;
        // We read 4 Base64 characters at a time into this buffer
        var buf = [4]u8{ 0, 0, 0, 0 };

        for (input) |ch| {
            buf[count] = self._char_at_index(ch);
            count += 1;

            // lets take an example of the b64 chars = U3Vu
            // buf = [20, 55, 21, 46]
            if (count == 4) {
                // buf[0] = 20
                // 0b00010100 << 2 = 0b01010000
                //       |↑|←            |↑ Shift left 2 to move into top of an 8-bit group
                // buf[1] = 55
                // 0b00110111 >> 4 = 0b00000011
                //     →|→|↑|            |↑↑↑↑ Take top 2 bits
                // Adding them combines to form the first 8-bit chunk.
                //         0b01010000
                //       + 0b00000011
                //       ____________
                // Char1:  0b01010011
                output[iout] = (buf[0] << 2) + (buf[1] >> 4);
                // buf[2] = 21 = 0b00010101
                if (buf[2] != 64) {
                    // buf[1] = 55
                    // 0b00110111 << 4 = 0b0011_0111_0000
                    //      ↑|←|←                 |↑ Shift left 4 to move into top of an 8-bit group
                    // this will result in an integer with 12 bit precision we therefore the cpu will only take the fixed width, typically 8 bits Specified in the buffer.
                    // buf[2] = 21
                    // 0b00010101 >> 2 = 0b00000101
                    //    →|↑|            |↑↑↑↑ Take top 2 bits
                    // Adding them combines to form the next 8-bit chunk.
                    // We need to add only the 8-bit overlapping region
                    // 0b0011_0111_0000 → 0b01110000
                    //         0b01110000
                    //       + 0b00000101
                    //       ____________
                    // Char2:  0b01110101
                    output[iout + 1] = (buf[1] << 4) + (buf[2] >> 2);
                }
                // buf[3] = 46
                if (buf[3] != 64) {
                    // buf[2] = 21
                    // 0b00010101 << 6 = 0b0000_0101_0100_0000
                    // this will result in an integer with 16 bit precision we therefore the cpu will only take the fixed width, typically 8 bits Specified in the buffer.
                    // Adding them combines to form the last 8-bit chunk.
                    // We need to add only the 8-bit overlapping region
                    // 0b0000_0101_0100_0000 → 0b01000000
                    //         0b01000000
                    //       + 0b00101110
                    //       ____________
                    // Char3:  0b01101110
                    output[iout + 2] = (buf[2] << 6) + buf[3];
                }

                iout += 3;
                count = 0;
                // results = 0b01010011 0b01110101 0b01101110 = S u n
            }
        }
        return output;
    }
};

/// But let’s use the first byte in the output of the base64 encoder as another example of what bit-shifting means.
///
/// This is the easiest byte of the 4 bytes in the output to build.
/// Because we only need to move the bits from the first byte in the input two positions to the right, with the bit shift to the right `(>>)` operator.
/// If we take the string “Hi” as an example, the first byte in this string is “H”, which is the sequence `01001000` in binary.
/// If we move the bits of this byte, two places to the right, we get the sequence `00010010` as result.
/// This binary sequence is the value `18` in decimal, and also, the value `0x12` in hexadecimal.
/// Notice that the 6-bit transformation **6 bits** of “H” were moved to the end of the byte. With this operation, we get the first byte of the output.
fn zig_bit_shifting() void {
    const input = "Hi";

    std.debug.print("{b:06}\n", .{input[0] >> 2});
}
/// It takes two numbers, looks at their binary form (their bits), and compares them bit by bit:
///
/// - If both bits are **1**, the result for that position is **1**.
/// - Otherwise (if one or both are **0**), the result is **0**.
///
/// As an example, suppose you have the binary sequence `10010111`, which is the number `151` in decimal.
/// How can we get a new binary sequence which contains only the third and fourth bits of this sequence?
///
/// We just need to combine this sequence with `00110000` (is `0x30` in hexadecimal) using the `&` operator.
/// Notice that only the third and fourth positions in this binary sequence is setted to `1`.
///
/// As a consequence, only the third and fourth values of both binary sequences are potentially preserved in the output.
/// All the remaining positions are setted to zero in the output sequence, which is `00010000` (is the number 16 in decimal).
fn zig_bitwise_and() void {
    const a: u8 = 0b110; //6
    const b: u8 = 0b011; //3

    const val1: u8 = 0b10010111; // 151
    const val2: u8 = 0b00110000; // 48

    const mask = val1 & val2;

    std.debug.print("{d}\n", .{a & b}); // 2

    std.debug.print("{d}\n", .{mask});

    // std.debug.print("{d}\n", .{std.math.maxInt(u4)});
}
pub fn main() !void {
    // buffers
    var stdout_buffer: [0x400]u8 = undefined;

    // writer interface
    var std_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &std_writer.interface;

    // Heap allocation
    var memory_buffer: [0x400]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&memory_buffer);

    const allocator = fba.allocator();

    // encoding | decoding
    const text = "Sun";
    const enctext = "U3Vu";

    const b64 = Base64.init();

    const encoded_text = try b64.encode(allocator, text);
    const decoded_text = try b64.decode(allocator, enctext);

    try stdout.print("Encoded Text: {s}\n", .{encoded_text});
    try stdout.print("Decoded Text: {s}\n", .{decoded_text});

    try stdout.flush();
}

test "get char" {
    const base64 = Base64.init();
    try std.testing.expectEqual(base64._char_at(28), 'c');
}
