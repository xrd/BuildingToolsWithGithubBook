---
layout: default
---

<h1>ByTravelers.com</h1>

Crowd sourced travel information.

<br/>

<div>
{% for post in site.posts %}
<a href="{{ post.url }}"><h2> {{ post.title }} </h2></a>
<img src="/assets/images/{{ post.image }}">
{{ post.content | strip_html | truncatewords: 40 }}
<br/>
<em>Posted on {{ post.date | date_to_string }}</em>
<br/>
{% endfor %}
</div>

