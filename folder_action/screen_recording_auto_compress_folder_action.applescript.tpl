on «event facofget» this_folder given «class flst»:added_items
  set workerScript to "__WORKER_SCRIPT__"
  repeat with addedItem in added_items
    set itemPath to POSIX path of addedItem
    set cmdline to "/bin/bash " & quoted form of workerScript & " " & quoted form of itemPath
    «event sysoexec» cmdline
  end repeat
end «event facofget»
