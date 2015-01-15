                jQuery(document).ready(function($) {
                    $('a[href="#layout-variants"]').on('click', function(ev) {
                        ev.preventDefault();
                        var win = {
                            top: $(window).scrollTop(),
                            toTop: $("#layout-variants").offset().top - 15
                        };
                        TweenLite.to(win, .3, {
                            top: win.toTop,
                            roundProps: ["top"],
                            ease: Sine.easeInOut,
                            onUpdate: function() {
                                $(window).scrollTop(win.top);
                            }
                        });
                    });
                });
