import XCTest
@testable import ScopeGraph

final class SessionTests: XCTestCase {
    
    struct TestSessionInfo: Codable, Sendable, Equatable {
        let userID: String
        let email: String
        let displayName: String
    }
    
    struct TestTokenInfo: Codable, Sendable {
        let accessToken: String
        let refreshToken: String
    }
    
    func testSessionCreation() async throws {
        let component = StorageModule.session<TestSessionInfo, TestTokenInfo>(
            sessionService: "test_sessions",
            tokenService: "test_tokens"
        )
        
        let sessionInfo = TestSessionInfo(
            userID: "123",
            email: "test@example.com",
            displayName: "Test User"
        )
        
        let tokens = TestTokenInfo(
            accessToken: "access_token",
            refreshToken: "refresh_token"
        )
        
        let result = try await component.process(.create(
            sessionID: "session_123",
            info: sessionInfo,
            tokens: tokens
        ))
        
        if case .session(let sessionActor) = result {
            XCTAssertEqual(sessionActor.id, "session_123")
            XCTAssertEqual(sessionActor.info, sessionInfo)
            
            let storedTokens = await sessionActor.getTokens()
            XCTAssertEqual(storedTokens?.accessToken, "access_token")
            XCTAssertEqual(storedTokens?.refreshToken, "refresh_token")
        } else {
            XCTFail("Expected session result")
        }
    }
    
    func testSessionRestore() async throws {
        let component = StorageModule.session<TestSessionInfo, TestTokenInfo>(
            sessionService: "test_sessions_restore",
            tokenService: "test_tokens_restore"
        )
        
        let sessionInfo = TestSessionInfo(
            userID: "456",
            email: "restore@example.com",
            displayName: "Restore User"
        )
        
        // Create session first
        _ = try await component.process(.create(
            sessionID: "session_456",
            info: sessionInfo,
            tokens: nil
        ))
        
        // Restore session
        let result = try await component.process(.restore(sessionID: "session_456"))
        
        if case .session(let sessionActor) = result {
            XCTAssertEqual(sessionActor.id, "session_456")
            XCTAssertEqual(sessionActor.info, sessionInfo)
        } else {
            XCTFail("Expected session result")
        }
    }
    
    func testActiveSession() async throws {
        let component = StorageModule.session<TestSessionInfo, TestTokenInfo>(
            sessionService: "test_sessions_active",
            tokenService: "test_tokens_active"
        )
        
        let sessionInfo = TestSessionInfo(
            userID: "789",
            email: "active@example.com",
            displayName: "Active User"
        )
        
        // Create session
        _ = try await component.process(.create(
            sessionID: "session_789",
            info: sessionInfo,
            tokens: nil
        ))
        
        // Set as active
        _ = try await component.process(.setActive("session_789"))
        
        // Get active session
        let result = try await component.process(.getActive)
        
        if case .session(let sessionActor) = result {
            XCTAssertEqual(sessionActor.id, "session_789")
            XCTAssertEqual(sessionActor.info, sessionInfo)
        } else {
            XCTFail("Expected session result")
        }
    }
    
    func testSessionRemoval() async throws {
        let component = StorageModule.session<TestSessionInfo, TestTokenInfo>(
            sessionService: "test_sessions_remove",
            tokenService: "test_tokens_remove"
        )
        
        let sessionInfo = TestSessionInfo(
            userID: "999",
            email: "remove@example.com",
            displayName: "Remove User"
        )
        
        // Create session
        _ = try await component.process(.create(
            sessionID: "session_999",
            info: sessionInfo,
            tokens: nil
        ))
        
        // Remove session
        let removeResult = try await component.process(.remove(sessionID: "session_999"))
        XCTAssertEqual(removeResult, .success)
        
        // Try to restore - should fail
        let restoreResult = try await component.process(.restore(sessionID: "session_999"))
        XCTAssertEqual(restoreResult, .notFound)
    }
    
    func testTokenManagement() async throws {
        let sessionActor = SessionActor<TestSessionInfo, TestTokenInfo>(
            id: "token_test",
            info: TestSessionInfo(userID: "token", email: "token@test.com", displayName: "Token"),
            tokenService: "test_token_service"
        )
        
        let initialTokens = TestTokenInfo(
            accessToken: "initial_access",
            refreshToken: "initial_refresh"
        )
        
        // Set tokens
        await sessionActor.setTokens(initialTokens)
        
        // Get tokens
        let retrievedTokens = await sessionActor.getTokens()
        XCTAssertEqual(retrievedTokens?.accessToken, "initial_access")
        XCTAssertEqual(retrievedTokens?.refreshToken, "initial_refresh")
        
        // Update tokens
        await sessionActor.updateTokens { _ in
            TestTokenInfo(accessToken: "updated_access", refreshToken: "updated_refresh")
        }
        
        let updatedTokens = await sessionActor.getTokens()
        XCTAssertEqual(updatedTokens?.accessToken, "updated_access")
        XCTAssertEqual(updatedTokens?.refreshToken, "updated_refresh")
        
        // Remove tokens
        await sessionActor.setTokens(nil)
        let removedTokens = await sessionActor.getTokens()
        XCTAssertNil(removedTokens)
    }
}

// MARK: - Result Equatable for Testing

extension SessionResult: Equatable where SessionInfo: Equatable, TokenInfo: Equatable {
    public static func == (lhs: SessionResult<SessionInfo, TokenInfo>, rhs: SessionResult<SessionInfo, TokenInfo>) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success), (.notFound, .notFound):
            return true
        case (.session(let lhsSession), .session(let rhsSession)):
            return lhsSession.id == rhsSession.id && lhsSession.info == rhsSession.info
        case (.sessions(let lhsSessions), .sessions(let rhsSessions)):
            return lhsSessions.count == rhsSessions.count &&
                   zip(lhsSessions, rhsSessions).allSatisfy { $0.id == $1.id && $0.info == $1.info }
        default:
            return false
        }
    }
}