#!/bin/bash

# This is a totaly useless script, because the site is migrated only once.
# And when the site is migrated, we can't use this script anymore.
# So, it's not necessary to automate the migration or modification of the site.
# But, there is very fun to do it, so I do it.
# And the client don't want to pay for an useless script, so I do it for free.
# But I don't want to do it for free, so I do it for fun.
# I USE ARCH BTW

set -x

# Define readonly variables
readonly ROOT="$(dirname "$(dirname "$(readlink -f -- "$0")")")"
readonly TOOLS="$ROOT/tools"
readonly PUBLIC="$ROOT/pub"
readonly NEWS="$ROOT/data_news.json"

readonly NEW_DOMAIN="negoce-village.iglou.eu"
readonly DOMAIN="negoce-village.com"
readonly URL="http://www.$DOMAIN/"

# Import utils.sh
source "$TOOLS/utils.sh"
source "$TOOLS/editor.sh"

# Check requirements
check_requirements "command" "echo" "curl" "wget" "sponge" "htmlq" "parallel" "jq" "sed"

# Clean public directory
if ! rm -rf "${PUBLIC:?}/"*; then
    error "Failed to clean public directory"
else 
    success "Cleaned public directory"
fi

# Download the site
wget -P "$PUBLIC" --recursive --no-clobber --page-requisites    \
    -nH --html-extension --convert-links --no-parent            \
    --local-encoding=UTF-8 --restrict-file-names=nocontrol      \
    --domains "$DOMAIN" "$URL"

result=$?
if [[ $result -ne 0 ]]; then
    warning "The scrapping of the site return a code '$result'"
    warning "See https://curl.se/libcurl/c/libcurl-errors.html for more details"
fi

jq -r '.[].Path' "$NEWS" | sed "s|^|$URL|" | parallel --gnu 'wget -P "'"$PUBLIC"'" --recursive --no-parent --html-extension --no-clobber --page-requisites -nH --convert-links --local-encoding=UTF-8 --restrict-file-names=nocontrol --domains "'"$DOMAIN"'" {}'
jq -r '.[].Path' "$NEWS" | while IFS= read -r file; do 
    mv "$PUBLIC/$file.html" "$PUBLIC/$file"
    < "$PUBLIC/$file" grep -E "<a .*/Lists/" | sed -E 's|.*<a href="([^"]+)".*|\1|g' | parallel --gnu 'wget -P "'"$PUBLIC"'" --no-clobber --recursive --no-parent -nH --restrict-file-names=nocontrol --domains "'"$DOMAIN"'" {}'
done

curl "$URL/_layouts/15/1036/initstrings.js?rev=rqljWeAFWwNOW%2FF%2FLwdjXg%3D%3D" > "$PUBLIC/_layouts/15/1036/initstrings.js"

# Fix errors in the downloaded site
while IFS= read -r -d '' file; do
    fix_error "$file" || fatal "Failed to fix errors in the downloaded site"
done < <(find "$PUBLIC" -type f -print0)
success "Fixed errors in the downloaded site"

# Update the site
while IFS= read -r -d '' file; do
    update_site "$file" || fatal "Failed to update the site"
done < <(find "$PUBLIC" -type f \( -name "*.html" -o -name "*.aspx" \) -print0)

cp "$NEWS" "$PUBLIC/actu.json"
if ! update_actu "$PUBLIC/le-négoce-agricole/actualités.html" "$PUBLIC/actualités.html"; then
    fatal "Failed to update the actualités pages"
fi

f="$PUBLIC/contact.html"
if ! htmlq -r 'div.content.fna_map' -f "$f" | sponge "$f"; then
    fatal "Failed to remove the map in $f"
else 
    success "Contact page updated"
fi

f="$PUBLIC/annuaire/annuaire-des-adhérents.html"
if ! htmlq -r 'section.annuaire>div' -f "$f" | sponge "$f"; then
    fatal "Failed to remove the map in $f"
fi

c='<iframe src="https://www.google.com/maps/d/embed?mid=1jeDL9eOVTDmLu9ii4BR_KnWksaSJEyY\&amp;ehbc=2E312F" width="100%" height="600" style="margin-bottom: 5em;"></iframe>'
if ! sed -i -E ':a;N;$!ba;s|/header>[\n ]*</section|/header>\n'"$c"'\n</section|' "$f"; then
    fatal "Failed to add the map in $f"
else 
    success "Index page updated"
fi

# Add CNAME file
if ! echo "$NEW_DOMAIN" > "$PUBLIC/CNAME"; then
    fatal "Failed to add CNAME file"
else 
    success "Added CNAME file"
fi