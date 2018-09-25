var expressionFileName = "expressionScript";

var TernServer = function(options) {
    this.options = options || {};
    this.server = new tern.Server({
        defs: this.options.defs || []
    });
};

TernServer.prototype = {
    setScript: function(script, callback) {
        this.request({files: [{type: "full", name: expressionFileName, text: script}]}, callback);
    },

    type: function(pos, startPos, callback) {
        var query = buildQuery({type: "type"}, pos, startPos);
        this.request({query: query}, callback);
    },

    completions: function(pos, callback) {
        var query = buildQuery({type: "completions", types: true, docs: true, urls: true}, pos);
        this.request({query: query}, callback);
    },

    request: function (query, callback) {
        var self = this;
        this.server.request(query, function (error, data) {
            if (callback) callback(error, data);
        });
    }
};

function buildQuery(query, pos, startPos) {
    query.end = pos;
    query.start = startPos;
    query.file = expressionFileName;
    return query;
}