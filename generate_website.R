suppressPackageStartupMessages(library(knitr))
suppressPackageStartupMessages(library(markdown))
suppressPackageStartupMessages(library(GetoptLong))

header = qq("
<html>
<head>
<style>
@{paste(readLines(getOption(\"markdown.HTML.stylesheet\")), collapse = '\n')}
</style>
</head>
<body>
<p style='text-align:right'>
<span><a href='index.html'>Home</a></span> | 
<span><a href='blog.html'>Blog</a></span> | 
<span><a href='software.html'>Software</a></span> | 
<span><a href='publications.html'>Publications</a></span>
</p>
<hr />
")

footer = "
</body>
</html>
"

## index.html

html = c(header,
"<p>Hi there. My name is Zuguang Gu. Currently I am working at German Cancer Research Center (DKFZ) as a postdoc. 
My major interest includes NGS data analysis and software development.
</p>
<p style='text-align:center'>
<script type=\"text/javascript\">
          Math.random() < 0.5 ? document.write(\"<img style='width:500px' src='image/image1.jpg' />\") 
                              : document.write(\"<img style='width:500px' src='image/image2.jpg' />\") ;
</script>
</p>
", footer)

writeLines(html, "index.html", useBytes = TRUE)

## software.html
html = c(header,
markdownToHTML("software.md", fragment.only = TRUE),
footer)

writeLines(html, "software.html", useBytes = TRUE)


## publication.html
html = c(header,
markdownToHTML("publications.md", fragment.only = TRUE),
footer)

writeLines(html, "publications.html", useBytes = TRUE)


### blog post
setwd("blog")

# need to test both file name and post title
if(file.exists(".post_mtile.RData")) {
	load(".post_mtime.RData")
} else {
	post_mtile = NULL
}

md_files = dir(pattern = "md$")
md_files = unique(gsub("\\.R?md$", "", md_files))
post_info = list(title = NULL, date = NULL)
for(mf in md_files) {
	if(file.exists(qq("@{mf}.Rmd"))) {
		knit(qq("@{mf}.Rmd"), qq("@{mf}.md"), quiet = TRUE)
		html = markdownToHTML(qq("@{mf}.md"))
		title = gsub("^.*<title>(.*?)</title>.*$", "\\1", html)[1]
		date = file.info(qq("@{mf}.Rmd"))$mtime
	} else {
		html = markdownToHTML(qq("@{mf}.md"))
		title = gsub("^.*<title>(.*?)</title>.*$", "\\1", html)[1]
		date = file.info(qq("@{mf}.md"))$mtime
	}
	
	post_info$title = c(post_info$title, title)
	post_info$date = c(post_info$date, date)

	title_url = gsub(" +", "_", title)
	writeLines(html, qq("@{title_url}.html"), useBytes = TRUE)
}
setwd("..")

## blog.html

html = c(header,
{
	blog_list = "<ul>\n";
	for(i in order(post_info$date, decreasing = TRUE)) {
		title = post_info$title[i]
		title_url = gsub(" +", "_", title)
		blog_list = c(blog_list, qq("<li><a href=\"blog/@{title_url}.html\">@{title}</a></li>"))
	}
	blog_list = c(blog_list, "</ul>\n")
},
footer)

writeLines(html, "blog.html", useBytes = TRUE)

