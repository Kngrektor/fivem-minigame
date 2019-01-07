function eatSpace(str, i) {
	let j = 0
	while (str[i+j] == " ") {
		j++
	}
	return j
}

function parseTemplate(input) {
	let tmpl = []
	let temp = ""
	let prop
	let state = 0

	for (let i = 0; i < input.length; i++) {
		let c = input[i]

		if (c === "{" && input[i+1] === "{") { // {{
			temp += "{"
			i += 1
		} else if (c === "}" && input[i+1] === "}") { // }}
			temp += "}"
			i += 1


		} else if (c === "{") { // {
			tmpl.push(temp)
			prop = {}
			temp = ""
			state = 1
			i += eatSpace(input, i+1)

		} else if (c === " " && state === 1) { // "Argument" split
			prop.prop = temp
			temp = ""
			state = 2
			i += eatSpace(input, i+1)

		} else if (c === " " && state === 2) { // "Argument" split
			if (!types[temp]) {
				throw Error("Unknown type '" + temp + "'")
			}
			prop.type = temp
			temp = ""
			state = 3
			i += eatSpace(input, i+1)

		} else if (c === "}") {
			if (state=== 0) {
				throw Error("Found a } before a matching {")
			} else if (state === 1 && temp === "") {
				throw Error("Expected a property name after {")
			} else if (state === 1) {
				prop.prop = temp
				prop.type = "String"
			} else if (state === 2 && temp === "") {
				prop.type = "String"
			} else if (state === 2 && !types[temp]) {
				throw Error ("Unknown type '"+temp+"'")
			} else if (state === 2) {
				prop.type = temp
			} else if (state === 3 && temp === "") {
				// Don't populate prop.fmt
			} else if (state === 3) {
				prop.fmt = temp
			}

			tmpl.push(prop)
			prop = undefined
			temp = ""
			state = 0

		} else {
			temp += c
		}
	}

	if (state !== 0) {
		throw Error("No matching } for {")
	} else if (temp !== "") {
		tmpl.push(temp)
	}

	return tmpl
}