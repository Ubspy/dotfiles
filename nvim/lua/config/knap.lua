local gknapsettings = {
    texoutputext = "pdf",
    textopdf = "pdflatex -synctex=1 -halt-on-error -interaction=batchmode %docroot%",
    textopdfviewerlaunch = "zathura %outputfile%",
    textopdfviewerrefresh = "kill -HUP %pid%",
    -- TODO: I can't get control + click to work on zathura -> nvim jump
    textopdfviewerlaunch = "zathura -x 'nvim --headless -es --cmd \"lua require(\"knaphelper\").relayjump(\"%servername%\", \"%srcfile%\", %line%, 0)\"' %outputfile%",
    textopdfviewerrefresh = "none",
    textopdfforwardjump = "zathura --synctex-forward=%line%:%column%:%srcfile% %outputfile%"
}

vim.g.knap_settings = gknapsettings
