# NOTICE

As you can see, the internet today is going towards a direction with only JavaScript and JSON API. Besides, more and more website started to develop an technology to identify the visitors and prevent web spiders to access their resource. Something beyond the technology world have also changed, such as law enforcement about web crawling and the decaying of Internet Freedom.

This project failed to achieve its target before all those changes happened. Thus, I'm archiving this repository and hope it still have some value for anyone who is interested in.

So Long, and Thanks for All the Fish.

# cl-spider
A Common Lisp Spider for the Web

> 🚨 **WARNING** 🚨
> **DON'T use this shit before you read the code, it's very badly written and incomplete.**

## Installlation

* Install [Quicklisp](http://quicklisp.org/), if you haven't.

* Download cl-spider:

```bash
cd ~/quicklisp/local-projects
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
