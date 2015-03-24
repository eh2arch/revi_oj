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
                var img_attr = null, tooltip = '';
                if(submission_data['status_code'] == 'AC'){
                    img_attr = 'tick.png';
                    tooltip = submission_data['running_time'];
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
                element.innerHTML = " <img src='/assets/" + img_attr + "' height='24' width='24' data-toggle='tooltip' data-placement='bottom' title='" + submission_data['status_code'] + "' data-original-title='" + Math.round(tooltip * 100) / 100 + "' > <br /><br /> <span><i><b>" + Math.round(tooltip * 100) / 100 + "</b></i></span>";
              }
            },
            dataType: "json"
        });
    }

    jQuery(".rejudge_submission").click(function(){
        rejudge_submission(this.getAttribute('data-submission-id'));
        img_attr = "load.gif";
        this.innerHTML = " <img src='/assets/" + img_attr + "' height='24' width='24' /> ";
    });

    function rejudge_submission(submission_id) {
        jQuery.ajax(
        {
            url: "/rejudge",
            data: { "submission_id": submission_id },
            dataType: "json"
        });
    }

    pending_elements = jQuery("td[data-status-code='PE'");
    for (i = 0; i < pending_elements.size(); i++) {
        get_submission_data(pending_elements[i], pending_elements[i].getAttribute('data-submission-id'));
    }


});