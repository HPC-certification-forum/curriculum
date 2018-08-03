/*
Copyright (c) 2018 Nathanael Hübbe

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

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
