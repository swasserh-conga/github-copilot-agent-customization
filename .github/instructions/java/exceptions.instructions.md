---
applyTo: "**/*.java"
description: "Rules for exception handling in Java code. Apply to all Java files."
---

# Exception Handling Rules

## Never swallow or log-only exceptions

Do **not** replace exceptions with log statements in the middle of application logic.
Exceptions must be propagated to the top-level caller in the thread (REST resource, ingress handler, etc.),
which is responsible for translating them into HTTP responses or error reports.

**Forbidden:**
```java
try {
    doSomething();
} catch (Exception e) {
    LOG.warn("Something went wrong", e); // WRONG: caller has no idea this failed
}
```

**Forbidden:**
```java
try {
    doSomething();
} catch (Exception e) {
    // silently ignore — WRONG
}
```

## Only catch exceptions to transform checked → unchecked

The only valid reason to catch an exception inside implementation logic is to wrap a
**checked exception** (one that extends `Exception` but not `RuntimeException`) into an
unchecked exception so it can propagate freely up the call stack.

**Correct pattern:**
```java
try {
    objectMapper.writeValueAsString(value); // throws JsonProcessingException (checked)
} catch (JsonProcessingException e) {
    throw new IllegalStateException("Failed to serialize value", e); // unchecked
}
```

## Do not catch `Exception` or `RuntimeException` generically

- Do **not** catch `Exception` or `RuntimeException` unless you are at a top-level boundary
  (REST resource exception mapper, ingress pipeline root, shutdown hook).
- Always catch the **most specific** exception type available.
- If the method you are calling only throws unchecked exceptions, **do not add a try-catch at all**.
- Adding `@SuppressWarnings("PMD.AvoidCatchingGenericException")` to silence a PMD warning is a
  strong signal that the code violates this rule — treat it as a required fix, not a shortcut.

**Correct — no catch needed when only unchecked exceptions are thrown:**
```java
// ObjectMapper.convertValue() throws IllegalArgumentException (unchecked) — no try-catch needed
MyDto result = objectMapper.convertValue(source, MyDto.class);
```

**Correct — catch only the specific business exception:**
```java
// Only NotFoundException is a meaningful "not found" signal; other failures must propagate.
try {
    return repositoryCache.getExistingRepositoryId(ctx, repoName);
} catch (NotFoundException e) {
    return null; // stale reference — deleted resource
}
```

## Preserve caller metadata

When rethrowing, always pass the original exception as the `cause`:
```java
throw new IllegalStateException("Descriptive message", originalException);
```
Never discard the original exception; doing so loses the root cause and stack trace.

## Fail fast on unsupported or unexpected branches

When control reaches a branch that is unreachable unless the code has a bug — an unhandled `switch`
case, an unexpected subtype, a state a preceding invariant should have excluded — **throw**.
Do not log and continue, and do not return a neutral value (`null`, an empty collection,
`Optional.empty()`).

Be offensive, not defensive. A log line delegates the problem to every caller, who must notice it
and decide what to do; in practice nobody does and the bug ships silently. An exception cannot be
missed. It also removes the neutral-value branch the caller would otherwise have to handle, so the
calling code gets simpler.

Use a **plain JDK unchecked exception** matching the case. Do not wrap unreachable states in a
generic project exception intended for translating checked failures.

| Situation | Exception |
|---|---|
| Unhandled `switch` case, unreachable state | `IllegalStateException` |
| Argument value the method cannot accept | `IllegalArgumentException` |
| Required argument is `null` | `Objects.requireNonNull(arg, "arg")` |
| Operation not supported for this subtype | `UnsupportedOperationException` |

**Forbidden:**
```java
default:
    LOG.warn("Unsupported validator type", "type", type);
    return null; // WRONG: every caller must now handle a null it cannot explain
```

**Correct:**
```java
default:
    throw new IllegalStateException("Unsupported validator type: " + type);
```

### This rule does not apply to invalid client data

A malformed request value is an **expected outcome**, not a bug: it must produce a
`ValidationError`, a `DataError`, or an HTTP 400 — never an `IllegalStateException`.

The test is: *could a well-behaved client cause this?*
- **Yes** → it is data handling. Report it through the normal error channel.
- **No** → it is a bug. Throw.
