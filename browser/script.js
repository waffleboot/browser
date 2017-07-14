
function handleClickEvent(event){
    const target = event.target
    if(!target) {
        return
    }
    target.parentNode.removeChild(target)
    window.webkit.messageHandlers.app.postMessage(document.documentElement.outerHTML.toString())
}

Array.from(document.querySelectorAll('a')).forEach(function (el) {
                                                   el.addEventListener('click', function(event) {
                                                                       event.preventDefault()
                                                                       handleClickEvent(event)
                                                                       }, false)

Array.from(document.querySelectorAll('p')).forEach(function (el) {
                                                   el.addEventListener('click', function(event) {
                                                                       event.preventDefault()
                                                                       handleClickEvent(event)
                                                                       }, false)
                                                   })
Array.from(document.querySelectorAll('div')).forEach(function (el) {
                                                     el.addEventListener('click', function(event) {
                                                                         event.preventDefault()
                                                                         handleClickEvent(event)
                                                                         }, false)
                                                     })
