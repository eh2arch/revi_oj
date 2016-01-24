jQuery(document).ready(function() {
    jQuery('.dropdown-toggle').dropdown();
    jQuery("#mode").selectBoxIt({
        showEffect: 'fadeIn',
        hideEffect: 'fadeOut'
    });
	var editor = new CodeMirror(document.getElementById("code"), {
		lineNumbers: true,
		extraKeys: null,
		mode: {name: "text/x-c++src", globalVars: true},
		scrollbarStyle: "null",
		lineWrapping: true,
		viewportMargin: Infinity,
		matchBrackets: true
	});
    jQuery("#mode").change(function(){
    	editor.setOption("mode", jQuery(this).val());
    });
    jQuery("#theme li").click(function(){
    	editor.setOption("theme", jQuery(this).attr('value'));
    });
    jQuery(".dropdown-menu a#auto-complete-a ").click(function(e){
    	e.stopPropagation();
    });
    jQuery("input[type=checkbox]").change(function(){
    	if (jQuery(this).is(':checked')) {
    		editor.setOption("extraKeys", {"Ctrl-Space": "autocomplete"});
    	}
    	else {
    		editor.setOption("extraKeys", null);
    	}
    	console.log(editor.getOption("extraKeys"));
    });
});