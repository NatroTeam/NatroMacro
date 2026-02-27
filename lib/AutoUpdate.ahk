#Requires AutoHotkey v2.0
#Include JSON.ahk

github := "https://api.github.com/repos"
class AutoUpdater {
    newVersion := false

    __New(owner, repo, tree:="main", savePath:="version") {
        this.APIRepoURL := github "/" owner "/" repo
        this.commitsURL := this.APIRepoURL "/commits?per_page=10&sha=" tree
        this.commitURL := this.APIRepoURL "/commits/"
        this.fileURL := "https://raw.githubusercontent.com/" owner "/" repo "/" tree "/"
        this.updatedFiles := Map()
        this.savePath := savePath ".txt"
        this.CommitString := ""
        this.currentCommit := false

        this._GetCommitVersion()
        this._CheckForCommitUpdates()
    }
    
    _HttpGet(url) {
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.Open("GET", url, false)
        http.SetRequestHeader("User-Agent", "AutoUpdate AHK")
        http.Send()
        http.WaitForResponse()

        return http.ResponseText
    }
    
    _JSONGet(url) {
        return JSON.parse(this._HttpGet(url))
    }

    _CheckCommit(commit) {
        commit := this._JSONGet(this.commitURL . commit)
        this.CommitString .= commit["commit"]["message"] "`n"
        for i, file in commit["files"] {
            fileDir := file["filename"]
            if file["status"] == "removed" {
                this.updatedFiles[fileDir] := "Remove"
            } else {
                this.updatedFiles[fileDir] := "Update"
            }
        }
        for _, newCommit in commit["parents"] {
            if newCommit["sha"] == this.currentCommit {
                return
            }
        }
        for _, newCommit in commit["parents"] {
            this._CheckCommit(newCommit["sha"])
        }
    }

    _GetCommitVersion() {
        if FileExist(this.savePath) {
            this.currentCommit := FileRead(this.savePath)
        }
    }

    _CheckForCommitUpdates() {
        commits := this._JSONGet(this.commitsURL)

        latestCommit := commits[1]
        latestCommitID := latestCommit["sha"]

        this.latestCommitID := latestCommitID
        if not this.currentCommit {
            this.currentCommit := latestCommitID
            FileAppend(latestCommitID, this.savePath)
        }
        
        if latestCommitID != this.currentCommit {
            this.newVersion := true
            this._CheckCommit(latestCommitID)
        }
        this.CommitString := SubStr(this.CommitString, 1, StrLen(this.CommitString)-1)
    }

    GetCommitMessages() {
        return this.CommitString
    }

    UpdateFiles() {
        for fileDir, cmd in this.updatedFiles {
            if cmd == "Remove" {
                if FileExist(fileDir) {
                    DirDelete fileDir
                }
            } else {
                Download(this.fileURL . fileDir, fileDir)
            }
        }
        versionFile := FileOpen(this.savePath, "w-d")
        versionFile.Write(this.latestCommitID)
        versionFile.Close()
    }
}