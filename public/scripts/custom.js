var checkBox = document.getElementsByClassName('checkbutton');

function styleCheckbox() {
    
    if (checkBox.checked == true){
        checkBox.classList.add("checked");
    } else {
       checkBox.classList.remove("checked")
    }
}