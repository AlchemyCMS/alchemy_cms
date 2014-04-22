window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.FileProgress = (file) ->

    # Build Wrapper
    @$fileProgressWrapper = $('<div class="progressWrapper"/>')

    # Build Container
    @$fileProgressElement = $('<div class="progressContainer"/>')

    # Append Cancel Button
    @$fileProgressCancel = $('<a href="javascript:void(0);" class="progressCancel"/>')
    @$fileProgressElement.append @$fileProgressCancel

    # Append Filename
    @$fileProgressElement.append "<div class=\"progressName\">" + file.name + "</div>"

    # Append Progressbar Status Text
    @$fileProgressStatus = $('<div class="progressBarStatus">&nbsp;</div>')
    @$fileProgressElement.append @$fileProgressStatus

    # Build Progressbar Container
    $progressBarContainer = $('<div class="progressBarContainer"/>')

    # Build Progressbar
    @$progressBar = $('<div class="progressBarInProgress"/>')

    # Knit all together
    $progressBarContainer.append @$progressBar
    @$fileProgressElement.append $progressBarContainer
    @$fileProgressWrapper.append @$fileProgressElement
    $('#uploadProgressContainer').append @$fileProgressWrapper
    this

Alchemy.FileProgress::reset = ->
  @$fileProgressStatus.html '&nbsp;'
  @$progressBar.removeClass().addClass 'progressBarInProgress'
  @$progressBar.css width: '0%'

Alchemy.FileProgress::setProgress = (percentage) ->
  @$progressBar.removeClass().addClass 'progressBarInProgress'
  @$progressBar.css width: percentage + '%'

Alchemy.FileProgress::setComplete = ->
  @$progressBar.removeClass().addClass 'progressBarComplete'
  @$progressBar.css width: '100%'
  @$fileProgressCancel.hide()
  @$fileProgressWrapper.delay(1500).fadeOut ->
    $(this).remove()

Alchemy.FileProgress::setError = ->
  @$progressBar.removeClass().addClass 'progressBarError'
  @$progressBar.css width: '100%'

Alchemy.FileProgress::setCancelled = ->
  @$progressBar.removeClass().addClass 'progressBarCanceled'
  @$progressBar.css width: '100%'
  @$fileProgressCancel.hide()
  @$fileProgressWrapper.delay(1500).fadeOut ->
    $(this).remove()

Alchemy.FileProgress::setStatus = (status) ->
  @$fileProgressStatus.text Alchemy._t(status)
