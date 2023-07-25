#!/bin/bash

# This is a totaly useless script, because the site is migrated only once.
# And when the site is migrated, we can't use this script anymore.
# So, it's not necessary to automate the migration or modification of the site.
# But, there is very fun to do it, so I do it.
# And the client don't want to pay for an useless script, so I do it for free.
# But I don't want to do it for free, so I do it for fun.
# I USE ARCH BTW

set -x
exec 2>debug.log

# Define readonly variables
readonly ROOT="$(dirname "$(dirname "$(readlink -f -- "$0")")")"
readonly TOOLS="$ROOT/tools"
readonly PUBLIC="$ROOT/pub"
readonly RAW="$ROOT/raw"
readonly DATA="$ROOT/data"
readonly NEWS="$DATA/news.json"
readonly ANNUAIRE="$DATA/annuaire.json"

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
if [[ ! -d "$RAW" ]] || [[ -z "$(ls -A "$RAW")" ]]; then
    warning "The raw directory does not exist or is empty, creating it"

    if ! mkdir -p "$RAW"; then
        fatal "Failed to create raw directory"
    fi

    wget -P "$PUBLIC" --recursive --no-clobber --page-requisites    \
        -nH --html-extension --convert-links --no-parent            \
        --local-encoding=UTF-8 --restrict-file-names=nocontrol      \
        --domains "$DOMAIN" "$URL"

    result=$?
    if [[ $result -ne 0 ]]; then
        warning "The scrapping of the site return a code '$result'"
        warning "See https://curl.se/libcurl/c/libcurl-errors.html for more details"
    fi

    jq -r '.[].Image' "$ANNUAIRE" | sed -E 's|.+src="([^"]+)".*|'"$URL"'\1|' | parallel --gnu 'wget -P "'"$PUBLIC"'" --no-clobber --recursive --no-parent -nH --restrict-file-names=nocontrol --domains "'"$DOMAIN"'" {}'
    jq -r '.[].Path' "$NEWS" | sed "s|^|$URL|" | parallel --gnu 'wget -P "'"$PUBLIC"'" --recursive --no-parent --html-extension --no-clobber --page-requisites -nH --convert-links --local-encoding=UTF-8 --restrict-file-names=nocontrol --domains "'"$DOMAIN"'" {}'
    jq -r '.[].Path' "$NEWS" | while IFS= read -r file; do 
        mv "$PUBLIC/$file.html" "$PUBLIC/$file"
        < "$PUBLIC/$file" grep -E "<a .*/Lists/" | sed -E 's|.*<a href="([^"]+)".*|\1|g' | parallel --gnu 'wget -P "'"$PUBLIC"'" --no-clobber --recursive --no-parent -nH --restrict-file-names=nocontrol --domains "'"$DOMAIN"'" {}'
    done

    curl "$URL/_layouts/15/1036/initstrings.js?rev=rqljWeAFWwNOW%2FF%2FLwdjXg%3D%3D" > "$PUBLIC/_layouts/15/1036/initstrings.js"
    curl "$URL/_layouts/15/1036/styles/Themable/corev15.css" > "$PUBLIC/_layouts/15/1036/styles/Themable/corev15.css?rev=AYgPqi8rrzekEl%2FnFu0Fow==.css"

    mkdir -p "$PUBLIC/PublishingImages/fc2a"
    curl "$URL/PublishingImages/fc2a/puce.png" > "$PUBLIC/PublishingImages/fc2a/puce.png"

    mkdir -p "$PUBLIC/PublishingImages/actualites"
    curl "$URL/PublishingImages/actualites/REG%20-%20NNE.png" > "$PUBLIC/PublishingImages/actualites/REG - NNE.png"
    curl "$URL/PublishingImages/actualites/FNA.png" > "$PUBLIC/PublishingImages/actualites/FNA.png"

    # Save the site to raw directory
    if ! cp -r "$PUBLIC/"* "$RAW/"; then
        fatal "Failed to save the site to raw directory"
    fi

    success "Saved the site to raw directory"
else
    warning "The raw directory exists and is not empty, using it"

    # Copy the site from raw directory to public directory
    if ! cp -r "$RAW/"* "$PUBLIC/"; then
        fatal "Failed to copy the site from raw directory to public directory"
    fi

    success "Copied the site from raw directory to public directory"
