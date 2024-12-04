
import Foundation

nonisolated(unsafe)
private let dateFormatter: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions.insert(.withFractionalSeconds)
    return f
}()

public class JSONFileEncoder:
    JSONEncoder, @unchecked Sendable
{
    public static let shared = JSONFileEncoder()
    
    public override init() {
        super.init()
        
        outputFormatting = [.sortedKeys]
        
        dateEncodingStrategy = .custom {
            var container = $1.singleValueContainer()
            let string = dateFormatter.string(from: $0)
            try container.encode(string)
        }
        
        nonConformingFloatEncodingStrategy = .convertToString(
            positiveInfinity: "inf",
            negativeInfinity: "-inf",
            nan: "nan")
    }
    
}

public class JSONFileDecoder:
    JSONDecoder, @unchecked Sendable
{
    public static let shared = JSONFileDecoder()
    
    public override init() {
        super.init()
        
        dateDecodingStrategy = .custom {
            let container = try $0.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = dateFormatter.date(from: string) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date: \(string)")
        }
        
        nonConformingFloatDecodingStrategy = .convertFromString(
            positiveInfinity: "inf",
            negativeInfinity: "-inf",
            nan: "nan")
    }
    
}
