## TinyMCE - AJAX

When using a TinyMCE editor in an AJAX form, the hidden field may not be updated with the richtext
data automatically. Use this JavaScript /  to manually update tinyMCE hidden fields:

    if (window.tinyMCE){
        for (i=0; i<tinyMCE.editors.length; i++){
            document.getElementById(tinyMCE.editors[i].id).value = tinyMCE.editors[i].getContent();
        }
    }