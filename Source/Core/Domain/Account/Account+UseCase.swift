import Foundation
import CoreData

// MARK: - Account Factory

public extension Account {
    /// Simplified version of CreateAccountUseCase
    static func create(id: String, externalID: String = "", in context: NSManagedObjectContext) throws -> Account {
        let account = Account(context: context)
        account.id = id
        account.image = .createEmpty(in: context)
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
    private let phone: String?
    private let image: AttachmentSource?
    
    public init(context: NSManagedObjectContext, id: String, externalID: String, name: String, email: String, phone: String? = nil, image: AttachmentSource?) {
        self.context = context
        self.restoredID = id
        self.externalID = externalID
        self.name = name
        self.email = email
        self.phone = phone
        self.image = image
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
        newAccount.name = name
        newAccount.email = email
        newAccount.phone = phone
        if let image {
            newAccount.image = try resolveAttachment(from: image, in: context)
        } else {
            newAccount.image = .createEmpty(in: context)
        }
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
            account.name = newName
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

// MARK: - Update Account Image Use Case

public struct UpdateAccountImageUseCase {
    private let accountID: String
    private let attachmentSource: AttachmentSource

    public init(accountID: String, source: AttachmentSource) {
        self.accountID = accountID
        self.attachmentSource = source
    }
    
    public init(accountID: String, imageURL: URL) {
        self.accountID = accountID
        self.attachmentSource = .url(imageURL)
    }
    
    public func execute(in context: NSManagedObjectContext) async throws {
        try await context.perform {
            let fetchRequest = Account.byID(self.accountID)
            fetchRequest.fetchLimit = 1
            
            guard let account = try context.fetch(fetchRequest).first else {
                throw AccountUpdateError.accountNotFound
            }
            
            if !account.image.isEmpty {
                context.delete(account.image)
            }
            
            account.image = try resolveAttachment(from: self.attachmentSource, in: context)
            
            if context.hasChanges {
                try context.save()
            }
        }
    }
}

// MARK: - Supporting Types

public enum AttachmentSource {
    case url(URL)
    case raw(Data)
    case native(Data)
    case pack(Data, Data)
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

private func resolveAttachment(from source: AttachmentSource, in context: NSManagedObjectContext) throws -> Attachment {
    switch source {
    case .url(let url): Attachment.fromURL(url, in: context)
    case .raw(let data): Attachment.fromData(raw: data, in: context)
    case .native(let data): Attachment.fromData(native: data, in: context)
    case .pack(let raw, let native): Attachment.fromData(raw: raw, native: native, in: context)
    }
}

