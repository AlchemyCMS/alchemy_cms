window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.FileProgress = (file) ->

    # Build Wrapper
    @$fileProgressWrapper = $('<div class="progress-wrapper"/>')

    # Build Container
    @$fileProgressElement = $('<div class="progress-container"/>')

    # Append Cancel Button
    @$fileProgressCancel = $('<a href="javascript:void(0);" class="progress-cancel"><i class="fas fa-times fa-fw"/></a>')
    @$fileProgressElement.append @$fileProgressCancel

    # Append Filename
    @$fileProgressElement.append "<div class=\"progress-name\">" + file.name + "</div>"

    # Append Progressbar Status Text
    @$fileProgressStatus = $('<div class="progress-bar-status">&nbsp;</div>')
    @$fileProgressElement.append @$fileProgressStatus

    # Build Progressbar Container
    $progressBarContainer = $('<div class="progress-bar-container"/>')

    # Build Progressbar
    @$progressBar = $('<div class="progress-bar-in-progress"/>')

    # Knit all together
    $progressBarContainer.append @$progressBar
    @$fileProgressElement.append $progressBarContainer
    @$fileProgressWrapper.append @$fileProgressElement
    $('.upload-progress-container').append @$fileProgressWrapper
    this

Alchemy.FileProgress::reset = ->
  @$fileProgressStatus.html '&nbsp;'
  @$progressBar.removeClass().addClass 'progress-bar-in-progress'
  @$progressBar.css width: '0%'

Alchemy.FileProgress::setProgress = (percentage) ->
  @$progressBar.removeClass().addClass 'progress-bar-in-progress'
  @$progressBar.css width: percentage + '%'

Alchemy.FileProgress::setComplete = ->
  @$progressBar.removeClass().addClass 'progress-bar-complete'
  @$progressBar.css width: '100%'
  @$fileProgressCancel.hide()
  @$fileProgressWrapper.delay(1500).fadeOut ->
    $(this).remove()

Alchemy.FileProgress::setError = ->
  @$progressBar.removeClass().addClass 'progress-bar-error'
  @$progressBar.css width: '100%'

Alchemy.FileProgress::setCancelled = ->
  @$progressBar.removeClass().addClass 'progress-bar-canceled'
  @$progressBar.css width: '100%'
  @$fileProgressCancel.hide()
  @$fileProgressWrapper.delay(1500).fadeOut ->
    $(this).remove()
    if $('.upload-progress-container').is(':empty')
      $('.overall-upload').removeClass('visible')
    return

Alchemy.FileProgress::setStatus = (status) ->
  @$fileProgressStatus.text Alchemy.t(status)
