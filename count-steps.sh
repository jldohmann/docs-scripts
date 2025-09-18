#!/bin/bash

# checks if individual files are passed as arguments; defaults to all files in directory
get_files() {
    if [ $# -eq 0 ]; then
        FILES=( *.adoc )
    else
        FILES=( "$@" )
    fi
}

# finds longest filename length for formatting and output alignment
max_filename_len(){
    local max=0
    for f in "${FILES[@]}"; do
        if [ -f "$f" ]; then
            local len=${#f}
            (( len > max )) && max=$len
        fi
    done
    MAX_LEN=$max
}

# prints header lines for output table
print_header() {
    printf "%-${MAX_LEN}s   %10s   %10s\n" "filename" "steps" "substeps"
    printf "%-${MAX_LEN}s   %10s   %10s\n" "$(printf '%.0s_' $(seq 1 $MAX_LEN))" "____" "________"
}

analyze_procedure() {
    local file="$1"
    local content
    content=$(<"$file")

    local step_count=0
    local substep_count=0
    local single_step_count=0

    # count step lines but not substeps
    step_count=$(grep -E '^\.\s+\S' <<< "$content" | grep -vE '^\.\.\s+\S' | wc -l)

    # count substeps
    substep_count=$(grep -E '^\.\.\s+\S' <<< $content | wc -l)

    # check for single-step procedure
    grep -q '^\*\s+\S' <<< "$content" && single_step_count=1

    # decide which step count to use
    if (( step_count > 0 )); then
        steps=$step_count
    else
        steps=$single_step_count
    fi

    printf "%-${MAX_LEN}s   %10d   %10d\n" "$file" "$steps" "$substep_count"
}

# if file is not a procedure, print n/a
print_row_na() {
    local file="$1"
    printf "%-${MAX_LEN}s   %10s   %10s\n" "$file" "n/a" "n/a"
}

main() {
    get_files "$@"
    max_filename_len
    print_header

    for file in "${FILES[@]}"; do
        [ -f "$file" ] || continue

        # check if file is a procedure
        if grep -q '^:_mod-docs-content-type: PROCEDURE$' "$file"; then
            analyze_procedure "$file"
        else
            print_row_na "$file"
        fi
    done
}

main "$@"
