path = require('path')
fs = require('fs')


module.exports =
class InlineParameters

    parse: (filename, callback) ->
        @readFirstLine filename, (line, error) =>
            if error
                callback(undefined, error)
            else
                params = @parseParameters(line)
                if typeof params is 'object'
                    if typeof params.main is 'string'
                        parentFilename = path.resolve(path.dirname(filename), params.main)
                        callback(parentFilename)
                    else
                        params.inputFilename = filename
                        callback(params)
                else
                    callback(false)


    readFirstLine: (filename, callback) ->
        if !fs.existsSync(filename)
            callback(null, "File does not exist: #{filename}")
            return

        # createReadStreams reads 65KB blocks and for each block data event is triggered,
        # so if large files should be read, we stop after the first 65KB block containing
        # the newline character
        line = ''
        called = false
        reader = fs.createReadStream(filename)
        	.on 'data', (data) =>
                line += data.toString()
                indexOfNewLine = line.indexOf("\n")
                if indexOfNewLine > -1
                    line = line.substr(0, indexOfNewLine)
                    called = true
                    reader.close()
                    callback(line)

            .on 'end', () =>
                if not called
                    callback(line)

            .on 'error', (error) =>
                callback(null, error)


    parseParameters: (str) ->
        # Extract comment block, if comment is put into /* ... */ or after //, #, -- or &
        regex = /^\s*(?:(?:\/\*\s*(.*?)\s*\*\/)|(?:(?:\/\/|#|--|%)\s*(.*)))/m
        if (match = regex.exec(str)) != null
            str = if match[2] then match[2] else match[1]

        # ... there is no comment at all
        else
            return false

        # Extract keys and values
        regex = /(?:([\w-\.]+)(?:\s*:\s*(?:(?:'(.*?)')|(?:"(.*?)")|([^,;]+)))?)*/g
        params = []
        while (match = regex.exec(str)) isnt null
            if match.index == regex.lastIndex
                regex.lastIndex++

            if match[1] != undefined
                key = match[1].trim()
                value = if match[2] then match[2] else if match[3] then match[3] else match[4]
                params[key] = @parseValue(value)

        return params


    parseValue: (value) ->
        # undefined is a special value that means, that the key is defined, but no value
        if value is undefined
            return true

        value = value.trim()

        if value in [true, 'true', 'yes']
            return true

        if value in [false, 'false', 'no']
            return false

        if isFinite(value)
            if value.indexOf('.') > -1
                return parseFloat(value)
            else
                return parseInt(value)

        # TODO: Extend for array and objects?

        return value
