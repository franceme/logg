import ballerina/io;
import ballerina/file;
import ballerina/log;
import frantzme/stringz as str;

isolated string? outputFilePath = ();
isolated boolean printOut = false;
isolated boolean logOut = false;
isolated boolean wrapBase64 = false;

public isolated function setOutputFile(string path, boolean overwrite = true) {
    boolean|error pathExists = file:test(path, file:EXISTS);
    if !(pathExists is error) && pathExists && overwrite {
        error? deleteResponse = file:remove(path);
    }
    lock {
        outputFilePath = path;
    }
}

public isolated function setPrintOut(boolean print = true) {
    lock {
        printOut = print;
    }
}

public isolated function setLog(boolean print = true) {
    lock {
        logOut = print;
    }
}

public isolated function setWrapBase64(boolean wrap = true) {
    lock {
        wrapBase64 = wrap;
    }
}

public isolated function logj(json rawdata) {
    //https://stackoverflow.com/questions/76983957/how-to-iterate-json-array-in-ballerina
    log:KeyValues data = {};
    if rawdata !is map<json> {
        return;
    }
    foreach [string, any] [fieldName, value] in rawdata.entries() {
        data[fieldName] = value;
    }
    log(data);
}

public isolated function log(*log:KeyValues data) {
    string content = data.toString();
    boolean toLog = false;
    boolean toWrap = false;

    lock {
        toWrap = wrapBase64;
    }
    if toWrap {
        content = str:stringToBase64(content);
    }

    lock {
        toLog = logOut;
    }
    if toLog {
        log:printInfo("", (), (), data);
    }

    lock {
        if printOut {
            io:println(content);
        }
    }

    lock {
        if outputFilePath != () {
            boolean|file:Error fileExists = file:test(outputFilePath ?: "", file:EXISTS);
            if !(fileExists is error) && fileExists {
                string|error currentReadFile = io:fileReadString(outputFilePath ?: "");
                if !(currentReadFile is error) {
                    content = currentReadFile + "\n" + content;
                }
                error? deleteResponse = file:remove(outputFilePath ?: "");
            }
            io:Error? fileWriteString = io:fileWriteString(outputFilePath ?: "", content);
        }
    }
}

