import Foundation

/// Writes a minimal .app that execs the ftlman binary sitting next to it.
/// ftlman stays outside the bundle because it reads settings.json and mods/ relative to its own path.
enum ModManagerLauncher {
    private static let executableName = "FTL Mod Manager"

    private static let script = """
        #!/bin/bash
        exec "$(dirname "$0")/../../../ftlman"

        """

    private static let infoPlist: [String: String] = [
        "CFBundleExecutable": executableName,
        "CFBundleIdentifier": "com.ftlhyperspace.modmanager",
        "CFBundleName": executableName,
        "CFBundlePackageType": "APPL",
        "CFBundleInfoDictionaryVersion": "6.0",
        "LSMinimumSystemVersion": "13.0"
    ]

    static func create(at appPath: String) throws {
        let fileManager = FileManager.default
        let contentsDir = "\(appPath)/Contents"
        let macosDir = "\(contentsDir)/MacOS"
        let scriptPath = "\(macosDir)/\(executableName)"

        try? fileManager.removeItem(atPath: appPath)
        try fileManager.createDirectory(atPath: macosDir, withIntermediateDirectories: true)

        let plistData = try PropertyListSerialization.data(fromPropertyList: infoPlist, format: .xml, options: 0)
        try plistData.write(to: URL(fileURLWithPath: "\(contentsDir)/Info.plist"))

        try script.write(toFile: scriptPath, atomically: true, encoding: .utf8)
        try fileManager.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptPath)
    }
}
