import Testing
@testable import EmojiEncryption

@Test func example() async throws {
    let salt = "Test Salt" // Example salt using only emojis
    let alice = EmojiEncryption(salt: salt)
    let bob = EmojiEncryption(salt: salt)

    let originalString = "Hello, Bob! 123"

    // Convert the original string to emojis
    let emojiString = alice.toEmoji(string: originalString)

    // Convert emojis back to the original string
    let decodedString = alice.fromEmoji(string: emojiString)

    // Encrypt the original string using Bob's public key
    let encryptedData = try alice.encrypt(string: originalString, to: bob.publicKey)

    // Decrypt the encrypted data using Alice's public key
    let decryptedString = try bob.decrypt(data: encryptedData, from: alice.publicKey)

    #expect(emojiString == "🏠🥚🦁🦁🍊🔹 🐝🍊🦋❗ 1️⃣2️⃣3️⃣")
    #expect(decodedString == originalString)
    #expect(decryptedString == originalString)
}
