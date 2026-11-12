#!/usr/bin/env bash
set -Eeuo pipefail

# Triggers .github/workflows/ios.yml on GitHub, waits for it, and downloads the
# unsigned IPA into the current directory.
#
# GitLab remains the authoritative remote (`origin`). This script talks to the
# GitHub mirror instead, using a remote named `github` by default. Add it later:
#
#   git remote add github git@github.com:OWNER/iKITT.git
#   git push github master
#
# Override the remote name with GITHUB_REMOTE if needed:
#
#   GITHUB_REMOTE=my-github ./build-ipa.sh
#
# Extra arguments are passed to `gh workflow run` (for example --ref BRANCH).
#
# Run from this directory:
#   ./build-ipa.sh
WORKFLOW="ios.yml"
ARTIFACT="iKITT-unsigned-ipa"
GITHUB_REMOTE="${GITHUB_REMOTE:-github}"
DOWNLOAD_DIR=""
TEMP_OUTPUT=""

cleanup() {
    if [[ -n "$DOWNLOAD_DIR" && -d "$DOWNLOAD_DIR" ]]; then
        rm -rf -- "$DOWNLOAD_DIR"
    fi

    if [[ -n "$TEMP_OUTPUT" && -f "$TEMP_OUTPUT" ]]; then
        rm -f -- "$TEMP_OUTPUT"
    fi
}
trap cleanup EXIT

github_repo_from_url() {
    local url="${1%/}"
    url="${url%.git}"

    case "$url" in
        git@github.com:*) printf '%s\n' "${url#git@github.com:}" ;;
        ssh://git@github.com/*) printf '%s\n' "${url#ssh://git@github.com/}" ;;
        https://github.com/*) printf '%s\n' "${url#https://github.com/}" ;;
        http://github.com/*) printf '%s\n' "${url#http://github.com/}" ;;
        git://github.com/*) printf '%s\n' "${url#git://github.com/}" ;;
        *) return 1 ;;
    esac
}

if ! GITHUB_URL=$(git remote get-url "$GITHUB_REMOTE" 2>/dev/null); then
    # A repository that uses GitHub as origin still works without an extra remote.
    if ORIGIN_URL=$(git remote get-url origin 2>/dev/null) && [[ "$ORIGIN_URL" == *github.com* ]]; then
        GITHUB_URL="$ORIGIN_URL"
        GITHUB_REMOTE="origin"
    else
        cat >&2 <<EOF
Error: GitHub remote '$GITHUB_REMOTE' not found.

GitLab remains the authoritative origin. Add the GitHub mirror with:

    git remote add github git@github.com:OWNER/iKITT.git
    git push github master

Then run this script again.
EOF
        exit 1
    fi
fi

if ! REPO=$(github_repo_from_url "$GITHUB_URL"); then
    echo "Error: remote '$GITHUB_REMOTE' is not a GitHub URL: $GITHUB_URL" >&2
    exit 1
fi

if [[ "$REPO" != */* || "$REPO" == */*/* ]]; then
    echo "Error: could not determine OWNER/REPO from $GITHUB_URL" >&2
    exit 1
fi

echo "GitHub repository: $REPO (remote: $GITHUB_REMOTE)"

# Check GitHub CLI authentication.
gh auth status --hostname github.com >/dev/null

# Remember the latest run before triggering a new one.
PREVIOUS_RUN=$(gh run list \
    --repo "$REPO" \
    --workflow "$WORKFLOW" \
    --event workflow_dispatch \
    --limit 1 \
    --json databaseId \
    --jq '.[0].databaseId // empty')

echo "Starting iOS IPA workflow..."

gh workflow run "$WORKFLOW" --repo "$REPO" "$@"

# Wait for the newly triggered run to appear.
echo "Waiting for workflow run..."

RUN_ID=""

for i in {1..60}; do
    RUN_ID=$(gh run list \
        --repo "$REPO" \
        --workflow "$WORKFLOW" \
        --event workflow_dispatch \
        --limit 1 \
        --json databaseId \
        --jq '.[0].databaseId // empty')

    if [[ -n "$RUN_ID" && "$RUN_ID" != "$PREVIOUS_RUN" ]]; then
        break
    fi

    sleep 2
done

if [[ -z "$RUN_ID" || "$RUN_ID" == "$PREVIOUS_RUN" ]]; then
    echo "Error: Could not find the new workflow run." >&2
    exit 1
fi

echo "Workflow run: $RUN_ID"
echo "Monitoring progress..."

# Watch until completion. Exit if the workflow fails.
if ! gh run watch --repo "$REPO" --interval 1 "$RUN_ID" --exit-status; then
    echo "Workflow failed!" >&2
    exit 1
fi

echo "Workflow completed successfully."

# Create a unique temporary download directory.
DOWNLOAD_DIR=$(mktemp -d)

echo "Downloading artifact: $ARTIFACT"

gh run download --repo "$REPO" "$RUN_ID" \
    --name "$ARTIFACT" \
    --dir "$DOWNLOAD_DIR"

# Find IPA files (compatible with Bash 3.2 and newer).
IPA_FILES=()

while IFS= read -r -d '' file; do
    IPA_FILES+=("$file")
done < <(find "$DOWNLOAD_DIR" -type f -iname '*.ipa' -print0)

if [[ ${#IPA_FILES[@]} -eq 0 ]]; then
    echo "Error: No IPA file found in downloaded artifact." >&2
    exit 1
fi

if [[ ${#IPA_FILES[@]} -gt 1 ]]; then
    echo "Error: Multiple IPA files found:" >&2
    printf '  %s\n' "${IPA_FILES[@]}" >&2
    exit 1
fi

IPA="${IPA_FILES[0]}"
OUTPUT="./$(basename -- "$IPA")"

# Copy to a temporary file alongside the destination.
# This ensures the final replacement happens atomically.
TEMP_OUTPUT=$(mktemp "${OUTPUT}.XXXXXX")

cp -- "$IPA" "$TEMP_OUTPUT"

mv -f -- "$TEMP_OUTPUT" "$OUTPUT"
TEMP_OUTPUT=""

echo
echo "IPA successfully downloaded: $OUTPUT"
