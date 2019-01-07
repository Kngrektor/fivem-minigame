let types = {
	String: function(v, fmt) {
		if (typeof v === "object") {
			let secs = v.left/1000
			return Math.floor(secs/60)+":"+Math.floor(secs%60)
		} else if (v === undefined) {
			return "undefined"
		} else if (v === null) {
			return "null"
		} else {
			return v.toString()
		}
	},
	Percentage: function(v, fmt) {
		if (typeof v === "object") {
			return 1-v.left/v.len
		} else {
			return Math.min(Math.max(types["Number"](v, fmt), 0), 1)
		}
	},
	Number: function(v, fmt) {
		if (typeof v === "object") {
			return v.left/1000
		} else {
			return parseFloat(v)
		}
	}
}

function templatize(node) {
	let tmpl = parseTemplate(node.nodeValue)
	// This doesn't have any variables so completely static
	if (tmpl.length < 2) {
		node.nodeValue = tmpl[0] || ""
		return false
	}

	function render(store) {
		let str = ""
		for (let i = 0; i < tmpl.length; i++) {
			let v = tmpl[i]
			if (i % 2 == 0) {
				str += v
				continue
			}
			str += types[v.type](store[v.prop], v.fmt)
		}
		node.nodeValue = str
	}
	render({})

	let props = []
	for (let i = 0; i < tmpl.length; i++) {
		if (i % 2 == 0) { continue }
		props.push(tmpl[i].prop)
	}

	return {
		render: render,
		props: props
	}
}

function instantiateTemplates(node) {
	let store = {} // Store all props
	let tmpls = [] // All templates and targets
	let props = {} // Map prop -> templates, "mg:roundTimer": [3, 4]

	function crawl(node) {
		if (node.tagName == "STYLE") { return }

		switch (node.nodeType) {
		case Node.TEXT_NODE:
		case Node.ATTRIBUTE_NODE:
			let tmpl = templatize(node)
			if (tmpl) {
				let idx = tmpls.push(tmpl.render)-1
				for (let i = 0; i < tmpl.props.length; i++) {
					let prop = tmpl.props[i]
					if (!props[prop]) { props[prop] = [] }
					props[prop].push(idx)
				}
			}
			break
		case Node.ELEMENT_NODE:
			// Let's first check all the attributes of this node
			let attrs = node.attributes
			for (let i = 0; i < attrs.length; i++) {
				crawl(attrs[i])
			}
			// Then all child elements
			let childs = node.childNodes
			for (let i = 0; i < childs.length; i++) {
				crawl(childs[i])
			}
		default:
		}
	}
	crawl(node)

	// Patch for timers n stuff
	updateVars = {}
	function update() {
		let tmplsToRender = []
		for (let prop in updateVars) {
			if (updateVars.hasOwnProperty(prop)) {
				let val
				if (typeof updateVars[prop] === "function") {
					val = updateVars[prop]()
				} else {
					val = updateVars[prop]
					delete updateVars[prop]
				}
				store[prop] = val
				for (let idx in props[prop]) {
					tmplsToRender.push(idx)
				}
			}
		}
		for (let idx in tmplsToRender) {
			tmpls[idx](store)
		}
		requestAnimationFrame(update)
	}
	requestAnimationFrame(update)

	return function(prop, val) {
		if (typeof val === "object" && val.type === "timer") {
			let end = performance.now() + val.left
			let len = val.len
			updateVars[prop] = function(){
				return {
					left: Math.max(end - performance.now(), 0),
					len:  len
				}
			}
		} else {
			updateVars[prop] = val;
		}
	}
}