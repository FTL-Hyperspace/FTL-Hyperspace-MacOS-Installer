import SwiftUI

public struct SummaryView: View {
    @ObservedObject public var state: InstallationState

    public init(state: InstallationState) {
        self._state = ObservedObject(wrappedValue: state)
    }

    public var body: some View {
        VStack(spacing: 20) {
            successView

            Spacer()

            HStack(spacing: 12) {
                Button(action: {
                    if let ftlPath = state.selectedFTL?.path {
                        let ftlFolder = (ftlPath as NSString).deletingLastPathComponent
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: ftlFolder)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "folder")
                        Text("Open FTL Folder")
                    }
                    .frame(maxWidth: .infinity)
                }

                Button(action: {
                    let homeDirectory = NSHomeDirectory()
                    let ftlHyperspaceFolder = InstallationPaths.baseDirectory(homeDirectory: homeDirectory)
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: ftlHyperspaceFolder)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "folder")
                        Text("Mod Manager")
                    }
                    .frame(maxWidth: .infinity)
                }

                Button(action: { NSApplication.shared.terminate(nil) }) {
                    Text("Quit")
                        .frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.cancelAction)
            }
        }
        .frame(maxWidth: 500)
        .padding(30)
    }

    private var successView: some View {
        let homeDirectory = NSHomeDirectory()
        let baseDir = (InstallationPaths.baseDirectory(homeDirectory: homeDirectory) as NSString).abbreviatingWithTildeInPath

        return VStack(spacing: 20) {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)

                Text("Installation Complete")
                    .font(.system(size: 18, weight: .bold))

                Text("\(AppInfo.appName) has been successfully installed!")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    infoItem(label: "FTL Version", value: state.selectedFTL?.version ?? "Unknown")
                    infoItem(label: "Installation Path", value: state.selectedFTL?.path ?? "Unknown")
                    infoItem(label: "Mod Manager Folder", value: baseDir)
                }
                .padding(12)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(6)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Next Steps")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray)

                VStack(alignment: .leading, spacing: 8) {
                    nextStepItem("Play: launch FTL as usual, \(AppInfo.appName) is already enabled")
                    nextStepItem("Add mods: drop .ftl or .zip files into the mods folder")
                    nextStepItem("Apply mods: open FTL Mod Manager, tick the mods you want, and click Apply")
                }

                Text("The mods folder and FTL Mod Manager are both in \(baseDir)")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(6)
        }
    }

    private func infoItem(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.gray)

            Text(value)
                .font(.system(size: 12))
                .foregroundColor(.primary)
                .lineLimit(1)
        }
    }

    private func nextStepItem(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.right.circle.fill")
                .foregroundColor(.blue)
                .font(.system(size: 12))

            Text(text)
                .font(.system(size: 12))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

}
