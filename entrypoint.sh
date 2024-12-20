#!/bin/bash -l

set -eo pipefail

# read project_path and tag_prefix
project_path=${INPUT_PROJECT_PATH}
tag_prefix=${INPUT_TAG_PREFIX}

# throw error if project_path or tag_prefix are not set
if [[ -z "$project_path" ]] || [[ -z "$tag_prefix" ]]
then
  echo "Error: project_path and tag_prefix inputs are required"
  exit 1
fi

# read remaining inputs
default_bump=${INPUT_DEFAULT_BUMP:-minor}

major_token=${INPUT_MAJOR_TOKEN:-#major}
minor_token=${INPUT_MINOR_TOKEN:-#minor}
patch_token=${INPUT_PATCH_TOKEN:-#patch}

# fatal: detected dubious ownership in repository at '/github/workspace'
git config --global --add safe.directory /github/workspace

setOutput() {
    echo "${1}=${2}" >> "${GITHUB_OUTPUT}"
}

echo "*** CONFIGURATION ***"
echo "  PROJECT_PATH: ${project_path}"
echo "  TAG_PREFIX: ${tag_prefix}"
echo "  DEFAULT_BUMP: ${default_bump}"
echo "  MAJOR_STRING_TOKEN: ${major_token}"
echo "  MINOR_STRING_TOKEN: ${minor_token}"
echo "  PATCH_STRING_TOKEN: ${patch_token}"
echo

cd "${GITHUB_WORKSPACE}/${PROJECT_PATH}/." || exit 1

echo "*** RESULTS ***"

# get the tags
tags=$(git tag -l --sort=-v:refname)

# get the old tag that looks like our tag
tag_format="^${tag_prefix}[0-9]+\.[0-9]+\.[0-9]+$"
tag_matches=$( (grep -E "${tag_format}" <<< "${tags}") || true)
old_tag=$(head -n 1 <<< "${tag_matches}")

# get commit hash for old tag
# if there is no tag, start at 0.0.0
if [[ -z "${old_tag}" ]]
then
    old_tag="${tag_prefix}0.0.0"
    old_commit=$(git rev-list --max-parents=0 HEAD)
else
    old_commit=$(git rev-list -n 1 "${old_tag}")
fi

echo "  OLD_TAG: ${old_tag}"
echo "  OLD_COMMIT: ${old_commit}"

# get new commit hash
new_commit=$(git rev-parse HEAD)
echo "  NEW_COMMIT: ${new_commit}"

log=$(git log "${old_commit}".."${new_commit}" --format=%B -- ${project_path})

old_semver=${old_tag#"${tag_prefix}"}

case "${log}" in
    *$major_token* ) new_semver=$(semver -i major "${old_semver}"); part="major";;
    *$minor_token* ) new_semver=$(semver -i minor "${old_semver}"); part="minor";;
    *$patch_token* ) new_semver=$(semver -i patch "${old_semver}"); part="patch";;
    * ) new_semver=$(semver -i "${default_bump}" "${old_semver}"); part=${default_bump};;
esac

new_semver="${new_semver}"
new_tag="${tag_prefix}${new_semver}"

echo "  NEW_TAG: ${new_tag}"
echo "  NEW_SEMVER: ${new_semver}"
echo "  PART: ${part}"

# set outputs
setOutput "new_tag" "$new_tag"
setOutput "new_semver" "$new_semver"
setOutput "part" "$part"

# use git api to push
git tag -f ${new_tag} ${commit} || exit 1
git push -f origin "${new_tag}" || exit 1
