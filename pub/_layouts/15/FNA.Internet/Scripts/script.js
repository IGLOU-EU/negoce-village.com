
    var slider_args = {
        arrowsNavAutoHide: false,
        keyboardNavEnabled: true,
        imageAlignCenter: false,
        controlNavigation: 'bullets',
        autoScaleSlider: false,
        slidesSpacing: 0,
        imageScalePadding: 0,
        loop: true,
        deeplinking: {
            enabled: false
        },
        autoPlay: {
            enabled: true,
            pauseOnHover: true,
            delay: 4000
        }
    };
    
    var videos_slider_args = {
        arrowsNav: false,
        fadeinLoadedSlide: true,
        controlNavigationSpacing: 0,
        controlNavigation: 'thumbnails',

        thumbs: {
          autoCenter: false,
          fitInViewport: true,
          orientation: 'horizontal',
          spacing: 0,
          paddingBottom: 0
        },
        keyboardNavEnabled: true,
        imageScaleMode: 'fill',
        imageAlignCenter:true,
        slidesSpacing: 0,
        loop: false,
        loopRewind: true,
        numImagesToPreload: 3,
        video: {
          autoHideArrows:true,
          autoHideControlNav:false,
          autoHideBlocks: true,
          youTubeCode: '<iframe src="http://www.youtube.com/embed/%id%?rel=1&autoplay=1&showinfo=0" frameborder="no"></iframe>',
          vimeoCode: '<iframe src="http://player.vimeo.com/video/%id%?byline=0&amp;portrait=0&amp;autoplay=1" frameborder="no" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>'
        }, 
        autoScaleSlider: true, 
        autoScaleSliderWidth: 626,     
        autoScaleSliderHeight: 387,

        imgWidth: 626,
        imgHeight: 387
    };
     
    function setCurrentTab(tabId){
        $('#'+tabId).parents('.tabsContent').find('.tabContent').hide();
        $('#'+tabId).parents('.tabsContent').find('.tabs a').removeClass('current');
        $('#'+tabId).addClass('current');
        $('#'+tabId).parents('.tabsContent').find('.tabContent.'+tabId).fadeIn(300);
    }
    
    $(document).ready(function () {
            //RETRAVAILLE AFFICHAGE DU SOUS MENU
            jQuery('ul[id$=_RootAspMenu]').find("li.static.dynamic-children > ul").addClass('submenu');
            jQuery('ul[id$=_RootAspMenu]').find("li.static.dynamic-children > ul > li > a").addClass('linkchild');
            jQuery('ul[id$=_RootAspMenu]').find("li.static.dynamic-children > ul").removeClass('dynamic');

            if ($('#mainNav ul > li > ul') != null){
                if ($('#mainNav ul > li > ul').attr('class') == "dynamic") {
                    $('#mainNav ul > li > ul').removeClass('dynamic');
                    $('#mainNav ul > li > ul').addClass('submenu');
                }
            }
            if ($('#mainNav.type2 ul li') != null){
                $('#mainNav.type2 ul li').hover(function () {
                    console.log('hover');
                    if ($(this).find('.submenu').length) {
                        $('#mainNav').addClass('subMenusOpened');
                    }
                }, function () {
                    if ($(this).find('.submenu').length) {
                        $('#mainNav').removeClass('subMenusOpened');
                    }
                });

                $('#mainNav.type2 ul li .submenu').each(function () {
                    var offset = $(this).parent('li').offset().left - $('#mainNav').offset().left;
                    $(this).find('li').css('left', offset + 'px');
                });
            }
            if(!Modernizr.input.placeholder){
                $('input[title!=""], textarea[title!=""]').hint();
            }
        
            if($.customSelect != null){
                if ( $.isFunction($.fn.customSelect) ) {
                    $('select.styled').customSelect();
                }
            }
            if ($('.linkSelect') != null) {
                $('.linkSelect').change(function () {
                    if ($(this).val() != '') {
                        window.location.href = $(this).val();
                    }
                });
            }
       var documentColumn = jQuery("tr.sqdoc-row");
    if (documentColumn.length > 0) {
        documentColumn.closest('table').css("position", "relative");
        documentColumn.closest('table').css("z-index", "2");
    }
            if ($('.royalSlider.topSlider') != null) {
                if ($.isFunction($.fn.royalSlider)) {
                    if ($('.royalSlider.topSlider').length) {
                        $('#mainContent').css('top', '-137px').css('padding-bottom', '0'); // Décalage vers le haut du contenu, par-dessus le slider
                        $('.royalSlider.topSlider').royalSlider(slider_args);
                    }

                    if ($('.royalSlider.videosSlider').length) {
                        var slider = $('.royalSlider.videosSlider').royalSlider(videos_slider_args).data('royalSlider');
                        slider.ev.on('rsOnCreateVideoElement', function (e, url) {
                            if (!(url.indexOf('youtube') > -1) && !(url.indexOf('vimeo') > -1)) {
                                // Ajout de la compatibilité Dailymotion, non native
                                if (url.indexOf('dailymotion') > -1) {
                                    slider.videoObj = $('<iframe frameborder="0" width="626" height="387" autoplay="true" src="' + url + '?autoPlay=1" allowfullscreen></iframe>');
                                } else {
                                    // Si ni YouTube, ni Vimeo, ni Dailymotion, alors nous sommes dans le cas d'un fichier vidéo à lire en html5
                                    slider.videoObj = $("<p>Renvoyer l'objet lecteur vidéo avec en paramètre l'url : " + url + "</p>");
                                }
                            }
                        });
                    }
                }
            }
            if ($('.tabsContent') !== null) {
                $('.tabsContent .tabs a').click(function(e){
                    setCurrentTab($(this).attr('id'));
                });
                $('.tabLink').click(function(e){
                    setCurrentTab($(this).attr('alt'));
                });
                $('.tabsContent').each(function(){
                    $(this).find('.tabs a:first').addClass('current');
                    $(this).find('.tabContent:first').addClass('current');
                });
            }

            if ($('.eventsCalendar') !== null) {
                if ($.isFunction($.fn.eCalendar)) {
                    $('.eventsCalendar').eCalendar({
                        url: 'data/events.json',
                        weekDays: ['L', 'M', 'M', 'J', 'V', 'S', 'D'],
                        months: ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'],
                        eventTitle: '',
                    });
                }
            }
            

    });

    window.onload = function() {
    }
   