#= require jquery-ui/widget
#= require alchemy/alchemy.file_progress
#= require fileupload/jquery.iframe-transport
#= require fileupload/jquery.fileupload
#= require fileupload/jquery.fileupload-process
#= require fileupload/jquery.fileupload-validate

window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.Uploader = (settings) ->
  totalFilesCount = 0
  completedUploads = 0
  $filesContainer = $('.upload-progress-container')
  selector = settings.selector || '.fileupload'
  $fields = $(selector)
  $dropZone = $(settings.dropzone)

  # Normalize file types regex
  file_types = if settings.file_types == '*' then '.+' else settings.file_types

  # Disable the default browser dragdrop handling
  $(document).bind 'drop dragover', (e) ->
    e.preventDefault()

  $dropZone.on 'dragleave', ->
    $dropZone.removeClass('dragover')

  getNumberOfFiles = ->
    $filesContainer
      .children()
      .not('.progress-bar-in-progress').length - 1

  dragover = ->
    $dropZone.addClass('dragover')
    return

  add = (e, data) ->
    $this = $(this)
    data.context = new Alchemy.FileProgress(data.files[0])
    totalFilesCount = data.originalFiles.length
    $('.total-files-count').text(totalFilesCount)
    $dropZone.removeClass('dragover').addClass('upload-in-progress')
    $('.overall-upload').addClass('visible')
    # trigger validations
    data.process -> $this.fileupload('process', data)
    if data.files.error
      data.context.setError()
      data.context.setStatus(data.files[0].error)
      data.context.$fileProgressCancel.click (e) ->
        data.context.setCancelled()
        data.context.setStatus('cancelled')
        return false
      return false
    else
      xhr = data.submit()
      data.context.$fileProgressCancel.click (e) ->
        xhr.abort()
        data.context.setCancelled()
        data.context.setStatus('cancelled')
        return false
      return xhr

  progress = (e, data) ->
    progress = parseInt(data.loaded / data.total * 100, 10)
    data.context.setProgress(progress)
    return

  progressall = (e, data) ->
    progress = parseInt(data.loaded / data.total * 100, 10)
    bar = $('.overall-upload .progress')
    bar.css width: "#{progress}%"
    $('.progress-status').text("#{progress}%")
    return

  done = (e, data) ->
    completedUploads += 1
    $('.uploaded-files-count').text(completedUploads)
    data.context.setComplete()
    data.context.setStatus('complete')
    response_data = data.xhr().response
    if completedUploads == totalFilesCount
      completedUploads = 0
      totalFilesCount = 0
      $('.overall-upload').removeClass('visible')
      settings.complete()
    return

  fail = (e, data) ->
    data.context.setError()
    response_data = data.xhr().response
    if response_data
      response = JSON.parse(response_data)
      error = response.files[0].error
    data.context.setStatus(error || data.textStatus)
    return

  always = (e, data) ->
    xhr = data.xhr()
    response_data = xhr.response
    if response_data
      response = JSON.parse(response_data)
      if response.growl_message
        Alchemy.growl(response.growl_message, if xhr.status == 422 then 'alert' else 'notice')
    return

  $fields.each ->
    $field = $(this)
    $form = $field.parents('form')
    url = $form.attr('action')
    http_method = $form.find('[name="_method"]').val()
    # Init jquery.fileupload
    $field.fileupload
      url: url
      type: if http_method then http_method.toUpperCase() else 'POST'
      dropZone: $dropZone
      dataType: 'json'
      filesContainer: $filesContainer
      acceptFileTypes: new RegExp("(.|/)(#{file_types})", "i")
      maxNumberOfFiles: Alchemy.uploader_defaults.file_upload_limit
      maxFileSize: Alchemy.uploader_defaults.file_size_limit * 1000000
      getNumberOfFiles: getNumberOfFiles
      dragover: dragover
      add: add
      progress: progress
      progressall: progressall
      done: done
      fail: fail
      always: always
    return

  return
