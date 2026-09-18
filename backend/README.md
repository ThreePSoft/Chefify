# Chefify backend

ASP.NET Core 9 API for Chefify. Docker Compose is the recommended local runtime because it supplies PostgreSQL and required configuration.

- [Українська документація](../docs/uk/README.md)
- [English documentation](../docs/en/README.md)
- [Backend development — Українська](../docs/uk/development.md#backend-через-docker)
- [Backend development — English](../docs/en/development.md#backend-through-docker)
- [API — Українська](../docs/uk/api.md)
- [API — English](../docs/en/api.md)

From the repository root:

```bash
docker compose up --build db api
```

With the default Development configuration, Swagger is available at <http://localhost:8080/swagger>.
