/*
 * object.watch polyfill
 *
 * 2012-04-03
 *
 * By Eli Grey, http://eligrey.com
 * Public Domain.
 * NO WARRANTY EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.
 */

var kp = require('keypath');

// object.watch
if (!Object.prototype.watch) {
    Object.defineProperty(Object.prototype, "watch", {
        enumerable: false,
        configurable: true,
        writable: false,
        value: function(keypath) {
            var self = this;
            var handler = function(sender, prop, oldValue, newValue) {
                self.trigger('change:' + prop, [ newValue, sender ]);
            };

            // Check for existence of wrapper object's native method
            if ('__watch' in this) {
                this.__watch(keypath, handler);
                return;
            }

            var prop = keypath.split('.').pop(),
                components = keypath.split('.'),
                parent;

            if (components.length == 1) {
                parent = this;
            }
            else {
                parent = kp.get(this, components.splice(components.length - 1, 1));
            }

            var oldval = this[prop],
                newval = oldval,
                getter = function() {
                    return newval;
                },
                setter = function(val) {
                    if (val === newval) return newval;
                    oldval = newval;
                    newval = val;
                    handler.call(self, self, keypath, oldval, val);
                    return newval;
                };

            if (delete this[prop]) { // can't watch constants
                Object.defineProperty(parent, prop, {
                    get: getter, set: setter, enumerable: true, configurable: true
                });
            }
        }
    });
}

// object.unwatch
if (!Object.prototype.unwatch) {
    Object.defineProperty(Object.prototype, "unwatch", {
        enumerable: false,
        configurable: true,
        writable: false,
        value: function(prop) {
            // Check for existence of wrapper object's native method
            if ('__unwatch' in this) {
                this.__unwatch(prop);
                return;
            }

            var val = this[prop];
            delete this[prop]; // remove accessors
            this[prop] = val;
        }
    });
}
