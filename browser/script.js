
function handleClickEvent(event) {
	const target = event.target
	if (!target) {
		return false
	} else if (target.tagName == 'A') {
		return false
	}
	target.parentNode.removeChild(target)
	window.webkit.messageHandlers.app.postMessage(document.documentElement.outerHTML.toString())
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
//Array.from(document.querySelectorAll('div')).forEach(function (el) {
//                                                     el.addEventListener('click', function(event) {
//                                                                         event.preventDefault()
//                                                                         handleClickEvent(event)
//                                                                         }, false)
//                                                     })

document.addEventListener('click',function (event) {
	if (handleClickEvent(event)) {
		event.preventDefault()
	}
}, false)
