jQuery(document).ready(function() {

    function get_submission_data(element, submission_id) {
        jQuery.ajax(
        {
            url: "/get_submission_data",
            data: { "submission_id": submission_id },
            success: function(submission_data)
            {
              if (submission_data['status_code'] == 'PE') {
                setTimeout(function(){
                    get_submission_data(element, submission_id);
                }, 3000);
              }
              else {
                var img_attr = null, tooltip = '', status_description = submission_data['description'];
                if(submission_data['status_code'] == 'AC'){
                    img_attr = 'tick.png';
                    tooltip = submission_data['running_time'];
                    status_description = Math.round(tooltip * 100) / 100;
                }
                else if (submission_data['status_code'] == 'WA'){
                    img_attr = 'red-cross.png';
                }
                else if (submission_data['status_code'] == 'CE') {
                    img_attr = 'alert.png';
                    // tooltip = submission_data['description'];
                }
                else if (submission_data['status_code'] == 'TLE') {
                    img_attr = 'clock.png';
                }
                else
                {
                    img_attr = 'exclamation.png';
                    tooltip = submission_data['description'];
                }

                element.setAttribute('data-status-code', submission_data['status_code']);
                jQuery(element).children().remove();
                jQuery(element).append(" <img src='/assets/" + img_attr + "' height='24' width='24' data-toggle='tooltip' data-placement='bottom' title='" + submission_data['status_code'] + "' data-original-title='" + status_description + "' > <br /><br /> <span><i><b>" + status_description + "</b></i></span>");
                jQuery(element).siblings('.rejudge_submission').find('img').show('slow');
              }
            },
            error: function() {
                setTimeout(function(){
                    get_submission_data(element, submission_id);
                }, 3000);                                
            },
            dataType: "json"
        });
    }

    function rejudge_submission_single(elements) {
        var img_attr = "load.gif";
        for (var i=0; i < jQuery(elements).length; i++) {
            var element = elements[i];
            jQuery(element).children().remove();
            jQuery(element).append(" <img src='/assets/" + img_attr + "' height='24' width='24' /> ");
            var submission = jQuery(element).attr('data-submission-id');
            rejudge_submission_call(element, submission);
        }
    }
    jQuery(".rejudge_submission").click(function(){
        var submission = jQuery(this).attr('data-submission-id');
        var element = jQuery("td.submission_img[data-submission-id="+submission+"]");
        rejudge_submission_single(element);
    });

     jQuery(".rejudge_page").click(function(){
        var elements = jQuery("td.submission_img[data-submission-id]");
        rejudge_submission_single(elements);
    });
    

    function rejudge_submission_call(element, submission_id) {
        jQuery(element).siblings('.rejudge_submission').find('img').hide('slow');
        jQuery.ajax(
        {
            url: "/rejudge",
            data: { "submission_id": submission_id },
            type: "GET",
            success: function(data)
            {
                get_submission_data(element, submission_id);
            }
        });
    }

    pending_elements = jQuery("td[data-status-code='PE']");
    for (i = 0; i < pending_elements.size(); i++) {
        get_submission_data(pending_elements[i], pending_elements[i].getAttribute('data-submission-id'));
    }


});