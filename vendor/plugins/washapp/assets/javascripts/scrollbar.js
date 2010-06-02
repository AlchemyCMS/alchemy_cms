/**
 * @author Ryan Johnson <http://syntacticx.com/>
 * @copyright 2008 PersonalGrid Corporation <http://personalgrid.com/>
 * @package LivePipe UI
 * @license MIT
 * @url http://livepipe.net/control/scrollbar
 * @require prototype.js, slider.js, livepipe.js
 */

if(typeof(Prototype) == "undefined")
    throw "Control.ScrollBar requires Prototype to be loaded.";
if(typeof(Control.Slider) == "undefined")
    throw "Control.ScrollBar requires Control.Slider to be loaded.";
if(typeof(Object.Event) == "undefined")
    throw "Control.ScrollBar requires Object.Event to be loaded.";

Control.ScrollBar = Class.create({
    initialize: function(container,track,options){
        this.enabled = false;
        this.notificationTimeout = false;
        this.container = $(container);
        this.boundMouseWheelEvent = this.onMouseWheel.bindAsEventListener(this);
        this.boundResizeObserver = this.onWindowResize.bind(this);
        this.track = $(track);
        this.handle = this.track.firstDescendant();
        this.options = Object.extend({
            active_class_name: 'scrolling',
            apply_active_class_name_to: this.container,
            notification_timeout_length: 125,
            handle_minimum_height: 25,
            scroll_to_smoothing: 0.01,
            scroll_to_steps: 15,
            proportional: true,
            slider_options: {}
        },options || {});
        this.slider = new Control.Slider(this.handle,this.track,Object.extend({
            axis: 'vertical',
            onSlide: this.onChange.bind(this),
            onChange: this.onChange.bind(this)
        },this.options.slider_options));
        this.recalculateLayout();
        Event.observe(window,'resize',this.boundResizeObserver);
        this.handle.observe('mousedown',function(){
            if(this.auto_sliding_executer)
                this.auto_sliding_executer.stop();
        }.bind(this));
    },
    destroy: function(){
        Event.stopObserving(window,'resize',this.boundResizeObserver);
    },
    enable: function(){
        this.enabled = true;
        this.container.observe('mouse:wheel',this.boundMouseWheelEvent);
        this.slider.setEnabled();
        this.track.show();
        if(this.options.active_class_name)
            $(this.options.apply_active_class_name_to).addClassName(this.options.active_class_name);
        this.notify('enabled');
    },
    disable: function(){
        this.enabled = false;
        this.container.stopObserving('mouse:wheel',this.boundMouseWheelEvent);
        this.slider.setDisabled();
        this.track.hide();
        if(this.options.active_class_name)
            $(this.options.apply_active_class_name_to).removeClassName(this.options.active_class_name);
        this.notify('disabled');
        this.reset();
    },
    reset: function(){
        this.slider.setValue(0);
    },
    recalculateLayout: function(){
        if(this.container.scrollHeight <= this.container.offsetHeight)
            this.disable();
        else{
            this.enable();
            this.slider.trackLength = this.slider.maximumOffset() - this.slider.minimumOffset();
            if(this.options.proportional){
                this.handle.style.height = Math.max(this.container.offsetHeight * (this.container.offsetHeight / this.container.scrollHeight),this.options.handle_minimum_height) + 'px';
                this.slider.handleLength = this.handle.style.height.replace(/px/,'');
            }
        }
    },
    onWindowResize: function(){
        this.recalculateLayout();
        this.scrollBy(0);
    },
    onMouseWheel: function(event){
        if(this.auto_sliding_executer)
            this.auto_sliding_executer.stop();
        this.slider.setValueBy(-(event.memo.delta / 20)); //put in math to account for the window height
        event.stop();
        return false;
    },
    onChange: function(value){
        this.container.scrollTop = Math.round(value / this.slider.maximum * (this.container.scrollHeight - this.container.offsetHeight));
        if(this.notification_timeout)
            window.clearTimeout(this.notificationTimeout);
        this.notificationTimeout = window.setTimeout(function(){
            this.notify('change',value);
        }.bind(this),this.options.notification_timeout_length);
    },
    getCurrentMaximumDelta: function(){
        return this.slider.maximum * (this.container.scrollHeight - this.container.offsetHeight);
    },
    getDeltaToElement: function(element){
        return this.slider.maximum * ((element.positionedOffset().top + (element.getHeight() / 2)) - (this.container.getHeight() / 2));
    },
    scrollTo: function(y,animate){
        var current_maximum_delta = this.getCurrentMaximumDelta();
        if(y == 'top')
            y = 0;
        else if(y == 'bottom')
            y = current_maximum_delta;
        else if(typeof(y) != "number")
            y = this.getDeltaToElement($(y));
        if(this.enabled){
            y = Math.max(0,Math.min(y,current_maximum_delta));
            if(this.auto_sliding_executer)
                this.auto_sliding_executer.stop();
            var target_value = y / current_maximum_delta;
            var original_slider_value = this.slider.value;
            var delta = (target_value - original_slider_value) * current_maximum_delta;
            if(animate){
                this.auto_sliding_executer = new PeriodicalExecuter(function(){
                    if(Math.round(this.slider.value * 100) / 100 < Math.round(target_value * 100) / 100 || Math.round(this.slider.value * 100) / 100 > Math.round(target_value * 100) / 100){
                        this.scrollBy(delta / this.options.scroll_to_steps);
                    }else{
                        this.auto_sliding_executer.stop();
                        this.auto_sliding_executer = null;
                        if(typeof(animate) == "function")
                            animate();
                    }            
                }.bind(this),this.options.scroll_to_smoothing);
            }else
                this.scrollBy(delta);
        }else if(typeof(animate) == "function")
            animate();
    },
    scrollBy: function(y){
        if(!this.enabled)
            return false;
        this.slider.setValueBy(y / this.getCurrentMaximumDelta());
    }
});
Object.Event.extend(Control.ScrollBar);
