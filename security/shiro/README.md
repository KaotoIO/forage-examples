# Camel Forage Shiro Security Policy Example

This example demonstrates how to use Camel Forage to automatically configure an Apache Shiro security policy for route authorization.

## Prerequisites

1. **Forage plugin** installed:
   ```bash
   camel plugin add -g=io.kaoto.forage -a=camel-jbang-plugin-forage -v=1.6-SNAPSHOT
   ```

## Configuration

The `application.properties` file configures the Shiro security policy:

- **INI Resource Path**: `classpath:shiro.ini` - Path to the Shiro INI configuration
- **Passphrase**: Base64-encoded passphrase for security token encryption
- **Roles**: Required roles for access (`admin`)
- **Always Reauthenticate**: Whether to re-authenticate on every exchange

The `shiro.ini` file defines users, passwords, and role assignments:

| User    | Password | Roles  |
|---------|----------|--------|
| admin   | secret   | admin  |
| user    | password | user   |
| guest   | guest    | guest  |

## What Happens

1. **Automatic Policy Creation**: Camel Forage creates a `ShiroSecurityPolicy` bean from the configuration properties
2. **Public Endpoint**: `/api/public` is accessible without authentication
3. **Secure Endpoint**: `/api/secure` requires valid credentials with the `admin` role
4. **Token Extraction**: Credentials are extracted from `X-Username` and `X-Password` HTTP headers

## Running the Example

### Using Camel JBang (Java DSL)

```bash
camel run Route.java shiro.ini application.properties
```

### Using Camel JBang (YAML DSL)

```bash
camel run route.camel.yaml shiro.ini application.properties
```

## Testing

### Public endpoint (no authentication needed)

```bash
curl http://localhost:8080/api/public
```

### Secure endpoint with valid admin credentials

```bash
curl -H "X-Username: admin" -H "X-Password: secret" http://localhost:8080/api/secure
```

### Secure endpoint with insufficient role

```bash
curl -H "X-Username: guest" -H "X-Password: guest" http://localhost:8080/api/secure
```

## Features Demonstrated

- Automatic Shiro security policy configuration via properties
- INI-based user/role management
- Role-based authorization on Camel routes
- Public vs. secured endpoint pattern
- Base64-encoded passphrase for token encryption

## Configuration Reference

| Property | Description | Default |
|----------|-------------|---------|
| `forage.shiro.ini.resource.path` | Path to Shiro INI file | *(required)* |
| `forage.shiro.passphrase` | Base64-encoded encryption passphrase | *(none)* |
| `forage.shiro.always.reauthenticate` | Re-authenticate every exchange | `false` |
| `forage.shiro.roles` | Comma-separated required roles | *(none)* |
| `forage.shiro.all.roles.required` | All roles must be present | `false` |
| `forage.shiro.permissions` | Comma-separated required permissions | *(none)* |
| `forage.shiro.all.permissions.required` | All permissions must be present | `false` |
