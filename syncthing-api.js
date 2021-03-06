// Generated by CoffeeScript 1.7.1
(function() {
  var Promise, rest, syncthing, syncthingAPI, _headers, _syncthing, _syncthingBaseURL;

  rest = require('restler');

  Promise = require('bluebird');

  syncthingAPI = {
    getVersion: function() {
      return syncthing('get', 'version');
    },
    getModel: function(data) {
      return syncthing('get', 'model', data);
    },
    getConnections: function() {
      return syncthing('get', 'connections');
    },
    getCompletion: function(id, folder) {
      return syncthing('get', 'completion', 'device=' + id + "&folder=" + folder);
    },
    getConfig: function() {
      return syncthing('get', 'config');
    },
    getConfigSync: function() {
      return syncthing('get', 'config/sync');
    },
    getSystem: function() {
      return syncthing('get', 'system');
    },
    getStatus: function() {
      return syncthing('get', 'system/connections');
    },
    getErrors: function() {
      return syncthing('get', 'errors');
    },
    getDiscovery: function() {
      return syncthing('get', 'discovery');
    },
    getNodeId: function(data) {
      return syncthing('get', 'nodeid', data);
    },
    postConfig: function(data) {
      return syncthing('postJson', 'config', data);
    },
    postRestart: function() {
      return syncthing('postJson', 'restart');
    },
    postErrorClear: function() {
      return syncthing('postJson', 'error/clear');
    },
    postDiscoveryHint: function(data) {
      return syncthing('postJson', 'discovery/hint', data);
    },
    postScan: function(data) {
      return syncthing('postJson', 'scan', data);
    }
  };

  module.exports = syncthingAPI;

  _syncthingBaseURL = 'http://localhost:8080/rest/';

  _headers = {
    'Accept': '*/*',
    'User-Agent': 'Restler for node.js',
    'X-API-Key': 'qana2s5oeaoq8oko12489ogphju8ao'
  };

  _syncthing = function(endpoint) {
    return _syncthingBaseURL + endpoint;
  };

  syncthing = function(verb, url, data) {
    if (data == null) {
      data = {};
    }
    if (verb !== 'get' && verb !== 'post' && verb !== 'postJson') {
      throw new Error('Unsupported REST verb: ' + verb);
    }
    return new Promise(function(fulfill, reject) {
      var optionsObject, restCall, retriesLeft;
      retriesLeft = 3;
      restCall = null;
      optionsObject = {
        headers: _headers
      };
      if (verb === 'get') {
        optionsObject.query = data;
        restCall = rest.get(_syncthing(url), optionsObject);
      } else if (verb === 'postJson') {
        if (!data) {
          data = {};
        }
        restCall = rest.postJson(_syncthing(url), data, optionsObject);
      }
      return restCall.on('success', function(result) {
        if (!result) {
          result = {};
        }
        result.__meta__ = {
          url: url,
          data: data
        };
        return process.nextTick(function() {
          return fulfill(result);
        });
      }).on('fail', function(data, response) {
        var util;
        data.__meta__ = {
          url: url,
          data: data
        };
        util = require('util');
        console.log('Fail: ' + util.inspect(response));
        return process.nextTick(function() {
          return reject(data);
        });
      }).on('error', function(error) {
        var retryOrRetries;
        console.log(error + ' while trying to reach ' + url);
        if (retriesLeft) {
          retryOrRetries = 'retries';
          if (retriesLeft === 1) {
            retryOrRetries = 'retry';
          }
          console.log(retriesLeft + ' ' + retryOrRetries + ' left. Trying again in 3 seconds…');
          this.retry(3000);
          return retriesLeft--;
        } else {
          error.__meta__ = {
            url: url,
            data: data
          };
          return process.nextTick(function() {
            console.log('No retries left.');
            return reject(error);
          });
        }
      });
    });
  };

}).call(this);
