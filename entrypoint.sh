#!/bin/bash -l

set -eo pipefail

# read tag_prefix and tag_part
tag_prefix=${INPUT_TAG_PREFIX}
tag_part=${INPUT_TAG_PART}

# throw error if tag_prefix or tag_part are not set
if [[ -z "${tag_prefix}" ]] || [[ -z "${tag_part}" ]]
then
  echo "Error: tag_prefix and tag_part inputs are required"
  exit 1
fi

echo "*** CONFIGURATION ***"
echo "  TAG_PREFIX: ${tag_prefix}"
echo "  TAG_PART: ${tag_part}"
echo

# fatal: detected dubious ownership in repository at '/github/workspace'
git config --global --add safe.directory /github/workspace

echo "*** DEBUG ***"
# DEBUG: Check git repository status
echo "DEBUG: Current directory: $(pwd)"
echo "DEBUG: Git version: $(git --version)"
echo "DEBUG: Is this a git repo? $(git rev-parse --is-inside-work-tree 2>/dev/null || echo 'NO')"
echo "DEBUG: Git status check:"
git status --short 2>/dev/null || echo "Git status failed"

# DEBUG: Check for tags with different methods
echo "DEBUG: Checking tags with different commands:"
echo "DEBUG: git tag (no options): $(git tag | wc -l) tags found"
git tag | head -5 || echo "No tags with basic git tag"

echo "DEBUG: git tag -l: $(git tag -l | wc -l) tags found"
git tag -l | head -5 || echo "No tags with git tag -l"

echo "DEBUG: git tag --list: $(git tag --list | wc -l) tags found"
git tag --list | head -5 || echo "No tags with git tag --list"

echo "DEBUG: Checking remote tags:"
git ls-remote --tags origin | head -5 || echo "Failed to get remote tags"

echo "*** RESULTS ***"

# get the tags
tags=$(git tag -l --sort=-v:refname)
echo "DEBUG: tags: ${tags}"

# get the old tag that looks like our tag
tag_format="^${tag_prefix}[0-9]+\.[0-9]+\.[0-9]+$"
echo "DEBUG: tag_format: ${tag_format}"
tag_matches=$( (grep -E "${tag_format}" <<< "${tags}") || true )
echo "DEBUG: tag_matches: ${tag_matches}"
old_tag=$(head -n 1 <<< "${tag_matches}")
echo "DEBUG: old_tag: ${old_tag}"

# if there is no tag, start at 0.0.0
if [[ -z "${old_tag}" ]]
then
    old_tag="${tag_prefix}0.0.0"
fi

old_semver=${old_tag#"${tag_prefix}"}
echo "  OLD_TAG: ${old_tag}"
echo "  OLD_SEMVER: ${old_semver}"

case "${tag_part}" in
    major ) new_semver=$(semver -i major "${old_semver}");;
    minor ) new_semver=$(semver -i minor "${old_semver}");;
    patch ) new_semver=$(semver -i patch "${old_semver}");;
    * ) echo "Error: tag_part must be one of: major, minor, or patch"; exit 1;;
esac

new_tag="${tag_prefix}${new_semver}"

echo "  NEW_TAG: ${new_tag}"
echo "  NEW_SEMVER: ${new_semver}"

# set outputs
setOutput() {
    echo "${1}=${2}" >> "${GITHUB_OUTPUT}"
}

setOutput "new_tag" "$new_tag"
setOutput "new_semver" "$new_semver"

# use git api to push
git tag -f "${new_tag}" || exit 1
git push -f origin "${new_tag}" || exit 1
