import Foundation
import CoreData

// MARK: - Account Factory

public extension Account {
    /// Simplified version of CreateAccountUseCase
    static func create(id: String, externalID: String = "", in context: NSManagedObjectContext) throws -> Account {
        let account = Account(context: context)
        account.id = id
        if externalID.isEmpty {
            account.sync.isDraft = true
        } else {
            account.sync.externalID = externalID
        }
        return account
    }
}

// MARK: - Create Account Use Case

public struct CreateAccountUseCase {
    private let context: NSManagedObjectContext
    private let restoredID: String?
    private let externalID: String
    private let name: String
    private let email: String

    public init(context: NSManagedObjectContext, id: String, externalID: String, name: String, email: String) {
        self.context = context
        self.restoredID = id
        self.externalID = externalID
        self.name = name
        self.email = email
    }
    
    @discardableResult
    public func execute() throws -> Account {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AccountCreateError.invalidName
        }
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AccountCreateError.invalidEmail
        }
        
        // Create new account entity without checking for existing ones
        let newAccount = Account(context: context)
        if let restoredID {
            newAccount.id = restoredID
        }
        newAccount.nickname = name
        newAccount.email = email
        newAccount.sync.externalID = externalID
        
        try context.save()
        return newAccount
    }
}

// MARK: - Update Account Use Case

public struct UpdateAccountUseCase {
    private let context: NSManagedObjectContext
    private let objectID: NSManagedObjectID
    private var newName: String?
    private var newEmail: String?
    private var newExternalID: String?

    /// Initialize with account object ID for direct updates
    public init(context: NSManagedObjectContext, objectID: NSManagedObjectID) {
        self.context = context
        self.objectID = objectID
    }
    
    /// Set account name
    public mutating func name(_ value: String) {
        self.newName = value
    }
    
    /// Set account email
    public mutating func email(_ value: String) {
        self.newEmail = value
    }
    
    /// Set external ID
    public mutating func externalID(_ value: String) {
        self.newExternalID = value
    }
    
    public func execute() throws {
        // Get account by object ID for direct access
        guard let account = try context.existingObject(with: objectID) as? Account else {
            throw AccountUpdateError.accountNotFound
        }
        
        // Update properties if provided
        if let newName = newName {
            account.nickname = newName
        }
        if let newEmail = newEmail {
            account.email = newEmail
        }
        if let newExternalID = newExternalID {
            account.sync.externalID = newExternalID
        }
        
        guard context.hasChanges else { return }
        try context.save()
    }
}

public enum AccountCreateError: Error, LocalizedError {
    case invalidName
    case invalidEmail
    case emailAlreadyExists(email: String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidName:
            return "The account name cannot be empty."
        case .invalidEmail:
            return "Please provide a valid email address."
        case .emailAlreadyExists(let email):
            return "An account with the email '\(email)' already exists."
        }
    }
}

public enum AccountUpdateError: Error, LocalizedError {
    case accountNotFound
    
    public var errorDescription: String? {
        switch self {
        case .accountNotFound:
            return "The specified account could not be found in the database."
        }
    }
}
