---
layout: default
title: Le blog
---

# Le blog

Ci dessous les articles du blog

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }} - {{post.date | date: '%d-%m-%Y'}}</a>
    </li>
  {% endfor %}
</ul>