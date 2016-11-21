Build a static website and blog by knitr and rmarkdown
=======================================================

There is already very nice solutions to build a static website and blog
based on [Jekyll](https://help.github.com/articles/using-jekyll-with-pages/) and host on [GitHub](http://github.com).
However, I still have problems to make a real functional website by learning those online tutorials. Actually
it is not that difficult to write my own scripts to generate static HTML pages.
Also it is easy to support **knitr** package to automatically generate a HTML document with
executing R code on the fly.

Take my website for example, there are `index.html`, `software.html`, `publications.html` which
are converted from [`index.md`](https://raw.githubusercontent.com/jokergoo/jokergoo.github.io/master/index.md), 
[`software.md`](https://raw.githubusercontent.com/jokergoo/jokergoo.github.io/master/software.md), 
[`publications.md`](https://raw.githubusercontent.com/jokergoo/jokergoo.github.io/master/publications.md) respectively. 
[A general script](https://github.com/jokergoo/jokergoo.github.io/blob/master/generate_website.R) takes
care of the common HTML head and foot for each HTML document, reads the `.md` files and convert to the HTML fragment.

For the blog part, there is a sub-folder called `blog/` and posts in `.md` or `.Rmd` format are put in.
If the file name of the post ends with `.Rmd`, `knit()` is first called and converts into HTML fragment by `markdownToHTML()`
afterwards, while if the file name of the post ends with `.md`, `markdownToHTML()` is simply called to convert
to HTML fragment.

There is a tiny "database" (`post_info`) which records some basic information for a post, e.g. create time, last
modified time so that post without changes does not need to be re-generated. 

[Inode](https://en.wikipedia.org/wiki/Inode) is used as the unique identifier of files. The drawback is 
the HTML pages can only be generated in a same computer.

After all posts are generated, title for each post is extracted as well as the creating time,
which will be used to generate `blog.html`.

If comments system is to be supported, after the HTML generation of each post, the Javascript fragment of [Disqus](https://disqus.com/home/)
can be inserted before `</body>`.
 

<!-- uid=website_knitr -->
