
console.log = function(message) {
    window.webkit.messageHandlers.host.postMessage({log:message})
}

function removeElement(el) {
	if (el === document.body) return
	var p = el.parentNode
	p.removeChild(el)
	var walker = document.createTreeWalker(p, NodeFilter.SHOW_TEXT, null, false)
	var nodeList = []
	var hasTextNodes = false
	while (walker.nextNode()) {
		var text = walker.currentNode.wholeText.trim()
		if (text.length) {
			hasTextNodes = true
		} else {
			nodeList.push(walker.currentNode)
		}
	}
	nodeList.forEach(function (c) {
		c.parentNode.removeChild(c)
	})
	if (!hasTextNodes) removeElement(p)
}

function handleClickEvent(event) {
	const target = event.target
	if (!target) {
		return false
	} else if (target.tagName == 'A') {
		return false
	}
	removeElement(target)
	window.webkit.messageHandlers.host.postMessage({html:document.documentElement.outerHTML.toString()})
	return true
}

// удалить все скрипты
Array.from(document.scripts).forEach(function (s) {
	s.parentNode.removeChild(s)
})

// обернуть все тексты в span
function allTextNodes() {
	var nodeList = [], walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT,null,false)
	while (walker.nextNode()) nodeList.push(walker.currentNode)
  	return nodeList;
}

allTextNodes().forEach(function (el) {
	var text = el.wholeText.trim()
	if (text.length) {
		if (el.parentNode.tagName != 'SPAN') {
			var span = document.createElement('SPAN')
			el.parentNode.replaceChild(span, el)
			span.appendChild(document.createTextNode(text))
		}
	} else {
		el.parentNode.removeChild(el)
	}
})

// добавить click handler
function addClickEventListener(el) {
	el.addEventListener('click', function(event) {
		if (handleClickEvent(event)) {
			event.preventDefault()
		}
	}, false)	
}

addClickEventListener(document)
// Array.from(document.querySelectorAll('div')).forEach(function (el) {
// 	addClickEventListener(el)
// })
