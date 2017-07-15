
console.log = function(message) {
    window.webkit.messageHandlers.host.postMessage({log:message})
}

// function handleClickEvent(event) {
//     window.webkit.messageHandlers.app.postMessage(document.documentElement.outerHTML.toString())
//     return true
// 	const target = event.target
// 	if (!target) {
// 		return false
// 	} else if (target.tagName == 'A') {
// 		return false
// 	}
// 	target.parentNode.removeChild(target)
// 	window.webkit.messageHandlers.app.postMessage(document.documentElement.outerHTML.toString())
// 	return true;
// }

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

// Array.from(document.querySelectorAll('div')).forEach(function (el) {
// 	console.log(el.outerHTML.toString())
// 	el.addEventListener('click', function(event) {
// 		console.log('click')
// 		if (handleClickEvent(event)) event.preventDefault()
// 	}, false)
// })

// document.addEventListener('click',function (event) {
// 	if (handleClickEvent(event)) {
// 		event.preventDefault()
// 	}
// }, false)

function has(el,callback) {
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
}
