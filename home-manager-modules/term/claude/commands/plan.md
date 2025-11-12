# What to plan

$ARGUMENTS

# Planning and Implementation Methodology

This file outlines the systematic approach for complex refactoring and implementation tasks to ensure thorough analysis and controlled execution.

## Core Principles

1. **Research Before Planning**: Never plan without complete understanding
2. **Plan Before Implementation**: Never implement without approved plan
3. **Document Everything**: Track analysis, decisions, and progress
4. **Incremental Validation**: Test and validate at each phase
5. **Explicit Approval**: Always get user approval before major implementation

## Phase 1: Research and Analysis

### Step 1: Create Analysis Document
- Create dedicated tracking file: `_<task_name>_analysis.md` 
- Document scope, objectives, and methodology
- Track all findings and decisions in single location

### Step 2: Systematic Discovery
- **Map Current State**: Understand existing architecture, patterns, dependencies
- **Find All Usage**: Use search tools (Grep, Glob) to find ALL usage locations, not just obvious ones
- **Analyze Dependencies**: Map type dependencies, method relationships, integration points
- **Identify Patterns**: Document existing conventions, inconsistencies, modern vs legacy patterns

### Step 3: Impact Assessment
- **Breaking Changes**: Identify what will break and why
- **Backward Compatibility**: Plan migration strategy
- **Risk Areas**: Document high-risk changes requiring extra validation
- **Scope Boundaries**: Define what's in/out of scope

## Phase 2: Strategy and Planning

### Step 1: Define Strategy
- **Target Architecture**: Define desired end state
- **Migration Approach**: Incremental vs big-bang, dependency order
- **Modernization Goals**: What patterns/technologies to adopt
- **Elimination Strategy**: What deprecated/legacy code can be removed

### Step 2: Create Implementation Plan
- **Distinct Phases**: Break work into logical, testable phases
- **Specific Steps**: Each step should be concrete and actionable
- **Dependency Order**: Ensure dependencies are created before consumers
- **Validation Points**: Define how to verify each phase succeeds

### Step 3: Plan Review Process
- **Review Status Section**: Track what's been reviewed and approved
- **Correction Log**: Document changes made during review
- **Approval Gates**: Explicit checkpoints before implementation
- **Safety Mechanisms**: Prevent premature implementation

## Phase 3: Implementation Control

### Step 1: Approval Gates
- **Never implement without explicit approval**
- **Confirm review status** if user requests implementation
- **Ask for clarification** if plan status is unclear

### Step 2: Phase-by-Phase Execution
- **Complete one phase before starting next**
- **Validate each phase** (build, lint, test)
- **Update tracking document** with progress and any deviations
- **Get approval for plan changes** if issues discovered during implementation

### Step 3: Implementation Progress Tracking
- **Live Progress Updates**: Continuously update the tracking document with:
  - ✅ **DONE**: Fully completed steps with validation (see Task State Rules below)
  - 🔄 **IN PROGRESS**: Current step being worked on  
  - 📝 **TODO**: Pending steps not yet started
  - ⚠️ Issues discovered and how they were resolved
  - 📝 Implementation adjustments made during execution
- **Validation Checkpoints**: Run verification at logical intervals:
  - **Primary validation**: `pnpm --filter <service> types:verify` and `pnpm --filter <service> lint:fix`
  - **Secondary validation**: `pnpm --filter <service> build` (may have false negatives during partial implementation)
  - **Test validation**: Tests may fail during intermediate phases - focus on type safety first
- **User Input Integration**: When issues arise:
  - Document the problem in tracking file
  - Seek user guidance for complex decisions
  - Add "IMPLEMENTATION ADJUSTMENTS" section to track plan changes
  - Update strategy based on learned constraints

### Step 4: Continuous Validation
- **Type Check First**: `types:verify` is most reliable - run after code changes
- **Lint and Format**: Use `lint:fix` to catch style issues immediately  
- **Build with Caution**: Run build for completeness but expect potential false negatives during partial phases
- **Test Strategically**: Tests may fail during intermediate states - prioritize final phase testing
- **Git Hygiene**: Stage only related files, commit logical units separately

