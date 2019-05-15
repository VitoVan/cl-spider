# cl-spider
A Common Lisp Spider for the Web

> 🚨 **WARNING** 🚨

> **DON'T use this shit before you read the code, it's very badly wriiten and incomplete.**

## Installlation

* Install [Quicklisp](http://quicklisp.org/), if you haven't.

* Configure ASDF:

```bash
mkdir -p ~/.config/common-lisp/source-registry.conf.d/
echo "(:tree (:home \"quicklisp/downloaded-projects/\"))" >> \
    ~/.config/common-lisp/source-registry.conf.d/projects.conf
```

* Download cl-spider:

```bash
mkdir -p ~/quicklisp/downloaded-projects
cd ~/quicklisp/downloaded-projects
git clone https://github.com/VitoVan/cl-spider.git
```

* Restart your REPL, then:

```Lisp
(ql:quickload 'cl-spider)
```
![](https://raw.githubusercontent.com/VitoVan/cl-spider/master/screenshots/quickload.png)

## Functions

**cl-spider:html-select** uri &key selector attrs

uri --- the uri
selector --- block selector
attrs --- the attrs of the selector


```Lisp
(cl-spider:html-select "https://news.ycombinator.com/"
                       :selector "a"
                       :attrs '("href" "text"))
```

![](https://raw.githubusercontent.com/VitoVan/cl-spider/master/screenshots/html-select.png)

**cl-spider:html-block-select** uri &key selector desires

uri --- the uri
selector --- block selector
desires --- a list contains sub selectors and their attrs

```Lisp
(cl-spider:html-block-select
 "https://news.ycombinator.com/" 
 :selector "tr.athing" 
 :desires '(((:selector . "span.rank") (:attrs . ("text as rank")))
            ((:selector . "td.title>a") (:attrs . ("href as uri" "text as title")))
            ((:selector . "span.sitebit.comhead") (:attrs . ("text as site")))))
```

![](https://raw.githubusercontent.com/VitoVan/cl-spider/master/screenshots/html-block-select.png)

## TODO

* POST method Support
* [JSONSelect](http://jsonselect.org/#overview) Support
* Cookie & Session Support

## License

GPL v2
