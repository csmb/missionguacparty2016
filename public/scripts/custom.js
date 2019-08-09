function hideDivs() {
  var blankform = document.getElementById('blankform');
  var formsubmit = document.getElementById('formsubmit');
  var sunset = document.getElementById("sunset-zone");

  $("#blankform").fadeOut(400);
  $("#formsubmit").fadeIn(200);
  thanks.classList.remove('hide');
  sunset.scrollIntoView();
};

$(document).ready(function () {
  $('#formsubmit').on('submit', function(e) {
    e.preventDefault();
    $.ajax({
      url : $(this).attr('action') || window.location.pathname,
      type: "POST",
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
