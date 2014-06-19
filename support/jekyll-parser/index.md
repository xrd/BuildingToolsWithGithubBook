---
---

<html>
<head>
<title>ByTravelers.com</title>
</head>

<body>
{% for post in site.posts %}
<a href="{{ BASE_PATH }}{{ post.url }}"><h2> {{ post.title }} </h2></a>
{{ post.content | strip_html | truncatewords: 40 }}
<br/>
<em>Posted on {{ post.date | date_to_string }}</em>
<br/>
{% endfor %}
</body>

</html>
