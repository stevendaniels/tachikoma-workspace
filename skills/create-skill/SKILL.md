---
name: create-skill
description: Use when creating new skills, editing existing skills, or need guidance on skill structure and effectiveness
---

# Creating Skills

## Overview

A **skill** is a reference guide for proven techniques, patterns, or tools. Skills help future Agent instances find and apply effective approaches.

**Skills are:** Reusable techniques, patterns, tools, reference guides

**Skills are NOT:** Narratives about how you solved a problem once

## When to Create a Skill

**Create when:**
- Technique wasn't intuitively obvious to you
- You'd reference this again across projects
- Pattern applies broadly (not project-specific)
- Others would benefit

**Don't create for:**
- One-off solutions
- Standard practices well-documented elsewhere
- Project-specific conventions (put in AGENT.md)
- Mechanical constraints (if enforceable with regex/validation, automate it)

## Skill Types

| Type | Description | Examples |
|------|-------------|----------|
| **Technique** | Concrete method with steps to follow | condition-based-waiting, root-cause-tracing |
| **Pattern** | Way of thinking about problems | flatten-with-flags, test-invariants |
| **Reference** | API docs, syntax guides, tool documentation | office docs, API references |

## Directory Structure

```
skills/{skill-name}/
├── SKILL.md              # Required - instructions loaded when skill activates
├── scripts/              # Optional - executable code (Python, Bash, etc.)
├── references/           # Optional - additional docs loaded on demand
│   └── REFERENCE.md
└── assets/               # Optional - templates, images, data files
```

**Flat namespace** - all skills in one searchable namespace

**Separate files for:**
1. **Heavy reference** (100+ lines) - API docs, comprehensive syntax
2. **Reusable tools** - Scripts, utilities, templates

**Keep inline:** Principles, concepts, code patterns (<50 lines), everything else

## SKILL.md Structure

### Frontmatter Constraints

```yaml
---
name: skill-name
description: Use when [trigger conditions and symptoms].
---
```

| Field | Constraints |
|-------|-------------|
| `name` | 1-64 chars, lowercase letters + hyphens only, must match folder name |
| `description` | 1-1024 chars, starts with "Use when...", describes triggers NOT workflow |

### Name Rules

**Mechanical constraints:**
- Lowercase letters and hyphens only (`a-z` and `-`)
- No consecutive hyphens (`--`)
- Cannot start or end with hyphen
- Must match the folder name exactly

**Valid:** `pdf-processing`, `data-analysis`, `code-review`
**Invalid:** `PDF-Processing`, `-pdf`, `pdf--processing`

**Discoverability (critical):**

Agent decides whether to invoke your skill based on name + description alone, before ever reading the content. Name choice can cause 4x difference in activation rates.

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

### Progressive Disclosure

Skills load in stages to minimize context usage:

1. **Metadata** (~100 tokens): `name` and `description` loaded at startup for all skills
2. **Instructions** (<5000 tokens recommended): Full `SKILL.md` body loaded when skill activates
3. **Resources** (as needed): Files in `scripts/`, `references/`, `assets/` loaded only when required

**Keep SKILL.md under 500 lines.** Move detailed reference material to `references/`.

### Section Template

```markdown
---
name: skill-name
description: Use when [specific triggering conditions and symptoms]
---

# Skill Name

## Overview
What is this? Core principle in 1-2 sentences.

## When to Use
Bullet list with SYMPTOMS and use cases
When NOT to use

## Core Pattern (for techniques/patterns)
Before/after code comparison

## Quick Reference
Table or bullets for scanning common operations

## Implementation
Inline code for simple patterns
Link to file for heavy reference or reusable tools

## Common Mistakes
What goes wrong + fixes
```

## Writing Effective Descriptions

**Critical insight:** Testing revealed that when a description summarizes the skill's workflow, Agent may follow the description instead of reading the full skill content.

A description saying "code review between tasks" caused Agent to do ONE review, even though the skill's flowchart clearly showed TWO reviews. When the description was changed to just triggering conditions (no workflow summary), Agent correctly read and followed the full skill.

**The trap:** Descriptions that summarize workflow create a shortcut Agent will take. The skill body becomes documentation Agent skips.

