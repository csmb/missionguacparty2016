function hideDivs() {
	var blankform = document.getElementById('blankform');
	var formsubmit = document.getElementById('formsubmit');

	blankform.classList.remove('hide');
    thanks.classList.add('hide');
};

$(document).ready(function () {
    $('#formsubmit').on('submit', function(e) {
        e.preventDefault();
        var url = $(this).attr('action') || window.location.pathname;
        console.log(url);
        $.ajax({
            url : $(this).attr('action') || window.location.pathname,
            type: "POST",
            crossDomain: true,
            data: $(this).serialize(),
            success: function (data) {
            	hideDivs();
            },
            error: function (jXHR, textStatus, errorThrown) {
                console.log(errorThrown);
            }
        });
    });
});
