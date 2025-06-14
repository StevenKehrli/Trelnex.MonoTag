# Trelnex.MonoTag

A GitHub action to automatically bump semantic version tags with configurable prefixes for monorepo projects.

## Usage

```yaml
      - name: bump version and push tag
        if: (github.ref == 'refs/heads/main')
        id: tag_version
        uses: StevenKehrli/Trelnex.MonoTag@v1.0.0
        with:
          tag_prefix: 'trelnex-core-'
          tag_part: 'minor'
```

## Inputs

- **tag_prefix** (required) - The prefix for the tag name (e.g., "trelnex-core-" will create tags like "trelnex-core-1.2.3")..
- **tag_part** (required) - The part of the semantic version to bump. Must be one of: 'major', 'minor', or 'patch'.

## Outputs

- **new_tag** - The complete new tag that was created (including prefix).
- **new_semver** - The semantic version portion of the new tag (without prefix).

## How it works

1. Fetches all existing tags from the repository
2. Finds the latest tag matching the specified prefix format (`prefix-X.Y.Z`)
3. Bumps the specified part of the semantic version
4. Creates and pushes the new tag to the repository

## Requirements

- The action requires write permissions to the repository to create and push tags
- Tags must follow semantic versioning format with the specified prefix
