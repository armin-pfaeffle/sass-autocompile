path = require('path')
fs = require('fs')

ArgumentParser = require('./argument-parser')


module.exports =
class InlineParameterParser

    parse: (target, callback) ->
        if typeof target is 'object' and target.constructor.name is 'TextEditor'
            @targetFilename = target.getURI()

            # Extract first line from active text editor
            text = target.getText()
            indexOfNewLine = text.indexOf("\n")
            firstLine = text.substr(0, if indexOfNewLine > -1 then indexOfNewLine else undefined)
            @parseFirstLineParameter(firstLine, callback)

        else if typeof target is 'string'
            @targetFilename = target
            @readFirstLine @targetFilename, (firstLine, error) =>
                if error
                    callback(undefined, error)
                else
                    @parseFirstLineParameter(firstLine, callback)

        else
            callback(false, 'Invalid parser call')


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


    parseFirstLineParameter: (line, callback) ->
        params = @parseParameters(line)
        if typeof params is 'object'
            if typeof params.main is 'string'
                if @targetFilename and not path.isAbsolute(params.main)
                    params.main = path.resolve(path.dirname(@targetFilename), params.main)
                callback(params)
            else
                callback(params)
        else
            callback(false)


    parseParameters: (str) ->
        # Extract comment block, if comment is put into /* ... */ or after //
        regex = /^\s*(?:(?:\/\*\s*(.*?)\s*\*\/)|(?:\/\/\s*(.*)))/m
        if (match = regex.exec(str)) != null
            str = if match[2] then match[2] else match[1]

        # ... there is no comment at all
        else
            return false

        argumentParser = new ArgumentParser()

        # Extract keys and values
        regex = /(?:(\!?[\w-\.]+)(?:\s*:\s*(?:(\[.*\])|({.*})|(?:'(.*?)')|(?:"(.*?)")|([^,;]+)))?)*/g

        params = []
        while (match = regex.exec(str)) isnt null
            if match.index == regex.lastIndex
                regex.lastIndex++

            if match[1] != undefined
                key = match[1].trim()
                for i in [2..6]
                    if match[i]
                        value = match[i]
                        break
                if key[0] is '!'
                    key = key.substr(1)
                    if value is undefined
                        value = 'false'
                params[key] = argumentParser.parseValue(value)

        return params
