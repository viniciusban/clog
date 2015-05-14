#!/bin/bash

# Generate a changelog based on git history.

##--------------------------------------------------
## parse and validate args.
##--------------------------------------------------

function _main () {
    if [ -z "$TMPDIR" ]; then
        TMPDIR=/tmp
    fi

    FROM=$(git tag --sort=refname | tail -n 1)
    TO="HEAD"
    TITLE="since $FROM"
    SHOW_WARNINGS=1

    while [ -n "$1" ]; do
        case "$1" in
            ( -f | --from ) FROM="$2"; shift ;;
            ( -t | --to ) TO="$2"; shift ;;
            ( -i | --title ) TITLE="$2"; shift ;;
            ( -q | --quiet ) SHOW_WARNINGS=; shift ;;
            ( -h | --help ) _show_help; exit 0 ;;
            ( * ) echo "invalid option: $1"; exit 1 ;;
        esac
        shift
    done

##--------------------------------------------------
## prepare for running
##--------------------------------------------------

    rm -f ${TMPDIR}/_clog*


##--------------------------------------------------
## showtime!
##--------------------------------------------------

    git log --reverse --grep='\([cC]lose[sd]\?\|[fF]ix\(e[sd]\?\)\?\|[rR]esolve[sd]\?\) #[0-9]' ${FROM}..${TO} | awk '\
function get_after_matched () {
# simulate non-greedy regex because sub() patterns are greedy.
    return substr(line, RSTART+RLENGTH-2);
}

BEGIN {
    all_patterns    = "([cC]lose[sd]?|[fF]ix(e[sd]?)?|[rR]esolve[sd]?) #[0-9]"
    rnotes_pattern  = ".*<release-notes>.*"
}

$1 == "commit" { sha1=$2; }

$1 == "Author:" {
    author=$NF;
    sub(/@.*/, "", author);
}

{ line = $0; }

match(line, all_patterns) { line = get_after_matched(); }
match(line, rnotes_pattern) { printf(" *rnotes*"); }

line != $0 {
    printf("  - %s (%s by %s)\n", line, substr(sha1,1,7), substr(author,2));
}
' > ${TMPDIR}/_clog_changelog.txt

    if [ -n "$SHOW_WARNINGS" ]; then
        grep -o -e '#[0-9]\+' ${TMPDIR}/_clog_changelog.txt > ${TMPDIR}/_clog_tickets.txt
        HOWMANY_TICKETS=$(wc -l ${TMPDIR}/_clog_tickets.txt | awk '{print $1}')
        HOWMANY_UNIQUE_TICKETS=$(sort -u ${TMPDIR}/_clog_tickets.txt | wc -l | awk '{print $1}')
        if [ "${HOWMANY_TICKETS}" != "${HOWMANY_UNIQUE_TICKETS}" ]; then
            echo "** Warning: Check the generated changelog. You possibly closed the same ticket twice." >&2
        fi
    fi

    cat <(echo "$TITLE") ${TMPDIR}/_clog_changelog.txt <(echo "")
}


function _show_help () {
    echo "
Usage: $(basename $0) <options>

Generate changelog from your git history.

Options:
    -f | --from <initial revision>
        Get commit messages from <initial revision>. It can be a commit SHA1 or a tag.
        If omitted, assumes last tag in lexicographic order.

    -t | --to <final revision>
        Get commit messages until <final revision>. It can be a commit SHA1, a tag or HEAD.
        Assumes "HEAD" if omitted.

    -i | --title  <text>
        Puts <text> as title.

    -q | --quiet
        Don't show warning messages.
"
}


_main $@
