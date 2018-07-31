//Create a skill tree viewer.
//containerPath is a jQuery path to a <div> tag that is used to render the skill tree viewer.
//views is either a dictionary of the form
//    {
//        '<view name>': [
//            '<config file url 1>',
//            '<config file url 2>',
//            ...
//        ],
//    }
//or a string containing an URL to a JSON file of that same format.
window['SkillTreeViewer'] = function(containerPath, views) {
	var container = $(containerPath)[0];

	//The core functionality without the ajax part (views must be a dictionary).
	var setViewConfig = function(views) {
		var globals = skillTreeObjects();
		globals.setContainer(container);
		for(var name in views) {
			var curView = new SkillList();
			var curFileList = views[name];
			(function(name, curView, curFileList){
				curView.loadFiles(
					function(jsonError) {
						if(jsonError) {
							console.log("error while loading view '" + name + "': " + jsonError);
						} else {
							globals.addView(name, curView);
						}
					},
					curFileList
				);
			}(name, curView, curFileList))
		}
	};

	//Signal to the user that an error occurred.
	var handleError = function(jqXHR, textStatus, error) {
		container.innerHTML = "error while loading file from '" + views + "':<br>status = " + textStatus + "<br>error = " + error;
	};

	if(typeof views == "string") {
		//views is an URL, so we need to fetch the view list file first
		$.ajax({
			url: views,
			dataType: "json",
			mimeType: "application/json",
			success: setViewConfig,
			error: handleError,
		});
	} else {
		setViewConfig(views);
	}
};