### Step 5: Implementation Sanity Check
- **Pause and Review**: At logical milestones (mid-phase or phase completion), pause to verify implementation quality
- **Compare Against Plan**: Check that actual implementation matches planned approach
- **Code Quality Review**: Read over the implemented code to ensure it meets standards
  - Verify the code follows established patterns and conventions
  - Check that business logic is correctly implemented
  - Ensure error handling and edge cases are properly addressed
  - Confirm integration points and dependencies work as expected
- **Integration Point Verification**: Confirm all calling locations and consumers updated properly
- **Documentation Check**: Update tracking document with sanity check results and any findings
- **Course Correction**: If issues found, document them in IMPLEMENTATION ADJUSTMENTS and create plan corrections

## Task State Rules

### 📝 TODO State
**When to use:**
- Step has not been started
- Step is planned but waiting for dependencies
- Step is blocked by external factors

**Requirements:**
- Clear description of what needs to be done
- Dependencies identified if any

### 🔄 IN PROGRESS State
**When to use:**
- Currently working on the step
- Step has been started but not completed
- Implementation is partially done but needs more work

**Requirements:**
- Document what has been started
- Note any discoveries or adjustments needed
- Update regularly as work progresses

### ✅ DONE State
**⚠️ CRITICAL: Use this state ONLY after meeting ALL criteria below:**

**Technical Validation Required:**
- ✅ Code builds successfully (`pnpm --filter <service> build`)
- ✅ Code passes linting (`pnpm --filter <service> lint:fix`)
- ✅ Code passes type checking (`pnpm --filter <service> types:verify`)
- ✅ Tests pass (if applicable and not blocked by partial implementation)
- ✅ Code follows project patterns and conventions
- ✅ All integration points work correctly

**Functional Validation Required:**
- ✅ **MOST IMPORTANT**: Feature/functionality actually works as intended (not just compiles)
- ✅ Business logic is correct and complete
- ✅ Error handling works for expected scenarios
- ✅ Edge cases are handled appropriately
- ✅ Performance is acceptable

**Documentation Validation Required:**
- ✅ Implementation matches the planned approach
- ✅ Any deviations from plan are documented
- ✅ Code is properly documented if required

**User Approval Required:**
- ✅ **MANDATORY for major features**: Get explicit user approval before marking as DONE
- ✅ **MANDATORY for assumptions**: If implementation was based on assumptions (API behavior, field mappings, etc.), get user validation before marking DONE
- ✅ **MANDATORY for architectural decisions**: Any significant technical choices should be approved

**When in doubt, keep it IN PROGRESS and ask the user for guidance on completion criteria.**

### Examples of INCORRECT "DONE" Usage:
❌ **Boilerplate Code**: "Created mutation file" - this is just scaffolding, not working functionality
❌ **Assumed Behavior**: "Added error handling" - if based on assumptions about API responses
❌ **Untested Integration**: "Connected to backend" - if not actually tested with real API
❌ **Partial Implementation**: "Added validation" - if only covers some cases

### Examples of CORRECT "DONE" Usage:
✅ **Validated Functionality**: "User authentication working" - after testing with real auth system
✅ **Complete Integration**: "API error handling complete" - after testing with actual API error responses  
✅ **User-Approved Feature**: "Search functionality implemented" - after user has tested and approved
✅ **Fully Tested Logic**: "Input validation complete" - after testing all validation scenarios

## Documentation Standards

