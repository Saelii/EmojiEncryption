# EmojiEncryption

EmojiEncryption is a Swift library that converts strings to emojis and provides secure encryption and decryption using public key cryptography. It combines the fun of emojis with robust security features, making it perfect for creative and secure messaging applications.

## Features

- **Emoji Conversion**: Easily convert text to emojis and back.
- **Encryption & Decryption**: Securely encrypt messages using public key cryptography.
- **Custom Salt**: Use custom salts to enhance security (no emoji salts allowed).
- **Error Handling**: Comprehensive error management for invalid inputs and operations.

## Usage

### Initialization

Create instances of `EmojiEncryption` with a custom salt or use the default initializer for a random salt.

```swift
let salt = "UniqueSalt123" // Example non-emoji-based salt
let alice = EmojiEncryption(salt: salt)
let bob = EmojiEncryption(salt: salt)
```

### Emoji Conversion

#### Convert String to Emoji

Transform a regular string into its emoji representation.

```swift
let originalString = "Hello, Bob! 123"
let emojiString = alice.toEmoji(string: originalString)
print(emojiString) // Outputs: 🏠🥚🦁🦁🍊🔹 🐝🍊🦋❗ 1️⃣2️⃣3️⃣
```

#### Convert Emoji to String

Convert the emoji representation back to the original string.

```swift
let decodedString = alice.fromEmoji(string: emojiString)
print(decodedString) // Outputs: Hello, Bob! 123
```

### Encryption and Decryption

#### Encrypting a Message

Encrypt a message using the recipient's public key.

```swift
do {
    let encryptedData = try alice.encrypt(string: originalString, to: bob.publicKey)
    // Send `encryptedData` to Bob securely
} catch {
    print("Encryption failed: \(error)")
}
```

#### Decrypting a Message

Decrypt the received data using the sender's public key.

```swift
do {
    let decryptedString = try bob.decrypt(data: encryptedData, from: alice.publicKey)
    print(decryptedString) // Outputs: Hello, Bob! 123
} catch {
    print("Decryption failed: \(error)")
}
```

## Testing

Here is an example test for the `EmojiEncryption` struct using the `@Test` annotation and `#expect` assertions.

### Example Test

```swift
import Testing
@testable import EmojiEncryption

@Test func example() async throws {
    let salt = "TestSalt123" // Example non-emoji salt
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
```

## Error Handling

`EmojiEncryption` defines several custom errors to handle invalid operations:

- `EmojCoderError.invalidString`: Thrown when an invalid string is provided for emoji conversion or encryption.
- `EmojCoderError.invalidData`: Thrown when decrypted data cannot be converted back to a string.
- `EmojCoderError.invalidSalt`: Thrown when the provided salt does not match the expected salt.

### Example

```swift
do {
    let decryptedString = try bob.decrypt(data: encryptedData, from: alice.publicKey)
} catch EmojiEncryption.EmojCoderError.invalidData {
    print("Failed to decode decrypted data.")
} catch {
    print("An unexpected error occurred: \(error).")
}
```

## Salt Management

A salt adds uniqueness and enhances security during encryption. You must use non-emoji salts.

### Creating a Salt

```swift
let salt = "UniqueSalt123"
let encryptionInstance = EmojiEncryption(salt: salt)
```

### Generating a Secure Salt Programmatically

```swift
import Foundation

func generateSalt(length: Int) -> String {
    let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    return String((0..<length).map { _ in characters.randomElement()! })
}

let secureSalt = generateSalt(length: 16)
let encryptionInstance = EmojiEncryption(salt: secureSalt)
```

**Note**: For enhanced security, store salts securely, such as in the Keychain.

## License

This project is open-source and available for use and modification.
