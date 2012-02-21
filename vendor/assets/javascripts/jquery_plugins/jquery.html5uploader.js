(function ($) {

	var xhrRequestQueue = {};
	var settings;
	var queuedFiles;
	var fileList;
	var methods = {

		init : function(options) { 
				
			var crlf = '\r\n';
			var boundary = "alchemy";
			var dashes = "--";
			var successfullyUploadedFiles = 0;

			settings = {
				"name": "uploadedFile",
				"postUrl": "Upload.aspx",
				"onClientAbort": null,
				"onClientError": null,
				"onClientLoad": null,
				"onClientLoadEnd": null,
				"onClientLoadStart": null,
				"onClientProgress": null,
				"onServerAbort": null,
				"onServerError": null,
				"onServerLoad": null,
				"onServerLoadStart": null,
				"onServerProgress": null,
				"onServerReadyStateChange": null,
				"onSuccess": null,
				"onDragEnter": null,
				"onDragOver": null,
				"onDragLeave": null,
				"onDrop": null,
				"onQueueStart": null,
				"onQueueComplete": null,
				"onQueueCancelled": null,
				"postParams": null
			};

			if (options) {
				$.extend(settings, options);
			}

			return this.each(function (options) {
				var $this = $(this);
				if ($this.is("[type=\"file\"]")) {
					$this.bind("change", function () {
						fillFileQueue(this.files);
						startUpload();
					});
				} else {
					$this.bind("dragenter", function (e) {
						if (settings.onDragEnter) {
							settings.onDragEnter($this, e);
						}
						return false;
					}).bind("dragover", function (e) {
						if (settings.onDragOver) {
							settings.onDragOver($this, e);
						}
						return false;
					}).bind("dragleave", function (e) {
						if (settings.onDragLeave) {
							settings.onDragLeave($this, e);
						}
						return false;
					}).bind("drop", function (e) {
						fillFileQueue(e.originalEvent.dataTransfer.files);
						startUpload();
						if (settings.onDrop) {
							settings.onDrop($this, e);
						}
						return false;
					});
				}
			});

			// Populating our own files array so we can be sure the browser does not change it.
			function fillFileQueue(files) {
				queuedFiles = [];
				fileList = files; //storing the original browsers FileList object.
				for (var file in files) {
					if (files.hasOwnProperty(file) && typeof(files[file]) === 'object') {
						queuedFiles.push(files[file]);
					}
				}
				return queuedFiles;
			}

			function startUpload () {
				if (settings.onQueueStart) {
					settings.onQueueStart(queuedFiles.length);
					successfullyUploadedFiles = 0;
				}
				for (var i = 0; i < queuedFiles.length; i++) {
					var file = queuedFiles[i];
					$.extend(file, {id: "file_progress_" + i});
					fileHandler(file);
				}
			}

			function fileHandler(file) {
				var xmlHttpRequest;
				var fileReader = new FileReader();
				fileReader.onabort = function (e) {
					if (settings.onClientAbort) {
						settings.onClientAbort(e, file);
					}
				};
				fileReader.onerror = function (e) {
					if (settings.onClientError) {
						settings.onClientError(e, file);
					}
				};
				fileReader.onload = function (e) {
					if (settings.onClientLoad) {
						settings.onClientLoad(e, file);
					}
				};
				fileReader.onloadend = function (e) {
					if (settings.onClientLoadEnd) {
						settings.onClientLoadEnd(e, file);
					}
				};
				fileReader.onloadstart = function (e) {
					if (settings.onClientLoadStart) {
						settings.onClientLoadStart(e, file);
					}
				};
				fileReader.onprogress = function (e) {
					if (settings.onClientProgress) {
						settings.onClientProgress(e, file);
					}
				};
				fileReader.readAsDataURL(file);

				xmlHttpRequest = new XMLHttpRequest();
				xhrRequestQueue[file.id] = xmlHttpRequest;

				xmlHttpRequest.upload.onabort = function (e) {
					if (settings.onServerAbort) {
						settings.onServerAbort(e, xhrRequestQueue);
					}
				};
				xmlHttpRequest.upload.onerror = function (e) {
					if (settings.onServerError) {
						settings.onServerError(e, file);
					}
				};
				xmlHttpRequest.upload.onload = function (e) {
					if (settings.onServerLoad) {
						settings.onServerLoad(e, file);
					}
				};
				xmlHttpRequest.upload.onloadstart = function (e) {
					if (settings.onServerLoadStart) {
						settings.onServerLoadStart(e, file);
					}
				};
				xmlHttpRequest.upload.onprogress = function (e) {
					if (settings.onServerProgress) {
						settings.onServerProgress(e, file);
					}
				};
				xmlHttpRequest.onreadystatechange = function (e) {
					if (settings.onServerReadyStateChange) {
						settings.onServerReadyStateChange(e, file, xmlHttpRequest.readyState);
					}
					if (xmlHttpRequest.readyState === 4) {
						if (xmlHttpRequest.status === 200) {
							successfullyUploadedFiles++;
							if (settings.onSuccess) {
								settings.onSuccess(e, file, xmlHttpRequest.responseText, successfullyUploadedFiles);
							}
						} else if (xmlHttpRequest.status === 500) {
							if (settings.onServerError) {
								settings.onServerError(e, file, xmlHttpRequest.statusText);
							}
						}
						if (queuedFiles[Math.abs(queuedFiles.length) - 1] === file) {
							completeQueue(xmlHttpRequest.status);
						}
					}
				};
				xmlHttpRequest.open("POST", settings.postUrl, true);

				if (file.getAsBinary) { // Firefox

					var data = dashes + boundary + crlf +
						"Content-Disposition: form-data;" +
						"name=\"" + settings.name + "\";" +
						"filename=\"" + unescape(encodeURIComponent(file.name)) + "\"" + crlf +
						"Content-Type: application/octet-stream" + crlf + crlf +
						file.getAsBinary() + crlf +
						dashes + boundary + dashes;
					
					xmlHttpRequest.setRequestHeader("Content-Type", "multipart/form-data;boundary=" + boundary);
					xmlHttpRequest.sendAsBinary(data);

				} else if (window.FormData) { // Chrome

					var formData = new FormData();
					var postParams = settings.postParams;

					formData.append(settings.name, file);

					 // Appending additional parameters to FormData object
					if (postParams) {
						for(var param in postParams) {
							if (postParams.hasOwnProperty(param)) {
								formData.append(param, postParams[param]);
							}
						}
					}

					xmlHttpRequest.send(formData);

				}
			}

			function completeQueue(status) {
				if (settings.onQueueComplete) {
					settings.onQueueComplete(successfullyUploadedFiles, status);
				}
			}

		},

		// Cancel the whole queue
		cancelQueue : function() {
			for (var file_id in xhrRequestQueue) {
				if (xhrRequestQueue.hasOwnProperty(file_id)) {
					xhrRequestQueue[file_id].abort();
					delete xhrRequestQueue[file_id];
				}
			}
			if (settings.onQueueCancelled) {
				settings.onQueueCancelled(queuedFiles);
			}
		},

		// Cancel one upload
		cancel : function(file_id) { 
			var xhrRequest = xhrRequestQueue[file_id];
			if (xhrRequest) {
				xhrRequest.abort();
				delete xhrRequestQueue[file_id];
			}
		}

	};

	$.fn.html5Uploader = function( method ) {
		
		// Method calling logic
		if ( methods[method] ) {
			return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
		} else if ( typeof method === 'object' || ! method ) {
			return methods.init.apply( this, arguments );
		} else {
			$.error( 'Method ' +  method + ' does not exist on jQuery.html5Uploader' );
		}    
		
	};

})(jQuery);
