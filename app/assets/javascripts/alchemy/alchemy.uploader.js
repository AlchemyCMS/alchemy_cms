if (typeof(Alchemy) === 'undefined') {
	var Alchemy = {};
}

Alchemy.Uploader = {

	HTML5uploadPossible: function() {
		function supportFileAPI() {
			var fi = document.createElement('INPUT');
			fi.type = 'file';
			return 'files' in fi;
		};
		function supportAjaxUploadProgressEvents() {
			var xhr = new XMLHttpRequest();
			return !! (xhr && ('upload' in xhr) && ('onprogress' in xhr.upload));
		};
		return typeof(window.FileReader) !== 'undefined' && supportFileAPI() && supportAjaxUploadProgressEvents();
		//return false;
	},

	init: function(settings) {
		var self = Alchemy.Uploader;
		
		function initHTML5Uploader() {
			$("#dropbox, #multiple").html5Uploader({
				name: "Filedata",
				postUrl: settings.upload_url,
				postParams: settings.post_params,
				onSuccess: function(event, file, responseText, successfullyUploadedFiles) {
					eval(responseText);
					var progress = new Alchemy.FileProgress(file);
					$('#upload_info').text(self.t('success_notice').replace('x', successfullyUploadedFiles));
					progress.setStatus(self.t('complete'));
					progress.setComplete();
				},
				onDragEnter: function(dropbox, event) {
					$(dropbox)
						.addClass('dragover')
						.text(self.t('drop_files_notice'));
				},
				onDragLeave: function(dropbox, event) {
					$(dropbox)
						.removeClass('dragover')
						.text(self.t('drag_files_notice'));
				},
				onDrop: function(dropbox, event) {
					$(dropbox)
						.removeClass('dragover')
						.text(self.t('drag_files_notice'));
				},
				onQueueStart: function(files) {
					var $status = $("#upload_info");
					if (Alchemy.Uploader.locale == 'en') {
						$status.text(files + " file" + (files === 1 ? "" : "s") + " queued.");
					} else {
						$status.text(files + " Datei" + (files === 1 ? "" : "en") + " in der Warteschlange.");
					}
					$('#upload_info_container').show();
					$('#dropbox').hide('fast');
					$('#multiple').hide();
					$('#cancelHTML5Queue').show();
				},
				onQueueComplete: function(files, status) {
					var $status = $("#upload_info");
					if (Alchemy.Uploader.locale == 'en') {
						$status.text(files + " file" + (files === 1 ? "" : "s") + " uploaded.");
					} else {
						$status.text(files + " Datei" + (files === 1 ? "" : "en") + " hochgeladen.");
					}
					$('#dropbox').show();
					$('#multiple').show().parents('form').get(0).reset();
					$('#cancelHTML5Queue').hide();
					if (status === 200) {
						window.setTimeout(function() {
							Alchemy.closeCurrentWindow();
						}, 3500);	
					}
				},
				onClientLoadStart: function(event, file) {
					var progress = new Alchemy.FileProgress(file);
					progress.setStatus(self.t('pending'));
				},
				onServerLoadStart: function(event, file) {
					var progress = new Alchemy.FileProgress(file);
					progress.setStatus(self.t('uploading'));
					progress.$fileProgressCancel.show().on('click', function(e) {
						e.preventDefault();
						$().html5Uploader('cancel', file.id);
						progress.setStatus(self.t('cancelled'));
						progress.setCancelled();
						return false;
					});
				},
				onServerProgress: function(event, file) {
					var progress = new Alchemy.FileProgress(file);
					var percentUploaded = (event.loaded / event.total) * 100;
					progress.setProgress(percentUploaded);
					progress.setStatus(self.t('uploading') + SWFUpload.speed.formatPercent(percentUploaded));
				},
				onServerError: function(e, file, errorMessage) {
					Alchemy.debug(e);
					var progress = new Alchemy.FileProgress(file);
					progress.setError();
					progress.setStatus(errorMessage);
				},
				onQueueCancelled: function(queuedFiles) {
					for (var i = queuedFiles.length - 1; i >= 0; i--) {
						var progress = new Alchemy.FileProgress(queuedFiles[i]);
						progress.setStatus(self.t('cancelled'));
						progress.setCancelled();
					}
					$('#cancelHTML5Queue').hide();
				}
			});
		}
		
		function initFlashUploader() {
			try {
				var swfu = new SWFUpload({
					flash_url: "/assets/swfupload/swfupload.swf",
					flash9_url: "/assets/swfupload/swfupload.swf",
					upload_url: settings.upload_url,
					post_params: settings.post_params,
					file_size_limit: settings.file_size_limit + ' MB',
					file_types: settings.file_types,
					file_types_description: settings.file_types_description,
					file_upload_limit: settings.file_upload_limit,
					file_queue_limit: 0,
					custom_settings: {
						language: settings.locale
					},
					debug: false,
					button_image_url: "/assets/alchemy/swfupload/browse_button.png",
					button_width: "120",
					button_height: "25",
					button_placeholder_id: "spanButtonPlaceHolder",
					button_text: "<span class='swfButtonText'>"+self.t('browse')+"</span>",
					button_text_style: '.swfButtonText {font-size: 11px; font-family: "Lucida Grande", Arial, sans-serif; text-align: center; color: #333333; height: 25px; padding-left: 8px; padding-right: 8px; padding-bottom: 3px; padding-top: 5px}',
					button_text_left_padding: 0,
					button_text_top_padding: 4,
					swfupload_load_failed_handler: function () {
						$('#swf_upload_container').hide();
						$('#choose_alternative_uploader').hide();
						$('#switch_to_flash_uploader').hide();
						$('#swfUploadFlashError').show();
						$('#alternativeUpload').show();
					},
					file_queued_handler : Alchemy.SWFUpload.fileQueued,
					file_queue_error_handler : Alchemy.SWFUpload.fileQueueError,
					file_dialog_complete_handler : Alchemy.SWFUpload.fileDialogComplete,
					upload_start_handler : Alchemy.SWFUpload.uploadStart,
					upload_progress_handler : Alchemy.SWFUpload.uploadProgress,
					upload_error_handler : Alchemy.SWFUpload.uploadError,
					upload_success_handler : Alchemy.SWFUpload.uploadSuccess,
					queue_complete_handler : Alchemy.SWFUpload.queueComplete
				});
				swfu.window_mode = "opaque";
			} catch(err) {
				Alchemy.debug(err);
				$('#swf_upload_container').hide();
				$('#choose_alternative_uploader').hide();
				$('#alternativeUpload').show();
				$('#flash_upload_error_explanation').show();
			};
		}
		
		self.locale = settings.locale;
		
		if (self.HTML5uploadPossible()) {
			$('#swf_upload_container').hide();
			$('#explain_step3').hide();
			$('#explain_drag_n_drop').show();
			initHTML5Uploader(settings);
			$('#cancelHTML5Queue').on('click', function(e) {
				e.preventDefault();
				$().html5Uploader('cancelQueue');
				return false;
			});
		} else {
			$('#multiple').hide();
			$('#dropbox').hide();
			$('#explain_step3').show();
			$('#explain_drag_n_drop').hide();
			initFlashUploader(settings);
		}
		
	},

	translation: {
		'browse' : {
			'de' : 'durchsuchen',
			'en' : 'browse'
		},
		'pending' : {
			'de' : 'Wartend...',
			'en' : 'Pending...'
		},
		'uploading' : {
			'de' : 'Ladend...',
			'en' : 'Uploading...'
		},
		'remaining' : {
			'de' : ' verbleibend.',
			'en' : ' remaining.'
		},
		'complete' : {
			'de' : 'Abgeschlossen',
			'en' : "Complete"
		},
		'cancelled' : {
			'de' : 'Abgebrochen',
			'en' : 'Cancelled'
		},
		'stopped' : {
			'de' : 'Gestoppt',
			'en' : 'Stopped'
		},
		'upload_failed' : {
			'de' : 'Fehlgeschlagen!',
			'en' : 'Upload Failed!'
		},
		'file_too_big' : {
			'de' : 'Datei ist zu groß!',
			'en' : 'File is too big!'
		},
		'upload_limit_exceeded' : {
			'de' : 'Maximales Dateilimit erreicht.',
			'en' : 'Upload limit exceeded.'
		},
		'validation_failed' : {
			'de' : 'Validierung fehlgeschlagen. Ladevorgang angehalten.',
			'en' : "Failed Validation. Upload skipped."
		},
		'zero_byte_file' : {
			'de' : 'Datei hat keinen Inhalt!',
			'en' : 'Cannot upload Zero Byte files!'
		},
		'invalid_file' : {
			'de' : 'Ungültiger Dateityp!',
			'en' : 'Invalid File Type!'
		},
		'unknown_error' : {
			'de' : 'Unbekannter Fehler!',
			'en' : 'Unhandled Error!'
		},
		'drag_files_notice' : {
			'de' : 'Oder ziehen Sie die Dateien hier rauf',
			'en' : 'Or drag files over here'
		},
		'drop_files_notice' : {
			'de' : 'Lassen Sie die Dateien nun los',
			'en' : 'Now drop the files'
		},
		'queued_files_notice' : {
			'de' : 'x Dateien in der Warteschlange.',
			'en' : 'Queued x files.'
		},
		'success_notice' : {
			'de' : 'x Dateien hochgeladen.',
			'en' : 'Uploaded x files.'
		}
	},

	t : function(id) {
		try {
			var self = Alchemy.Uploader;
			var translation = self.translation[id];
			if (translation) {
				return translation[self.locale];
			} else {
				return id;
			}
		} catch(ex) {
			this.debug(ex);
		}
	},

};
