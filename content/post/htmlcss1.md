---
title: "HTML & CSS 1 - HTML"
date: 2015-12-06
draft: false
tags: ["tutorials", "beginner"]
author: Evan Smith
image: defimg/htmlcss1.webp
---

# HTML & CSS 1 - HTML

# What are HTML & CSS?

HTML, HyperText Markup Language, gives content structure and meaning by defining that content as, for example, headings, paragraphs, or images. CSS, or Cascading Style Sheets, is a presentation language created to style the appearance of content—using, for example, fonts or colors.

The two languages—HTML and CSS—are independent of one another and should remain that way. CSS should not be written inside of an HTML document and vice versa. As a rule, HTML will always represent content, and CSS will always represent the appearance of that content.

With this understanding of the difference between HTML and CSS, let’s dive into HTML in more detail.

# Understanding Common HTML Terms

While getting started with HTML, you will likely encounter new—and often strange—terms. Over time you will become more and more familiar with all of them, but the three common HTML terms you should begin with are elements, tags, and attributes.

## Elements

Elements are designators that define the structure and content of objects within a page. Some of the more frequently used elements include multiple levels of headings \(identified as \<h1\> through \<h6\> elements\) and paragraphs \(identified as the \<p\> element\); the list goes on to include the \<a\>, \<div\>, \<span\>, \<strong\>, and \<em\> elements, and many more.

Elements are identified by the use of less-than and greater-than angle brackets, < >, surrounding the element name. Thus, an element will look like the following:

```
<a>
```

## Tags

The use of less-than and greater-than angle brackets surrounding an element creates what is known as a tag. Tags most commonly occur in pairs of opening and closing tags.

An opening tag marks the beginning of an element. It consists of a less-than sign followed by an element’s name, and then ends with a greater-than sign; for example, `<div>`.

A closing tag marks the end of an element. It consists of a less-than sign followed by a forward slash and the element’s name, and then ends with a greater-than sign; for example, `</div>`.

The content that falls between the opening and closing tags is the content of that element. An anchor link, for example, will have an opening tag of `<a>` and a closing tag of `</a>`. What falls between these two tags will be the content of the anchor link.

So, anchor tags will look a bit like this:

```
<a> Our link's text </a>
```

## Attributes

Attributes are properties used to provide additional information about an element. The most common attributes include the `id` attribute, which identifies an element; the `class` attribute, which classifies an element; the `src` attribute, which specifies a source for embeddable content; and the `href` attribute, which provides a hyperlink reference to a linked resource.

Attributes are defined within the opening tag, after an element’s name. Generally attributes include a name and a value. The format for these attributes consists of the attribute name followed by an equals sign and then a quoted attribute value. For example, an `<a>` element including an href attribute would look like the following:

```
<a href="http://netsoc.co/"> UCC Netsoc </a>
```

# Setting Up the HTML Document Structure

HTML documents are plain text documents saved with an .html file extension rather than a .txt file extension. To begin writing HTML, you first need a plain text editor that you are comfortable using. Sadly this does not include Microsoft Word or Pages, as those are rich text editors. Two of the more popular plain text editors for writing HTML and CSS are Dreamweaver and Sublime Text. Free alternatives also include Notepad++ for Windows and TextWrangler for Mac.

All HTML documents have a required structure that includes the following declaration and elements: `<!DOCTYPE html>`, `<html>`, `<head>`, and `<body>`.

The document type declaration, or `<!DOCTYPE html>`, informs web browsers which version of HTML is being used and is placed at the very beginning of the HTML document. Because we’ll be using the latest version of HTML, our document type declaration is simply `<!DOCTYPE html>`. Following the document type declaration, the `<html>` element signifies the beginning of the document.

Inside the `<html>` element, the `<head>` element identifies the top of the document, including any metadata \(accompanying information about the page\). The content inside the `<head>` element is not displayed on the web page itself. Instead, it may include the document title \(which is displayed on the title bar in the browser window\), links to any external files, or any other beneficial metadata.

All of the visible content within the web page will fall within the `<body>` element. A breakdown of a typical HTML document structure looks like this:

```
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Hello World</title>
  </head>
  <body>
    <h1>Hello World</h1>
    <p>This is a web page.</p>
  </body>
</html>
```

The preceding code shows the document beginning with the document type declaration, `<!DOCTYPE html>`, followed directly by the `<html>` element. Inside the `<html>` element come the `<head>` and `<body>` elements. The `<head>` element includes the character encoding of the page via the `<meta charset=”utf-8″>` tag and the title of the document via the `<title>` element. The `<body>` element includes a heading via the `<h1>` element and a paragraph via the `<p>` element. Because both the heading and paragraph are nested within the `<body>` element, they are visible on the web page.

When an element is placed inside of another element, also known as nested, it is a good idea to indent that element to keep the document structure well organized and legible. In the previous code, both the `<head>` and `<body>` elements were nested—and indented—inside the `<html>` element. The pattern of indenting for elements continues as new elements are added inside the `<head>` and `<body>` elements.
Self-Closing Elements

In the previous example, the `<meta>` element had only one tag and didn’t include a closing tag. Fear not, this was intentional. Not all elements consist of opening and closing tags. Some elements simply receive their content or behavior from attributes within a single tag. The `<meta>` element is one of these elements. The content of the previous `<meta>` element is assigned with the use of the charset attribute and value. Other common selfclosing elements include

* `<br>`
* `<embed>`
* `<hr>`
* `<img>`
* `<input>`
* `<link>`
* `<meta>`
* `<param>`
* `<source>`
* `<wbr>`
