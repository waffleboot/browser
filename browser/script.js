
var removeLinks = false;

console.log = function(message) {
    window.webkit.messageHandlers.host.postMessage({log:message})
}

function removeElement(el) {
	var p = el.parentNode
	while (el.nextElementSibling instanceof HTMLBRElement) {
		var nextSibling = el.nextSibling;
		if (nextSibling instanceof Text) {
			var text = nextSibling.wholeText.trim()
			if (text.length) break
		}
		p.removeChild(el.nextElementSibling)
	}
	p.removeChild(el)
	tryToRemoveParentElement(p)
}

function tryToRemoveParentElement(el) {
	var emptyTextNodes = []
	var noTextNodesAnymore = true
	var walker = document.createTreeWalker(el, NodeFilter.SHOW_TEXT, null, false)
	while (walker.nextNode()) {
		var text = walker.currentNode.wholeText.trim()
		if (text.length) {
			noTextNodesAnymore = false
		} else {
			emptyTextNodes.push(walker.currentNode)
		}
	}
	emptyTextNodes.forEach(function (t) {
		t.parentNode.removeChild(t)
	})
	if (noTextNodesAnymore) {
		removeElement(el)
	}
}

function findClosest (el, selector) {
  while ((el = el.parentElement) && !el.matches(selector));
  return el
}

function handleClickEvent(event) {
	const target = event.target
	if (!target) {
		return false
	}
	const anchorForTarget = findClosest(target, 'A')
	if (anchorForTarget && !removeLinks) {
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

// удалить meta
Array.from(document.querySelectorAll('meta')).forEach(function (el) {
	el.parentNode.removeChild(el)
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

window.webkit.messageHandlers.host.postMessage({removeLinks:1})
