#!/bin/bash

# emoji symbols
CHECK="✅"
CROSS="❌"
NA="➖"

# max width for filename column
filename_width=30

# fixed column widths
col_prereq=7      # "prereqs"
col_procedure=9   # "procedure"
col_verified=8    # "verified"
col_ar=2          # "AR"

# column format
header_format="%-${filename_width}s  %-${col_prereq}s  %-${col_procedure}s  %-${col_verified}s  %-${col_ar}s\n"

# truncate filename if too long
truncate_filename() {
    local name="$1"
    if [ ${#name} -le $filename_width ]; then
        printf "%s" "$name"
    else
        printf "%s…" "${name:0:$(($filename_width - 1))}"
    fi
}

print_header() {
    printf "$header_format" "filename" "prereqs" "procedure" "verified" "AR"
}

is_procedure_file() {
    grep -q '^:_mod-docs-content-type: PROCEDURE$' "$1"
}

parse_file() {
    local file="$1"
    local content
    content=$(<"$file")

    [[ "$content" == *$'\n.Prerequisites\n'* ]]        && prereq=$CHECK || prereq=$CROSS
    [[ "$content" == *$'\n.Procedure\n'* ]]            && procedure=$CHECK || procedure=$CROSS
    [[ "$content" == *$'\n.Verification\n'* ]]         && verification=$CHECK || verification=$CROSS
    [[ "$content" == *$'\n.Additional resources\n'* ]] && additional=$CHECK || additional=$CROSS

    echo "$prereq $procedure $verification $additional"

}

print_summary() {
    local short_name="$1"
    local prereq="$2"
    local procedure="$3"
    local verification="$4"
    local additional="$5"

    printf "$header_format" "$short_name" "$prereq" "$procedure" "$verification" "$additional"
}

main() {
    FILES=( "$@" )
    [ ${#FILES[@]} -eq 0 ] && FILES=( *.adoc )

    print_header

    for file in "${FILES[@]}"; do
        [ -f "$file" ] || continue
        short_name=$(truncate_filename "$file")

        if is_procedure_file "$file"; then
            read prereq procedure verification additional < <(parse_file "$file")
            print_summary "$short_name" "$prereq" "$procedure" "$verification" "$additional"
        else
            print_summary "$short_name" "$NA" "$NA" "$NA" "$NA"
        fi
    done
}

main "$@"
