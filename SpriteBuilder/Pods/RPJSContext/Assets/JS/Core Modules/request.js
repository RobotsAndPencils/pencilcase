exports.get = function(url) {
    return new Promise(function(resolve, reject) {
        __request_get(url, function(result) {
            resolve(result);
        }, function(error) {
            reject(error);
        });
    });
};

exports.post = function(url, params) {
    return new Promise(function(resolve, reject) {
        __request_post(url, params, function(result) {
            resolve(result);
        }, function(error) {
            reject(error);
        });
    })
};
