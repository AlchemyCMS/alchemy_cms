/*
Copyright (c) 2009, http://seyfertdesign.com/jquery/ui-tabs-paging.html

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

(function($) {
	
	$.extend($.ui.tabs.prototype, {
		paging: function(options) {
			var opts = {
				tabsPerPage: 0,
				nextButton: '&#187;',
				prevButton: '&#171;',
				follow: false,
				cycle: false,
				selectOnAdd: false,
				followOnSelect: false
			};

			opts = $.extend(opts, options);

			var self = this, initialized = false, currentPage, 
				buttonWidth, containerWidth, allTabsWidth, tabWidths, 
				maxPageWidth, pages, resizeTimer = null, 
				windowHeight = $(window).height(), windowWidth = $(window).width();

			function init() {
				destroy();

				allTabsWidth = 0, currentPage = 0, maxPageWidth = 0, buttonWidth = 0,
					pages = new Array(), tabWidths = new Array(), selectedTabWidths = new Array();

				containerWidth = self.element.width();

				// loops through LIs, get width of each tab when selected and unselected.
				var maxDiff = 0;  // the max difference between a selected and unselected tab
				self.lis.each(function(i) {			
					if (i == self.options.selected) {
						selectedTabWidths[i] = $(this).outerWidth({ margin: true });
						tabWidths[i] = self.lis.eq(i).removeClass('ui-tabs-selected').outerWidth({ margin: true });
						self.lis.eq(i).addClass('ui-tabs-selected');
						maxDiff = Math.min(maxDiff, Math.abs(selectedTabWidths[i] - tabWidths[i]));
						allTabsWidth += tabWidths[i];
					} else {
						tabWidths[i] = $(this).outerWidth({ margin: true });
						selectedTabWidths[i] = self.lis.eq(i).addClass('ui-tabs-selected').outerWidth({ margin: true });
						self.lis.eq(i).removeClass('ui-tabs-selected');
						maxDiff = Math.max(maxDiff, Math.abs(selectedTabWidths[i] - tabWidths[i]));
						allTabsWidth += tabWidths[i];
					}
				});
	            // fix padding issues with buttons
	            // TODO determine a better way to handle this
				allTabsWidth += maxDiff + ($.browser.msie?4:0) + 9;  

				// if the width of all tables is greater than the container's width, calculate the pages
				if (allTabsWidth > containerWidth) {
					// create next button			
					li = $('<li></li>')
						.addClass('ui-state-default ui-tabs-paging-next')
						.append($('<a href="#"></a>')
								.click(function() { page('next'); return false; })
								.html(opts.nextButton));

					self.lis.eq(self.length()-1).after(li);
					buttonWidth = li.outerWidth({ margin: true });

					// create prev button
					li = $('<li></li>')
						.addClass('ui-state-default ui-tabs-paging-prev')
						.append($('<a href="#"></a>')
								.click(function() { page('prev'); return false; })
								.html(opts.prevButton));
					self.lis.eq(0).before(li);
					buttonWidth += li.outerWidth({ margin: true });

					// TODO determine fix for padding issues to next button
					buttonWidth += 19; 

					var pageIndex = 0, pageWidth = 0, maxTabPadding = 0;

					// start calculating pageWidths
					for (var i = 0; i < tabWidths.length; i++) {
						// if first tab of page or selected tab's padding larger than the current max, set the maxTabPadding
						if (pageWidth == 0 || selectedTabWidths[i] - tabWidths[i] > maxTabPadding)
							maxTabPadding = (selectedTabWidths[i] - tabWidths[i]);

						// if first tab of page, initialize pages variable for page 
						if (pages[pageIndex] == null) {
							pages[pageIndex] = { start: i };

						} else if ((i > 0 && (i % opts.tabsPerPage) == 0) || (tabWidths[i] + pageWidth + buttonWidth + 12) > containerWidth) {
							if ((pageWidth + maxTabPadding) > maxPageWidth)	
								maxPageWidth = (pageWidth + maxTabPadding);
							pageIndex++;
							pages[pageIndex] = { start: i };			
							pageWidth = 0;
						}
						pages[pageIndex].end = i+1;
						pageWidth += tabWidths[i];
						if (i == self.options.selected) currentPage = pageIndex;
					}
					if ((pageWidth + maxTabPadding) > maxPageWidth)	
						maxPageWidth = (pageWidth + maxTabPadding);				

				    // hide all tabs then show tabs for current page
					self.lis.hide().slice(pages[currentPage].start, pages[currentPage].end).show();
					if (currentPage == (pages.length - 1) && !opts.cycle) 
						disableButton('next');			
					if (currentPage == 0 && !opts.cycle) 
						disableButton('prev');

					// calculate the right padding for the next button
					buttonPadding = containerWidth - maxPageWidth - buttonWidth;
					if (buttonPadding > 0) 
						$('.ui-tabs-paging-next', self.element).css({ paddingRight: buttonPadding + 'px' });

					initialized = true;
				} else {
					destroy();
				}

				$(window).bind('resize', handleResize);
			}

			function page(direction) {
				currentPage = currentPage + (direction == 'prev'?-1:1);

				if ((direction == 'prev' && currentPage < 0 && opts.cycle) ||
					(direction == 'next' && currentPage >= pages.length && !opts.cycle))
					currentPage = pages.length - 1;
				else if ((direction == 'prev' && currentPage < 0) || 
						 (direction == 'next' && currentPage >= pages.length && opts.cycle))
					currentPage = 0;

				var start = pages[currentPage].start;
				var end = pages[currentPage].end;
				self.lis.hide().slice(start, end).show();

				if (direction == 'prev') {
					enableButton('next');
					if (opts.follow && (self.options.selected < start || self.options.selected > (end-1))) self.select(end-1);
					if (!opts.cycle && start <= 0) disableButton('prev');
				} else {
					enableButton('prev');
					if (opts.follow && (self.options.selected < start || self.options.selected > (end-1))) self.select(start);
					if (!opts.cycle && end >= self.length()) disableButton('next');
				}
			}

			function disableButton(direction) {
				$('.ui-tabs-paging-'+direction, self.element).addClass('ui-tabs-paging-disabled');
			}

			function enableButton(direction) {
				$('.ui-tabs-paging-'+direction, self.element).removeClass('ui-tabs-paging-disabled');
			}

			// special function defined to handle IE6 and IE7 resize issues
			function handleResize() {
				if (resizeTimer) clearTimeout(resizeTimer);

				if (windowHeight != $(window).height() || windowWidth != $(window).width()) 
					resizeTimer = setTimeout(reinit, 100);
			}

			function reinit() {	
				windowHeight = $(window).height();
				windowWidth = $(window).width();
				init();
			}

			function destroy() {
				// remove buttons
				$('.ui-tabs-paging-next', self.element).remove();
				$('.ui-tabs-paging-prev', self.element).remove();

				// show all tabs
				self.lis.show();

				initialized = false;

				$(window).unbind('resize', handleResize);
			}

			// reconfigure "ui.tabs" add/remove events to reinit paging
			var tabsAdd = self.add;
			self.add = function(url, label, index) {
				// remove paging buttons before adding a tab
				if (initialized)
					destroy();

				tabsAdd.apply(this, [url, label, index]);

				if (opts.selectOnAdd) {
					if (index == undefined) index = this.lis.length-1;
					this.select(index);
				}
				// re-initialize paging buttons
				init();
			};
			var tabsRemove = self.remove;
			self.remove = function(index) {
				// remove paging buttons before removing a tab
				if (initialized)
					destroy();

				tabsRemove.apply(this, [index]);

				// re-initialize paging buttons
				init();
			};
			// reconfigure "ui.tabs" select event to change pages if new tab is selected
			var tabsSelect = self.select;
			self.select = function(index) {
				var $panel;
				var $parent;
				if (typeof(index) === 'string') {
					$panel = $('#' + index);
					$parent = $panel.parent();
					// getting my index
					index = $parent.children('.ui-tabs-panel').index($panel);
				}
				tabsSelect.apply(this, [index]);
				// if paging is not initialized or it is not configured to 
				// change pages when a new tab is selected, then do nothing
				if (!initialized || !opts.followOnSelect)
					return;

				// find the new page based on index of the tab selected
				for (i in pages) {
					var start = pages[i].start;
					var end = pages[i].end;
					if (index >= start && index < end) {
						// if the the tab selected is not within the currentPage of tabs, then change pages
						if (i != currentPage) {
							self.lis.hide().slice(start, end).show();

							currentPage = parseInt(i);
							if (currentPage == 0) {
								enableButton('next');
								if (!opts.cycle && start <= 0) disableButton('prev');
							} else {
								enableButton('prev');
								if (!opts.cycle && end >= self.length()) disableButton('next');
							}
						}
						break;
					}
				}
			};

			// add, remove, and destroy functions specific for paging 
			$.extend($.ui.tabs.prototype, {
				pagingDestroy: function() {
					destroy();
				}
			});

			init();
		}
	});
	
})(jQuery);
