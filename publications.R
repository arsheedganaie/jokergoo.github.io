suppressPackageStartupMessages(library(GetoptLong))
suppressPackageStartupMessages(library(easyPubMed))

pubmed <- easyPubMed::get_pubmed_ids("Zuguang Gu[AU]")
papers <- easyPubMed::fetch_pubmed_data(pubmed)
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

library(scholar)
pub_info = get_publications("zheH1qkAAAAJ")
cites = sapply(titles, function(x) {
	dist = adist(pub_info[[1]], x)/nchar(x)
	i = which.min(dist)
	if(dist[i] < 0.2) {
		pub_info[i, "cites"]
	} else {
		0
	}
})

cites2 = qq(" <span class='cite'><a href='https://scholar.google.de/citations?user=zheH1qkAAAAJ'>cite@{ifelse(cites > 1, 's', '')}: @{cites}</a></span>", collapse = FALSE)
cites2[cites == 0] = ""

con = file("publications.md", "w")
cat("
<style>
.cite {
	padding:2px 10px;
	text-align:center;
	background-color:#1881c2;
	border-radius: 4px;
	-moz-border-radius: 4px;
	-webkit-border-radius: 4px;
}

.cite a {
	font-size: 10px;
	color: white;
	text-decoration: none;
}
</style>
", file = con)
qqcat("## Publications\n\n", file = con)
qqcat("@{seq_along(author_list)}. @{author_list}, @{titles} <i>@{journal_title}</i> @{publish_year}. <a href='https://www.ncbi.nlm.nih.gov/pubmed/@{unlist(pubmed$IdList)}'>PubMed</a>@{cites2}.</li>\n", file = con)
qqcat("\n<p style='border-top:1px dotted #CCCCCC;text-align:right;margin-top:10px;color:#CCCCCC;font-style:normal;font-weight:normal;'>Recodes were automatically retrieved from PubMed by <a href='https://cran.r-project.org/web/packages/easyPubMed/index.html' style='color:#CCCCCC'>easyPubMed</a> and <a href='https://cran.r-project.org/web/packages/XML/index.html' style='color:#CCCCCC'>XML</a> packages.</p>\n", file = con)
close(con)
