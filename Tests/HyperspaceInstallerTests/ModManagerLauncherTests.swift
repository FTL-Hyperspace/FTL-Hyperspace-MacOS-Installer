import Testing
import Foundation
@testable import HyperspaceInstallerLib

@Suite("ModManagerLauncher Tests")
struct ModManagerLauncherTests {

    @Test("Launcher bundle execs the ftlman binary next to it")
    func testLauncherRunsSiblingFTLMan() throws {
        let baseDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).path
        defer { try? FileManager.default.removeItem(atPath: baseDir) }
        try FileManager.default.createDirectory(atPath: baseDir, withIntermediateDirectories: true)

        let markerPath = "\(baseDir)/launched"
        let fakeFTLMan = "\(baseDir)/ftlman"
        try "#!/bin/bash\ntouch '\(markerPath)'\n".write(toFile: fakeFTLMan, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: fakeFTLMan)

        let appPath = InstallationPaths.modManagerAppPath(homeDirectory: baseDir)
            .replacingOccurrences(of: "/Games/FTLHyperspace", with: "")
        try ModManagerLauncher.create(at: appPath)

        let plist = NSDictionary(contentsOfFile: "\(appPath)/Contents/Info.plist")
        let executable = try #require(plist?["CFBundleExecutable"] as? String)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "\(appPath)/Contents/MacOS/\(executable)")
        try process.run()
        process.waitUntilExit()

        #expect(process.terminationStatus == 0)
        #expect(FileManager.default.fileExists(atPath: markerPath))
    }

    @Test("Creating the launcher twice replaces the old bundle")
    func testLauncherIsIdempotent() throws {
        let appPath = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("FTL Mod Manager.app").path
        defer { try? FileManager.default.removeItem(atPath: (appPath as NSString).deletingLastPathComponent) }

        try ModManagerLauncher.create(at: appPath)
        try ModManagerLauncher.create(at: appPath)

        #expect(FileManager.default.isExecutableFile(atPath: "\(appPath)/Contents/MacOS/FTL Mod Manager"))
    }
}
