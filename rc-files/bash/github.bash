#!/bin/bash

function _lookup_git_user {
    case "$1" in
        bob)     echo bobs-github-name;;
        sue)     echo sues-github-name;;
        *)
            echo >&2 "user '$1' not found"
            return 1
            ;;
    esac
}

function _lookup_github_remote() (
    # confirm the remote exists -- could do some mapping here if necessary
    remote="$user/$repo"
    git ping "git@github.com:$remote" && { echo "$remote"; return 0; }
    echo >&2 "no remote found for '$remote'"
    return 1
)

function g {
    repo=my_repo_name  # might want to have this as an arg in the future
    cd ~/dev/"$repo" || return 1
    case "$1" in
        add)
            name=$2
            user=$(_lookup_git_user "$name") || return 1
            remote=$(_lookup_github_remote "$user" "$repo") || return 1

            git remote add "$name" "git@github.com:$remote"
            git remote set-url --push "$name" DISALLOWED
            ;;
        disable)
            name=$2

            git remote set-url --push "$name" DISALLOWED
            ;;
        enable)
            name=$2
            user=$(_lookup_git_user "$name") || return 1
            remote=$(_lookup_github_remote "$user" "$repo") || return 1

            git remote set-url --push "$name" "git@github.com:$remote"
            ;;
        hub)
            # open the github webpage for a remote
            name=$2
            user=$(_lookup_git_user "$name") || return 1
            remote=$(_lookup_github_remote "$user" "$repo") || return 1
            open -a '/Applications/Google Chrome.app' "https://github.com/$remote"
            ;;
        *)
            # just cd to the directory
            ;;
    esac
}
