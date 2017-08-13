
console.log = function(message) {
    window.webkit.messageHandlers.host.postMessage({log:message})
}

function handleClickEvent(event) {
	// console.log('click')
//     window.webkit.messageHandlers.app.postMessage(document.documentElement.outerHTML.toString())
//     return true
	const target = event.target
	if (!target) {
		return false
	} else if (target.tagName == 'A') {
		return false
	}
	target.parentNode.removeChild(target)
	window.webkit.messageHandlers.host.postMessage({html:document.documentElement.outerHTML.toString()})
	return true;
}

//Array.from(document.querySelectorAll('a')).forEach(function (el) {
//                                                   el.addEventListener('click', function(event) {
//                                                                       event.preventDefault()
//                                                                       handleClickEvent(event)
//                                                                       }, false)

//Array.from(document.querySelectorAll('p')).forEach(function (el) {
//                                                   el.addEventListener('click', function(event) {
//                                                                       event.preventDefault()
//                                                                       handleClickEvent(event)
//                                                                       }, false)
//                                                   })

function addMyEventListener(el) {
	el.addEventListener('click', function(event) {
		if (handleClickEvent(event)) {
			event.preventDefault()
		}
	}, false)	
}

addMyEventListener(document)
Array.from(document.querySelectorAll('div')).forEach(function (el) {
	addMyEventListener(el)
})

function textNodesUnder(el) {
  	var node, all = [], walker = document.createTreeWalker(el,NodeFilter.SHOW_TEXT,null,false);
  	while (node = walker.nextNode()) {
  		if (node.wholeText.trim().length && node.parentNode.tagName != 'SCRIPT') {
  			all.push(node);
  		}
  	}
  	return all;
}

allTextNodes = textNodesUnder(document.body);

for (var el in allTextNodes) {
	var span = document.createElement('SPAN')
	var textNode = allTextNodes[el]
	textNode.parentNode.replaceChild(span, textNode)
	span.appendChild(textNode)
}

/*function has(el,callback) {
	var children = Array.from(el.children || [])
	for (var child in children) {
		if (callback(child)) return true
		if (has(child,callback)) return true
	}
	return false
}

click = function (x, y) {
	var divs = Array.from(document.querySelectorAll('div')).filter(function(el){
		var rect = el.getBoundingClientRect()
		return x - rect.left <= rect.width && y - rect.top <= rect.height
	})
	var low
	var lowrect
	divs.forEach(function(el){
		var rect = el.getBoundingClientRect()
		if (low && (rect.width > lowrect.width || rect.height > lowrect.height)) {
			return
		}
		low = el
		lowrect = rect
	})
	// var el = divs.values.next().value
	if (low && low.parentNode) {
		console.log(lowrect.top)
		console.log(low.outerHTML.toString())
		low.parentNode.removeChild(low)
	}
}*/
