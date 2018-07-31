(function(){
	//Create a <div> element as a child of the given container (if its not null).
	//This new <div> is inserted into the DOM and parameterized to contain the tree view, but initially empty.
	var createContainer = function(container, zIndex) {
		var element = document.createElement("div");
		element.setAttribute("z-index", "" + zIndex);
		if(container) container.appendChild(element);
		return element;
	}

	//Returns a singleton object that is used as a container for global data.
	skillTreeObjects = function() {
		kTreeContainerId = makeId(128);

		//The class of the singleton.
		var SkillTreeObjects = function() {
			this.views = {};
		};

		SkillTreeObjects.prototype = {
			//Add a view to the list of available views.
			//If this is the first view that is set, it will be made the current view.
			addView: function(name, view) {
				this.views[name] = view;
				if(!this.curViewName) {
					this.setCurView(name);
				} else {
					this.displayViewMenu();
				}
			},

			//select which view is to be used for display
			//returns true on success
			setCurView: function(name) {
				if(!this.views[name]) return false;
				if(this.curViewName && this.treeContainer) {
					//Unset the class that publishes the active view to CSS, displayTree() will set it again.
					this.treeContainer.classList.remove("view_" + this.curViewName);
				}

				this.curViewName = name;
				this.displayTree();
				return true;
			},

			curView: function() {
				return this.views[this.curViewName];
			},

			//Set the DOM element that is used to display the tree.
			//Will set some of the elements properties to make it ready to serve our purposes.
			setContainer: function(container) {
				if(this.treeContainer) {
					console.log("Error: skillTreeObjects().setContainer() called twice\n");
					return;
				}

				this.viewSelector = new Menu(container, "views");

				//There must be no other element within the same container as the tree and the hoverBox, in order to guarantee that the hoverBox is positioned correctly.
				var intermediateContainer = createContainer(null, 0);
				intermediateContainer.style.position = "relative";	//this is required for the hoverBox to be positioned relative to this <div>
				intermediateContainer.className = "SkillTree";	//allow us to select anything we control via CSS
				this.treeContainer = createContainer(intermediateContainer, 0);
				this.treeContainer.setAttribute("id", kTreeContainerId);
				this.hoverBox = new HoverBox(intermediateContainer, 1);
				container.appendChild(intermediateContainer);

				this.displayTree();
			},

			//Disable the hover box (because an animation (collapse/expansion) is about to be started).
			//Must be followed by a call to enableHoverBox().
			disableHoverBox: function() { this.hoverBox.disable(); },
			enableHoverBox: function() { this.hoverBox.enable(); },

			displayViewMenu: function() {
				//Are we ready for display yet?
				if(!this.treeContainer) return;
				if(!this.curViewName) return;

				//setup the view menu
				this.viewSelector.clear();
				this.viewSelector.setTitle(this.curViewName);
				var menuHandler = function(me) {
					return function(name) { me.setCurView(name); };	//This is not a recursion as this will only get executed when the user selects a view.
				}(this);
				var viewCount = 0;
				for(var name in this.views) {
					this.viewSelector.addItem(name, menuHandler, name);
					viewCount++;
				}
				if(viewCount > 1) {	//Only show view menu if several views have been configured.
					this.viewSelector.show();
				} else {
					this.viewSelector.hide();
				}
				this.treeContainer.classList.add("view_" + this.curViewName);	//Publish the active view as a CSS class.
			},

			//Perform the actual display if possible.
			displayTree: function() {
				//Are we ready for display yet?
				if(!this.treeContainer) return;
				if(!this.curViewName) return;

				//setup the view menu
				this.displayViewMenu();

				//setup Treant configuration
				var treantTree = this.curView().makeTreantNodeStructure();
				var chartConfig = {
					chart: {
						container: "#" + kTreeContainerId,
						rootOrientation: "WEST",
						node: {
							collapsable: true
						},
						animateOnInit: false,
						animation: {
							nodeAnimation: "linear",
							nodeSpeed: 300,
							connectorsAnimation: "linear",
							connectorsSpeed: 300
						},
						callback: {
							onCreateNode: function(node, domNode) {
								domNode.addEventListener("mouseenter", function(event) {
									nodeMouseEnter(node);
								});
								domNode.addEventListener("mouseleave", function(event) {
									nodeMouseLeave();
								});
							},
							onToggleCollapseFinished: function(node, domNode) {
								skillTreeObjects().enableHoverBox();	//reenable hover box after animation finishes
							},
						}
					},
					nodeStructure: treantTree
				};

				//display the tree
				this.tree = new Treant(chartConfig);
			},
		};

		//The singleton itself.
		var globals = new SkillTreeObjects();

		//Create closure that hides the class and singleton variable from the global namespace.
		return function() {
			return globals;
		};
	}();

	var nodeMouseEnter = function(node) {
		skillTreeObjects().hoverBox.show(node);
	}

	var nodeMouseLeave = function() {
		//a mouseenter with a disabled hover box would have been deferred, but it is outdated now that the mouse has left
		skillTreeObjects().hoverBox.clearDeferred();
	}
}())
