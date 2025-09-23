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
/// ### The base64 scale
/// The base64 encoding system is based on a scale that goes from **0 to 63** (hence the name).
/// Each index in this scale is represented by a character (it’s a scale of 64 characters).
/// Therefore, in order to convert some binary data, to the base64 encoding,
/// we need to convert each binary number to the corresponding character in this “scale of 64 characters”.
///
/// The base64 scale starts with all ASCII uppercase letters (A to Z) which represents the first 25 indexes in this scale (0 to 25).
pub fn main() !void {}
