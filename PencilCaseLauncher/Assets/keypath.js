var getter = function(obj, path) {
    if ('valueForKeyPath' in obj) {
        return obj.valueForKeyPath(path);
    }
    var parts = path.split('.');
    var value = obj;
    while (parts.length) {
        var part = parts.shift();
        value = value[part];
        if (value === undefined) parts.length = 0;
    }
    return value;
};

var setter = function(obj, path, value) {
    if (getter(obj, path) === value) return;
    if ('setValueForKeyPath' in obj) {
        obj.setValueForKeyPath(value, path);
        return;
    }
    var parts = path.split('.');
    var target = obj;
    var last = parts.pop();
    while (parts.length) {
        part = parts.shift();
        if (!target[part]) target[part] = {};
        target = target[part];
    }
    target[last] = value;
};

exports.get = getter;
exports.set = setter;
