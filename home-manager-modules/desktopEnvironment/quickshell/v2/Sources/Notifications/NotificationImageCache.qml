import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    readonly property string directory:
        Quickshell.statePath("notification-images")
    readonly property int maxDimension: 256

    // Emitted when a cached file exists for the key. Emitted twice per image:
    // first for the raw capture, then for the downscaled thumbnail.
    signal ready(string key, string url)
    // Emitted when the sender file could not be captured, usually because the
    // sender deleted its temporary file before the copy ran.
    signal failed(string key)

    Component.onCompleted: run(["mkdir", "-p", root.directory], null)

    function localPathOf(image: string): string {
        if (image.startsWith("file://"))
            return decodeURIComponent(image.substring(7))
        const iconPrefix = "image://icon/"
        if (image.startsWith(iconPrefix)) {
            const rest = decodeURIComponent(image.substring(iconPrefix.length))
            // A leading slash means a real file path, not a themed icon name.
            if (rest.startsWith("/"))
                return rest
        }
        return ""
    }

    function extensionOf(path: string): string {
        const dot = path.lastIndexOf(".")
        const slash = path.lastIndexOf("/")
        if (dot > slash && dot !== -1)
            return path.substring(dot)
        return ".png"
    }

    function cache(key: string, image: string): void {
        const source = localPathOf(image)
        if (source === "")
            return
        const rawPath = root.directory + "/" + key + ".raw" + extensionOf(source)
        const finalPath = root.directory + "/" + key + ".png"
        run(["cp", "--", source, rawPath], code => {
            if (code !== 0) {
                root.failed(key)
                return
            }
            root.ready(key, "file://" + rawPath)
            const scale = "scale='min(" + root.maxDimension + ",iw)':'min("
                + root.maxDimension + ",ih)':force_original_aspect_ratio=decrease"
            run(["ffmpeg", "-y", "-i", rawPath, "-vf", scale, finalPath],
                ffmpegCode => {
                    if (ffmpegCode !== 0)
                        return
                    root.ready(key, "file://" + finalPath)
                    run(["rm", "-f", "--", rawPath], null)
                })
        })
    }

    function remove(key: string): void {
        if (key === "")
            return
        run(["sh", "-c", 'rm -f -- "' + root.directory + "/" + key + '".*'], null)
    }

    function isCached(image: string): bool {
        return image.startsWith("file://" + root.directory + "/")
    }

    function keyOf(fileName: string): string {
        const dot = fileName.indexOf(".")
        return dot === -1 ? fileName : fileName.substring(0, dot)
    }

    // Delete cached files whose key is not in the kept set.
    function sweep(keepKeys): void {
        const keep = ({})
        keepKeys.forEach(key => keep[key] = true)
        const orphans = []
        const lister = listComponent.createObject(root, { keep, orphans })
        lister.running = true
    }

    function run(command, callback): void {
        const process = procComponent.createObject(root, { command })
        process.exited.connect((code, status) => {
            if (callback !== null)
                callback(code)
            process.destroy()
        })
        process.running = true
    }

    Component {
        id: procComponent
        Process {}
    }

    Component {
        id: listComponent

        Process {
            id: lister

            required property var keep
            required property var orphans

            command: ["find", root.directory, "-maxdepth", "1", "-type", "f",
                "-printf", "%f\n"]

            stdout: SplitParser {
                onRead: line => {
                    const name = line.trim()
                    if (name === "")
                        return
                    if (lister.keep[root.keyOf(name)] !== true)
                        lister.orphans.push(root.directory + "/" + name)
                }
            }

            onExited: (code, status) => {
                if (lister.orphans.length > 0)
                    root.run(["rm", "-f", "--"].concat(lister.orphans), null)
                lister.destroy()
            }
        }
    }
}
