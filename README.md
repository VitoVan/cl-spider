# cl-spider
A Common Lisp Spider for the Web

## Installlation

* 1) Install [Quicklisp](http://quicklisp.org/), if not.

* 2) Configure ASDF:

```bash
mkdir -p ~/.config/common-lisp/source-registry.conf.d/
echo "(:tree (:home \"quicklisp/downloaded-projects/\"))" > ~/.config/common-lisp/source-registry.conf.d/projects.conf
```

* 3) Download cl-spider:

```bash
mkdir -p ~/quicklisp/downloaded-projects
cd ~/quicklisp/downloaded-projects
git clone git@github.com:VitoVan/cl-spider.git
```

* 4) Restart your REPL, then:

```Lisp
(ql:quickload 'cl-spider)
```
![](https://avatars1.githubusercontent.com/u/1756956?v=3&s=460)

## Function

**cl-spider:get-data** uri &key selector attrs

uri --- the uri
selector --- block selector
attrs --- the attrs of the selector


```Lisp
(cl-spider:get-data "https://news.ycombinator.com/" :selector "a" :attrs '("href" "text"))
```

![](https://avatars1.githubusercontent.com/u/1756956?v=3&s=460)

**cl-spider:get-block-data** uri &key selector desires

uri --- the uri
selector --- block selector
desires --- a list contains sub selectors and their attrs

```Lisp
(cl-spider:get-block-data "https://news.ycombinator.com/" 
                                   :selector "tr.athing" 
                                   :desires '(((:selector . "span.rank") (:attrs . ("text as rank")))
                                              ((:selector . "td.title>a") (:attrs . ("href as uri" "text as title")))
                                              ((:selector . "span.sitebit.comhead") (:attrs . ("text as site")))))
```

![](https://avatars1.githubusercontent.com/u/1756956?v=3&s=460)

## TODO

* Multiple Selector Support
