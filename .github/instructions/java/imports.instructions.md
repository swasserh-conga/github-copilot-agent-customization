---
applyTo: "**/*.java"
description: "Directives for Java import statements"
---

# jakarta vs javax

## Always use `jakarta.*` imports

The `javax.*` namespace is a legacy Java EE artifact. All new code and modified code **must** use `jakarta.*` equivalents.

```java
// CORRECT
import jakarta.annotation.Nullable;
import jakarta.ws.rs.BadRequestException;
import jakarta.validation.constraints.NotNull;

// WRONG — do not use
import javax.annotation.Nullable;
import javax.ws.rs.BadRequestException;
import javax.validation.constraints.NotNull;
```
