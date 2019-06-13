suppressPackageStartupMessages(library(GetoptLong))
suppressPackageStartupMessages(library(easyPubMed))
library(XML)

pubmed <- easyPubMed::get_pubmed_ids("Zuguang Gu[AU]")
papers <- xmlParse(easyPubMed::fetch_pubmed_data(pubmed))
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
	dist = adist(gsub("\\s+", " ", pub_info[[1]]), x)/nchar(x)
	i = which.min(dist)
	if(dist[i] < 0.2) {
		pub_info[i, "cites"]
	} else {
		0
	}
})

# cites2 = qq(" <span class='cite'><a href='https://scholar.google.de/citations?user=zheH1qkAAAAJ'>cite@{ifelse(cites > 1, 's', '')}: @{cites}</a></span>", collapse = FALSE)

cites2 = qq('
<a href="https://scholar.google.de/citations?user=zheH1qkAAAAJ"><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="70" height="16"><linearGradient id="b" x2="0" y2="100%"><stop offset="0" stop-color="#bbb" stop-opacity=".1"/><stop offset="1" stop-opacity=".1"/></linearGradient><clipPath id="a"><rect width="70" height="16" rx="3" fill="#fff"/></clipPath><g clip-path="url(#a)"><path fill="#555" d="M0 0h35v20H0z"/><path fill="#007ec6" d="M35 0h35v20H35z"/><path fill="url(#b)" d="M0 0h70v20H0z"/></g><g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="10"><text x="17.5" y="12" fill="#010101" fill-opacity=".3">cites</text><text x="17.5" y="12">cites</text><text x="51.5" y="12" fill="#010101" fill-opacity=".3">@{cites}</text><text x="51.5" y="12">@{cites}</text></g></svg></a>', collapse = FALSE)
cites2[cites == 0] = ""

con = file("publications.md", "w")
cat("
<style>
svg {
    position: relative;
    top: 3px;
}
</style>
", file = con)
qqcat("## Publications\n\n", file = con)

for(y in sort(unique(publish_year), decreasing = TRUE)) {
	l = publish_year == y
	qqcat("### @{y}\n", file = con)
	qqcat("@{seq_along(author_list)[l]}. @{author_list[l]}, @{titles[l]} <i>@{journal_title[l]}</i> @{y}. <a href='https://www.ncbi.nlm.nih.gov/pubmed/@{unlist(pubmed$IdList[l])}'>PubMed</a>@{cites2[l]}.</li>\n", file = con)
}

qqcat("\n<p style='border-top:1px dotted #CCCCCC;text-align:right;margin-top:10px;color:#CCCCCC;font-style:normal;font-weight:normal;'>Recodes were automatically retrieved from PubMed by <a href='https://cran.r-project.org/web/packages/easyPubMed/index.html' style='color:#CCCCCC'>easyPubMed</a> and <a href='https://cran.r-project.org/web/packages/XML/index.html' style='color:#CCCCCC'>XML</a> packages.</p>\n", file = con)
close(con)
