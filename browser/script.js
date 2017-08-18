
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
		HTMLLIElement
	]
	for (var i = 0; i < blockElements.length; ++i) if (el instanceof blockElements[i]) return true
	return false
}

function isElementValidToRemove(el) {
	if (isBlockElement(el)) return true
	if (el instanceof HTMLSpanElement && el.className == 'yangand') return true
	return false
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

function wrapSpanTextNodes() {
	var textNodes = []
	var walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, { acceptNode: function (n) {
		return n.wholeText.trim().length ? NodeFilter.FILTER_ACCEPT : NodeFilter.FILTER_REJECT
	}}, false)
	while (walker.nextNode()) {
		if (walker.currentNode.nextSibling instanceof HTMLBRElement || isBlockElement(walker.currentNode.nextSibling) 
		 || walker.currentNode.previousSibling instanceof HTMLBRElement || isBlockElement(walker.currentNode.previousSibling)) {
			textNodes.push(walker.currentNode)
		}
	}
	textNodes.forEach(function(n){
		var span = document.createElement('SPAN')
		var newTextNode = document.createTextNode(n.wholeText)
		span.className = 'yangand'
		span.appendChild(newTextNode)
		n.parentNode.replaceChild(span, n)
	})
}

wrapSpanTextNodes()
setTimeout(clear,3000)
