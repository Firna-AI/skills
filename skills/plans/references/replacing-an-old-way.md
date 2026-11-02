# Replacing an old way

This file holds the detail of the section "Replacing an old way" in the
`plans` skill. That section defines the old way, a consumer, and a
converter.

## What the change deletes

- The old way is dead code under the `git-commit` skill when no consumer
  uses it. Delete it in the same change, with its converters. The deletion
  needs no approval.
- Delete also each part that existed only for the old way:
  - a value that the new way holds and the code derives again,
  - two code paths that do the same job,
  - a mechanism whose reason the change removes.
- A test that uses the old way moves to the new way, with every assertion.
  A test that covers only the old way goes, under the removal rule of the
  `testing` skill.

## Code that moves into a component or a package

When code moves into a component or a package, the API of that component
or package is the new way. Give it the props, refs, and callbacks that
other code needs from it. Code that finds its elements through selectors,
class names, or globals is a consumer of the old way. Move that code to the
API.

## A converter for one milestone

A converter can keep the product working at the end of one milestone, as
the section "Milestones" of the `plans` skill asks. A later milestone of
the same plan then has a TODO that deletes the converter. The plan does not
complete while a converter remains.

## Consumers outside the repository

Some consumers cannot move in the same change. Examples are an export of a
published package, stored user data, and a client that is already
deployed. A converter for such a consumer is a decision for the user. Write
it as a decision of the plan, with the time when the converter goes.

## The words that show a converter

Each row quotes a real plan or module that left an old way behind.

| The record says | The answer |
| --- | --- |
| "Update the viewer's data readers and validators to the generated [...] types." | A TODO that changes only the reader leaves every other consumer on the old way. List the consumers, and move each one. |
| "Convert validated public data to the existing shell's display records." | This is a converter. Move the shell to the public data, and delete the old records. |
| "Markup and class names do not change, so the viewer's string-rendered tests and the browser specs keep passing." | Give the package props and refs. Move the tests to them, with every assertion. |
| "The embedded selector transform, the shell tokens, and the store design stay as they are." | Each part that stays on the old way is a consumer. Move it in this plan, or ask the user. |
| "Read the controller that the standalone bundle installed." | The controller existed for the server render that the change removed. Delete it with the server render. |
