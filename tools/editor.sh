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
            # So much errors in this microsoft sharepoint site... I can't fix it without breaking it...
            # sed -i -E -e 's/&#39;/\x27/g' -e 's/&#34;/\x22/g' -e 's/&quot;/\x22/g' \
            #     "$file" || status=$FAILURE
            # < "$file" recode html..utf8 | sponge "$file" || status=$FAILURE
            # sed -i -E 's/"([^":]+\.(css|js|axd))(%3F|\?)[^"]*"/"\1"/g' \
            #     "$file" || status=$FAILURE
            # < "$file" perl -MHTML::Entities -CSD -pe 'decode_entities($_)' | sponge "$file" || status=$FAILURE
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
    local css='<style type="text/css">#mainNav.type1 ul li ul.submenu {left: auto !important}body{overflow: auto !important}#s4-workspace{width: auto !important;height: auto !important}@media screen and (max-width:1000px){#footer .span{width:auto;height:auto;padding:0}#footerTop{width:auto;display:grid;grid-template-columns:repeat(2,1fr)}#footerInfos{grid-column:span 2}ul.socialLinks{margin:auto;width:fit-content}#footer .span.last{grid-column:span 2;text-align:center;width:auto;padding-top:1em}#mainNav > .menutoggle{color:#fff;font-weight:700;margin:0 1em 0 0 !important;padding:.25em!important;display:block!important;border-width:0 2px 0 0;border-style:solid;cursor:pointer}#mainNav.open > .menutoggle{border-width:0 2px 2px 0}.pageInner > *{padding:0 1em!important;float:unset!important;width:fit-content!important;margin:auto!important}.pageInner{width:100vw!important;display:grid;gap:.5em}.linkedin:hover svg{fill:#0e76a8}#mainNav ul > li.static,#mainNav ul > li.static > a{height:auto!important;display:block!important;text-align:left!important}#mainNav ul{float:unset!important}#zz1_TopNavigationMenu{display:block!important}#DeltaTopNavigation{display:none!important;float:unset!important;position:unset!important;margin-top:1em!important}#mainNav.open #DeltaTopNavigation{display:block!important}#mainNav{display:block!important;height:auto!important;border-width:0 0 2px!important}ul.dynamic{position:relative!important;display:none!important;left:unset!important;top:unset!important;float:unset!important}}.royalSlider.topSlider{top:unset!important}.menutoggle{display:none!important}</style>'
    local js='<script>document.addEventListener("DOMContentLoaded",function(){var e=document.querySelector("#mainNav"),t=document.createElement("span");t.classList.add("menutoggle"),t.textContent="Menu",e.insertBefore(t,e.firstChild),t.addEventListener("click",function(){e.classList.contains("open")?(e.classList.remove("open"),e.classList.add("close"),t.textContent="Menu"):(e.classList.remove("close"),e.classList.add("open"),t.textContent="Fermer")});for(var n=document.querySelectorAll("li.static.dynamic-children > a"),s=0;s<n.length;s\+\+){var a=n[s].parentNode.querySelector("ul.dynamic");console.log("links: "\+n[s]\+" submenus: "\+a\+" parent: "\+n[s].parentNode.className),a\&\&n[s].addEventListener("click",function(e){e.preventDefault()})}});</script>'
    local linkedin='<li class="linkedin"><a href="https://fr.linkedin.com/company/federationnegoceagricole" target="_blank" style="width:auto" title="Page LinkedIn de la FC2A"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" data-supported-dps="24x24" fill="currentColor" class="mercado-match" width="24" height="24" focusable="false"><path d="M20.5 2h-17A1.5 1.5 0 002 3.5v17A1.5 1.5 0 003.5 22h17a1.5 1.5 0 001.5-1.5v-17A1.5 1.5 0 0020.5 2zM8 19H5v-9h3zM6.5 8.25A1.75 1.75 0 118.3 6.5a1.78 1.78 0 01-1.8 1.75zM19 19h-3v-4.74c0-1.42-.6-1.93-1.38-1.93A1.74 1.74 0 0013 14.19a.66.66 0 000 .14V19h-3v-9h2.9v1.3a3.11 3.11 0 012.7-1.4c1.55 0 3.36.86 3.36 3.66z"></path></svg></a></li>'

    if ! sed -i 's|href="http://www.negoce-centre-atlantique.com/"|href="http://www.negoce-centre-atlantique.com/" target="_blank"|g' "$file"; then
        error "Failed to add target in '$file'"
    fi

    if ! sed -i 's|</head>|'"$css$js"'</head>|g' "$file"; then
        error "Failed to add custom css and js in '$file'"
    fi

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
