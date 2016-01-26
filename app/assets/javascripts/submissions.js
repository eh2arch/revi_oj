$(document).ready(function() {

    function get_submission_data(element, submission_id) {
        $.ajax(
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
                    tooltip = 'Correct Answer:' + submission_data['running_time'];
                    status_description = Math.round(submission_data['running_time'] * 100) / 100;
                }
                else if (submission_data['status_code'] == 'WA'){
                    img_attr = 'red-cross.png';
                    tooltip = 'Wrong Answer';
                    status_description = null;
                }
                else if (submission_data['status_code'] == 'CE') {
                    img_attr = 'alert.png';
                    tooltip = 'Compilation Error';
                    status_description = null;
                    // tooltip = submission_data['description'];
                }
                else if (submission_data['status_code'] == 'TLE') {
                    img_attr = 'clock.png';
                    tooltip = 'Time Limit Exceeded';
                    status_description = null;
                }
                else
                {
                    img_attr = 'exclamation.png';
                    tooltip = 'Signal received: ' + submission_data['description'];
                }

                $(element).attr('data-status-code', submission_data['status_code']);
                $(element).children().remove();
                $(element).append(" <img src='/assets/" + img_attr + "' height='24' width='24' data-toggle='tooltip' data-placement='bottom' title='" + tooltip + "' >");
                if(status_description !== null) {
                    $(element).append("<br /><br /> <span><b>" + status_description + "</b></span>");
                }
                $(element).siblings('.rejudge_submission').find('img').show('slow');
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

    function rejudge_submission_single(elements, callback) {
        var img_attr = "load.gif";
        for (var i=0; i < $(elements).length; i++) {
            var element = elements[i];
            $(element).children().remove();
            $(element).append(" <img src='/assets/" + img_attr + "' height='24' width='24' /> ");
            var submission = $(element).attr('data-submission-id');
            callback(element, submission);
        }
    }
    $(".rejudge_submission").click(function(){
        var submission = $(this).attr('data-submission-id');
        var element = $("td.submission_img[data-submission-id="+submission+"]");
        rejudge_submission_single(element, rejudge_submission_call);
    });

    $(".rejudge_page").click(function(){
        var elements = $("td.submission_img[data-submission-id]");
        rejudge_submission_single(elements, rejudge_submission_call);
    });

    $('.rejudge_all').click(function(){
        $.ajax({
            url: '/rejudge_multiple/' + window.location.pathname.split('/').slice(2, window.location.pathname.split('/').length).join('/'),
            type: 'GET',
            success: function()
            {
                var elements = $("td.submission_img[data-submission-id]");
                rejudge_submission_single(elements, (function(element, submission_id){
                    $(element).siblings('.rejudge_submission').find('img').hide('slow');
                    get_submission_data(element, submission_id);
                }));
            }
        })
    });

    function rejudge_submission_call(element, submission_id) {
        $(element).siblings('.rejudge_submission').find('img').hide('slow');
        $.ajax(
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

    pending_elements = $("td[data-status-code='PE']");
    for (i = 0; i < pending_elements.size(); i++) {
        get_submission_data(pending_elements[i], pending_elements[i].getAttribute('data-submission-id'));
    }


});