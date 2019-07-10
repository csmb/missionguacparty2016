var thanks = document.getElementById('thanks');
var blankform = document.getElementById('blankform');
var formsubmit = document.getElementById('formsubmit');


formsubmit.addEventlistener('click', showthanks(e) {
    e.preventDefault()
    blankform.classList.add('hide')
    thanks.classList.add('show')
    thanks.classList.remove('hide')
});