path = require('path')
fs = require('fs')


module.exports =
class ArgumentParser

    parseValue: (value) ->
        # undefined is a special value that means, that the key is defined, but no value
        if value is undefined
            return true

        value = value.trim()

        # Boolean
        if value in [true, 'true', 'yes']
            return true
        if value in [false, 'false', 'no']
            return false

        # Number
        if isFinite(value)
            if value.indexOf('.') > -1
                return parseFloat(value)
            else
                return parseInt(value)

        # Array
        if value[0] is '['
            value = @parseArray(value)

        # Object
        if value[0] is '{'
            value = @parseObject(value)

        return value


    parseArray: (arrayAsString) ->
        arrayAsString = arrayAsString.substr(1, arrayAsString.length - 2)
        regex = /(?:\s*(?:(?:'(.*?)')|(?:"(.*?)")|([^,;]+))?)*/g
        arr = []
        while (match = regex.exec(arrayAsString)) isnt null
            if match.index == regex.lastIndex
                regex.lastIndex++

            value = if match[1] then match[1] else if match[2] then match[2] else if match[3] then match[3] else undefined
            if value isnt undefined
                value = @parseValue(value)
                arr.push(value)

        return arr


    parseObject: (objectAsString) ->
        objectAsString = objectAsString.substr(1, objectAsString.length - 2)
        regex = /(?:(\!?[\w-\.]+)(?:\s*:\s*(?:(?:'(.*?)')|(?:"(.*?)")|([^,;]+)))?)*/g
        obj = {}
        while (match = regex.exec(objectAsString)) isnt null
            if match.index == regex.lastIndex
                regex.lastIndex++

            if match[1] != undefined
                key = match[1].trim()
                value = if match[2] then match[2] else if match[3] then match[3] else if match[4] then match[4]
                if key[0] is '!'
                    key = key.substr(1)
                    if value is undefined
                        value = 'false'
                obj[key] = @parseValue(value)

        return obj
