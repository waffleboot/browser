
var removeLinks = false;

console.log = function(message) {
    window.webkit.messageHandlers.host.postMessage({log:message})
}

function hasTextNodes(el) {
	var walker = document.createTreeWalker(el, NodeFilter.SHOW_TEXT, null, false)
	while (walker.nextNode()) {
		var text = walker.currentNode.wholeText.trim()
		if (text.length) {
			return true
		}
	}
	return false
}

function removeElement(el) {
	var elements = [el]
	var parent = el.parentNode
	while (el.nextElementSibling instanceof HTMLBRElement) {
		elements.push(el.nextElementSibling)
		el = el.nextElementSibling
	}
	elements.forEach(function(c){
		parent.removeChild(c)
	})
	if (!hasTextNodes(parent)) {
		removeElement(parent)
	}
}

function findClosest (el, selector) {
  if (el.matches(selector)) return el
  while ((el = el.parentElement) && !el.matches(selector));
  return el
}

function isBlockElement(el) {
	var blockElements = [
		HTMLButtonElement,
		HTMLDivElement,
		HTMLHeadingElement,
		HTMLHRElement,
		HTMLImageElement,
		HTMLParagraphElement,
		HTMLSelectElement,
		HTMLTableElement,
		HTMLTextAreaElement,
		HTMLVideoElement,
		HTMLPreElement,
		HTMLLIElement,
		HTMLUListElement,
		HTMLDListElement,
		HTMLOListElement
	]
	for (var i = 0; i < blockElements.length; ++i) if (el instanceof blockElements[i]) return true
	return false
}

function isMyElement(el) {
	return el instanceof HTMLDivElement && el.className == 'yangand'
}

function isElementValidToRemove(el) {
	return isBlockElement(el) || isMyElement(el) || (el instanceof HTMLElement && el.tagName == 'HEADER')
}

function handleClickEvent(event) {
	var target = event.target
	if (!target) {
		return false
	}
	const anchorForTarget = findClosest(target, 'A')
	if (anchorForTarget && !removeLinks) {
		return false
	}
	while (!isElementValidToRemove(target)) {
		target = target.parentElement
	}
	removeElement(target)
	window.webkit.messageHandlers.host.postMessage({html:document.documentElement.outerHTML.toString()})
	// console.log(document.body.outerHTML.toString())
	return true
}

function clear() {
	function removeAllScriptElements() {
		Array.from(document.scripts).forEach(function (s) {
			s.parentNode.removeChild(s)
		})
	}
	function removeAllMetaTags() {
		document.querySelectorAll('meta').forEach(function (el) {
			el.parentNode.removeChild(el)
		})
	}
	function removeIFrames() {
		document.querySelectorAll('iframe').forEach(function(el){
			el.parentNode.removeChild(el)
		})
	}
	removeAllScriptElements()
	removeAllMetaTags()
	removeIFrames()
}

document.addEventListener('click',function (event) {
	if (handleClickEvent(event)) {
		event.preventDefault()
	}
},false)

window.webkit.messageHandlers.host.postMessage({removeLinks:1})

function findBefore(el) {
	var top = el
	while (!(el instanceof HTMLBRElement)) {
		top = el; el = el.previousSibling	
	}
	return top
}

function createMyElement(nodes) {
	var div = document.createElement('div')
	div.className = 'yangand'
	nodes.forEach(function(el){
		div.appendChild(el)
	})
	return div
}

function wrapTextNodes() {
	var set = new Set()
	document.querySelectorAll('BR').forEach(function(br){
		if (!isMyElement(br.parentNode)) set.add(br.parentNode)
	})
	set.forEach(function(p){
		var nodes = []
		var element = p.firstChild
		var breakLine = false
		var elements = []
		while (element) {
			if (breakLine) {
				var skip = element instanceof HTMLBRElement || element instanceof Text && !element.wholeText.trim().length
				if (!skip) {
					elements.push(createMyElement(nodes))
					breakLine = false
					nodes = []
				}
			} else {
				breakLine = element instanceof HTMLBRElement
			}
			nodes.push(element)
			element = element.nextSibling
		}
		elements.push(createMyElement(nodes))
		
		elements.forEach(function(el){
			p.appendChild(el)
		})
	})
}

wrapTextNodes()

setTimeout(clear,3000)
