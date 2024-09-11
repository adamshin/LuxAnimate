//
//  ThreadSafeDictionary.swift
//

import Foundation

class ThreadSafeDictionary<Key: Hashable & Sendable, Value: Sendable>:
    @unchecked Sendable
{
    
    private var dictionary: [Key: Value] = [:]
    
    private let queue = DispatchQueue(
        label: "ThreadSafeDictionary.queue",
        attributes: .concurrent)
    
    func getValue(forKey key: Key) -> Value? {
        return queue.sync {
            return self.dictionary[key]
        }
    }
    
    func setValue(_ value: Value, forKey key: Key) {
        queue.async(flags: .barrier) {
            self.dictionary[key] = value
        }
    }
    
    func setValues(_ values: [Key: Value]) {
        queue.async(flags: .barrier) {
            self.dictionary.merge(
                values,
                uniquingKeysWith: { $1 })
        }
    }
    
    func removeValue(forKey key: Key) {
        queue.async(flags: .barrier) {
            self.dictionary.removeValue(forKey: key)
        }
    }
    
    func removeValues(forKeys keys: [Key]) {
        queue.async(flags: .barrier) {
            keys.forEach { 
                self.dictionary.removeValue(forKey: $0)
            }
        }
    }
    
    func removeAllValues() {
        queue.async(flags: .barrier) {
            self.dictionary = [:]
        }
    }
    
}
