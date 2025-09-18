#!/bin/bash

# color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # no color

is_procedure_file() {
    grep -q '^:_mod-docs-content-type: PROCEDURE$' "$1"
}

# strips comments/metadata from beginning of file
strip_comments() {
    sed '/^\/\//d' "$1"
}

# checks if procedure has these required sections first
has_required_sections() {
    echo "$1" | grep -qE '^\.(Procedure|Prerequisites)'
}

# extracts content between title heading and either prereq section or procedure section
# whichever section appears first
extract_info_section() {
    echo "$1" | awk '
        BEGIN { found_title = 0 }
        /^= / { found_title = 1 }
        found_title {
            if (/^\.(Procedure|Prerequisites)/) exit
            print
        }
'
}

# removces metadata, headings, and blank lines
clean_intro() {
    echo "$1" | grep -Ev '^\[.*\]|^=|^\.Prerequisites|^\.Procedure|^$'
}

# collapses into one line for more accuracy and counts
count_sentences() {
    echo "$1" | tr '\n' ' ' | grep -oE '\.' | wc -l
}

analyze_file() {
    local file="$1"
    [[ ! -f "$file" ]] && return

    if is_procedure_file "$file"; then
        local content
        content=$(strip_comments "$file")

        if ! has_required_sections "$content"; then
            echo -e "${RED}${file} : MISSING .Procedure and .Prerequisites section${NC}"
            return
        fi

        local intro_section
        intro_section=$(extract_info_section "$content")

        local cleaned_intro
        cleaned_intro=$(clean_intro "$intro_section")

        local sentence_count
        sentence_count=$(count_sentences "$cleaned_intro")

        # if it is not minimum 2 sentences, then it is not valid short description per CCS guidelines
        if [[ "$sentence_count" -lt 2 ]]; then
            echo -e "${RED}${file} : MISSING or too-short intro \nSee https://redhat-documentation.github.io/supplementary-style-guide/#shortdesc for more information${NC}"
        else
            echo -e "${GREEN}${file} : Contains valid short desc${NC}"
        fi
    fi
}

main() {
    if [[ $# -gt 0 ]]; then
        # pass arguments
        # e.g. ./check-intros.sh file1.adoc file2.adoc
        for file in "$@"; do
            analyze_file "$file"
        done
    else
        # read from stdin
        # e.g. cat list.txt | ./check-intros.sh
        while IFS= read -r file; do
            analyze_file "$file"
        done
    fi
}

main "$@"
