/* **********************
   Alchemy SWFUpload Event Handlers
   ********************** */

if (typeof(Alchemy) === 'undefined') {
	var Alchemy = {};
}

(function($) {

	$.extend(Alchemy, {

		SWFUpload : {

			init : function() {
				Alchemy.SWFUpload.language = this.customSettings['language'];
			},

			fileQueued: function(file) {
				try {
					var self = Alchemy.SWFUpload;
					var progress = new Alchemy.FileProgress(file);
					var status_text = self.getTranslation('pending');
					progress.setStatus(status_text);
					progress.toggleCancelButton(true, this);
				} catch (ex) {
					this.debug(ex);
				}
			},

			fileDialogComplete: function(numFilesSelected, numFilesQueued) {
				try {
					if (numFilesSelected > 0) {
						$('#swf_upload_container .button').show();
						$('#choose_alternative_uploader').hide();
					}
					/* I want auto start the upload and I can do that here */
					this.startUpload();
				} catch (ex)  {
					this.debug(ex);
				}
			},

			uploadStart: function(file) {
				try {
					var self = Alchemy.SWFUpload;
					var progress = new Alchemy.FileProgress(file);
					progress.setStatus(self.getTranslation('uploading'));
					progress.toggleCancelButton(true, this);
				}
				catch (ex) {}
				return true;
			},

			uploadProgress: function(file, bytesLoaded, bytesTotal) {
				try {
					var self = Alchemy.SWFUpload;
					var progress = new Alchemy.FileProgress(file);
					progress.setProgress(file.percentUploaded);
					progress.setStatus(self.getTranslation('uploading') + ' ('+SWFUpload.speed.formatPercent(file.percentUploaded)+') - ' + SWFUpload.speed.formatTime(file.timeRemaining) + self.getTranslation('remaining'));
				} catch (ex) {
					this.debug(ex);
				}
			},

			uploadSuccess: function(file, serverData) {
				eval(serverData);
				try {
					var self = Alchemy.SWFUpload;
					var progress = new Alchemy.FileProgress(file);
					progress.setComplete();
					progress.setStatus(self.getTranslation('complete'));
					progress.toggleCancelButton(false);
				} catch (ex) {
					this.debug(ex);
				}
			},

			uploadError: function(file, errorCode, message) {
				try {
					var self = Alchemy.SWFUpload;
					var progress = new Alchemy.FileProgress(file);
					progress.toggleCancelButton(false);
					switch (errorCode) {
					case SWFUpload.UPLOAD_ERROR.HTTP_ERROR:
						progress.setStatus("Upload Error: " + message);
						progress.setError();
						this.debug("Error Code: HTTP Error, File name: " + file.name + ", Message: " + message);
						break;
					case SWFUpload.UPLOAD_ERROR.UPLOAD_FAILED:
						progress.setStatus(self.getTranslation("upload_failed"));
						progress.setError();
						this.debug("Error Code: Upload Failed, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
						break;
					case SWFUpload.UPLOAD_ERROR.IO_ERROR:
						progress.setStatus("Server (IO) Error");
						progress.setError();
						this.debug("Error Code: IO Error, File name: " + file.name + ", Message: " + message);
						break;
					case SWFUpload.UPLOAD_ERROR.SECURITY_ERROR:
						progress.setStatus("Security Error");
						progress.setError();
						this.debug("Error Code: Security Error, File name: " + file.name + ", Message: " + message);
						break;
					case SWFUpload.UPLOAD_ERROR.UPLOAD_LIMIT_EXCEEDED:
						progress.setStatus(self.getTranslation("upload_limit_exceeded"));
						progress.setError();
						this.debug("Error Code: Upload Limit Exceeded, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
						break;
					case SWFUpload.UPLOAD_ERROR.FILE_VALIDATION_FAILED:
						progress.setStatus(self.getTranslation('validation_failed'));
						progress.setError();
						this.debug("Error Code: File Validation Failed, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
						break;
					case SWFUpload.UPLOAD_ERROR.FILE_CANCELLED:
						// If there aren't any files left (they were all cancelled) disable the cancel button
						if (this.getStats().files_queued === 0) {
							self.hideQueueCancelButton();
						}
						progress.setStatus(self.getTranslation("cancelled"));
						progress.setCancelled();
						break;
					case SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED:
						progress.setStatus(self.getTranslation('stopped'));
						progress.setCancelled();
						break;
					default:
						progress.setStatus("Unhandled Error: " + errorCode);
						progress.setError();
						this.debug("Error Code: " + errorCode + ", File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
						break;
					}
				} catch (ex) {
					this.debug(ex);
				}
			},

			fileQueueError: function(file, errorCode, message) {
				try {
					if (errorCode === SWFUpload.QUEUE_ERROR.QUEUE_LIMIT_EXCEEDED) {
						alert("You have attempted to queue too many files.\n" + (message === 0 ? "You have reached the upload limit." : "You may select " + (message > 1 ? "up to " + message + " files." : "one file.")));
						return;
					}
					var self = Alchemy.SWFUpload;
					var progress = new Alchemy.FileProgress(file);
					progress.setError();
					progress.toggleCancelButton(false);
					switch (errorCode) {
					case SWFUpload.QUEUE_ERROR.FILE_EXCEEDS_SIZE_LIMIT:
						progress.setStatus(self.getTranslation("file_too_big"));
						this.debug("Error Code: File too big, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
						break;
					case SWFUpload.QUEUE_ERROR.ZERO_BYTE_FILE:
						progress.setStatus(self.getTranslation("zero_byte_file"));
						this.debug("Error Code: Zero byte file, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
						break;
					case SWFUpload.QUEUE_ERROR.INVALID_FILETYPE:
						progress.setStatus(self.getTranslation("invalid_file"));
						this.debug("Error Code: Invalid File Type, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
						break;
					default:
						if (file !== null) {
							progress.setStatus(self.getTranslation("unknown_error"));
						}
						this.debug("Error Code: " + errorCode + ", File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
						break;
					}
				} catch (ex) {
					this.debug(ex);
				}
			},

			uploadComplete: function(file) {
				if (this.getStats().files_queued === 0) {
					Alchemy.SWFUpload.hideQueueCancelButton();
				}
			},

			queueComplete: function(numFilesUploaded) {
				var $status = $("#SWFUploadStatus");
				$status.show();
				if (Alchemy.SWFUpload.language == 'en') {
					$status.append(numFilesUploaded + " file" + (numFilesUploaded === 1 ? "" : "s") + " uploaded.");
				} else {
					$status.append(numFilesUploaded + " Datei" + (numFilesUploaded === 1 ? "" : "en") + " hochgeladen.");
				}
				Alchemy.SWFUpload.hideQueueCancelButton();
				setTimeout(function () {
					Alchemy.closeCurrentWindow();
				}, 3500);
			},

			translation: {
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
					'de' : 'Abgeschlossen.',
					'en' : "Complete."
				},
				'cancelled' : {
					'de' : 'Abgebrochen.',
					'en' : 'Cancelled.'
				},
				'stopped' : {
					'de' : 'Gestoppt',
					'en' : 'Stopped.'
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
				}
			},

			getTranslation : function(id) {
				try {
					var self = Alchemy.SWFUpload;
					var translation = self.translation[id];
					if (translation) {
						return translation[self.language];
					} else {
						return id;
					}
				} catch(ex) {
					this.debug(ex);
				}
			},

			hideQueueCancelButton : function() {
				$('#swf_upload_container .button').hide();
				$('#swf_upload_container .cloned-button').remove();
			}

		}

	});

	// Show/Hide the cancel button and bind click event.
	Alchemy.FileProgress.prototype.toggleCancelButton = function (show, swfUploadInstance) {
		show ? this.$fileProgressCancel.show() : this.$fileProgressCancel.hide();
		if (swfUploadInstance) {
			this.$fileProgressCancel.click(function (e) {
				e.preventDefault();
				swfUploadInstance.cancelUpload(this.fileID);
				return false;
			});
		}
	};

})(jQuery);
