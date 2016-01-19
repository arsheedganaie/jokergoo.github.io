suppressPackageStartupMessages(library(GetoptLong))
suppressPackageStartupMessages(library(easyPubMed))
pubmed <- getPubmedIds("Zuguang Gu[AU]")
papers <- fetchPubmedData(pubmed)
author_list = xpathApply(papers, "//AuthorList", function(x) xmlParse(saveXML(x)))
author_list = sapply(author_list, function(x) {
	last_name = xpathApply(x, "//LastName", xmlValue)
	first_name = xpathApply(x, "//ForeName", xmlValue)
	name = paste(first_name, last_name, sep = " ")
	name[name == "Zuguang Gu"] = "<strong>Zuguang Gu</strong>"
	#if(length(name) > 10) name = name[1:10]
	paste0(name, collapse = ", ")
})
titles = unlist(xpathApply(papers, "//ArticleTitle", xmlValue))
journal = xpathApply(papers, "//Journal", function(x) xmlParse(saveXML(x)))
journal_title = sapply(seq_len(length(journal)), function(i) {
	x = xpathApply(journal[[i]], "//Title", xmlValue)[[1]]
	if(length(x)) x[1] else ""
})
publish_year = sapply(seq_len(length(journal)), function(i) {
	x = xpathApply(journal[[i]], "//Year", xmlValue)[[1]]
	if(length(x)) x[1] else ""
})


con = file("publications.md", "w")
qqcat("## Publications\n\n", file = con)
qqcat("@{seq_along(author_list)}. @{author_list}, @{titles}, <i>@{journal_title}</i> @{publish_year}. <a href='http://www.ncbi.nlm.nih.gov/pubmed/@{unlist(pubmed$IdList)}'>PubMed</a>.</li>\n", file = con)
qqcat("\n<p style='border-top:1px dotted #CCCCCC;text-align:right;margin-top:10px;color:#CCCCCC;font-style:normal;font-weight:normal;'>Recodes were automatically retrieved from PubMed by <a href='https://cran.r-project.org/web/packages/easyPubMed/index.html'>easyPubMed</a> and <a href='https://cran.r-project.org/web/packages/XML/index.html'>XML</a> packages.</p>\n", file = con)
close(con)
