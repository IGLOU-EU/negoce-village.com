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

update_site() {
    if [ $# -ne 1 ]; then
        error "Usage: fixerror <file>"
        return $FAILURE
    fi

    local file="$1"
    local linkedin='<li class="linkedin"><a href="https://www.facebook.com/laFC2A" target="_blank" style="width:auto" title="Page LinkedIn de la FC2A"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" data-supported-dps="24x24" fill="currentColor" class="mercado-match" width="24" height="24" focusable="false"><path d="M20.5 2h-17A1.5 1.5 0 002 3.5v17A1.5 1.5 0 003.5 22h17a1.5 1.5 0 001.5-1.5v-17A1.5 1.5 0 0020.5 2zM8 19H5v-9h3zM6.5 8.25A1.75 1.75 0 118.3 6.5a1.78 1.78 0 01-1.8 1.75zM19 19h-3v-4.74c0-1.42-.6-1.93-1.38-1.93A1.74 1.74 0 0013 14.19a.66.66 0 000 .14V19h-3v-9h2.9v1.3a3.11 3.11 0 012.7-1.4c1.55 0 3.36.86 3.36 3.66z"></path></svg></a></li>'

    if ! sed -i -E 's|<ul class="socialLinks">|<ul class="socialLinks">'"$linkedin"'|g' "$file"; then
        error "Failed to add linkedin in '$file'"
    fi

    if ! htmlq -r 'li.facebook' -r 'li.dailymotion' -f "$file" | sponge "$file"; then
        error "Failed to remove facebook in '$file'"
    fi

    if ! htmlq -r 'div#SearchBox' -f "$file" | sponge "$file"; then
        error "Failed to remove searchbox in '$file'"
    fi
}