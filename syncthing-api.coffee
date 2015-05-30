######################################################################
#
# Syncthing REST API client for Node.js.
#
# Uses reslter under the hood and exposes
# the API via Bluebird promises.
#
# Example usage:
#
# st = require('syncthing-node')
#
# st.version()
#	.then (result) ->
#		console.log 'Version: ' + result
#	.catch (error) ->
#		console.log 'Error while attempting to get version: ' + error
#
#
# Copyright (c) 2014 Aral Balkan. Released under GNU GPLv3.
# Independence ★ Democracy ★ Design
# ❤ ind.ie
#
######################################################################

rest = require 'restler'
Promise = require 'bluebird'

#
# Public API
#

syncthingAPI =

    ######################################################################
    #
    # GET
    #
    ######################################################################

    getVersion: -> syncthing('get', 'version')

    # Data parameter:
    # repo: repository ID
    getModel: (data) -> syncthing('get', 'model', data)

    getConnections: ->	syncthing('get', 'connections')

    # Data parameters:
    # repo: repository ID
    # node: node ID
    getCompletion: (id,folder) -> syncthing('get', 'completion', 'device=' + id + "&folder=" + folder)

    getConfig: -> syncthing('get', 'config')

    getConfigSync: -> syncthing('get', 'config/sync')

    getSystem: -> syncthing('get', 'system')

    getStatus: -> syncthing('get', 'system/connections')

    getErrors: -> syncthing('get', 'errors')

    getDiscovery: -> syncthing('get', 'discovery')

    # Data parameter:
    # id: node ID
    getNodeId: (data) -> syncthing('get', 'nodeid', data)


    ######################################################################
    #
    # POST
    #
    ######################################################################


    # Data: same object structure as returned from GET:config
    postConfig: (data) -> syncthing('postJson', 'config', data)

    postRestart: -> syncthing('postJson', 'restart')

    # Not sure about the format the data should be sent in: ask Jakob.
    # postError: (data) -> syncthing('post', 'error', data)

    postErrorClear: -> syncthing('postJson', 'error/clear')

    # Data: node (node ID), addr (IP address)
    postDiscoveryHint: (data) -> syncthing('postJson', 'discovery/hint', data)

    # TODO: Not working. Ask Jakob about this (see tests for more info)
    postScan: (data) -> syncthing('postJson', 'scan', data)


module.exports = syncthingAPI


######################################################################
#
# Private functions.
#
######################################################################

# The URL to syncthing REST API.
_syncthingBaseURL = 'http://localhost:8080/rest/'

# Headers
_headers = { 'Accept': '*/*', 'User-Agent': 'Restler for node.js', 'X-API-Key': 'qana2s5oeaoq8oko12489ogphju8ao'}

#
# Helper function for creating REST URLS.
#_
_syncthing = (endpoint) ->
    return _syncthingBaseURL + endpoint

#
# Helper function that makes the calls.
#
syncthing = (verb, url, data = {}) ->

    # Sanity
    if verb not in ['get', 'post', 'postJson']
        throw new Error 'Unsupported REST verb: ' + verb

    return new Promise (fulfill, reject) ->
        retriesLeft = 3

        # Choose the correct data token ('query' or 'data') based
        # on whether the REST call is GET or POST, respectively.
        restCall = null
        optionsObject = {headers: _headers}

        if verb == 'get'

            #
            # GET
            #

            optionsObject.query = data
            restCall = rest.get(_syncthing(url), optionsObject)

        else if verb == 'postJson'

            #
            # POST JSON
            #

            if !data
                data = {}
            restCall = rest.postJson(_syncthing(url), data, optionsObject)

        # else if verb == 'post'

        #   #
        #   # Regular POST
        #   # (The post error method, for example, requires the body of
        #   # the error in the message)
        #   #

        #   optionsObject.data = data
        #   restCall = rest.post(_syncthing(url), optionsObject)


        restCall
            .on 'success', (result) ->
                # Success
                # Inject the url and passed data as metadata on the result
                # in case the handler needs to introspect it to differentiate this call from others.

                # console.log 'RESULT: '
                # console.log result

                # Some calls seems to return nothing (not an empty object but simply nothing)
                # if there is nothing to return.
                # TODO: Check with Jakob if this is expected behaviour. Surely this should
                # ===== be handled differently by Pulse.
                if !result
                    result = {}

                result.__meta__ = {url: url, data: data}

                process.nextTick ->
                    # console.log 'Success'
                    fulfill(result)

            .on 'fail', (data, response) ->
                # A failure is a successful response with a failure code.
                # Retrying will not alter the outcome so let’s fail.
                data.__meta__ = {url: url, data: data}
                util = require 'util'
                console.log 'Fail: ' + util.inspect response
                process.nextTick ->
                    reject(data)

            .on 'error', (error) ->
                # An error is possibly recoverable — try to do so.
                console.log error + ' while trying to reach ' + url
                if retriesLeft
                    retryOrRetries = 'retries'
                    if retriesLeft == 1
                        retryOrRetries = 'retry'

                    console.log retriesLeft + ' ' + retryOrRetries + ' left. Trying again in 3 seconds…'
                    this.retry 3000

                    retriesLeft--

                else
                    error.__meta__ = {url: url, data: data}
                    process.nextTick ->
                        console.log 'No retries left.'
                        reject(error)
