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

(function(){
	//title may be either a DOM element, or a string containing HTML code.
	Menu = function(container, title) {
		var me = this;	//give any closures created here access to the currently constructed object
		this.container = document.createElement("div");
		this.dropButton = document.createElement("div");
		this.menuPane = document.createElement("ul");
		this.opened = false;

		this.container.setAttribute("class", "menu-container");

		this.dropButton.innerHTML = title;
		this.dropButton.setAttribute("class", "menu-toggle");
		this.dropButton.addEventListener("mouseenter", function(event) {
			me.dropButton.classList.add("hover");
		});
		this.dropButton.addEventListener("mouseleave", function(event) {
			me.dropButton.classList.remove("hover");
		});
		this.dropButton.addEventListener("click", function(event) {
			if(me.opened) {
				me.menuPane.setAttribute("hidden", "");
			} else {
				me.menuPane.removeAttribute("hidden");
			}
			me.opened = !me.opened;
		});

		this.menuPane.setAttribute("hidden", "");
		this.menuPane.setAttribute("class", "menu-body");

		this.container.appendChild(this.dropButton);
		this.container.appendChild(this.menuPane);
		container.appendChild(this.container);
	};

	Menu.prototype = {
		setTitle: function(title) {
			this.dropButton.innerHTML = title;
		},

		//Add an item at the end of the menu with the provided html visualization, that will call `action(argument)` when it's selected by the user.
		//title is a string containing HTML code.
		addItem: function(title, action, argument) {
			var me = this;	//give closures access to this object
			var item = document.createElement("li")

			item.innerHTML = title;
			item.addEventListener("mouseenter", function(event) {
				item.classList.add("hover");
			});
			item.addEventListener("mouseleave", function(event) {
				item.classList.remove("hover");
			});
			item.addEventListener("click", function(event) {
				me.opened = false;
				me.menuPane.setAttribute("hidden", "");
				item.classList.remove("hover");
				action(argument);
			});

			this.menuPane.appendChild(item);
		},

		//Add a separator at the end of the menu (most likely, this is followed by further `addItem()` calls).
		addSeparator: function() {
			//TODO
		},

		//Reset the menu to an empty pane to allow it to be rebuilt.
		clear: function() {
			var child;
			while(child = this.menuPane.lastChild) this.menuPane.removeChild(child);
		},

		//Can't use the "hidden" attribute because the CSS adds a "display:" style which overrides the setting by "hidden".
		//XXX: This code requires that "display: none" is the only contents the "style" attribute ever has.
		//     This shouldn't be a problem as use of the "style" attribute is discouraged in favor of external CSS anyway.
		show: function() { this.dropButton.removeAttribute("style"); },
		hide: function() { this.dropButton.setAttribute("style", "display: none"); },
	};
}())
