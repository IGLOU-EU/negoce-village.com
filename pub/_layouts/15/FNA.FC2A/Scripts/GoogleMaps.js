var map
var marker;
var map_canvas_ClientID;
var map_search_adr;
var map_lat;
var map_lng;
var map_results_description;
var map_results_intitule;

//infobulle
var infowindow = new google.maps.InfoWindow();

//init map after windows loaded
google.maps.event.addDomListener(window, 'load', initializeMap);

function initializeMap() {
    initMapControls();
    //alert('map_canvas_ClientID: ' + map_canvas_ClientID);
    //default centering map
    var FranceLatlng;
    if (map_lat != '' && map_lng != '')
        FranceLatlng = new google.maps.LatLng(map_lat, map_lng);
    else
        FranceLatlng = new google.maps.LatLng(48.862035, 2.349674);

    var myOptions = {
        zoom: 14,
        center: FranceLatlng,
        mapTypeId: google.maps.MapTypeId.ROADMAP
    }

    map = new google.maps.Map(document.getElementById(map_canvas_ClientID), myOptions);
    //places = new google.maps.places.PlacesService(map);

    if (map_search_adr != '') {
        var geocoder = new google.maps.Geocoder();
        geocoder.geocode({ 'address': map_search_adr }, function (results, status) {
            if (status == google.maps.GeocoderStatus.OK) {
                infowindow.close();
                var place = results[0];
                // If the place has a geometry, then present it on a map.
                if (place.geometry.viewport) {
                    map.fitBounds(place.geometry.viewport);
                } else {
                    map.setCenter(place.geometry.location);
                    map.setZoom(17);  // Why 17? Because it looks good.
                }
                map.setZoom(17);  // Why 17? Because it looks good.

                marker = new google.maps.Marker({
                    map: map,
                    position: place.geometry.location,
                    animation: google.maps.Animation.DROP
                });

                google.maps.event.addListener(marker, 'click', toggleBounce);

                marker.setPosition(place.geometry.location);

                infowindow.setContent(getIWContent(place, map_search_adr));
                infowindow.open(map, marker);
            }
        });
    }
}
function toggleBounce() {
    if (marker.getAnimation() != null) {
        marker.setAnimation(null);
        infowindow.open(map, marker);
    } else {
        infowindow.close();
        marker.setAnimation(google.maps.Animation.BOUNCE);
    }
}
function getIWContent(place, address) {
    var content = "";

    if (!place.geometry) {
        return '<div><strong>' + place.name + '</strong><br>' + address;
    }

    if (place.address_components) {
        address = [
  (place.address_components[0] && place.address_components[0].short_name || ''),
  (place.address_components[1] && place.address_components[1].short_name || ''),
  (place.address_components[2] && place.address_components[2].short_name || '')
        ].join(' ');
    }

    content += '<div class="bulleTitle"><strong>';
    if (map_results_intitule != '') {
        content += '<a>' + map_results_intitule + '</a>';
    }
    else {
        content += '<a>' + place.name + '</a>';
    }
    content += '</strong><br />';
    content += '<div class="bulleInfo">' + address;
    if (map_results_description != '') {
        content += '<br />' + map_results_description;
    }
    content += '</div></div>';
    return content;
}