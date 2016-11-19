+++
date = "2016-11-19T22:17:58Z"
description = "My experiences in moving from Jekyll to Hugo"
title = "Hello, hugo!"
summary = "Finally got around to moving this blog from Jekyll to Hugo and setting up a Cloudflare account with SSL."
categories = ["yak-shaving"]
draft = true
+++
I had been running this blog using Jekyll for a while now, but didn't quite understand how it all worked. Jekyll is a great tool, and you don't need a whole lot of configuration to get started. If you're using github to host either personal, project or organisation pages, Jekyll is a no-brainer to get started with. However, as I'm not much of a Ruby programmer, I didn't quite understand how Jekyll worked and having to `gem install ruby` felt wrong -- especially since it also installs a whole lot of other dependencies that I don't understand, either. After some digging around, I discovered [hugo](http://gethugo.io), which is a static site generator written in Go. 

### Why hugo?
Hugo's written in Go, which means that all you need to get started is a binary of hugo somewhere in your `$PATH`. That's it. Everything it needs is baked into this statically compiled binary. To me, Go code is easy to read and I find it easier to understand how it works. Besides, all the cool kids today use go for both personal and professional projects and I didn't want to miss out. 

Hugo shares much of the same common philosophy as Jekyll and possibly the hundreds of [static site generators](https://www.staticgen.com/) available today. You write your blog posts are written in markdown and rendered as HTML. They layout of your content and the look and feel of your blog is made up of [community created themes](http://themes.gohugo.io/) that you can customise to get the perfect look and feel for your site.  It is also arguably a masochistic way to publish your blog, if you're used to WordPress or similar content management platforms. Hugo doesn't give you an editor or a point and click interface to add images, for example. But it's not just for people who are suckers for punishment, it's a great way to maintain your blog entirely from the command line (web based editing is on the roadmap - but I wouldn't hold my breath).

This is not meant to be a hugo tutorial; if you want to learn how to start out with a hugo blog or website, try the [official documentation](https://gohugo.io/overview/introduction/). 

### Hugo and User GitHub pages
Jekyll works great with GitHub pages of all kinds as GitHub automatically recognises Jekyll based sites and automatically "builds" them into great looking static websites. Unfortunately, GitHub doesn't know what to do with Hugo based sites, so it attempts to build them and fails. When moving from Jekyll to Hugo, this was the first hurdle that I ran into. There's a well written tutorial on using GitHub for [hosting with Hugo](https://gohugo.io/tutorials/github-pages-blog/) and I'll try and summarise my experience in getting it to work with personal sites i.e. served from the <YOUR_USERNAME>.github.io repository. 

If you don't already have a <YOUR_USERNAME>.github.io repository, you should create one now. The most important bit of information that I missed while reading the tutorial was that for personal sites, GitHub will only serve pages from the master branch of the <YOUR_USERNAME>.github.io repository. Not the `gh-pages` branch, which I initially thought was the case. This took me way too long to figure out, even though the tutorial clearly calls it out. 

To host and serve your user github page, you'll need to set up two repositories. One that stores the source for your blog and the other is the static site itself (e.g. ritesh.github.io). First, you want to create a git repo that is going to store all the contents of your blog. This includes the entire directory structure your site as created by Hugo on first run. Next, you want to add the `<YOUR_GITHUB_USERNAME>.github.io` repository as a git submodule. I've added the theme as a submodule too, but this is not stricly required if you don't intend to modify the theme. After you're happy with the way your site looks, you need a way to push the generated site to your `<YOUR_GITHUB_USERNAME>.github.io`. To do this, the following script from the tutorial above works perfectly. The script to do this looks like this:

```
#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the project.
hugo # if using a theme, replace by `hugo -t <yourtheme>`

# Go To Public folder
cd public
# Add changes to git.
git add -A

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master

# Come Back
cd ..
```

The `public` folder is a submodule of the blog source project. Every time you run the deploy script a new commit is created and added to the user page repository. Each time that you run the deploy script, a new commit is created in the submodule that contains your final site. 

### Adding SSL/TLS
Github pages offer free SSL connections, but only if you're not using custom domain names. To enable SSL/TLS, I used cloudflare as my DNS servers for blog.rsinha.org. Cloudflare can also be configured to provide additional features, such as caching. Note that when setting up Cloudflare, you can configure your site to serve all URLs over HTTPS rather than HTTP. This took me a while to figure out, since some of my assets were being served over HTTP and Chrome prevented the site from rendering correctly due to mixed-content warnings. 

### Total cost of hosting
- uses github pages
- free cloudflare plan
- no server setup
- free caching


### Future work
- set up a hugo content publishing method that allows me to edit drafts on the go
- tweak theme
- actually blog about useful things, and avoid yak-shaving exercises



