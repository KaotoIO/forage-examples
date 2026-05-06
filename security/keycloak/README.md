# Camel Forage Keycloak Security Policy Example

This example demonstrates how to use Camel Forage to automatically configure a Keycloak security policy for route authorization with OIDC token validation.

## Prerequisites

1. **Forage plugin** installed:
   ```bash
   camel plugin add -g=io.kaoto.forage -a=camel-jbang-plugin-forage -v=1.3-SNAPSHOT
   ```

2. **Keycloak** running on `localhost:8180`:
   ```bash
   docker run -it --rm \
     -p 8180:8080 \
     -e KC_BOOTSTRAP_ADMIN_USERNAME=admin \
     -e KC_BOOTSTRAP_ADMIN_PASSWORD=admin \
     quay.io/keycloak/keycloak:latest start-dev
   ```

3. **Keycloak realm and client** configured:
   - Create realm: `forage-demo`
   - Create client: `forage-app` (confidential, with client secret `change-me`)
   - Create role: `user`
   - Create a test user and assign the `user` role

## Configuration

The `application.properties` file configures the Keycloak security policy:

- **Server URL**: `http://localhost:8180` - Keycloak server address
- **Realm**: `forage-demo` - Keycloak realm name
- **Client ID/Secret**: Credentials for the Keycloak client
- **Required Roles**: `user` - Roles required for access
- **Token Validation**: Issuer validation and public key auto-fetch enabled
- **Introspection**: Optional token introspection with caching

## What Happens

1. **Automatic Policy Creation**: Camel Forage creates a `KeycloakSecurityPolicy` bean from the configuration properties
2. **Public Endpoint**: `/api/public` is accessible without authentication
3. **Secure Endpoint**: `/api/secure` validates the Bearer token against Keycloak and checks role requirements
4. **Token Validation**: JWT tokens are validated using the Keycloak realm's public key

## Running the Example

### Using Camel JBang (Java DSL)

```bash
camel run Route.java application.properties
```

### Using Camel JBang (YAML DSL)

```bash
camel run route.camel.yaml application.properties
```

## Testing

### Public endpoint (no authentication needed)

```bash
curl http://localhost:8080/api/public
```

### Obtain a token from Keycloak

```bash
TOKEN=$(curl -s -X POST \
  http://localhost:8180/realms/forage-demo/protocol/openid-connect/token \
  -d "grant_type=password" \
  -d "client_id=forage-app" \
  -d "client_secret=change-me" \
  -d "username=testuser" \
  -d "password=testpassword" | jq -r '.access_token')
```

### Secure endpoint with valid token

```bash
curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/api/secure
```

### Secure endpoint without token (should fail)

```bash
curl http://localhost:8080/api/secure
```

## Features Demonstrated

- Automatic Keycloak security policy configuration via properties
- OIDC/JWT token validation against Keycloak server
- Role-based authorization on Camel routes
- Public vs. secured endpoint pattern
- Auto-fetch of Keycloak public key for token verification
- Optional token introspection with result caching

## Configuration Reference

| Property | Description | Default |
|----------|-------------|---------|
| `forage.keycloak.server.url` | Keycloak server URL | *(required)* |
| `forage.keycloak.realm` | Keycloak realm name | *(required)* |
| `forage.keycloak.client.id` | Client ID | *(required)* |
| `forage.keycloak.client.secret` | Client secret | *(required)* |
| `forage.keycloak.required.roles` | Comma-separated required roles | *(none)* |
| `forage.keycloak.all.roles.required` | All roles must be present | `false` |
| `forage.keycloak.required.permissions` | Comma-separated required permissions | *(none)* |
| `forage.keycloak.all.permissions.required` | All permissions must be present | `false` |
| `forage.keycloak.validate.issuer` | Validate token issuer | `true` |
| `forage.keycloak.auto.fetch.public.key` | Auto-fetch public key from Keycloak | `true` |
| `forage.keycloak.use.token.introspection` | Use token introspection endpoint | `false` |
| `forage.keycloak.introspection.cache.enabled` | Cache introspection results | `false` |
| `forage.keycloak.introspection.cache.ttl` | Introspection cache TTL (ms) | `300000` |
