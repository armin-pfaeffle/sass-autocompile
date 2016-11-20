fs = require('fs')
path = require('path')


module.exports =
class File

    @delete: (files) ->
        # if file is a single filename then we wrap it into an array and in
        # next step we delete an array of file
        if typeof files is 'string'
            files = [files]

        if typeof files is 'object'
            for file in files
                if fs.existsSync(file)
                    try
                        fs.unlinkSync(file)
                    catch e
                        # do nothing here, if an error occurs


    @getFileSize: (filenames) ->
        fileSize = (filename) ->
            if fs.existsSync(filename)
                return fs.statSync(filename)['size']
            else
                return -1

        if typeof filenames is 'string'
            return fileSize(filenames)
        else
            sizes = {}
            for filename in filenames
                sizes[filename] = fileSize(filename)
            return sizes


    @getTemporaryFilename: (prefix = "", outputPath = null, fileExtension = 'tmp') ->
        os = require('os')
        uuid = require('node-uuid')

        loop
            uniqueId = uuid.v4()
            filename = "#{prefix}#{uniqueId}.#{fileExtension}"

            if not outputPath
                outputPath = os.tmpdir()
            filename = path.join(outputPath, filename)

            break if not fs.existsSync(filename)

        return filename


    @ensureDirectoryExists: (paths) ->
        if typeof paths is 'string'
            paths = [paths]

        for p in paths
            if fs.existsSync(p)
                continue

            parts = p.split(path.sep)

            # If part[0] is an empty string, it's Darwin or Linux, so we set the tmpPath to
            # root directory as starting point
            tmpPath = ''
            if parts[0] is ''
                parts.shift()
                tmpPath = path.sep

            for folder in parts
                tmpPath += (if tmpPath in ['', path.sep] then '' else path.sep) + folder
                if not fs.existsSync(tmpPath)
                    fs.mkdirSync(tmpPath)


    @fileSizeToReadable: (bytes, decimals = 2) ->
        if typeof bytes is 'number'
            bytes = [bytes]

        units = ['Bytes', 'KB', 'MB', 'GB', 'TB']
        unitIndex = 0
        decimals = Math.pow(10, decimals)
        dividend = bytes[0]
        divisor = 1024

        while dividend >= divisor
            divisor = divisor * 1024
            unitIndex++
        divisor = divisor / 1024

        for i in [0..bytes.length - 1]
            bytes[i] = Math.round(bytes[i] * decimals / divisor) / decimals

        readable =
            size: bytes
            unit: units[unitIndex]
            divisor: divisor

        return readable


    @hasFileExtension: (filename, extension) ->
        return false unless typeof filename == 'string'
        fileExtension = path.extname(filename)
        if typeof extension is 'string'
            extension = [extension]
        return fileExtension.toLowerCase() in extension
