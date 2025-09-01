# ``Endpoint``

A type-safe DSL for building REST API clients with fluent interface design.

## Overview

Swift Endpoint provides a modern, type-safe way to build HTTP requests using a fluent interface. It supports async/await, automatic token refresh, and comprehensive error handling.

## Topics

### Building Requests

- ``Endpoint(baseURL:)``
- ``EndpointConfigurator``

### Authentication

- ``Authenticator``
- ``BearerTokenAuthenticator``
- ``RefreshableTokenAuthenticator``
- ``UnauthenticatedAuthenticator``

### Error Handling

- ``EndpointError``

### API Organization

- ``EndpointBuilder``
- ``SessionProtocol``