#!/bin/bash

# fix errors in the downloaded site
fix_error() {
    if [ $# -ne 1 ]; then
        error "Usage: fixerror <file>"
        return $FAILURE
    fi

    local file="$1"
    local status=$SUCCESS

    case "$file" in 
        *.html)
            sed -i -E -e 's/&#39;/\x27/g' -e 's/&#34;/\x22/g' -e 's/&quot;/\x22/g' \
                "$file" || status=$FAILURE
            # sed -i -E 's/"([^":]+\.(css|js|axd))(%3F|\?)[^"]*"/"\1"/g' \
            #     "$file" || status=$FAILURE
            ;;
        *.css)
            sed -i -E ':a;N;$!ba;s/,\s*\{/ {/g' "$file" || status=$FAILURE
            ;;
        *)
            return $SUCCESS
            ;;
    esac

    if [[ $status -eq $FAILURE ]]; then
        error "Failed to fix errors in '$file'"
    fi

    if ! sed -i 's/Microsoft SharePoint/Custom Import/gi' "$file"; then
        error "Failed to fix generator in '$file'"
    fi

    if ! sed -i 's|http://www.negoce-village.com/|/|g' "$file"; then
        error "Failed to fix urls in '$file'"
    fi

    if ! sed -i 's/"http:\\u002f\\u002fwww.negoce-village.com"/protocol + "\\u002f\\u002f" + domainName/g' "$file"; then
        error "Failed to fix js urls in '$file'"
    fi

    # This is not optimal, but it works and view the state of the site, it is not necessary to optimize it...
    if ! sed -i 's|<head>|<head><script type="text/javascript">\nvar protocol = window.location.protocol;\nvar domainName = window.location.hostname;</script>|g' "$file"; then
        error "Failed to add proto and domain in '$file'"
    fi

    return $status
}