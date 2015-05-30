# syncthing-node

A promises-based API client for the [Syncthing REST API][2] in Node.js.

## Installation

	npm install syncthing-node

## Usage

	st = require('syncthing-node')

	st.version()
		.then (result) ->
			console.log 'Version: ' + result
		.catch (error) ->
			console.log 'Error while attempting to get version: ' + error

## Tests

	coffee test.coffee

## Reference

* [The REST interface][2]

## Credits

  * [Syncthing][1] by Jakob Borg, et. al.
  * Uses [Restler][6] by Dan Webb.
  * Uses [bluebird][7] by Petka Antonov.

Copyright &copy; 2014 [Aral Balkan][3]. Licensed under [GNU GPLv3][5]. Released with ❤ by [ind.ie][4]

[1]: http://syncthing.net
[2]: https://discourse.syncthing.net/t/the-rest-interface/85
[3]: https://aralbalkan.com
[4]: https://ind.ie
[5]: http://www.gnu.org/licenses/gpl-3.0.html
[6]: https://github.com/danwrong/restler
[7]: https://github.com/petkaantonov/bluebird