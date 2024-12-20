# Trelnex.MonoTag

A GitHub action for monorepos to automatically bump the semantic version and tag based on the project path, tag prefix, and commit log.

## Usage

```yaml
      - name: bump version and push tag
        if: (github.ref == 'refs/heads/main')
        id: tag_version
        uses: StevenKehrli/Trelnex.MonoTag@v1.0.0
        with:
          project_path: 'Trelnex.Core'
          tag_prefix: 'trelnex-core-'
```

## Inputs

- **project_path** - The path to the project directory.
- **tag_prefix** - The prefix to prepend to the tag.
- **default_bump** - The part of the semantic version to bump by default. Default: minor.
- **major_token** - The commit message token to bump the major semantic version. Default: #major.
- **minor_token** - The commit message token to bump the minor semantic version. Default: #minor.
- **patch_token** - The commit message token to bump the patch semantic version. Default: #patch.

## Outputs

- **new_tag** - The newly created tag.
- **new_semver** - The newly created semantic version.
- **part** - The part of the semantic version that was bumped.
