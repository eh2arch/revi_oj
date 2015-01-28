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
                var img_attr = null;
                if(submission_data == 'WA'){
                    img_attr='cross.png';
                }
                else if (submission_data == 'AC'){
                    img_attr='tick.png';
                }
                else if (submission_data == 'CE') {
                    img_attr='exclamation.png';
                }
                else
                {
                    img_attr='alert.png';   
                }

                element.setAttribute('data-status-code', submission_data['status_code']);
                element.innerHTML = "<img src='assets/images/" + img_attr + "'> ";//submission_data['status_code'];
              }
            },
            dataType: "json"
        });
    }

    pending_elements = jQuery("td[data-status-code='PE'");
    for (i = 0; i < pending_elements.size(); i++) {
        get_submission_data(pending_elements[i], pending_elements[i].getAttribute('data-submission-id'));
    }
});