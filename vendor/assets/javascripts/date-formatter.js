/*
 * Javascript Date formatter
 *
 * Copyright (C) 2010 Greg Methvin (greg@methvin.net)
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

Date.dayNamesShort = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
Date.dayNames = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
Date.monthNamesShort = ['Jan','Feb','Mar','Apr','May','Jun', 'Jul','Aug','Sep','Oct','Nov','Dec'];
Date.monthNames = ['January','February','March','April','May','June', 'July','August', 'September','October','November','December'];

(function () {
    var strpad = function (n, nc, c) {
        nc = nc || 2;
        c = c || '0';
        n = String(Math.round(n));
        while (n.length < nc) {
            n = c + n;
        }
        return n;
    };
    var proto = Date.prototype;
    var formatters = Date.formatters = {
        A: function () {
            return Date.dayNames[this.getDay()];
        },
        a: function () {
            return Date.dayNamesShort[this.getDay()];
        },
        B: function () {
            return Date.monthNames[this.getMonth()];
        },
        b: function () {
            return Date.monthNamesShort[this.getMonth()];
        },
        C: function() {
            return strpad(this.getFullYear()/100);
        },
        D: proto.getDate,
        d: function () {
            return strpad(this.getDate());
        },
        e: function () {
            return strpad(this.getDate(), 2, ' ');
        },
        G: function () {
            var y = this.getFullYear();
            var V = parseInt(formatters.V.call(this), 10);
            var W = parseInt(formatters.W.call(this), 10);
            y -= W === 0 && V >= 52;
            y += W > V;
            return y;
        },
        g: function() {
            return strpad(parseInt(formatters.G.call(this) % 100, 10));
        },
        H: function () {
            return strpad(this.getHours());
        },
        I: function () {
            return strpad(formatters.l.call(this));
        },
        i: proto.getHours,
        j: function () {
            var ms = this.getTime() - new Date(String(this.getFullYear()) + '-1-1 GMT').getTime() +
                this.getTimezoneOffset()*60000;
            return strpad(ms / (60000*60*24) + 1, 3);
        },
        l: function () {
            return this.getHours() % 12 || 12;
        },
        M: function () {
            return strpad(this.getMinutes());
        },
        m: function () {
            return strpad(this.getMonth() + 1);
        },
        P: function () {
            return formatters.H.call(this) < 12 ? 'AM' : 'PM';
        },
        p: function () {
            return formatters.H.call(this) < 12 ? 'am' : 'pm';
        },
        S: function () {
            return strpad(this.getSeconds());
        },
        U: function () {
            return strpad((parseInt(formatters.j.call(this), 10) +
                6 - this.getDay()) / 7);
        },
        u: function () {
            return this.getDay() || 7;
        },
        V: function () {
            var yr = this.getFullYear();
            var firstDay = (new Date(yr, 0, 1)).getDay();
            var isoWeek = parseInt(formatters.W.call(this), 10) + (firstDay <= 4 && firstDay > 1);
            if (isoWeek === 53 && (new Date(yr, 11, 31)).getDay() < 4) {
                isoWeek = 1;
            }
            return strpad(isoWeek || formatters.V.call(new Date(yr - 1, 11, 31)));
        },
        W: function () {
            return strpad(Math.floor((parseInt(formatters.j.call(this), 10) + 7 - (this.getDay() || 7)) / 7));
        },
        w: proto.getDay,
        X: proto.toLocaleTimeString,
        x: proto.toLocaleDateString,
        Y: proto.getFullYear,
        y: function () {
            return strpad(formatters.Y.call(this) % 100);
        },
        z: function () {
            var off = this.getTimezoneOffset(), offHrs = Math.abs(off) / 60, offMin = Math.abs(off) % 60;
            return (off > 0 ? '-' : '+') + strpad(offHrs) + strpad(offMin);
        },
        Z: function () {
            return this.toString().replace(/^.*\((.*?)\)$/, '$1');
        },
        '%': function() {
            return '%';
        }
    };

    Date.format = function (date, str) {
        return String(str).replace(/%([\w%])/g, function () {
            var f = formatters[arguments[1]];
            return f ? f.call(date) : arguments[0];
        });
    };

    Date.prototype.format = function () {
        return Date.format.apply(null, [this].concat(Array.prototype.slice.call(arguments)));
    };
})();

// strftime implementation
var strftime = function (str, date) {
    return Date.format(date || new Date(), str);
};
