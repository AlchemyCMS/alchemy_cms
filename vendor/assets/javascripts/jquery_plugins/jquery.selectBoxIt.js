/* jquery Selectboxit - v0.9.0 - 2012-05-21
* http://www.gregfranko.com/jQuery.selectBoxIt.js/
* Copyright (c) 2012 Greg Franko; Licensed MIT */

// Immediately-Invoked Function Expression (IIFE) [Ben Alman Blog Post](http://benalman.com/news/2010/11/immediately-invoked-function-expression/) that calls another IIFE that contains all of the plugin logic.  I used this pattern so that anyone viewing this code would not have to scroll to the bottom of the page to view the local parameters that were passed to the main IIFE.

(function (selectBoxIt) {

    //ECMAScript 5 Strict Mode: [John Resig Blog Post](http://ejohn.org/blog/ecmascript-5-strict-mode-json-and-more/)
    "use strict";

    // Calls the second IIFE and locally passes in the global jQuery, window, and document objects
    selectBoxIt(jQuery, window, document);

}

// Locally passes in `jQuery`, the `window` object, the `document` object, and an `undefined` variable.  The `jQuery`, `window` and `document` objects are passed in locally, to improve performance, since javascript first searches for a variable match within the local variables set before searching the global variables set.  All of the global variables are also passed in locally to be minifier friendly. `undefined` can be passed in locally, because it is not a reserved word in JavaScript.

(function ($, window, document, undefined) {

    // ECMAScript 5 Strict Mode: [John Resig Blog Post](http://ejohn.org/blog/ecmascript-5-strict-mode-json-and-more/)
    "use strict";

    // Calling the jQueryUI Widget Factory Method
    $.widget("selectBox.selectBoxIt", {

        // Plugin version

        version: "0.9.0",

        // These options will be used as defaults
        options: {

            // **showEffect**: Accepts String: "none", "fadeIn", "show", "slideDown", or any of the jQueryUI show effects (i.e. "bounce")
            showEffect: "none",

            // **showEffectOptions**: Accepts an object literal.  All of the available properties are based on the jqueryUI effect options
            showEffectOptions: {},

            // **showEffectSpeed**: Accepts Number (milliseconds) or String: "slow", "medium", or "fast"
            showEffectSpeed: "medium",

            // **hideEffect**: Accepts String: "none", "fadeOut", "hide", "slideUp", or any of the jQueryUI hide effects (i.e. "explode")
            hideEffect: "none",

            // **hideEffectOptions**: Accepts an object literal.  All of the available properties are based on the jqueryUI effect options
            hideEffectOptions: {},

            // **hideEffectSpeed**: Accepts Number (milliseconds) or String: "slow", "medium", or "fast"
            hideEffectSpeed: "medium",

            // **showFirstOption**: Shows the first dropdown list option within the dropdown list options list
            showFirstOption: true,

            // **defaultText**: Overrides the text used by the dropdown list selected option to allow a user to specify custom text.  Accepts a String.
            defaultText: "",

            // **defaultIcon**: Overrides the icon used by the dropdown list selected option to allow a user to specify a custom icon.  Accepts a String (CSS class name(s)).
            defaultIcon: "",

            // **downArrowIcon**: Overrides the default down arrow used by the dropdown list to allow a user to specify a custom image.  Accepts a String (CSS class name(s)).
            downArrowIcon: ""

        },

        // _Create
        // -------
        //      Sets the Plugin Instance variables and
        //      constructs the plugin.  Only called once.
        _create: function() {

            // The original select box DOM element
            this.originalElem = this.element[0];

            // The original select box DOM element wrapped in a jQuery object
            this.selectBox = this.element;

            // All of the original select box options
            this.selectItems = this.element.find("option");

            // The first option in the original select box
            this.firstSelectItem = this.element.find("option").slice(0, 1);

            // The index of the currently selected dropdown list option
            this.currentFocus = 0;

            // Keeps track of which blur events will hide the dropdown list options
            this.blur = true;

            // The html document height
            this.documentHeight = $(document).height();

            // Array holding all of the original select box options text
            this.textArray = [];

            // Maintains search order in the `search` method
            this.currentIndex = 0;

            // Whether or not the dropdown list opens up or down (depending on how much room is on the page)
            this.flipped = false;

            // Creates the div elements that will become the dropdown
            this._createDiv();

            // Creates the ul element that will become the dropdown options list
            this._createUnorderedList();

            // Hides the original select box and adds the new plugin DOM elements to the page
            this._replaceSelectBox();

            // Adds event handlers to the new dropdown list
            this._eventHandlers();

            if(this.originalElem.disabled && this.disable) {

                // Disables the dropdown list if the original dropdown list had the `disabled` attribute
                this.disable();

            }

            if(this._ariaAccessibility) {

                // Adds ARIA accessibillity tags to the dropdown list
                this._ariaAccessibility();

            }

            // Adds jQueryUI classes to the dropdown list if the jqueryUI option is set to true
            this._addClasses();

            // Focus the selectbox div, if the original select tag has autofocus attribute
            if (this.selectBox.attr("autofocus")) {

                this.div.focus();

            }

            // Triggers a custom `create` event on the original dropdown list
            this.selectBox.trigger("create");

        },
        // _Create Div
        // -----------
        //      Creates new div and span elements to replace
        //      the original select box with a dropdown list
        _createDiv: function() {

            // Creates a span element that contains the dropdown list text value
            this.divText = $("<span/>", {

                // Dynamically sets the span `id` attribute
                "id": this.originalElem.id + "SelectBoxItText",

                "class": "selectboxit-text",

                // IE specific attribute to not allow the element to be selected
                "unselectable": "on",

                // Sets the span `text` to equal the original select box default value
                "text": this.firstSelectItem.text()

            }).

            // Sets the HTML5 data attribute on the divText `span` element
            attr("data-val", this.originalElem.value);

            // Creates a span element that contains the dropdown list text value
            this.divImage = $("<span/>", {

                // Dynamically sets the span `id` attribute
                "id": this.originalElem.id + "SelectBoxItDefaultIcon",

                "class": "selectboxit-default-icon",

                // IE specific attribute to not allow the element to be selected
                "unselectable": "on"

            });

            // Creates a div to act as the new dropdown list
            this.div = $("<div/>", {

                // Dynamically sets the div `id` attribute
                "id": this.originalElem.id + "SelectBoxIt",

                "class": "selectboxit" + (this.originalElem.className !== "" ? " " + this.originalElem.className : ""),

                // Sets the div `name` attribute to be the same name as the original select box
                "name": this.originalElem.name,

                // Sets the div `tabindex` attribute to 0 to allow the div to be focusable
                "tabindex": 0,

                // IE specific attribute to not allow the element to be selected
                "unselectable": "on"

            }).

            // Appends the default text to the inner dropdown list div element
            append(this.divImage).append(this.divText);

            // Create the div container that will hold all of the dropdown list dom elements
            this.divContainer = $("<div/>", {

                "id": this.originalElem.id + "SelectBoxItContainer",

                "class": "selectboxit-container"
            }).

            // Appends the inner dropdown list div element to the dropdown list container div element
            append(this.div);

            // Maintains chainability
            return this;
        },

        // _Create Unordered List
        // ----------------------
        //      Creates an unordered list element to hold the
        //        new dropdown list options that directly match
        //        the values of the original select box options
        _createUnorderedList: function() {

            // Storing the context of the widget
            var self = this,

                dataDisabled,

                optgroupClass = "",

                optgroupElement = "",

                iconClass,

                // Declaring the variable that will hold all of the dropdown list option elements
                currentItem = "",
                // Creates an unordered list element
                createdList = $("<ul/>", {

                    // Sets the unordered list `id` attribute
                    "id": this.originalElem.id + "SelectBoxItOptions",

                    "class": "selectboxit-options",

                    //Sets the unordered list `tabindex` attribute to -1 to prevent the unordered list from being focusable
                    "tabindex": -1

                });

            // Checks the `showFirstOption` plugin option to determine if the first dropdown list option should be shown in the options list.
            if (!this.options.showFirstOption) {

                // Excludes the first dropdown list option from the options list
                this.selectItems = this.selectBox.find("option").slice(1);
            }

            // Loops through the original select box options list and copies the text of each
            // into new list item elements of the new dropdown list
            this.selectItems.each(function(index) {

                dataDisabled = $(this).prop("disabled");

                iconClass = $(this).data("icon") || "";

                // If the current option being traversed is within an optgroup

                if($(this).parent().is("optgroup")) {

                    optgroupClass = "selectboxit-optgroup-option";

                    if($(this).index() === 0) {

                         optgroupElement = '<div class="selectboxit-optgroup-header" data-disabled="true">' + $(this).parent().first().attr("label") + '</div>';

                    }

                    else {

                        optgroupElement = "";

                    }

                }

                // If the current option being traversed is not within an optgroup

                else {

                    optgroupClass = "";

                }

                // Uses string concatenation instead of append for speed since the number of dropdown list options is unknown.
                currentItem += optgroupElement + '<li id="' + index + '" data-val="' + this.value + '" data-disabled="' + dataDisabled + '" class="' + optgroupClass + '"><span class="' + iconClass + '"></span>' + $(this).text() + '</li>';

                // Stores all of the original select box options text inside of an array
                // (Used later in the `searchAlgorithm` method)
                self.textArray[index] = $(this).text();

                // Checks the original select box option for the `selected` attribute
                if (this.selected) {

                    //Replace the default text with the selected option
                    self.divText.text($(this).text());

                    //Set the currently selected option
                    self.currentFocus = index;
                }

            });

            // If the `defaultText` option is being used
            if (self.options.defaultText) {

                //Overrides the current dropdown default text with the value the user specifies in the `defaultText` option
                self.divText.text(self.options.defaultText);
            }

            // If the `defaultText` HTML5 data attribute is being used
            if (self.selectBox.data("text")) {

                // Overrides the current dropdown default text with the value from the HTML5 `defaultText` value
                self.divText.text(self.selectBox.data("text"));
                self.options.defaultText = self.selectBox.data("text");

            }

            // Append the list item to the unordered list
            createdList.append(currentItem);

            // Stores the dropdown list options list inside of the `list` instance variable
            this.list = createdList;

            // Append the dropdown list options list to the div container element
            this.divContainer.append(this.list);

            // Stores the individual dropdown list options inside of the `listItems` instance variable
            this.listItems = this.list.find("li");

            // Set the disabled CSS class for select box options
            this.list.find("li[data-disabled='true']").not(".optgroupHeader").addClass("ui-state-disabled");

            // If the first select box option is disabled, and the user has chosen to not show the first select box option
            if (this.currentFocus === 0 && !this.options.showFirstOption && this.listItems.eq(0).hasClass("ui-state-disabled")) {

                //Sets the default value of the dropdown list to the first option that is not disabled
                this.currentFocus = +this.listItems.not(".ui-state-disabled").first().attr("id");

            }

            this.divImage.addClass(this.selectBox.data("icon") || this.options.defaultIcon || this.listItems.eq(this.currentFocus).find("span").attr("class"));

            //Maintains chainability
            return this;
        },

        // _Replace Select Box
        // -------------------
        //      Hides the original dropdown list and inserts
        //        the new DOM elements
        _replaceSelectBox: function() {

            // Hides the original select box
            this.selectBox.css("display", "none").

            // Adds the new dropdown list to the page directly after the hidden original select box element
            after(this.divContainer);

            // The height of the dropdown list
            var height = this.div.height();

            // The down arrow element of the dropdown list
            this.downArrow = $("<span/>", {

                // Dynamically sets the span `id` attribute of the dropdown list down arrow
                "id": this.originalElem.id + "SelectBoxItArrow",

                "class": "selectboxit-arrow",

                // IE specific attribute to not allow the dropdown list text to be selected
                "unselectable": "on"

            });

            // The down arrow container element of the dropdown list
            this.downArrowContainer = $("<span/>", {

                // Dynamically sets the span `id` attribute for the down arrow container element
                "id": this.originalElem.id + "SelectBoxItArrowContainer",

                "class": "selectboxit-arrow-container",

                // IE specific attribute to not allow the dropdown list text to be selected
                "unselectable": "on",

                // The dynamic CSS of the down arrow container element
                "style": "height:" + height + "px;"

            }).

            // Inserts the down arrow element inside of the down arrow container element
            append(this.downArrow);

            // Appends the down arrow element to the dropdown list
            this.div.append(this.downArrowContainer);

            // Dynamically adds the `max-width` and `line-height` CSS styles of the dropdown list text element
            this.divText.css({

                "line-height": this.div.height() > 0 ? this.div.css("height") : "auto",

                "max-width": this.div.width() - (this.downArrowContainer.width() + this.divImage.width()) - 5
            });

            this.divImage.css({

                "margin-top": height / 4

            });

            this.listItems.find("span").css({

                "margin-top": height / 4

            });

            // Maintains chainability
            return this;
        },

        // _Scroll-To-View
        // ---------------
        //      Updates the dropdown list scrollTop value
        _scrollToView: function(type) {

            // The current scroll positioning of the dropdown list options list
            var listScrollTop = this.list.scrollTop(),

                // The height of the currently selected dropdown list option
                currentItemHeight = this.listItems.eq(this.currentFocus).height(),

                // The relative distance from the currently selected dropdown list option to the the top of the dropdown list options list
                currentTopPosition = this.listItems.eq(this.currentFocus).position().top,

                // The height of the dropdown list option list
                listHeight = this.list.height();

            // Scrolling logic for a text search
            if (type === "search") {

                // Increases the dropdown list options `scrollTop` if a user is searching for an option
                // below the currently selected option that is not visible
                if (listHeight - currentTopPosition < currentItemHeight) {

                    // The selected option will be shown at the very bottom of the visible options list
                    this.list.scrollTop(listScrollTop + (currentTopPosition - (listHeight - currentItemHeight)));

                }

                // Decreases the dropdown list options `scrollTop` if a user is searching for an option above the currently selected option that is not visible
                else if (currentTopPosition < -1) {

                    this.list.scrollTop(currentTopPosition - currentItemHeight);

                }
            }

            // Scrolling logic for the `up` keyboard navigation
            else if (type === "up") {

                // Decreases the dropdown list option list `scrollTop` if a user is navigating to an element that is not visible
                if (currentTopPosition < -1) {

                    this.list.scrollTop(listScrollTop - Math.abs(this.listItems.eq(this.currentFocus).position().top));

                }
            }

            // Scrolling logic for the `down` keyboard navigation
            else if (type === "down") {

                // Increases the dropdown list options `scrollTop` if a user is navigating to an element that is not fully visible
                if (listHeight - currentTopPosition < currentItemHeight) {

                    // Increases the dropdown list options `scrollTop` by the height of the current option item.
                    this.list.scrollTop((listScrollTop + (Math.abs(this.listItems.eq(this.currentFocus).position().top) - listHeight + currentItemHeight)));

                }
            }

            // Maintains chainability
            return this;
        },

        // _Callback
        // ---------
        //      Call the function passed into the method
        _callbackSupport: function(callback) {

            // Checks to make sure the parameter passed in is a function
            if ($.isFunction(callback)) {

                // Calls the method passed in as a parameter and sets the current `SelectBoxIt` object that is stored in the jQuery data method as the context(allows for `this` to reference the SelectBoxIt API Methods in the callback function. The `div` DOM element that acts as the new dropdown list is also passed as the only parameter to the callback
                callback.call(this.element.data(this.widgetName), this.div);

            }
        },

        // Open
        // ----
        //      Opens the dropdown list options list
        open: function(callback) {

            if(!this.list.is(":visible")) {

                var self = this;

                // Triggers a custom "open" event on the original select box
                this.selectBox.trigger("open");

                if (this._dynamicPositioning) {
                    // Dynamically positions the dropdown list options list
                    this._dynamicPositioning();
                }

                // Determines what jQuery effect to use when opening the dropdown list options list
                switch (this.options.showEffect) {

                    // Uses `no effect`
                    case "none":

                        // Does not require a callback function because this animation will complete before the call to `scrollToView`
                        this.list.show();

                       // Updates the list `scrollTop` attribute
                       this._scrollToView("search");

                    break;

                    // Uses the jQuery `show` special effect
                    case "show":

                        // Requires a callback function to determine when the `show` animation is complete
                        this.list.show(this.options.showEffectSpeed, function() {

                            // Updates the list `scrollTop` attribute
                            self._scrollToView("search");

                        });

                    break;

                   // Uses the jQuery `slideDown` special effect
                   case "slideDown":

                       // Requires a callback function to determine when the `slideDown` animation is complete
                       this.list.slideDown(this.options.showEffectSpeed, function() {

                           // Updates the list `scrollTop` attribute
                           self._scrollToView("search");

                       });

                   break;

                  // Uses the jQuery `fadeIn` special effect
                  case "fadeIn":

                      // Does not require a callback function because this animation will complete before the call to `scrollToView`
                      this.list.fadeIn(this.options.showEffectSpeed);

                      // Updates the list `scrollTop` attribute
                      this._scrollToView("search");

                  break;

                  // If none of the above options were passed, then a `jqueryUI show effect` is expected
                  default:

                     // Allows for custom show effects via the [jQueryUI core effects](http://http://jqueryui.com/demos/show/)
                     this.list.show(this.options.showEffect, this.options.showEffectOptions, this.options.showEffectSpeed, function() {

                         // Updates the list `scrollTop` attribute
                         self._scrollToView("search");

                     });

                 break;

                }

            }

            // Provide callback function support
            this._callbackSupport(callback);

            // Maintains chainability
            return this;
        },

        // Close
        // -----
        //      Closes the dropdown list options list
        close: function(callback) {

            if(this.list.is(":visible")) {

                var self = this;

                // Triggers a custom "close" event on the original select box
                this.selectBox.trigger("close");

                // Determines what jQuery effect to use when closing the dropdown list options list
                switch (this.options.hideEffect) {

                    // Uses `no effect`
                    case "none":

                        // Does not require a callback function because this animation will complete before the call to `scrollToView`
                        this.list.hide();

                        // Updates the list `scrollTop` attribute
                        this._scrollToView("search");

                    break;

                    // Uses the jQuery `hide` special effect
                    case "hide":

                        this.list.hide(this.options.hideEffectSpeed);

                    break;

                    // Uses the jQuery `slideUp` special effect
                    case "slideUp":

                    this.list.slideUp(this.options.hideEffectSpeed);

                    break;

                    // Uses the jQuery `fadeOut` special effect
                    case "fadeOut":

                        this.list.fadeOut(this.options.hideEffectSpeed);

                    break;

                    // If none of the above options were passed, then a `jqueryUI hide effect` is expected
                    default:

                        // Allows for custom hide effects via the [jQueryUI core effects](http://http://jqueryui.com/demos/hide/)
                        this.list.hide(this.options.hideEffect, this.options.hideEffectOptions, this.options.hideEffectSpeed, function() {

                            //Updates the list `scrollTop` attribute
                            self._scrollToView("search");

                        });

                    break;
                }

            }

            // Provide callback function support
            this._callbackSupport(callback);

            // Maintains chainability
            return this;
        },


        // _Event Handlers
        // ---------------
        //      Adds event handlers to the new dropdown list
        _eventHandlers: function() {

            // LOCAL VARIABLES
            var self = this,

                upKey = 38,

                downKey = 40,

                enterKey = 13,

                backspaceKey = 8,

                tabKey = 9,

                spaceKey = 32,

                escKey = 27;

            // Select Box events
            this.div.bind({

                // `click` event with the `selectBoxIt` namespace
                "click.selectBoxIt": function() {

                    if(!self.div.is(":focus")) {

                        $(this).focus();

                    }

                    // The `click` handler logic will only be applied if the dropdown list is enabled
                    if (!self.originalElem.disabled) {

                        // Triggers the `click` event on the original select box
                        self.selectBox.trigger("click");

                        // If the dropdown list options list is visible when a user clicks on the dropdown list
                        if (self.list.is(":visible")) {

                            // Closes the dropdown list options list
                            self.close();
                        }

                        // If the dropdown list options list is not visible when a user clicks on the dropdown list
                        else {

                            // Shows the dropdown list options list
                            self.open();
                        }
                    }
                },

                // `mousedown` event with the `selectBoxIt` namespace
                "mousedown.selectBoxIt": function() {

                    // Stores data in the jQuery `data` method to help determine if the dropdown list gains focus from a click or tabstop.  The mousedown event fires before the focus event.
                    $(this).data("mdown", true);
                },

                // `blur` event with the `selectBoxIt` namespace.  Uses special blur logic to make sure the dropdown list closes correctly
                "blur.selectBoxIt": function() {

                    // If `self.blur` property is true
                    if (self.blur) {

                        // Triggers both the `blur` and `focusout` events on the original select box.
                        // The `focusout` event was also triggered because the event bubbles
                        // This event has to be used when using event delegation (such as the jQuery `delegate` or `on` methods)
                        // Popular open source projects such as Backbone.js utilize event delegation to bind events, so if you are using Backbone.js, use the `focusout` event instead of the `blur` event
                        self.selectBox.trigger("blur").trigger("focusout");

                        //If the dropdown options list is visible
                        if (self.list.is(":visible")) {
                            //Closes the dropdown list options list
                            self.close();
                        }
                    }
                },

                "focus.selectBoxIt": function() {

                    // Stores the data associated with the mousedown event inside of a local variable
                    var mdown = $(this).data("mdown");

                    // Removes the jQuery data associated with the mousedown event
                    $(this).removeData('mdown');

                    // If a mousedown event did not occur and no data was passed to the focus event (this correctly triggers the focus event), then the dropdown list gained focus from a tabstop
                    if (!mdown) {

                        // Triggers the `tabFocus` custom event on the original select box
                        self.selectBox.trigger("tabFocus");
                    }

                    // Only trigger the `focus` event on the original select box if the dropdown list is hidden (this verifies that only the correct `focus` events are used to trigger the event on the original select box
                    if(!self.list.is(":visible")) {

                        //Triggers the `focus` default event on the original select box
                        self.selectBox.trigger("focus").trigger("focusin");

                    }
                },

                // `keydown` event with the `selectBoxIt` namespace.  Catches all user keyboard navigations
                "keydown.selectBoxIt": function(e) {

                    // Stores the `keycode` value in a local variable
                    var currentKey = e.keyCode;

                    // Performs keyboard events if the dropdown list is focused
                    if (self.div.is(":focus")) {

                        // Supports keyboard navigation
                        switch (currentKey) {

                            // If the user presses the `down key`
                            case downKey:

                                // Prevents the page from moving down
                                e.preventDefault();

                                // If the plugin options allow keyboard navigation
                                if (self.moveDown) {

                                    //Opens the dropdown list if it's hidden
                                    if (self.list.is(":hidden")) {
                                        self.open();
                                    }

                                    // Moves the focus down to the dropdown list option directly beneath the currently selected selectbox option
                                    self.moveDown();

                                }

                                break;

                            //If the user presses the `up key`
                            case upKey:

                                // Prevents the page from moving up
                                e.preventDefault();

                                // If the plugin options allow keyboard navgiation
                                if (self.moveUp) {

                                    //Opens the dropdown list if it's hidden
                                    if (self.list.is(":hidden")) {
                                        self.open();
                                    }

                                    // Moves the focus up to the dropdown list option directly above the currently selected selectbox option
                                    self.moveUp();

                                }

                                break;

                            // If the user presses the `enter key`
                            case enterKey:

                                // Prevents the default event from being triggered
                                e.preventDefault();

                                // Checks to see if the dropdown list options list is open
                                if (self.list.is(":visible")) {

                                    // Closes the dropdown list options list
                                    self.close();
                                }

                                // If the first dropdown list option is not shown in the options list, and the dropdown list has not been interacted with, then update the dropdown list value when the enter key is pressed
                                if (!self.options.showFirstOption && self.div.text() === self.firstSelectItem.text() && self.currentFocus === 0 || (self.options.showFirstOption && self.options.defaultText) || (!self.options.showFirstOption && !self.listItems.eq(0).not("[data-disabled='true']"))) {

                                    // Updates the dropdown list value
                                    self.selectBox.val(self.listItems.eq(self.currentFocus).attr("data-val")).

                                    // Triggers a `change` event on the original select box
                                    trigger("change");
                                }

                                // Triggers the `enter` events on the original select box
                                self.selectBox.trigger("enter");

                                break;

                            // If the user presses the `tab key`
                            case tabKey:

                                // Triggers the custom `tabBlur` events on the original select box
                                self.selectBox.trigger("tabBlur");

                                break;

                            // If the user presses the `backspace key`
                            case backspaceKey:

                                // Prevents the browser from navigating to the previous page in its history
                                e.preventDefault();

                                // Triggers the custom `backspace` event on the original select box
                                self.selectBox.trigger("backspace");

                                break;

                            // If the user presses the `escape key`
                            case escKey:

                                // Closes the dropdown options list
                                self.close();

                                break;

                            // Default is to break out of the switch statement
                            default:

                                break;

                        }
                    }
                },

                // `keypress` event with the `selectBoxIt` namespace.  Catches all user keyboard text searches since you can only reliably get character codes using the `keypress` event
                "keypress.selectBoxIt": function(e) {

                    // Performs a text search if the dropdown list is focused
                    if (self.div.is(":focus")) {

                        // Sets the current key to the `keyCode` value if `charCode` does not exist.  Used for cross
                        // browser support since IE uses `keyCode` instead of `charCode`.
                        var currentKey = e.charCode || e.keyCode,

                            // Converts unicode values to characters
                            alphaNumericKey = String.fromCharCode(currentKey);

                        // If the user presses the `space bar`
                        if (currentKey === spaceKey) {

                            // Prevents the browser from scrolling to the bottom of the page
                            e.preventDefault();
                        }

                        // If the plugin options allow text searches
                        if (self.search) {

                            // Calls `search` and passes the character value of the user's text search
                            self.search(alphaNumericKey, true, "");
                        }
                    }
                },

                // `mousenter` event with the `selectBoxIt` namespace .The mouseenter JavaScript event is proprietary to Internet Explorer. Because of the event's general utility, jQuery simulates this event so that it can be used regardless of browser.
                "mouseenter.selectBoxIt": function() {

                    // Trigger the `mouseenter` event on the original select box
                    self.selectBox.trigger("mouseenter");
                },

                // `mouseleave` event with the `selectBoxIt` namespace. The mouseleave JavaScript event is proprietary to Internet Explorer. Because of the event's general utility, jQuery simulates this event so that it can be used regardless of browser.
                "mouseleave.selectBoxIt": function() {

                    // Trigger the `mouseleave` event on the original select box
                    self.selectBox.trigger("mouseleave");
                }

            });

            // Select box options events that set the dropdown list blur logic (decides when the dropdown list gets
            // closed)
            this.list.bind({

                // `mouseover` event with the `selectBoxIt` namespace
                "mouseover.selectBoxIt": function() {

                    // Prevents the dropdown list options list from closing
                    self.blur = false;
                },

                // `mouseout` event with the `selectBoxIt` namespace
                "mouseout.selectBoxIt": function() {

                    // Allows the dropdown list options list to close
                    self.blur = true;
                },

                // `focusin` event with the `selectBoxIt` namespace
                "focusin.selectBoxIt": function() {

                    // Prevents the default browser outline border to flicker, which results because of the `blur` event
                    self.div.focus();
                }

            })

            // Select box individual options events bound with the jQuery `delegate` method.  `Delegate` was used because binding individual events to each list item (since we don't know how many there will be) would decrease performance.  Instead, we bind each event to the unordered list, provide the list item context, and allow the list item events to bubble up (`event bubbling`). This greatly increases page performance because we only have to bind an event to one element instead of x number of elements. Delegates the `click` event with the `selectBoxIt` namespace to the list items
            .delegate("li", "click.selectBoxIt", function() {

                if (!$(this).data("disabled")) {

                    // Sets the original dropdown list value and triggers the `change` event on the original select box
                    self.originalElem.value = $(this).attr("data-val");

                    // Sets `currentFocus` to the currently focused dropdown list option.
                    // The unary `+` operator casts the string to a number
                    // [James Padolsey Blog Post](http://james.padolsey.com/javascript/terse-javascript-101-part-2/)
                    self.currentFocus = +this.id;

                    // Closes the list after selecting an option
                    self.close();

                    // Triggers the dropdown list `change` event if a value change occurs
                    if (self.originalElem.value !== self.divText.attr("data-val")) {

                        self.selectBox.trigger("change");

                    }
                }
            })

            // Delegates the `focus` event with the `selectBoxIt` namespace to the list items
            .delegate("li", "focus.selectBoxIt", function() {

                if (!$(this).data("disabled")) {

                    // Sets the original select box current value and triggers the change event
                    self.originalElem.value = $(this).attr("data-val");

                    // Triggers the dropdown list `change` event if a value change occurs
                    if (self.originalElem.value !== self.divText.attr("data-val")) {

                        self.selectBox.trigger("change");

                    }
                }
            });

            // Original dropdown list events
            this.selectBox.bind({

                // `change` event handler with the `selectBoxIt` namespace
                "change.selectBoxIt": function() {

                    // Sets the new dropdown list text to the value of the original dropdown list
                    self.divText.text(self.listItems.eq(self.currentFocus).text()).attr("data-val", self.originalElem.value);

                    if(self.listItems.eq(self.currentFocus).find("span").attr("class")) {

                        self.divImage.attr("class", self.listItems.eq(self.currentFocus).find("span").attr("class"));
                    }
                },

                // `disable` event with the `selectBoxIt` namespace
                "disable.selectBoxIt": function() {

                    // Adds the `disabled` CSS class to the new dropdown list to visually show that it is disabled
                    self.div.addClass("ui-state-disabled");
                },

                // `enable` event with the `selectBoxIt` namespace
                "enable.selectBoxIt": function() {

                    // Removes the `disabled` CSS class from the new dropdown list to visually show that it is enabled
                    self.div.removeClass("ui-state-disabled");
                }
            });

            // Maintains chainability
            return this;
        },

        // _addClasses
        // ---------
        //      Adds SelectBoxIt CSS classes
        _addClasses: function() {

            var self = this,

                focusClass = "selectboxit-focus",

                hoverClass = "selectboxit-hover";

            this.downArrow.addClass(this.selectBox.data("downarrow") || this.options.downArrowIcon || "");

            // Adds the default class to the dropdown list
            this.div.addClass("selectboxit-widget");

            // Adds the default styling for the dropdown list options
            this.list.addClass("selectboxit-widget selectboxit-widget-content");

            // Select box individual option events
            this.listItems.bind({

                // `focus` event with the `selectBoxIt` namespace
                "focus.selectBoxIt": function() {

                    // Adds the focus CSS class to the currently focused dropdown list option
                    $(this).addClass(focusClass);

                },

                // `blur` event with the `selectBoxIt` namespace
                "blur.selectBoxIt": function() {

                    // Removes the focus CSS class from the previously focused dropdown list option
                    $(this).removeClass(focusClass);

                }

            });

            // Select box events
            this.selectBox.bind({

                // `click` event with the `selectBoxIt` namespace
                "open.selectBoxIt": function() {

                    // Removes the jQueryUI hover class from the dropdown list and adds the jQueryUI focus class for both the dropdown list and the currently selected dropdown list option
                    self.div.removeClass(hoverClass).add(self.listItems.eq(self.currentFocus)).

                    addClass(focusClass);
                },

                "blur.selectBoxIt": function() {

                    self.div.removeClass(focusClass);

                },

                // `mousenter` event with the `selectBoxIt` namespace
                "mouseenter.selectBoxIt": function() {

                    self.div.addClass(hoverClass);

                },

                // `mouseleave` event with the `selectBoxIt` namespace
                "mouseleave.selectBoxIt": function() {

                    // Removes the hover CSS class on the previously hovered dropdown list option
                    self.div.removeClass(hoverClass);

                }

            });

            this.listItems.bind({

                "mouseenter.selectBoxIt": function() {

                    // Sets the dropdown list individual options back to the default state and sets the hover CSS class on the currently hovered option
                    self.listItems.removeClass(focusClass);

                    $(this).addClass(hoverClass);

                },

                "mouseleave.selectBoxIt": function() {

                    $(this).removeClass(hoverClass);

                }

            });

            // Maintains chainability
            return this;

        }

    });

})); // End of core module
$(function() {

    //_ARIA Accessibility
    // ------------------
    //      Adds ARIA (Accessible Rich Internet Applications)
    //      Accessibility Tags to the Select Box

    $.selectBox.selectBoxIt.prototype._ariaAccessibility = function() {

        var self = this;

        //Adds `ARIA attributes` to the dropdown list
        this.div.attr({

            //W3C `combobox` description: A presentation of a select; usually similar to a textbox where users can type ahead to select an option.
            "role": "combobox",

            //W3C `aria-autocomplete` description: Indicates whether user input completion suggestions are provided.
            "aria-autocomplete": "list",

            //W3C `aria-expanded` description: Indicates whether the element, or another grouping element it controls, is currently expanded or collapsed.
            "aria-expanded": "false",

            //W3C `aria-owns` description: The value of the aria-owns attribute is a space-separated list of IDREFS that reference one or more elements in the document by ID. The reason for adding aria-owns is to expose a parent/child contextual relationship to assistive technologies that is otherwise impossible to infer from the DOM.
            "aria-owns": this.list.attr("id"),

            //W3C `aria-activedescendant` description: This is used when a composite widget is responsible for managing its current active child to reduce the overhead of having all children be focusable. Examples include: multi-level lists, trees, and grids.
            "aria-activedescendant": this.listItems.eq(this.currentFocus).attr("id"),

            //W3C `aria-label` description:  It provides the user with a recognizable name of the object.
            "aria-label": $("label[for='" + this.originalElem.id + "']").text() || "",

            //W3C `aria-live` description: Indicates that an element will be updated.
            //Use the assertive value when the update needs to be communicated to the user more urgently.
            "aria-live": "assertive"
        }).

        //Dynamically adds `ARIA attributes` if the new dropdown list is enabled or disabled
        bind({

            //Select box custom `disable` event with the `selectBoxIt` namespace
            "disable.selectBoxIt" : function() {

                //W3C `aria-disabled` description: Indicates that the element is perceivable but disabled, so it is not editable or otherwise operable.
                self.div.attr("aria-disabled", "true");

            },

            //Select box custom `enable` event with the `selectBoxIt` namespace
            "enable.selectBoxIt" : function() {

                //W3C `aria-disabled` description: Indicates that the element is perceivable but disabled, so it is not editable or otherwise operable.
                self.div.attr("aria-disabled", "false");

            }

        });

        //Adds ARIA attributes to the dropdown list options list
        self.list.attr({

            //W3C `listbox` description: A widget that allows the user to select one or more items from a list of choices.
            "role": "listbox",

            //Indicates that the dropdown list options list is currently hidden
            "aria-hidden": "true"
        });

        //Adds `ARIA attributes` to the dropdown list options
        self.listItems.attr({

            //This must be set for each element when the container element role is set to `listbox`
            "role": "option"
        });

        //Dynamically updates the new dropdown list `aria-label` attribute after the original dropdown list value changes
        self.selectBox.bind({

            //Custom `change` event with the `selectBoxIt` namespace
            "change.selectBoxIt": function() {

                //Provides the user with a recognizable name of the object.
                self.divText.attr("aria-label", self.originalElem.value);

            },

            //Custom `open` event with the `selectBoxIt` namespace
            "open.selectBoxIt": function() {

                //Indicates that the dropdown list options list is currently visible
                self.list.attr("aria-hidden", "false");

                //Indicates that the dropdown list is currently expanded
                self.div.attr("aria-expanded", "true");

            },

            //Custom `close` event with the `selectBoxIt` namespace
            "close.selectBoxIt": function() {

                //Indicates that the dropdown list options list is currently hidden
                self.list.attr("aria-hidden", "true");

                //Indicates that the dropdown list is currently collapsed
                self.div.attr("aria-expanded", "false");

            }

        });

        //Maintains chainability
        return this;

    };

});
$(function() {

    //Destroy
    // ------
    //    Delays execution by the amount of time
    //    specified by the parameter

    $.selectBox.selectBoxIt.prototype.destroy = function(callback) {

        //Unbinds all of the dropdown list event handlers with the `selectBoxIt` namespace
        this.div.unbind(".selectBoxIt").

        //Undelegates all of the dropdown list event handlers with the `selectBoxIt` namespace
        undelegate(".selectBoxIt");

        //Remove all of the `selectBoxIt` DOM elements from the page
        this.divContainer.remove();

        //Triggers the custom `destroy` event on the original select box and then shows the original dropdown list
        this.selectBox.trigger("destroy").show();

        // Calls the jQueryUI Widget Factory destroy method
        $.Widget.prototype.destroy.call(this);

        //Provides callback function support
        this._callbackSupport(callback);

        //Maintains chainability
        return this;

    };

});
$(function() {

    //Disable
    // ------
    //      Disables the new dropdown list

    $.selectBox.selectBoxIt.prototype.disable = function(callback) {

            if(!this.options.disabled) {

                //Makes sure the dropdown list is closed
                this.close();

                //Triggers a `disable` custom event on the original select box
                this.selectBox.trigger("disable")

                //Sets the `disabled` attribute on the original select box
                .attr("disabled", "disabled");

                //Makes the dropdown list not focusable by removing the `tabindex` attribute
                this.div.removeAttr("tabindex").css("cursor", "default");

                // Calls the jQueryUI Widget Factory disable method to make sure all options are correctly synced
                $.Widget.prototype.disable.call(this);

                //Provides callback function support
                this._callbackSupport(callback);

                //Maintains chainability
                return this;

            }

    };

    //_Is Disabled
    // -----------
    //      Checks the original select box for the
    //    disabled attribute

    $.selectBox.selectBoxIt.prototype._isDisabled = function(callback) {

        //If the original select box is disabled
        if (this.originalElem.disabled) {

            //Disables the dropdown list
            this.disable();
        }

        //Maintains chainability
        return this;

    };

});
$(function() {

    //_Dynamic positioning
    // ------------------
    //      Dynamically positions the dropdown list options list

    $.selectBox.selectBoxIt.prototype._dynamicPositioning = function() {

        //Returns the x and y coordinates of the dropdown list options list relative to the document
        var listOffsetTop = this.div.offset().top,

            //The height of the dropdown list options list
            listHeight = this.list.height(),

            //The height of the dropdown list DOM element
            selectBoxHeight = this.div.height();

        //Places the dropdown list options list on top of the dropdown list if the dropdown list options list does not fit on the page when opened
        if ((listOffsetTop + selectBoxHeight + listHeight >= $(window).height() + $(window).scrollTop()) && (listOffsetTop - listHeight >= 0)) {

            //If the dropdown list currently opens downward
            if (!this.flipped) {

                //Sets custom CSS properties to place the dropdown list options directly above the dropdown list
                this.list.css("top", (this.divContainer.position().top - this.list.height()) - 2);

                //Sets the `flipped` instance variable to false to reflect that the dropdown list opens upward
                this.flipped = true;

            }

        }

        //If the dropdown list options have enough room on the page to open downward
        else {

            //If the dropdown list is currently opening upward
            if (this.flipped) {

                //Sets custom CSS properties to place the dropdown list options directly below the dropdown list
                this.list.css("top", (this.divContainer.position().top + this.div.height()) + 2);

                //Sets the `flipped` instance variable to false to reflect that the dropdown list opens downward
                this.flipped = false;

            }

        }

    };

});
$(function() {

    //Enable
    // -----
    //      Enables the new dropdown list

    $.selectBox.selectBoxIt.prototype.enable = function(callback) {

            if(this.options.disabled) {

                //Triggers a `enable` custom event on the original select box
                this.selectBox.trigger("enable")

                //Removes the `disabled` attribute from the original dropdown list
                .removeAttr("disabled");

                //Make the dropdown list focusable
                this.div.attr("tabindex", 0).css("cursor", "pointer");

                $.Widget.prototype.enable.call(this);

                //Provide callback function support
                this._callbackSupport(callback);

            }

            //Maintains chainability
            return this;

        };

});
$(function() {

    //Move Down
    // --------
    //      Handles the down keyboard navigation logic

    $.selectBox.selectBoxIt.prototype.moveDown = function(callback) {

        //Increments `currentFocus`, which represents the currently focused list item `id` attribute.
        this.currentFocus += 1;

        //Determines whether the dropdown option the user is trying to go to is currently disabled
        var disabled = this.listItems.eq(this.currentFocus).data("disabled"),

            hasNextEnabled = this.listItems.eq(this.currentFocus).nextAll("li").not("[data-disabled='true']").first().length;

        //If the user has reached the top of the list
        if (this.currentFocus === this.listItems.length) {

            //Does not allow the user to continue to go up the list
            this.currentFocus -= 1;

        }

        //If the option the user is trying to go to is disabled, but there is another enabled option
        else if (disabled && hasNextEnabled) {

            //Blur the previously selected option
            this.listItems.eq(this.currentFocus - 1).blur();

            //Call the `moveDown` method again
            this.moveDown();

            //Exit the method
            return;

        }

        //If the option the user is trying to go to is disabled, but there is not another enabled option
        else if (disabled && !hasNextEnabled) {

            this.currentFocus -= 1;

        }

        //If the user has not reached the bottom of the unordered list
        else {

            //Blurs the previously focused list item
            //The jQuery `end()` method allows you to continue chaining while also using a different selector
            this.listItems.eq(this.currentFocus - 1).blur().end().

            //Focuses the currently focused list item
            eq(this.currentFocus).focus();

            //Calls `scrollToView` to make sure the `scrollTop` is correctly updated. The `down` user action
            this._scrollToView("down");

            //Triggers the custom `moveDown` event on the original select box
            this.selectBox.trigger("moveDown");

        }

        //Provide callback function support
        this._callbackSupport(callback);

        //Maintains chainability
        return this;
    };

    //Move Up
    // ------
    //      Handles the up keyboard navigation logic
    $.selectBox.selectBoxIt.prototype.moveUp = function(callback) {

        //Increments `currentFocus`, which represents the currently focused list item `id` attribute.
        this.currentFocus -= 1;

        //Determines whether the dropdown option the user is trying to go to is currently disabled
        var disabled = this.listItems.eq(this.currentFocus).data("disabled"),

            hasPreviousEnabled = this.listItems.eq(this.currentFocus).prevAll("li").not("[data-disabled='true']").first().length;

        //If the user has reached the top of the list
        if (this.currentFocus === -1) {

            //Does not allow the user to continue to go up the list
            this.currentFocus += 1;
        }

        //If the option the user is trying to go to is disabled and the user is not trying to go up after the user has reached the top of the list
        else if (disabled && hasPreviousEnabled) {

            //Blur the previously selected option
            this.listItems.eq(this.currentFocus + 1).blur();

            //Call the `moveUp` method again
            this.moveUp();

            //Exit the method
            return;
        }

        else if (disabled && !hasPreviousEnabled) {

            this.currentFocus += 1;

        }

        //If the user has not reached the top of the unordered list
        else {

            //Blurs the previously focused list item
            //The jQuery `end()` method allows you to continue chaining while also using a different selector
            this.listItems.eq(this.currentFocus + 1).blur().end().

            //Focuses the currently focused list item
            eq(this.currentFocus).focus();

            //Calls `scrollToView` to make sure the `scrollTop` is correctly updated. The `down` user action
            this._scrollToView("up");

            //Triggers the custom `moveDown` event on the original select box
            this.selectBox.trigger("moveUp");

        }

        //Provide callback function support
        this._callbackSupport(callback);

        //Maintains chainability
        return this;
    };

});
$(function() {

    // _Set Current Search Option
    // -------------------------
    //      Sets the currently selected dropdown list search option

    $.selectBox.selectBoxIt.prototype._setCurrentSearchOption = function(currentOption) {

        // Does not change the current option if `showFirstOption` is false and the matched search item is the hidden first option.
        // Otherwise, the current option value is updated
        if (!(currentOption === 0 && !this.options.showFirstOption) && this.listItems.eq(currentOption).data("disabled") !== true) {

            //Updates the default dropdown list text
            this.divText.text(this.textArray[currentOption]);

            //Calls the `blur` event of the currently selected dropdown list option
            this.listItems.eq(this.currentFocus).blur();

            //Sets `currentIndex` to the currently selected dropdown list option
            this.currentIndex = currentOption;

            //Sets `currentFocus` to the currently selected dropdown list option
            this.currentFocus = currentOption;

            //Focuses the currently selected dropdown list option
            this.listItems.eq(this.currentFocus).focus();

            //Updates the scrollTop so that the currently selected dropdown list option is visible to the user
            this._scrollToView("search");

            //Triggers the custom `search` event on the original select box
            this.selectBox.trigger("search");

        }

        //Maintains chainability
        return this;

    };

    // _Search Algorithm
    // -----------------
    //      Uses regular expressions to find text matches
    $.selectBox.selectBoxIt.prototype._searchAlgorithm = function(currentIndex, alphaNumeric) {

        // Boolean to determine if a pattern match exists
        var matchExists = false,

            //Iteration variable used in the outermost for loop
            x,

            //Iteration variable used in the nested for loop
            y,

            //Variable used to cache the length of the text array (Small enhancement to speed up traversing)
            arrayLength;

        //Loops through the text array to find a pattern match
        for (x = currentIndex, arrayLength = this.textArray.length; x < arrayLength; x += 1) {

            //Nested for loop to help search for a pattern match with the currently traversed array item
            for (y = 0; y < arrayLength; y += 1) {

                //Searches for a match
                if (this.textArray[y].search(alphaNumeric) !== -1) {

                    //`matchExists` is set to true if there is a match
                    matchExists = true;

                    //Exits the nested for loop
                    y = arrayLength;

                }

            } //End nested for loop

            //If a match does not exist
            if (!matchExists) {

                //Sets the current text to the last entered character
                this.currentText = this.currentText.charAt(this.currentText.length - 1).

                //Escapes the regular expression to make sure special characters are seen as literal characters instead of special commands
                replace(/[|()\[{.+*?$\\]/g, "\\$0");

                //Resets the regular expression with the new value of `self.currentText`
                alphaNumeric = new RegExp(this.currentText, "gi");

            }

            //Searches based on the first letter of the dropdown list options text if the currentText < 2 characters
            if (this.currentText.length < 2) {

                //If there is a match based on the first character
                if ((this.textArray[x].charAt(0).search(alphaNumeric) !== -1)) {

                    //Sets properties of that dropdown list option to make it the currently selected option
                    this._setCurrentSearchOption(x);

                    //Increments the current index by one
                    this.currentIndex += 1;

                    //Exits the search
                    return false;

                }
            }

            // If `self.currentText` > 1 character
            else {

                // If there is a match based on the entire string
                if ((this.textArray[x].search(alphaNumeric) !== -1)) {

                    // Sets properties of that dropdown list option to make it the currently selected option
                    this._setCurrentSearchOption(x);

                    // Exits the search
                    return false;
                }
            }

            // If the current text search is an exact match
            if (this.textArray[x].toLowerCase() === this.currentText.toLowerCase()) {

                // Sets properties of that dropdown list option to make it the currently selected option
                this._setCurrentSearchOption(x);

                // Resets the current text search to a blank string to start fresh again
                this.currentText = "";

                // Exits the search
                return false;

            }
        }

        //Returns true if there is not a match at all
        return true;
    };

    // Search
    // ------
    //      Calls searchAlgorithm()
    $.selectBox.selectBoxIt.prototype.search = function(alphaNumericKey, rememberPreviousSearch, callback) {

        // If the search method is being called internally by the plugin, and not externally as a method by a user
        if (rememberPreviousSearch) {

            // Continued search with history from past searches.  Properly escapes the regular expression
            this.currentText += alphaNumericKey.replace(/[|()\[{.+*?$\\]/g, "\\$0");

        }

        else {

            // Brand new search.  Properly escapes the regular expression
            this.currentText = alphaNumericKey.replace(/[|()\[{.+*?$\\]/g, "\\$0");

        }

        // Wraps the current user text search in a regular expression that is case insensitive and searches globally
        var alphaNumeric = new RegExp(this.currentText, "gi"),

            // Calls `searchAlgorithm` which searches an array that contains all of the dropdown list option values.
            notFound = this._searchAlgorithm(this.currentIndex, alphaNumeric);

        // Searches the list again if a match is not found.  This is needed, because the first search started at the array indece of the currently selected dropdown list option, and does not search the options before the current array indece.
        // If there are many similar dropdown list options, starting the search at the indece of the currently selected dropdown list option is needed to properly traverse the text array.
        if (notFound) {

            // Searches the dropdown list values starting from the beginning of the text array
            this._searchAlgorithm(0, alphaNumeric);

        }

        // Provide callback function support
        this._callbackSupport(callback);

        // Maintains chainability
        return this;

    };

});
$(function() {

    //Set Option
    // ----------
    //      Accepts an string key, a value, and a callback function to replace a single
    //      property of the plugin options object

    $.selectBox.selectBoxIt.prototype.setOption = function(key, value, callback) {

            //If a user sets the `showFirstOption` to false
            if (key === "showFirstOption" && !value) {

                //Hides the first option in the dropdown list
                this.listItems.eq(0).hide();

            }

            //If a user sets the `showFirstOption` to true
            else if (key === "showFirstOption" && value) {

                //Shows the first option in the dropdown list
                this.listItems.eq(0).show();

            }

            else if(key === "defaultIcon" && value) {

                this.divImage.attr("class", value);

            }

            else if(key === "downArrowIcon" && value) {

                this.downArrow.attr("class", value);

            }

            //If a user sets the defaultText option
            else if (key === "defaultText") {

                //Sets the new dropdown list default text
                this.divText.text(value);

            }

            $.Widget.prototype._setOption.apply(this, arguments);

            //Provides callback function support
            this._callbackSupport(callback);

            //Maintains chainability
            return this;
        };

});
$(function() {

    //Set Options
    // ----------
    //      Accepts an object to replace plugin options
    //      properties of the plugin options object

    $.selectBox.selectBoxIt.prototype.setOptions = function(newOptions, callback) {

            $.Widget.prototype._setOptions.apply(this, arguments);

            //If the `showFirstOption` option is true
            if (this.options.showFirstOption) {

                //Shows the first option in the dropdown list
                this.listItems.eq(0).show();

            }

            //If the `showFirstOption` option is false
            else {

                //Hides the first option in the dropdown list
                this.listItems.eq(0).hide();

            }

            if(this.options.defaultIcon) {

                this.divImage.attr("class", this.options.defaultIcon);

            }

            if(this.options.downArrowIcon) {

                this.downArrow.attr("class", this.options.downArrowIcon);

            }

            //If the defaultText option is set, make sure the dropdown list default text reflects this value
            if (this.options.defaultText) {

                this.divText.text(this.options.defaultText);

            }

            //Provide callback function support
            this._callbackSupport(callback);

            return this;

        };

});
$(function() {

    //Wait
    // ---
    //    Delays execution by the amount of time
    //    specified by the parameter

    $.selectBox.selectBoxIt.prototype.wait = function(time, callback) {

        var self = this,

            //The timeout variable stores a Deferred Object, which will be resolved after the time specified in the parameter
            timeout = this.returnTimeout(time);

        //Once the Deferred object is resolved, call the callback function
        timeout.then(function() {

            //Provide callback function support
            self._callbackSupport(callback);

        });

        //Maintains chainability
        return this;

    };

    //Return timeout
    // -------------
    //    Returns a Deferred Object after the time
    //    specified by the parameter

    $.selectBox.selectBoxIt.prototype.returnTimeout = function(time) {

        //Returns a Deferred Object
        return $.Deferred(function(dfd) {

            //Call the JavaScript `setTimeout function and resolve the Deferred Object
            setTimeout(dfd.resolve, time);

        });

    };

});