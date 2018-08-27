suppressPackageStartupMessages(library(knitr))
suppressPackageStartupMessages(library(markdown))
suppressPackageStartupMessages(library(GetoptLong))
suppressPackageStartupMessages(library(htmltools))
library(digest)

all = FALSE
GetoptLong(c("all", "whether refresh all"))

list = "
<p style='text-align:right'>
<span><a href='index.html'>Home</a></span> | 
<span><a href='blog.html'>Blog</a></span> | 
<span><a href='software.html'>Software</a></span> | 
<span><a href='publications.html'>Publications</a></span> |
<span><a href='https://github.com/jokergoo/'>GitHub</a></span>
</p>
<hr />
"

header = qq('
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head xmlns:xi="http://www.w3.org/2001/XInclude"><meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<style>
@{paste(readLines(getOption("markdown.HTML.stylesheet")), collapse = "\n")}
</style>
</head>
<body>
@{list}
')

footer = "
</body>
</html>
"

## index.html

html = c(header,
markdownToHTML("index.md", fragment.only = TRUE),
footer)

cat("generate index.html...\n")
writeLines(html, "index.html", useBytes = TRUE)


## software.html
html = c(header,
markdownToHTML("software.md", fragment.only = TRUE),
footer)

cat("generate software.html...\n")
writeLines(html, "software.html", useBytes = TRUE)


## publication.html
system("Rscript publications.R")
html = c(header,
markdownToHTML("publications.md", fragment.only = TRUE),
footer)

cat("generate publications.html...\n")
writeLines(html, "publications.html", useBytes = TRUE)


### blog post
setwd("blog")

# need to test both file name and post title
# if(file.exists(".post_mtile.RData")) {
# 	load(".post_mtime.RData")
# } else {
# 	post_mtile = NULL
# }

add_disqus = function(html, url) {
	disqus = qq("
<div id='disqus_thread'></div>
<script>
var disqus_config = function () {
this.page.url = \"http://jokergoo.github.io/blog/@{url}\";
};
(function() { // DON'T EDIT BELOW THIS LINE
var d = document, s = d.createElement('script');

s.src = '//jokergoogithub.disqus.com/embed.js';

s.setAttribute('data-timestamp', +new Date());
(d.head || d.body).appendChild(s);
})();
</script>
<noscript>Please enable JavaScript to view the <a href='https://disqus.com/?ref_noscript' rel='nofollow'>comments powered by Disqus.</a></noscript>
")
	html = gsub("</body>", qq("@{disqus}</body>"), html)
	return(html)
}

add_list = function(html) {
	gsub("<body>", qq("<body>@{list}"), html)
}

if(!file.exists(".post_info.RData")) {
	cat("cannot find .post_info.RData, initalize a new one...\n")
	post_info = list(uid = NULL, title = NULL, create_time = NULL, last_modified_time = NULL, file_name = NULL)
} else {
	cat("load .post_info.RData...\n")
	load(".post_info.RData")	
	qqcat("There are already @{length(post_info$title)} posts.\n")
}

md_files = dir(pattern = "\\.R?md$")
md_uid = sapply(md_files, function(f) {
	lines = readLines(f)
	ind = grep("<!-- uid=.*? -->", lines)
	if(length(ind)) {
		ind = ind[1]
		uid = gsub("<!-- uid=(.*?) -->", "\\1", lines[ind])
		return(uid)
	} else {
		return("")
	}
})
md_uid2 = md_uid
md_last_modified = file.info(md_files)$mtime
qqcat("detected @{length(md_files)} (R)md files.\n")

for(i in seq_along(md_files)) {
	
	# if it is a new file
	if(md_uid[i] == "" || !md_uid[i] %in% post_info$uid) {
		cat("==\n")
		# uid = digest(qq("@{md_files[i]}_@{md_last_modified[i]}"), algo = "md5")
		if(md_uid[i] == "") {
			uid = gsub("\\.R?md$", "", md_files[i])
		} else {
			uid = md_uid[i]
		}
		post_info$uid = c(post_info$uid, uid)
		fn = uid
		post_info$file_name = c(post_info$file_name, fn)
		if(length(post_info$create_time) == 0) {
			post_info$create_time = md_last_modified[i]
		} else {
			post_info$create_time = c(post_info$create_time, md_last_modified[i])
		}
		if(length(post_info$last_modified_time) == 0) {
			post_info$last_modified_time = md_last_modified[i]
		} else {
			post_info$last_modified_time = c(post_info$last_modified_time, md_last_modified[i])
		}
		md_uid2[i] = uid

		# add uid to (R)md file
		if(md_uid[i] == "") {
			lines = readLines(md_files[i])
			lines = c(lines, "", qq("<!-- uid=@{uid} -->"))
			writeLines(lines, md_files[i])
		}

		if(grepl("\\.Rmd$", md_files[i])) {
			knit(md_files[i], qq("md_files[i].md"), quiet = TRUE)
			html = markdownToHTML(qq("md_files[i].md"), stylesheet = "../markdown.css"); file.remove(qq("md_files[i].md"))
			title = gsub("^.*<title>(.*?)</title>.*$", "\\1", html)[1]
		} else {
			html = markdownToHTML(md_files[i], stylesheet = "../markdown.css")
			title = gsub("^.*<title>(.*?)</title>.*$", "\\1", html)[1]
		}

		post_info$title = c(post_info$title, title)
		
		title_url = paste0("html/", fn)
		html = add_disqus(html, url = title_url)
		html = add_list(html)
		qqcat("writing @{title_url}.html\n")
		writeLines(html, qq("@{title_url}.html"), useBytes = TRUE)

		qqcat("created post: @{title}.\n")

	} else {
		k = which(post_info$uid %in% md_uid[i])
		# if it is modified since last time
		if(md_last_modified[i] > post_info$last_modified_time[k] || all) {
			cat("==\n")
			qqcat("@{md_last_modified[i]} > @{post_info$last_modified_time[k]}\n")
			post_info$last_modified_time[k] = md_last_modified[i]

			title_url = paste0("html/", post_info$file_name[k])
			if(file.exists(qq("@{title_url}.html"))) file.remove(qq("@{title_url}.html"))

			if(grepl("\\.Rmd$", md_files[i])) {
				knit(md_files[i], qq("md_files[i].md"), quiet = TRUE)
				html = markdownToHTML(qq("md_files[i].md"), stylesheet = "../markdown.css"); file.remove(qq("md_files[i].md"))
				title = gsub("^.*<title>(.*?)</title>.*$", "\\1", html)[1]
			} else {
				html = markdownToHTML(md_files[i], stylesheet = "../markdown.css")
				title = gsub("^.*<title>(.*?)</title>.*$", "\\1", html)[1]
			}

			post_info$title[k] = title
			
			title_url = paste0("html/", post_info$file_name[k])
			html = add_disqus(html, url = title_url)
			html = add_list(html)
			qqcat("writing @{title_url}.html\n")
			writeLines(html, qq("@{title_url}.html"), useBytes = TRUE)

			qqcat("updated post: @{title}.\n")
		}
	}
}

deleted_md_uid = setdiff(post_info$uid, md_uid2)
if(length(deleted_md_uid) > 0) {
	l = post_info$uid %in% deleted_md_uid
	post_info = lapply(post_info, function(x) x[!l])
	qqcat("delete @{deleted_md_uid}.\n")
}
save(post_info, file = ".post_info.RData")
setwd("..")

## blog.html

html = c(header,
"<div style='min-height:400px'>",
{
	blog_list = "<ul>\n";
	for(i in order(post_info$create_time, decreasing = TRUE)) {
		title = post_info$title[i]
		title_url = paste0("html/", post_info$file_name[i])
		blog_list = c(blog_list, qq("<li><a href=\"blog/@{title_url}.html\">@{title}</a> (@{format(post_info$create_time[i], '%m/%d/%Y')})</li>"))
	}
	blog_list = c(blog_list, "</ul>\n")
},
"</div>\n",
"\n<p style='border-top:1px dotted #CCCCCC;text-align:right;margin-top:10px;font-size:0.8em'><a href='http://feeds.feedburner.com/ZuguangGusBlog' style='color:#CCCCCC;font-weight:normal'>RSS</a></p>\n",
footer)

cat("generate blog.html...\n")
writeLines(html, "blog.html", useBytes = TRUE)


## rss.xml
header = "<?xml version='1.0' encoding='UTF-8' ?>
<rss version='2.0'>
<channel>
  <title>Zuguang Gu's blog</title>
  <link>http://zuguang.de/blog.html</link>
  <description>Zuguang Gu's blog</description>
"

footer = "
</channel>
</rss>
"

html = c(header,
{
	blog_list = NULL
	i_rss = 0
	for(i in order(post_info$create_time, decreasing = TRUE)) {
		title = post_info$title[i]
		title_url = paste0("html/", post_info$file_name[i])

		blog_html = paste(readLines(qq("blog/@{title_url}.html")), collapse = "\n")
		blog_body = gsub("^.*?<span><a href='https://github.com/jokergoo/'>GitHub</a></span>\n</p>\n<hr />\n(.*?)<div id='disqus_thread'></div>.*$", "\\1", blog_html)

		if(grepl("<!--\\s*?rss\\s*?=\\s*?FALSE\\s*?-->", blog_body)) {
			next()
		}

		blog_body = gsub(qq("<h1>@{title}</h1>"), "", blog_body)
		blog_body = gsub("<img src=\"data:image.*?>", "<strong>Please see the figure in the original post.</strong>", blog_body)

		i_rss = i_rss + 1

		blog_body = htmlEscape(blog_body)
		blog_body = qq("<item>\n<title>@{title}</title>\n<link>blog/@{title_url}.html</link>\n<pubDate>@{format(post_info$create_time[i], \"%a, %d %h %Y %H:%M:%S CET\")}</pubDate>\n<description>@{blog_body}</description>\n</item>\n")

		blog_list = c(blog_list, blog_body)
		
		if(i_rss > 20) break()
	}
	blog_list
	
},
footer)

cat("generate rss.html...\n")
writeLines(html, "rss.xml", useBytes = TRUE)

