//Create a <div> element that is a child of the given container.
//This new <div> is inserted into the DOM, but initially hidden and empty.
function HoverBox(container, zIndex) {
	var domElement = document.createElement("div");	//we need this local variable for the closure of the mouseleave event listener
	this.domElement = domElement;
	this.enabled = true;
	this.deferredShowNode = null;

	domElement.setAttribute("hidden", "");
	domElement.style.position = "absolute";
	domElement.style.top = "0px";
	domElement.style.left = "0px";
	domElement.setAttribute("z-index", "" + zIndex);
	domElement.innerHTML = "hoverBox";
	domElement.addEventListener("mouseleave", function(event) {
		domElement.setAttribute("hidden", "");
	});
	container.appendChild(domElement);
}

HoverBox.prototype = {
	//show hover box for the given node if it is enabled
	show: function(node) {
		if(!this.enabled) {
			this.deferredShowNode = node;	//defer the showing of the hover box until it is reenabled
		} else {
			this.show_internal(node);
		}
	},

	hide: function() {
		this.domElement.setAttribute("hidden", "");
	},

	enable: function() {
		this.enabled = true;
		if(this.deferredShowNode) this.show_internal(this.deferredShowNode);
	},

	disable: function() {
		this.hide();
		this.enabled = false;
	},

	clearDeferred: function() {
		this.deferredShowNode = null;
	},

//private
	//Expands the view of a single node in the skill tree by displaying a hover box above it.
	//The hover box contains the exact same text and formatting as the node.nodeDOM element, but appends a divider and details.
	//The hover box will be shown until the mouse leaves the hover box.
	//
	//If the hover box is disabled, the action will be deferred until `show()` is called without a truthy argument.
	//If several shows are deferred in sequence before calling `show()` without an argument, it is only the last show that will be acted upon.
	show_internal: function(node) {
		this.domElement.setAttribute("hidden", "");
		this.domElement.setAttribute("class", node.nodeDOM.getAttribute("class") + " Details");
		this.domElement.style.top = node.nodeDOM.offsetTop - node.nodeDOM.offsetParent.scrollTop + "px";
		this.domElement.style.left = node.nodeDOM.offsetLeft - node.nodeDOM.offsetParent.scrollLeft + "px";
		this.domElement.innerHTML = node.nodeDOM.innerHTML + '<hr class="TitleDivider">' + node.meta.skillHtmlDescription();
		this.domElement.onclick = function(event) {
			skillTreeObjects().disableHoverBox();
			node.toggleCollapse();
		};

		this.domElement.removeAttribute("hidden");
		this.clearDeferred();
	},
};
