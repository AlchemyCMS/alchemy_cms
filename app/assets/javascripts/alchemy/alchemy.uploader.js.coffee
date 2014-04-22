#= require jquery.ui.widget
#= require alchemy/alchemy.file_progress
#= require fileupload/jquery.iframe-transport
#= require fileupload/jquery.fileupload
#= require fileupload/jquery.fileupload-process
#= require fileupload/jquery.fileupload-validate

window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.Uploader = (settings) ->
  totalFilesCount = 0
  completedUploads = 0

  # Normalize file types regex
  file_types = if settings.file_types == '*' then '.+' else settings.file_types

  # Disable the default browser dragdrop handling
  $(document).bind 'drop dragover', (e) ->
    e.preventDefault()

  # Hide the upload form submit button
  $('.upload-button').hide()

  # Init jquery.fileupload
  $("#fileupload").fileupload
    dropZone: '#dropbox'
    dataType: 'json'
    acceptFileTypes: new RegExp("(.|/)(#{file_types})", "i")
    maxNumberOfFiles: settings.file_upload_limit
    maxFileSize: settings.file_size_limit * 1000000
    formData: (form) ->
      form_data = form.serializeArray()
      $.merge(form_data, settings.post_params)
      form_data
    add: (e, data) ->
      $this = $(this)
      data.context = new Alchemy.FileProgress(data.files[0])
      totalFilesCount = data.originalFiles.length
      $('.total-files-count').text(totalFilesCount)
      $('.overall-upload').show()
      # trigger validations
      data.process -> $this.fileupload('process', data)
      if data.files.error
        data.context.setError()
        data.context.setStatus(data.files[0].error)
        data.context.$fileProgressCancel.click (e) ->
          e.preventDefault()
          data.context.setCancelled()
          data.context.setStatus('cancelled')
          false
        false
      else
        xhr = data.submit()
        data.context.$fileProgressCancel.click (e) ->
          e.preventDefault()
          xhr.abort()
          data.context.setCancelled()
          data.context.setStatus('cancelled')
          false
        xhr
    progress: (e, data) ->
      progress = parseInt(data.loaded / data.total * 100, 10)
      data.context.setProgress(progress)
    progressall: (e, data) ->
      progress = parseInt(data.loaded / data.total * 100, 10)
      bar = $('.overall-upload .progress')
      bar.css width: "#{progress}%"
      $('.progress-status').text("#{progress}%")
    done: (e, data) ->
      completedUploads += 1
      $('.uploaded-files-count').text(completedUploads)
      data.context.setComplete()
      data.context.setStatus('complete')
      response_data = data.xhr().response
      if completedUploads == totalFilesCount
        completedUploads = 0
        totalFilesCount = 0
        # wait 2 seconds before calling callback
        window.setTimeout ->
          settings.complete()
        , 2000
    fail: (e, data) ->
      data.context.setError()
      response_data = data.xhr().response
      if response_data
        response = JSON.parse(response_data)
        error = response.files[0].error
      data.context.setStatus(error || data.textStatus)
    always: (e, data) ->
      xhr = data.xhr()
      response_data = xhr.response
      if response_data
        response = JSON.parse(response_data)
        if response.growl_message
          Alchemy.growl(response.growl_message, if xhr.status == 422 then 'alert' else 'notice')

  return
