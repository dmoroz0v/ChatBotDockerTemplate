import Foundation
import __BOTNAME__
import ChatBotSDK
import TgBotSDK
import SQLite

func shell(_ args: [String]) -> [String] {
    var result : [String] = []
    let process = Process()
    process.launchPath = "/usr/bin/env"
    process.arguments = args
    let standardOutput = Pipe()
    process.standardOutput = standardOutput
    process.launch()
    let resultdata = standardOutput.fileHandleForReading.readDataToEndOfFile()
    if var stringValue = String(data: resultdata, encoding: .utf8) {
        stringValue = stringValue.trimmingCharacters(in: .newlines)
        result = stringValue.components(separatedBy: "\n")
    }
    process.waitUntilExit()
    return result.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

}

FileManager.ChatBotSDK.instance = FileManager.ChatBotSDK(documentsUrl: URL(fileURLWithPath: "/var/lib/logic/content/documents"))
if !FileManager.default.fileExists(
    atPath: FileManager.ChatBotSDK.instance.documentsUrl.path
) {
    try? FileManager.default.createDirectory(
        at: FileManager.ChatBotSDK.instance.documentsUrl,
        withIntermediateDirectories: true,
        attributes: nil)
}

struct Config: Decodable {
	let telegram_bot_token: String
}

let basePath = URL(fileURLWithPath: shell(["pwd"]).first!)
let configPath = basePath.appendingPathComponent("../config.json")

let config = try! JSONDecoder().decode(Config.self, from: Data(contentsOf: configPath))

let b = TgBotSDK.Bot(
    flowStorage: try! FlowStorageImpl(),
    botAssembly: BotAssemblyImpl(),
    token: config.telegram_bot_token,
    apiEndpoint: "https://api.telegram.org/bot")

DispatchQueue.global().async {
    while true {
        b.handleUpdates()
    }
}

dispatchMain()