**Rules:**
- Start with "Use when..." to focus on triggering conditions
- Include specific symptoms, situations, and contexts
- **NEVER summarize the skill's process or workflow**
- Write in third person (injected into system prompt)
- Keep under 500 characters if possible

See [references/cso-patterns.md](references/cso-patterns.md) for detailed examples, keyword strategies, and token efficiency techniques.

## Common Rationalizations

When creating or using skills, watch for these excuses:

| Excuse | Reality |
|--------|---------|
| "Skill is obviously clear" | Clear to you ≠ clear to other agents. Test it. |
| "It's just a reference" | References can have gaps, unclear sections. |
| "This is too simple for a skill" | Simple patterns get forgotten. Document them. |
| "I'll create the skill later" | Later = never. Capture now while context is fresh. |
| "No one else will use this" | Future you is "someone else." |
| "AGENT.md is good enough" | AGENT.md = project-specific. Skills = reusable. |

## Testing Your Skill (Best Practice)

Before deploying, verify your skill works:

### For Discipline Skills (rules/requirements)
Test with pressure scenarios:
- Does Agent follow the rule under stress?
- What rationalizations does it use to skip steps?
- Add explicit counters for each rationalization found

### For Technique Skills (how-to guides)
Test with application scenarios:
- Can Agent apply the technique correctly?
- Are instructions complete or are there gaps?

### For Reference Skills (documentation)
Test with retrieval scenarios:
- Can Agent find the right information?
- Are common use cases covered?

**Tip:** Run a subagent with and without the skill to see if behavior changes appropriately.

## Creation Workflow

When creating a skill:

1. Ask: "What will this skill help with?"
2. Based on the answer, propose 2 name alternatives with reasoning:

```
Based on "help build React components":

1. `react-component-builder` (recommended)
   - Action verb "builder" + specific tech "react"

2. `component-generator-react`
   - Action verb first, tech qualifier

Avoid: `react-helper`, `component-assistant`, `frontend-toolkit`
```

3. User picks a name before proceeding to content

## Creation Checklist

**Structure:**
- [ ] Name uses only lowercase letters and hyphens
- [ ] Name matches folder name exactly
- [ ] Name evaluated for activation signals (avoid helper/assistant/toolkit)
- [ ] YAML frontmatter with `name` and `description` only
- [ ] Description starts with "Use when..." (no workflow summary)
- [ ] Description includes specific triggers/symptoms
- [ ] Description written in third person
- [ ] SKILL.md under 500 lines

**Content:**
- [ ] Clear overview with core principle
- [ ] Keywords throughout for search (errors, symptoms, tools)
- [ ] One excellent example (not multi-language)
- [ ] Code inline OR linked to separate file
- [ ] Quick reference table for scanning
- [ ] Common mistakes section

**Quality:**
- [ ] No narrative storytelling
- [ ] Small flowchart only if decision non-obvious
- [ ] Supporting files only for tools or heavy reference
- [ ] Tested with at least one scenario

**Deployment:**
- [ ] Symlink created: `ln -s ~/notes/skills/{name} ~/.claude/commands/{name}`

## Template

```yaml
---
name: skill-name
description: Use when [specific triggering conditions and symptoms].
metadata:
  argument-hint: <required-arg> [optional-arg]
  allowed-tools: Read(**), Write(**), Glob(**)
---

# Skill Title

Brief description of the skill's purpose.

## Overview

What is this? Core principle in 1-2 sentences.

## When to Use

- Symptom or trigger 1
- Symptom or trigger 2
- When NOT to use: [conditions]

## Usage

- `/skill-name arg` - Description of this usage
- `/skill-name --flag` - Description of this usage

## Instructions

### Step 1: First Step

Instructions for this step.

### Step 2: Second Step

Instructions for this step.

## Quick Reference

| Action | How |
|--------|-----|
| Common action 1 | How to do it |
| Common action 2 | How to do it |

## Common Mistakes

- **Mistake 1**: How to avoid/fix it
- **Mistake 2**: How to avoid/fix it

## Tips

- Helpful tip 1
- Helpful tip 2
```

## Validation

Name must:
- Match folder name
- Be 1-64 characters
- Use only lowercase letters and hyphens
- Not start/end with hyphen
- Not contain consecutive hyphens

Description must:
- Be non-empty
- Be under 1024 characters
- Start with "Use when..."
- Describe triggers, not workflow
