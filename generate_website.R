suppressPackageStartupMessages(library(knitr))
suppressPackageStartupMessages(library(markdown))
suppressPackageStartupMessages(library(GetoptLong))


list = "
<p style='text-align:right'>
<span><a href='http://jokergoo.github.io/index.html'>Home</a></span> | 
<span><a href='http://jokergoo.github.io/blog.html'>Blog</a></span> | 
<span><a href='http://jokergoo.github.io/software.html'>Software</a></span> | 
<span><a href='http://jokergoo.github.io/publications.html'>Publications</a></span> |
<span><a href='https://github.com/jokergoo/'>GitHub</a></span>
</p>
<hr />
"

header = qq("
<html>
<head>
<style>
@{paste(readLines(getOption(\"markdown.HTML.stylesheet\")), collapse = '\n')}
</style>
</head>
<body>
@{list}
")

footer = "
</body>
</html>
"

## index.html

html = c(header,
markdownToHTML("index.md", fragment.only = TRUE),
footer)

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

	title_url = gsub(" +", "-", title)
	html = add_disqus(html, url = title_url)
	html = add_list(html)
	writeLines(html, qq("@{title_url}.html"), useBytes = TRUE)
}
setwd("..")

## blog.html

html = c(header,
{
	blog_list = "<ul>\n";
	for(i in order(post_info$date, decreasing = TRUE)) {
		title = post_info$title[i]
		title_url = gsub(" +", "-", title)
		blog_list = c(blog_list, qq("<li><a href=\"blog/@{title_url}.html\">@{title}</a></li>"))
	}
	blog_list = c(blog_list, "</ul>\n")
},
footer)

writeLines(html, "blog.html", useBytes = TRUE)

