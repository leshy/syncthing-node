################################################################
#
# Syncthing REST API client for Node.js tests.
#
# Make sure syncthing is running :)
#
# Copyright (c) 2014 Aral Balkan. Released under GNU GPLv3.
# Independence ★ Democracy ★ Design
# ❤ ind.ie
#
################################################################

Promise = require('bluebird')
st = require('./syncthing-api')

#
# Config — you will need to change at least the NodeID, below, to run the tests.
#

# Change this to a nodeID that exists on your system.
nodeID = 'MLGOSWP-6QVQL4U-S6PHGXP-JFGTUGL-WKJQI5N-XH3A5Z3-WTU5XWF-X7U7EAN'

# Unless you removed this repo, you can leave this alone.
repository = 'test'

#
# Tests — lightweight tests.
#

st.getConfig()
	.then (config) ->
		# Initialisation — we will use the init to set POST variables later
		# while having the least impact on the existing configuration.

		delete config['__meta__']

		tests = [
			{command: 'getVersion', data: {}}, 
			{command: 'getModel', data: {repo: repository}},
			{command: 'getConnections', data: {}},
			{command: 'getCompletion', data: {node: nodeID, repo: repository}},
			{command: 'getConfig', data:{}},
			{command: 'getConfigSync', data:{}},
			{command: 'getSystem', data:{}},
			{command: 'getErrors', data:{}},
			{command: 'getDiscovery', data:{}},
			{command: 'getNodeId', data:{id: nodeID}},
			{command: 'getNodeId', data:{id: 'illegalNodeIDShouldFail'}},
			{command: 'postConfig', data: config},
			
			# Not implementing reset right now — too dangerous :)
			
			# Not testing restart as it throws off other tests (it works)
			# TODO: Test it separately.
			# {command: 'postRestart', data:{}},

			# Not sure about the format the data should be sent in: ask Jakob.
			# {command: 'postError', data:'This is a dummy error'}

			{command: 'postErrorClear', data:{}},

			{command: 'postDiscoveryHint', data: {node: 'LGFPDIT7SKNNJVJZA4FC7QNCRKCE753K72BW5QD2FOZ7FRFEP57Q', addr: '192.162.129.11:22000'}},

			# TODO: Also test with sub parameter (sub folder, e.g., 'foo/bar')
			# TODO: For some reason, this fails with “no such repo” error, even though
			#       the repository exists. Ask Jakob.
			# {command: 'postScan', data:{repo: repository}},
		]

		#
		# Create a suite of GET test promises and execute them.
		#
		testPromises = []
		for test in tests
			testPromises.push st[test.command](test.data)

		Promise.all(testPromises)
			.then (results) ->
				for result in results
					meta = result.__meta__

					prettyDataString = ''
					url = ''

					if meta
						data = meta.data
						url = meta.url

						if Object.keys(data).length != 0
							for parameter of data
								prettyDataString += parameter + ': ' + data[parameter] + ', '
							prettyDataString = prettyDataString.substr(0, prettyDataString.length-2)
					else
						url = '???'
						prettyDataString = 'No data'

					console.log '\n____________________________________________________________'
					console.log '\n' + url + '(' + prettyDataString + ') \n'
					console.log result

			.catch (e) ->
				console.log e

	.catch (e) ->
		console.log 'Could not connect to Syncthing. Are you sure it’s running?'
