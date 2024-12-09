import CryptoKit
import Foundation

public struct EmojiEncryption {
    // Custom Errors
    public enum EmojCoderError: Error {
        case invalidString
        case invalidData
        case invalidSalt
    }

    private let alphabetToEmoji: [Character: Character] = [
        "A": "🍎", "a": "🍏", "B": "🐝", "b": "🦋", "C": "🌊", "c": "🍪", "D": "🐬", "d": "🍩",
        "E": "🌍", "e": "🥚", "F": "🍟", "f": "🍀", "G": "🦍", "g": "🍉", "H": "🏠", "h": "🍯",
        "I": "🍦", "i": "🍡", "J": "🕹️", "j": "🤹", "K": "🔑", "k": "🥝", "L": "🍋", "l": "🦁",
        "M": "🌙", "m": "🍈", "N": "🎵", "n": "🥜", "O": "🐙", "o": "🍊", "P": "🍍", "p": "🥞",
        "Q": "👸", "q": "📯", "R": "🚀", "r": "🌹", "S": "🌞", "s": "🐍", "T": "🌴", "t": "🍵",
        "U": "☂️", "u": "🍄", "V": "🎻", "v": "🏐", "W": "🐋", "w": "🎏", "X": "❌", "x": "⚔️",
        "Y": "🌱", "y": "💛", "Z": "🦓", "z": "⚡",
        "!": "❗", "@": "📧", "#": "🔢", "$": "💲", "%": "📊", "^": "⚜️", "&": "🤝", "*": "⭐",
        "(": "👈", ")": "👉", "-": "➖", "_": "🛑", "+": "➕", "=": "🔁", "{": "📬", "}": "📭",
        "[": "📥", "]": "📤", ":": "⏳", ";": "⚙️", "'": "💬", "\"": "🔊", "<": "👀", ">": "🎯",
        ",": "🔹", ".": "🔸", "?": "❓", "/": "🚪", "\\": "🪞", "|": "🚧", "`": "🎩", "~": "🌈",
        "0": "0️⃣", "1": "1️⃣", "2": "2️⃣", "3": "3️⃣", "4": "4️⃣",
        "5": "5️⃣", "6": "6️⃣", "7": "7️⃣", "8": "8️⃣", "9": "9️⃣"
    ]

    private let emojiToAlphabet: [Character: Character] = [
        "🍎": "A", "🍏": "a", "🐝": "B", "🦋": "b", "🌊": "C", "🍪": "c", "🐬": "D", "🍩": "d",
        "🌍": "E", "🥚": "e", "🍟": "F", "🍀": "f", "🦍": "G", "🍉": "g", "🏠": "H", "🍯": "h",
        "🍦": "I", "🍡": "i", "🕹️": "J", "🤹": "j", "🔑": "K", "🥝": "k", "🍋": "L", "🦁": "l",
        "🌙": "M", "🍈": "m", "🎵": "N", "🥜": "n", "🐙": "O", "🍊": "o", "🍍": "P", "🥞": "p",
        "👸": "Q", "📯": "q", "🚀": "R", "🌹": "r", "🌞": "S", "🐍": "s", "🌴": "T", "🍵": "t",
        "☂️": "U", "🍄": "u", "🎻": "V", "🏐": "v", "🐋": "W", "🎏": "w", "❌": "X", "⚔️": "x",
        "🌱": "Y", "💛": "y", "🦓": "Z", "⚡": "z",
        "❗": "!", "📧": "@", "🔢": "#", "💲": "$", "📊": "%", "⚜️": "^", "🤝": "&", "⭐": "*",
        "👈": "(", "👉": ")", "➖": "-", "🛑": "_", "➕": "+", "🔁": "=", "📬": "{", "📭": "}",
        "📥": "[", "📤": "]", "⏳": ":", "⚙️": ";", "💬": "'", "🔊": "\"", "👀": "<", "🎯": ">",
        "🔹": ",", "🔸": ".", "❓": "?", "🚪": "/", "🪞": "\\", "🚧": "|", "🎩": "`", "🌈": "~",
        "0️⃣": "0", "1️⃣": "1", "2️⃣": "2", "3️⃣": "3", "4️⃣": "4",
        "5️⃣": "5", "6️⃣": "6", "7️⃣": "7", "8️⃣": "8", "9️⃣": "9"
    ]

    private let salt: String

    // Public and Private keys for encryption
    private let privateKey: P256.KeyAgreement.PrivateKey
    public let publicKey: P256.KeyAgreement.PublicKey

    // Computed property to get the public key as a Base64 string
    public var publicKeyRepresentation: String {
        publicKey.rawRepresentation.base64EncodedString()
    }

    // Initialization with a salt
    public init(salt: String = UUID().uuidString) {
        self.salt = salt
        let keyPair = P256.KeyAgreement.PrivateKey()
        self.privateKey = keyPair
        self.publicKey = keyPair.publicKey
    }

    /// Converts a string to its emoji representation
    public func toEmoji(string: String) -> String {
        String(
            string.map { character in
                alphabetToEmoji[character] ?? character
            }
        )
    }

    /// Converts emojis back to their original string representation
    public func fromEmoji(string: String) -> String {
        String(
            string.map { character in
                emojiToAlphabet[character] ?? character
            }
        )
    }

    /// Encrypts the string using the peer's public key
    public func encrypt(string: String, to peerPublicKey: P256.KeyAgreement.PublicKey) throws -> Data {
        // Add salt to the string
        let saltedString = string + salt

        // Convert to emoji
        let emojiString = String(saltedString.map { character in
            alphabetToEmoji[character] ?? character
        })

        // Convert emoji string to Data
        guard let emojiData = emojiString.data(using: .utf8) else {
            throw EmojCoderError.invalidString
        }

        // Perform key agreement to derive a symmetric key
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: peerPublicKey)
        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data(),
            sharedInfo: Data(),
            outputByteCount: 32
        )

        // Encrypt the emoji data using the symmetric key
        let sealedBox = try ChaChaPoly.seal(emojiData, using: symmetricKey)
        return sealedBox.combined
    }

    /// Decrypts the data and decodes it back to the original string
    public func decrypt(data: Data, from peerPublicKey: P256.KeyAgreement.PublicKey) throws -> String {
        // Perform key agreement to derive the same symmetric key
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: peerPublicKey)
        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data(),
            sharedInfo: Data(),
            outputByteCount: 32
        )

        // Decrypt the data using the symmetric key
        let sealedBox = try ChaChaPoly.SealedBox(combined: data)
        let decryptedData = try ChaChaPoly.open(sealedBox, using: symmetricKey)

        // Convert decrypted data back to string
        guard let emojiString = String(data: decryptedData, encoding: .utf8) else {
            throw EmojCoderError.invalidData
        }

        // Decode emoji back to original string
        let decodedWithSalt = fromEmoji(string: emojiString)

        // Remove salt
        guard decodedWithSalt.hasSuffix(salt) else {
            throw EmojCoderError.invalidSalt
        }
        let originalString = String(decodedWithSalt.dropLast(salt.count))
        return originalString
    }
}
