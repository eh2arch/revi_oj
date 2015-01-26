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
                element.setAttribute('data-status-code', submission_data['status_code']);
                element.innerHTML = submission_data['status_code'];
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