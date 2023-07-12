#!/bin/bash
set -x

# Define readonly variables
readonly ROOT="$(dirname "$(dirname "$(readlink -f -- "$0")")")"
readonly TOOLS="$ROOT/tools"
readonly PUBLIC="$ROOT/pub"

readonly NEW_DOMAIN="negoce-village.iglou.eu"
readonly DOMAIN="negoce-village.com"
readonly URL="http://www.$DOMAIN/"

# Import utils.sh
source "$TOOLS/utils.sh"
source "$TOOLS/editor.sh"

# Check requirements
check_requirements "command" "echo" "wget"

# Clean public directory
if ! rm -rf "${PUBLIC:?}/"*; then
    error "Failed to clean public directory"
else 
    success "Cleaned public directory"
fi

# Download the site
# wget -P "$PUBLIC" --recursive --no-clobber --page-requisites   \
    # --html-extension --convert-links --no-parent            \
    # --local-encoding=UTF-8 --restrict-file-names=nocontrol  \
    # --domains "$DOMAIN" "$URL"; then

wget -P "$PUBLIC" -nH --no-clobber --page-requisites   \
            --html-extension --convert-links --no-parent            \
            --local-encoding=UTF-8 --restrict-file-names=nocontrol  \
            --domains "$DOMAIN" "$URL"
result=$?
if [[ $result -ne 0 ]] && [[ $result -ne 8 ]]; then
    fatal "Failed to download the site"
else 
    success "The site '$URL' has been downloaded"
fi

# Fix errors in the downloaded site
while IFS= read -r -d '' file; do
    fix_error "$file" || fatal "Failed to fix errors in the downloaded site"
done < <(find "$PUBLIC" -type f -print0)
success "Fixed errors in the downloaded site"

# # Update the site
# while IFS= read -r -d '' file; do
#     update_site "$file" || fatal "Failed to update the site"
# done < <(find "$PUBLIC" -type f -name "*.html" -print0)

# Add CNAME file
if ! echo "$NEW_DOMAIN" > "$PUBLIC/CNAME"; then
    fatal "Failed to add CNAME file"
else 
    success "Added CNAME file"
fi