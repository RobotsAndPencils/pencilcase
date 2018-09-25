var kp = require('keypath');

if (!Object.prototype.bind) {
    Object.defineProperty(Object.prototype, 'bind', {
        enumerable: false,
        configurable: true,
        writable: false,
        value: function(keypath, target, targetKeypath, map, backwardsMap) {
            if (!_.isFunction(backwardsMap)) {
                backwardsMap = map;
            }

            this.watch(keypath);
            this.on('change:' + keypath, function(newValue) {
                if (_.isFunction(backwardsMap)) {
                    newValue = backwardsMap(newValue);
                }
                kp.set(target, targetKeypath, newValue);
            });

            target.watch(targetKeypath);
            var self = this;
            target.on('change:' + targetKeypath, function(newValue) {
                if (_.isFunction(map)) {
                    newValue = map(newValue);
                }
                kp.set(self, keypath, newValue);
            });
        }
    });
}