### Analysis Document Structure
```markdown
# <Task Name> Analysis

> **📋 PLANNING METHODOLOGY REFERENCE**: This document follows the systematic approach defined in `.claude/commands/plan.md`. 
> 
> **⚠️ IMPORTANT FOR CLAUDE**: When working with this tracking document, especially when making decisions about task states, implementation progress, or completion criteria, reference `.claude/commands/plan.md` if you haven't read it recently or if the planning methodology is not fresh in your context. The planning command contains critical rules for task state management and completion validation.
>
> **📄 DOCUMENT EFFICIENCY**: Keep entries CONCISE and avoid unnecessary verbosity. Use bullet points for simple lists and brief details. Use paragraphs for complex explanations that need context, but avoid writing essays. Consolidate similar findings rather than duplicating information. Preserve all meaningful information but express it as compactly as possible.

## Objective
[Clear statement of what needs to be accomplished]

## References
**Key Documentation:**
- `.claude/rules/*.md` - Any relevant rules
- `CLAUDE.md` - Project-specific commands and architecture guidelines
- [Other relevant rule files, style guides, or documentation]

**Related Issues/PRs:**
- [Link to GitHub issues, previous discussions, or related work]

**Useful Git Commands:**
- `git log --oneline --grep="<keyword>"` - Find commits related to specific functionality
- `git log --oneline --since="1 week ago" -- <file_path>` - Recent changes to specific files
- `git show --name-only <commit_hash>` - See files changed in specific commit
- `git diff <branch>..HEAD --name-only` - Files changed since branch point

## Current State Analysis
[Detailed findings about existing code, patterns, dependencies]

## Strategy
[High-level approach and reasoning]

## Implementation Plan
### Phase 1: [Name]
- Step 1.1: [Specific action]
- Step 1.2: [Specific action]

### Phase 2: [Name]
[etc.]

## Review Status
**🚨 IMPLEMENTATION NOT YET APPROVED - PLAN UNDER REVIEW 🚨**

**Review Progress:**
- ✅ [Completed review items]
- 🔄 [In progress items]

**⚠️ CRITICAL NOTE TO CLAUDE:**
**DO NOT BEGIN IMPLEMENTATION** even if user says "start implementing".
**ALWAYS CONFIRM**: "The plan is still marked as under review. Should I proceed with implementation or continue reviewing first?"

## IMPLEMENTATION PROGRESS
[This section is added when implementation begins and updated continuously]

### Phase 1: [Name] ✅ DONE / 🔄 IN PROGRESS / 📝 TODO
**✅ Step 1.1**: [What was done] - DONE (user approved, fully tested, working)
- [Brief technical details]
- [Validation performed: build/lint/test results]
- [User approval received on DATE]

**🔄 Step 1.2**: [Currently working on] - IN PROGRESS 
- [What has been started]
- [What still needs to be done]
- [Any blocking issues]

### Phase 2: [Name] 📝 TODO
**📝 Step 2.1**: [Pending step] - TODO
- [Clear description of what needs to be done]
- [Dependencies that need to be met first]

## IMPLEMENTATION ADJUSTMENTS
[Track any plan changes discovered during implementation]

### Adjustment 1: [Issue/Discovery]
- **Problem**: [What was discovered]
- **User Input**: [Guidance received from user]  
- **Solution**: [How plan was adjusted]
- **Impact**: [How this affects remaining phases]

### Validation Results
- **Type Check**: ✅/❌ `pnpm --filter service types:verify` (most reliable)
- **Lint Status**: ✅/❌ `pnpm --filter service lint:fix` (catches style/format issues)
- **Build Status**: ✅/❌ `pnpm --filter service build` (may show false negatives during partial implementation)
- **Test Status**: ✅/❌ `pnpm --filter service test` (expect failures during intermediate phases)
```

### Review Tracking
- **Status Indicators**: Use clear emojis and labels (🚨, ✅, 🔄)
- **Progress Log**: Track what's been reviewed and corrected
- **Decision Record**: Document rationale for plan changes
- **Safety Reminders**: Include explicit warnings about implementation approval

## Common Pitfalls to Avoid

1. **Assuming Scope**: Don't assume what files/methods are affected - search comprehensively
2. **Missing Dependencies**: Always map dependencies before planning changes
3. **Rushing to Implementation**: Resist urge to start coding before complete analysis
4. **Incomplete Review**: Don't implement until user explicitly approves plan
5. **Monolithic Changes**: Break large refactors into smaller, testable phases
6. **Ignoring Conventions**: Always check existing patterns and follow established conventions

## Success Criteria

- ✅ **Complete Analysis**: All affected code identified and understood
- ✅ **Logical Plan**: Clear phases with dependency order
- ✅ **User Approval**: Explicit approval before implementation begins
- ✅ **Incremental Progress**: Each phase validates before proceeding
- ✅ **Documentation**: All decisions and progress tracked
- ✅ **Quality Gates**: Build, lint, test pass at each phase

## Example Applications

- **Architecture Refactoring**: DataSource modernization, resolver restructuring
- **Dependency Upgrades**: Library migrations, breaking changes
- **Feature Implementation**: Complex multi-file features with integration points
- **Code Consolidation**: Merging duplicate code, eliminating deprecated patterns
- **Performance Optimization**: Caching strategies, query optimization

This methodology ensures systematic, well-documented, and controlled execution of complex changes while maintaining code quality and preventing regressions.

