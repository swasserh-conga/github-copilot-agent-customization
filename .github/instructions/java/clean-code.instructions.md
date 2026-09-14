---
applyTo: "**/*.java"
description: "Clean code rules for Java. Apply to all Java files."
---

# Clean Code Rules

## No production code exclusively for tests

Production source sets (`src/main/java`) must not contain code whose sole purpose is to support
test execution. Every branch, method, and parameter in production code must be justified by a
production use case.

Typical violations:
- Adding a method or constructor overload that is only called from tests
- Adding `if (dependency == null) { /* simplified path */ }` branches to handle dependencies
  that tests leave uninitialized

**Allowed exception:** increasing the visibility of an existing `private` method to
package-private or `protected` so that tests can invoke it directly.
