# CSO Patterns Reference

Agent Search Optimization (CSO) patterns for writing discoverable, effective skills.

## Description Examples

### The Critical Rule

**Description = When to Use, NOT What the Skill Does**

```yaml
# BAD: Summarizes workflow - Agent may follow this instead of reading skill
description: Use when executing plans - dispatches subagent per task with code review between tasks

# BAD: Too much process detail
description: Use for TDD - write test first, watch it fail, write minimal code, refactor

# GOOD: Just triggering conditions, no workflow summary
description: Use when executing implementation plans with independent tasks in the current session

# GOOD: Triggering conditions only
description: Use when implementing any feature or bugfix, before writing implementation code
```

### More Examples

```yaml
# BAD: Too abstract, vague, doesn't include when to use
description: For async testing

# BAD: First person
description: I can help you with async tests when they're flaky

# BAD: Mentions technology but skill isn't specific to it
description: Use when tests use setTimeout/sleep and are flaky

# GOOD: Starts with "Use when", describes problem, no workflow
description: Use when tests have race conditions, timing dependencies, or pass/fail inconsistently

# GOOD: Technology-specific skill with explicit trigger
description: Use when using React Router and handling authentication redirects
```

## Keyword Coverage

Use words Agent would search for:

**Error messages:**
- "Hook timed out", "ENOTEMPTY", "race condition"
- Exact error text users encounter

**Symptoms:**
- "flaky", "hanging", "zombie", "pollution"
- Problem indicators, not solutions

**Synonyms:**
- "timeout/hang/freeze"
- "cleanup/teardown/afterEach"
- Cover how different users describe the same problem

**Tools:**
- Actual commands, library names, file types
- `pytest`, `jest`, `.md`, `git`

## Naming Conventions

**Critical insight:** Agent decides whether to invoke your skill based on name + description alone, before ever reading the content. Name choice can cause 4x difference in activation rates.

| Name | Activation |
|------|------------|
| `reactjs-component-builder` | 84% |
| `component-library-docs` | 79% |
| `react-components-helper` | 23% |
| `ui-development-assistant` | 19% |

**High-activation patterns:**
- Action verbs: `builder`, `reviewer`, `analyzer`, `generator`
- Concrete nouns: `docs`, `library`, `schema`, `config`
- Specific tech: `react`, `typescript`, `postgres`, `jwt`

**Low-activation anti-patterns (avoid):**
- Vague words: `helper`, `assistant`, `toolkit`, `utility`, `manager`
- Generic terms: `frontend`, `backend`, `development`, `workflow`

**Use active voice, verb-first:**
- `creating-skills` not `skill-creation`
- `condition-based-waiting` not `async-test-helpers`

**Gerunds (-ing) work well for processes:**
- `creating-skills`, `testing-skills`, `debugging-with-logs`
- Active, describes the action you're taking

**Name by what you DO or core insight:**
- `flatten-with-flags` > `data-structure-refactoring`
- `root-cause-tracing` > `debugging-techniques`

## Token Efficiency

**Target word counts:**
- Getting-started workflows: <150 words each
- Frequently-loaded skills: <200 words total
- Other skills: <500 words (still be concise)

### Techniques

**Move details to tool help:**
```bash
# BAD: Document all flags in SKILL.md
search-conversations supports --text, --both, --after DATE, --before DATE, --limit N

# GOOD: Reference --help
search-conversations supports multiple modes and filters. Run --help for details.
```

**Use cross-references:**
```markdown
# BAD: Repeat workflow details
When searching, dispatch subagent with template...
[20 lines of repeated instructions]

# GOOD: Reference other skill
Always use subagents (50-100x context savings). REQUIRED: Use [other-skill-name] for workflow.
```

**Compress examples:**
```markdown
# BAD: Verbose example (42 words)
your human partner: "How did we handle authentication errors in React Router before?"
You: I'll search past conversations for React Router authentication patterns.
[Dispatch subagent with search query: "React Router authentication error handling 401"]

# GOOD: Minimal example (20 words)
Partner: "How did we handle auth errors in React Router?"
You: Searching...
[Dispatch subagent -> synthesis]
```

**Verification:**
```bash
wc -w skills/path/SKILL.md
# getting-started workflows: aim for <150 each
# Other frequently-loaded: aim for <200 total
```

## Cross-Referencing Other Skills

Use skill name only, with explicit requirement markers:
- **Good:** `**REQUIRED SUB-SKILL:** Use superpowers:test-driven-development`
- **Good:** `**REQUIRED BACKGROUND:** You MUST understand superpowers:systematic-debugging`
- **Bad:** `See skills/testing/test-driven-development` (unclear if required)
- **Bad:** `@skills/testing/test-driven-development/SKILL.md` (force-loads, burns context)

**Why no @ links:** `@` syntax force-loads files immediately, consuming 200k+ context before you need them.