fi

# Fix errors in the downloaded site
while IFS= read -r -d '' file; do
    fix_error "$file" || fatal "Failed to fix errors in the downloaded site"
done < <(find "$PUBLIC" -type f -print0)
success "Fixed errors in the downloaded site"

# Update the site
while IFS= read -r -d '' file; do
    update_site "$file" || fatal "Failed to update the site"
done < <(find "$PUBLIC" -type f \( -name "*.html" -o -name "*.aspx" \) -print0)

cp "$ANNUAIRE" "$PUBLIC/annuaire.json"
f="$PUBLIC/annuaire/réseaux-économiques.html"
if ! htmlq -r 'section#pageContentSection *' -f "$f" | sponge "$f"; then
    fatal "Failed to remove the old annuaire in $f"
fi

c='<header><h1 class="h1">Réseaux économiques</h1></header><ul id="posts" class="postsList press"></ul><div style="text-align: center;"><button id="prev" style="height: auto;">Précédent</button> <span id="page-num">Page 1 / 1</span> <button id="next" style="height: auto;">Suivant</button></div><script>let currentPage=0;const pageSize=3;let data=[];function updatePageNum(){const e=document.querySelector("#page-num"),t=Math.ceil(data.length/pageSize);e.textContent=`Page ${currentPage+1} / ${t}`}function loadData(){return fetch("/annuaire.json").then((e=>e.json()))}function renderPage(){const e=currentPage*pageSize,t=e+pageSize,a=data.slice(e,t),n=document.querySelector("#posts");n.innerHTML="",updatePageNum(),a.forEach((e=>{const t=new Date(e.Date),a=`<li><div class="cbs-picture3LinesContainer">${e.Image}<div class="text"><h3 class="h2"> ${e.Title} </h3><div class="preview">${e.Content}</div><div class="cbs-pictureLine3 ms-textSmall ms-noWrap"><a class="cbs-picture3LinesLine1Link" href="${e.Link}" target="_blank"> Voir les membres des réseaux économiques </a></div></div><div class="clear"></div></div></li>`;n.innerHTML+=a}))}function handlePrev(){currentPage>0\&\&(currentPage--,renderPage())}function handleNext(){(currentPage+1)*pageSize<data.length\&\&(currentPage++,renderPage())}window.addEventListener("DOMContentLoaded",(e=>{loadData().then((e=>{data=e,renderPage()})),document.querySelector("#prev").addEventListener("click",handlePrev),document.querySelector("#next").addEventListener("click",handleNext)}));</script>'
if ! sed -i 's|id="pageContentSection">|id="pageContentSection">'"$c"'|g' "$f"; then
    fatal "Failed to add actu in $f"
fi

cp "$NEWS" "$PUBLIC/actu.json"
if ! update_actu "$PUBLIC/le-négoce-agricole/actualités.html" "$PUBLIC/actualités.html"; then
    fatal "Failed to update the actualités pages"
fi

f="$PUBLIC/index.html"
if ! htmlq -r '#WebPartWPQ5 *' -f "$f" | sponge "$f"; then
    error "Failed to remove the useless news container in $f"
fi
if ! sed -i -E 's|(<div[^>]*id="WebPartWPQ5"[^>]*>)|\1'"$(< "$DATA/accueil_news.html")"'|g' "$f"; then
    error "Failed to add the actualités in $f"
fi

if ! htmlq -r '#WebPartWPQ6 *' -f "$f" | sponge "$f"; then
    error "Failed to remove the useless fc2a container in $f"
fi
if ! sed -i -E 's|(<div[^>]*id="WebPartWPQ6"[^>]*>)|\1'"$(< "$DATA/accueil_fc2a.html")"'|g' "$f"; then
    error "Failed to add the fc2a actualités in $f"
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
c='<iframe src="https://www.google.com/maps/d/embed?mid=1Vct3pML9LcD-6y-hBotbL--zTcx0lq4\&amp;ehbc=2E312F" width="100%" height="600" style="margin-bottom: 5em;"></iframe>'
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