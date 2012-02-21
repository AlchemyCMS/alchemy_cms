if (typeof(Alchemy) === 'undefined') {
	var Alchemy = {};
}

(function($) {

	$.extend(Alchemy, {

		FileProgress : function(file) {
			var $progressBarContainer;
			this.fileID = file.id;
			this.$fileProgressWrapper = $('#' + this.fileID);
			if (!this.$fileProgressWrapper.get(0)) {
				// Build Wrapper
				this.$fileProgressWrapper = $('<div class="progressWrapper" id="'+this.fileID+'"/>');
				// Build Container
				this.$fileProgressElement = $('<div class="progressContainer"/>');
				// Append Cancel Button
				this.$fileProgressCancel = $('<a href="javascript:void(0);" class="progressCancel" style="display: none"/>');
				this.$fileProgressElement.append(this.$fileProgressCancel);
				// Append Filename
				this.$fileProgressElement.append('<div class="progressName">'+file.name+'</div>');
				// Append Progressbar Status Text
				this.$fileProgressStatus = $('<div class="progressBarStatus">&nbsp;</div>');
				this.$fileProgressElement.append(this.$fileProgressStatus);
				// Build Progressbar Container
				$progressBarContainer = $('<div class="progressBarContainer"/>');
				// Build Progressbar
				this.$progressBar = $('<div class="progressBarInProgress"/>');
				// Knit all together
				$progressBarContainer.append(this.$progressBar);
				this.$fileProgressElement.append($progressBarContainer);
				this.$fileProgressWrapper.append(this.$fileProgressElement);
				$('#uploadProgressContainer').append(this.$fileProgressWrapper);
			} else {
				this.$fileProgressElement = this.$fileProgressWrapper.find('.progressContainer');
				this.$fileProgressCancel = this.$fileProgressElement.find('.progressCancel');
				this.$fileProgressStatus = this.$fileProgressElement.find('.progressBarStatus');
				this.$progressBar = this.$fileProgressElement.find('.progressBarContainer *:first-child');
				this.reset();
			}
			this.setTimer(null);
			return this;
		}

	});

	Alchemy.FileProgress.prototype.setTimer = function (timer) {
		this.$fileProgressElement["FP_TIMER"] = timer;
	};

	Alchemy.FileProgress.prototype.getTimer = function (timer) {
		return this.$fileProgressElement["FP_TIMER"] || null;
	};

	Alchemy.FileProgress.prototype.reset = function () {
		this.$fileProgressStatus.html("&nbsp;");
		this.$progressBar.removeClass().addClass("progressBarInProgress");
		this.$progressBar.css({width: '0%'});
	};

	Alchemy.FileProgress.prototype.setProgress = function (percentage) {
		this.$progressBar.removeClass().addClass("progressBarInProgress");
		this.$progressBar.css({width: percentage + '%'});
	};

	Alchemy.FileProgress.prototype.setComplete = function () {
		this.$progressBar.removeClass().addClass("progressBarComplete");
		this.$progressBar.css({width: '100%'});
		this.$fileProgressWrapper.delay(1500).fadeOut(function() {
			$(this).remove();
		});
	};

	Alchemy.FileProgress.prototype.setError = function () {
		this.$progressBar.removeClass().addClass("progressBarError");
		this.$progressBar.css({width: '100%'});
	};

	Alchemy.FileProgress.prototype.setCancelled = function () {
		this.$progressBar.removeClass().addClass("progressBarCanceled");
		this.$progressBar.css({width: '100%'});
		this.$fileProgressWrapper.delay(1500).fadeOut(function() {
			$(this).remove();
		});
	};

	Alchemy.FileProgress.prototype.setStatus = function (status) {
		this.$fileProgressStatus.text(status);
	};

})(jQuery);
