import WinSDK

enum Win32Process {
    struct Win32Error: Error {
        public var code: DWORD

        public static func throwLastIf(_ condition: Bool) throws {
            if !condition { return }
            let lastError = GetLastError()
            throw Win32Error(code: lastError)
        }
    }

    struct Result {
        public var exitCode: UInt32
        public var standardOutput: String
        public var standardError: String
    }

    private struct Pipe {
        public private(set) var readHandle: HANDLE?
        public private(set) var writeHandle: HANDLE?

        public init(securityAttributes: UnsafeMutablePointer<SECURITY_ATTRIBUTES>? = nil, size: DWORD = 0) throws {
            var readHandle: HANDLE? = nil
            var writeHandle: HANDLE? = nil
            try Win32Error.throwLastIf(!WinSDK.CreatePipe(&readHandle, &writeHandle, securityAttributes, size))
            self.readHandle = readHandle!
            self.writeHandle = writeHandle!
        }

        public mutating func closeRead() {
            WinSDK.CloseHandle(readHandle)
            readHandle = nil
        }

        public mutating func closeWrite() {
            WinSDK.CloseHandle(writeHandle)
            writeHandle = nil
        }

        public mutating func close() {
            closeRead()
            closeWrite()
        }
    }

    static func run(application: String, args: [String]) throws -> Result {
        var commandLine = application
        for arg in args {
            commandLine += " "
            if arg.contains(" ") || arg.isEmpty {
                commandLine += "\""
                commandLine += arg.replacingOccurrences(of: "\"", with: "\"\"")
                commandLine += "\""
            } else {
                commandLine += arg
            }
        }

        return try run(commandLine: commandLine)
    }

    static func run(commandLine: String) throws -> Result {
        var pipeSecurityAttributes = SECURITY_ATTRIBUTES()
        pipeSecurityAttributes.nLength = DWORD(MemoryLayout<SECURITY_ATTRIBUTES>.size)
        pipeSecurityAttributes.bInheritHandle = true

        var standardInputPipe = try Pipe(securityAttributes: &pipeSecurityAttributes, size: 1)
        defer { standardInputPipe.close() }
        var standardOutputPipe = try Pipe(securityAttributes: &pipeSecurityAttributes)
        defer { standardOutputPipe.close() }
        var standardErrorPipe = try Pipe(securityAttributes: &pipeSecurityAttributes)
        defer { standardErrorPipe.close() }

        var startupInfo = STARTUPINFOW()
        startupInfo.cb = UInt32(MemoryLayout<STARTUPINFOW>.size)
        startupInfo.dwFlags = STARTF_USESTDHANDLES
        startupInfo.hStdInput = standardInputPipe.readHandle
        startupInfo.hStdOutput = standardOutputPipe.writeHandle
        startupInfo.hStdError = standardErrorPipe.writeHandle

        var commandLine = Array(commandLine.utf16) + [0]
        var processInformation = PROCESS_INFORMATION()
        try Win32Error.throwLastIf(!WinSDK.CreateProcessW(
            nil, &commandLine,
            nil, nil, // lpProcessAttributes, lpThreadAttributes
            true, // bInheritHandles
            0, // dwCreationFlags
            nil, // dwCreationFlags
            nil, // lpCurrentDirectory
            &startupInfo,
            &processInformation))
        defer { WinSDK.CloseHandle(processInformation.hThread); WinSDK.CloseHandle(processInformation.hProcess) }

        // The child process should be the only owner of the write handle,
        // so that when it exits, the pipe will be closed.
        standardOutputPipe.closeWrite()
        standardErrorPipe.closeWrite()

        var standardOutputBytes = [UInt8]()
        var standardErrorBytes = [UInt8]()
        var readBuffer = Array(repeating: UInt8(0), count: 256)
        while true {
            var bytesRead: DWORD = 0
            guard WinSDK.ReadFile(standardOutputPipe.readHandle, &readBuffer, DWORD(readBuffer.count), &bytesRead, nil) && bytesRead > 0 else { break }
            standardOutputBytes.append(contentsOf: readBuffer[0..<Int(bytesRead)])
        }

        let standardOutputString = String(decoding: standardOutputBytes, as: UTF8.self)
        let standardErrorString = String(decoding: standardErrorBytes, as: UTF8.self)

        var exitCode: DWORD = 0
        try Win32Error.throwLastIf(WinSDK.WaitForSingleObject(processInformation.hProcess, INFINITE) != WAIT_OBJECT_0)
        try Win32Error.throwLastIf(!GetExitCodeProcess(processInformation.hProcess, &exitCode));

        return Result(exitCode: exitCode, standardOutput: standardOutputString, standardError: standardErrorString)
    }
}