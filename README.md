# Trelnex.MonoTag

A GitHub action to automatically bump semantic version tags with a configurable prefix.

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

- **tag_prefix** (required) - The prefix to prepend to the tag.
- **tag_part** (required) - The part of the semantic version to bump. Must be one of: major, minor, or patch.

## Outputs

- **new_tag** - The newly created tag.
- **new_semver** - The newly created semantic version.
