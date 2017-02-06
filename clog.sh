#!/bin/bash

# Generate a changelog based on git history.

##--------------------------------------------------
## parse and validate args.
##--------------------------------------------------

function _main () {
    if [ -z "$TMPDIR" ]; then
        TMPDIR=/tmp
    fi

    FROM=$(git tag --sort=refname | tail -n 1) # get last tag
    FROM_TO_DISPLAY=$FROM
    if test -z "$FROM"
    then
        FROM=$(git log --oneline --reverse --format=format:%h | head -n 1) # get 1st commit
        FROM_TO_DISPLAY="1st commit ($FROM)"
    fi
    TO="HEAD"
    TITLE=
    SHOW_WARNINGS=1

    for P in "$@"
    do
        case "$P" in
            ( -f | --from ) I='FROM';;
            ( -t | --to ) I='TO';;
            ( -i | --title ) I='TITLE';;
            ( -q | --quiet ) I='SHOW_WARNINGS';;
            ( -h | --help ) _show_help; exit 0 ;;
            ( * )
                case "$I" in
                    ( FROM ) FROM="$P";FROM_TO_DISPLAY="$FROM";;
                    ( TO ) TO="$P";;
                    ( TITLE ) TITLE="$P";;
                    ( SHOW_WARNINGS ) SHOW_WARNINGS="$P";;
                    ( * ) echo "invalid option: $P"; exit 1 ;;
                esac
                I=''
        esac
    done

    if test -z "$TITLE"
    then
        TITLE="since $FROM_TO_DISPLAY"
    fi

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
    rnotes_pattern  = "^ *<release-notes>$"
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
    printf("\n  - %s (%s by %s)", line, substr(sha1,1,7), substr(author,2));
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

    cat <(echo "$TITLE") <(grep -v '^$' ${TMPDIR}/_clog_changelog.txt) <(echo "")
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


_main "$@"
